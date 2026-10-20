using JSON3
using MATLAB

const ACTIVE_RUNTIME = Ref{Any}(nothing)
const MATLAB_EVAL_SEQUENCE = Ref(0)
const MATLAB_ASYNC_COMPLETION_TIMEOUT_SECONDS = 120.0
const MATLAB_ASYNC_COMPLETION_POLL_SECONDS = 0.1

struct MatlabValueRef
    expression::String
end

mutable struct GraphRuntime
    specifications::Dict{String, Any}
    node_outputs::Dict{String, Dict{String, MatlabValueRef}}
    node_ordinals::Dict{String, Int}
    current_node_id::String
end

"""
Evaluate one MATLAB command with an explicit try/catch contract.

MATLAB.jl checks the process-global `MException.last` after `engEvalString`.
Some legacy spreadsheet APIs can abort an Engine command without leaving the
temporary variables used by that check, which hides the useful failure behind
`failed to get variable matlab_exception_jl_message`.  A per-command sentinel
lets the graph runner distinguish a normal MATLAB exception from an invalid or
interrupted Engine session.
"""
function matlab_eval_checked(
    session::MATLAB.MSession,
    statement::String;
    context::String="MATLAB命令",
)
    MATLAB_EVAL_SEQUENCE[] += 1
    suffix = MATLAB_EVAL_SEQUENCE[]
    status_name = Symbol("modelcloud_eval_status_$(suffix)")
    identifier_name = Symbol("modelcloud_eval_identifier_$(suffix)")
    message_name = Symbol("modelcloud_eval_message_$(suffix)")
    wrapped = """
    $(status_name) = 0;
    $(identifier_name) = '';
    $(message_name) = '';
    try
        $(statement)
        $(status_name) = 1;
    catch modelcloud_eval_error
        $(status_name) = -1;
        $(identifier_name) = modelcloud_eval_error.identifier;
        $(message_name) = getReport(modelcloud_eval_error, 'extended', 'hyperlinks', 'off');
    end
    """

    MATLAB.disable_exception_check!(session)
    MATLAB.eval_string(session, wrapped)
    read_status() = try
        MATLAB.get_variable(status_name)
    catch exception
        throw(ErrorException(
            "$(context)执行后MATLAB Engine会话不可用；原命令可能被旧式I/O接口或本机库异常中止。" *
            " 底层错误：$(sprint(showerror, exception))"
        ))
    end
    status = read_status()
    if status == 0
        # MATLAB Engine may yield control while graphics callbacks and file
        # export are still running. Wait for the sentinel written after the
        # command instead of treating the transient zero as an abort.
        deadline = time() + MATLAB_ASYNC_COMPLETION_TIMEOUT_SECONDS
        while status == 0 && time() < deadline
            sleep(MATLAB_ASYNC_COMPLETION_POLL_SECONDS)
            status = read_status()
        end
    end

    if status == -1
        identifier = MATLAB.jvalue(MATLAB.get_mvariable(session, identifier_name), String)
        message = MATLAB.jvalue(MATLAB.get_mvariable(session, message_name), String)
        error("$(context)执行失败[$(identifier)]：$(message)")
    elseif status != 1
        error("$(context)未在$(MATLAB_ASYNC_COMPLETION_TIMEOUT_SECONDS)秒内正常结束" *
              "（状态=$(status)）；MATLAB命令被非普通异常中止")
    end

    MATLAB.eval_string(session,
        "clear $(status_name) $(identifier_name) $(message_name) modelcloud_eval_error;")
    return nothing
end

function native_value(value)
    value isa JSON3.Object && return Dict(
        String(key) => native_value(item) for (key, item) in pairs(value)
    )
    value isa JSON3.Array && return Any[native_value(item) for item in value]
    return value
end

function write_json(path::String, value)
    open(path, "w") do io
        JSON3.write(io, value)
    end
end

function matlab_string_literal(value::AbstractString)
    return "'" * replace(String(value), "'" => "''") * "'"
end

function matlab_literal(value)
    value isa Bool && return value ? "true" : "false"
    if value isa Real
        number = Float64(value)
        isfinite(number) || throw(ArgumentError("MATLAB输入必须是有限数值"))
        return repr(number)
    end
    if value isa AbstractVector
        isempty(value) && return "[]"
        if all(item -> item isa Real && !(item isa Bool), value)
            return "[" * join((matlab_literal(item) for item in value), ",") * "]"
        end
        if all(item -> item isa AbstractVector, value)
            rows = collect(value)
            widths = length.(rows)
            all(==(first(widths)), widths) || throw(ArgumentError("MATLAB数值矩阵各行长度必须一致"))
            all(row -> all(item -> item isa Real && !(item isa Bool), row), rows) ||
                throw(ArgumentError("MATLAB数组只支持数值元素"))
            return "[" * join((join((matlab_literal(item) for item in row), ",") for row in rows), ";") * "]"
        end
        throw(ArgumentError("MATLAB数组只支持一维或二维数值数组"))
    end
    value isa AbstractString && return matlab_string_literal(value)
    throw(ArgumentError("不支持的MATLAB字面量类型$(typeof(value))"))
end

function output(node_result::Dict{String, MatlabValueRef}, port_name::String)
    haskey(node_result, port_name) ||
        throw(ArgumentError("上游节点缺少输出端口$(port_name)"))
    return node_result[port_name]
end

function resolve_input_expression(
    node_id::String,
    input_name::String,
    connected_inputs::AbstractDict,
    local_values::AbstractDict,
)
    haskey(connected_inputs, input_name) &&
        return connected_inputs[input_name].expression
    haskey(local_values, input_name) && return matlab_literal(local_values[input_name])
    throw(ArgumentError("节点$(node_id)缺少输入$(input_name)"))
end

function ensure_object_path!(
    statements::Vector{String}, variable::String,
    fields::AbstractVector{<:AbstractString},
)
    current = variable
    for field in fields
        push!(statements,
            "if ~isfield($(current), '$(field)'), $(current).$(field) = struct(); end;")
        current *= ".$(field)"
    end
end

function binding_expression(
    node_id::String,
    binding::AbstractDict,
    connected_inputs::AbstractDict,
    local_values::AbstractDict,
    resources::AbstractDict,
)
    source = String(binding["source"])
    name = String(binding["name"])
    if source == "input"
        return resolve_input_expression(node_id, name, connected_inputs, local_values)
    elseif source == "resource"
        property_name = String(binding["property"])
        if !haskey(resources, name) || !haskey(resources[name], property_name)
            get(binding, "optional", false) && return nothing
            throw(ArgumentError("节点$(node_id)缺少资源$(name).$(property_name)"))
        end
        return matlab_literal(resources[name][property_name])
    end
    throw(ArgumentError("节点$(node_id)存在不支持的binding source=$(source)"))
end

function execute_node!(
    runtime::GraphRuntime,
    node_id::String,
    connected_inputs::Dict{String, MatlabValueRef},
)
    runtime.current_node_id = node_id
    haskey(runtime.specifications, node_id) ||
        throw(ArgumentError("不存在节点定义$(node_id)"))
    specification = runtime.specifications[node_id]
    function_name = String(specification["functionName"])
    invocation = specification["invocation"]
    String(invocation["function"]) == function_name ||
        throw(ArgumentError("节点$(node_id)invocation函数与可信定义不一致"))
    local_values = specification["values"]
    resources = specification["resources"]
    ordinal = runtime.node_ordinals[node_id]
    statements = String[]
    argument_expressions = String[]

    for (argument_index, argument) in enumerate(invocation["arguments"])
        source = String(argument["source"])
        if source == "input"
            push!(argument_expressions, resolve_input_expression(
                node_id,
                String(argument["name"]),
                connected_inputs,
                local_values,
            ))
        elseif source == "object"
            variable = "pmsm_node_$(ordinal)_argument_$(argument_index)"
            push!(statements, "$(variable) = struct();")
            for binding in get(argument, "bindings", Any[])
                expression = binding_expression(
                    node_id, binding, connected_inputs, local_values, resources
                )
                expression === nothing && continue
                target_fields = split(String(binding["target"]), ".")
                length(target_fields) > 1 && ensure_object_path!(
                    statements, variable, target_fields[1:end-1]
                )
                push!(statements,
                    "$(variable).$(join(target_fields, ".")) = $(expression);")
            end
            push!(argument_expressions, variable)
        else
            throw(ArgumentError("节点$(node_id)存在不支持的argument source=$(source)"))
        end
    end

    returns = invocation["returns"]
    return_count = maximum(Int(item["returnIndex"]) for item in returns) + 1
    return_variables = [
        "pmsm_node_$(ordinal)_return_$(index)" for index in 1:return_count
    ]
    call_expression = "$(function_name)($(join(argument_expressions, ", ")))"
    if return_count == 1
        push!(statements, "$(return_variables[1]) = $(call_expression);")
    else
        push!(statements,
            "[$(join(return_variables, ", "))] = $(call_expression);")
    end
    matlab_eval_checked(
        MATLAB.get_default_msession(),
        join(statements, "\n");
        context="节点$(node_id)",
    )

    logical_outputs = Dict{String, MatlabValueRef}()
    for result in returns
        output_name = String(result["output"])
        return_variable = return_variables[Int(result["returnIndex"]) + 1]
        path = String(get(result, "path", ""))
        expression = isempty(path) ? return_variable : "$(return_variable).$(path)"
        logical_outputs[output_name] = MatlabValueRef(expression)
    end
    runtime.node_outputs[node_id] = logical_outputs
    return logical_outputs
end

function execute_bus_creator!(
    runtime::GraphRuntime,
    node_id::String,
    connected_inputs::Dict{String, MatlabValueRef},
)
    runtime.current_node_id = node_id
    specification = runtime.specifications[node_id]
    config = specification["busConfig"]
    ordinal = runtime.node_ordinals[node_id]
    variable = "pmsm_bus_$(ordinal)"
    statements = String["$(variable) = struct();"]
    for field in config["fields"]
        path = String(field["path"])
        input_port = String(get(field, "inputPortId", field["id"]))
        expression = if haskey(connected_inputs, input_port)
            connected_inputs[input_port].expression
        elseif haskey(field, "defaultValue") && field["defaultValue"] !== nothing
            matlab_literal(field["defaultValue"])
        elseif Bool(get(field, "required", true))
            throw(ArgumentError("Bus Creator节点$(node_id)缺少必需字段$(path)"))
        else
            continue
        end
        path_parts = split(path, ".")
        length(path_parts) > 1 && ensure_object_path!(
            statements, variable, path_parts[1:end-1]
        )
        push!(statements, "$(variable).$(path) = $(expression);")
    end
    matlab_eval_checked(
        MATLAB.get_default_msession(),
        join(statements, "\n");
        context="Bus Creator节点$(node_id)",
    )
    outputs = Dict{String, MatlabValueRef}("bus" => MatlabValueRef(variable))
    runtime.node_outputs[node_id] = outputs
    return outputs
end

function execute_bus_selector!(
    runtime::GraphRuntime,
    node_id::String,
    connected_inputs::Dict{String, MatlabValueRef},
)
    runtime.current_node_id = node_id
    haskey(connected_inputs, "bus") ||
        throw(ArgumentError("Bus Selector节点$(node_id)缺少bus输入"))
    bus_expression = connected_inputs["bus"].expression
    config = runtime.specifications[node_id]["selectorConfig"]
    outputs = Dict{String, MatlabValueRef}()
    for field in config["selectedFields"]
        path = String(field["path"])
        output_port = String(get(field, "outputPortId", "bus_out_" * String(field["id"])))
        outputs[output_port] = MatlabValueRef("$(bus_expression).$(path)")
    end
    runtime.node_outputs[node_id] = outputs
    return outputs
end

function json_safe_matlab_value(value::MatlabValueRef, output_type::String = "")
    session = MATLAB.get_default_msession()
    temporary_name = "pmsm_graph_json_$(abs(hash(value.expression)))"
    try
        expression = value.expression
        matlab_eval_checked(
            session,
            "$(temporary_name) = jsonencode($(expression));";
            context="MATLAB输出序列化",
        )
        encoded = MATLAB.jvalue(
            MATLAB.get_mvariable(session, Symbol(temporary_name)), String
        )
        return JSON3.read(encoded)
    finally
        MATLAB.eval_string(session, "clear $(temporary_name);")
    end
end

function complex_fields_for_matlab_value(value::MatlabValueRef)
    session = MATLAB.get_default_msession()
    temporary_name = "modelcloud_complex_fields_$(abs(hash(value.expression)))"
    try
        matlab_eval_checked(session,
            "$(temporary_name) = jsonencode(component_matlab_complex_fields($(value.expression)));";
            context="MATLAB复数字段诊断")
        encoded = MATLAB.jvalue(MATLAB.get_mvariable(session, Symbol(temporary_name)), String)
        fields = native_value(JSON3.read(encoded))
        return fields isa AbstractDict ? [fields] : fields
    finally
        MATLAB.eval_string(session, "clear $(temporary_name);")
    end
end

function julia_variable_name(node_id::String, index::Int)
    normalized = replace(node_id, r"[^A-Za-z0-9_]" => "_")
    isempty(normalized) && (normalized = "node")
    return "node_$(normalized)_$(index)"
end

function generate_graph_code(graph::AbstractDict)::String
    nodes = graph["nodes"]
    node_by_id = Dict(String(node["id"]) => node for node in nodes)
    execution_order = [String(item) for item in graph["executionOrder"]]
    variable_by_id = Dict(
        node_id => julia_variable_name(node_id, index)
        for (index, node_id) in enumerate(execution_order)
    )
    incoming = Dict(
        node_id => Dict{String, Tuple{String, String}}()
        for node_id in execution_order
    )
    for edge in graph["edges"]
        incoming[String(edge["targetNodeId"])][String(edge["targetPort"])] =
            (String(edge["sourceNodeId"]), String(edge["sourcePort"]))
    end

    lines = String[
        "# 此文件由统一MATLAB图运行器自动生成。",
        "# 每个节点按可信拓扑顺序在同一Julia进程和MATLAB会话中执行。",
        "",
    ]
    for node_id in execution_order
        node = node_by_id[node_id]
        variable_name = variable_by_id[node_id]
        execution_kind = String(get(node, "executionKind", "matlabFunction"))
        function_name = String(get(node, "functionName", ""))
        push!(lines, "# $(node_id): $(execution_kind) $(function_name)")
        runner_name = execution_kind == "busCreator" ? "execute_bus_creator!" :
            execution_kind == "busSelector" ? "execute_bus_selector!" : "execute_node!"
        push!(lines, "$(variable_name) = $(runner_name)(")
        push!(lines, "    ACTIVE_RUNTIME[],")
        push!(lines, "    $(repr(node_id)),")
        push!(lines, "    Dict{String, MatlabValueRef}(")
        for (target_port, (source_node, source_port)) in incoming[node_id]
            push!(lines,
                "        $(repr(target_port)) => output($(variable_by_id[source_node]), $(repr(source_port))),")
        end
        push!(lines, "    ),")
        push!(lines, ")")
        push!(lines, "")
    end
    push!(lines, "graph_result = Dict{String, Any}(")
    for node_id in execution_order
        push!(lines, "    $(repr(node_id)) => $(variable_by_id[node_id]),")
    end
    push!(lines, ")")
    return join(lines, "\n") * "\n"
end

function validate_graph(graph::AbstractDict)
    nodes = get(graph, "nodes", Any[])
    isempty(nodes) && throw(ArgumentError("MATLAB图至少需要一个节点"))
    execution_order = [String(item) for item in get(graph, "executionOrder", Any[])]
    length(execution_order) == length(nodes) ||
        throw(ArgumentError("MATLAB图executionOrder数量不正确"))
    node_ids = Set(String(node["id"]) for node in nodes)
    Set(execution_order) == node_ids ||
        throw(ArgumentError("MATLAB图executionOrder与节点集合不一致"))
    return nothing
end

function execute_graph(
    graph_path::String,
    result_path::String,
    generated_path::String,
)
    graph_path = abspath(graph_path)
    result_path = abspath(result_path)
    generated_path = abspath(generated_path)
    runtime = nothing
    graph = nothing
    execution_stage = "execute-node"
    serialization_details = Dict{String, Any}()
    try
        graph = native_value(JSON3.read(read(graph_path, String)))
        validate_graph(graph)
        component_root = normpath(abspath(String(graph["componentRoot"])))
        isdir(component_root) || throw(ArgumentError("MATLAB组件根目录不存在"))
        execution_order = [String(item) for item in graph["executionOrder"]]
        specifications = Dict(
            String(node["id"]) => node for node in graph["nodes"]
        )
        runtime = GraphRuntime(
            specifications,
            Dict{String, Dict{String, MatlabValueRef}}(),
            Dict(node_id => index for (index, node_id) in enumerate(execution_order)),
            "",
        )
        ACTIVE_RUNTIME[] = runtime

        generated_code = generate_graph_code(graph)
        write(generated_path, generated_code)
        execution_stage = "prepare"
        session = MATLAB.get_default_msession()
        matlab_eval_checked(session,
            "addpath(genpath($(matlab_string_literal(component_root))));";
            context="初始化MATLAB组件路径")
        if haskey(graph, "modelPrograms")
            program_json = matlab_string_literal(String(JSON3.write(graph["modelPrograms"])))
            matlab_eval_checked(session,
                "mc_pmsm_program_registry('clear',''); " *
                "mc_pmsm_program_registry('install',$(program_json));";
                context="注册PMSM计算子图")
        end
        execution_stage = "execute-node"
        Base.include(Main, generated_path)

        consumed_outputs = Set(
            (String(edge["sourceNodeId"]), String(edge["sourcePort"]))
            for edge in graph["edges"]
        )
        node_results = Dict{String, Any}()
        final_outputs = Dict{String, Any}()
        for node_id in execution_order
            runtime.current_node_id = node_id
            specification = specifications[node_id]
            serialized_outputs = Dict{String, Any}()
            terminal_outputs = Dict{String, Any}()
            available_output_ports = String[]
            for output_definition in specification["outputs"]
                output_name = String(output_definition["name"])
                push!(available_output_ports, output_name)
                execution_stage = "serialize-output"
                serialization_details = Dict{String, Any}("outputPort" => output_name)
                value_ref = runtime.node_outputs[node_id][output_name]
                serialized_value = try
                    json_safe_matlab_value(value_ref, String(get(output_definition, "type", "")))
                catch exception
                    if occursin("MATLAB:json:UnsupportedComplexDataType", sprint(showerror, exception))
                        try
                            serialization_details["complexFields"] = complex_fields_for_matlab_value(value_ref)
                        catch diagnostic_error
                            serialization_details["diagnosticError"] = sprint(showerror, diagnostic_error)
                        end
                    end
                    rethrow()
                end
                serialized_outputs[output_name] = serialized_value
                if !((node_id, output_name) in consumed_outputs)
                    terminal_outputs[output_name] = serialized_value
                end
            end
            node_results[node_id] = Dict{String, Any}(
                "componentId" => String(specification["componentId"]),
                "functionName" => String(specification["functionName"]),
                "status" => "completed",
                "availableOutputPorts" => available_output_ports,
                "outputs" => serialized_outputs,
            )
            haskey(specification, "originPath") &&
                (node_results[node_id]["originPath"] = specification["originPath"])
            haskey(specification, "sourceNodeId") &&
                (node_results[node_id]["sourceNodeId"] = specification["sourceNodeId"])
            haskey(specification, "phase") &&
                (node_results[node_id]["phase"] = specification["phase"])
            isempty(terminal_outputs) ||
                (final_outputs[node_id] = terminal_outputs)
        end
        model_program_results = Any[]
        if haskey(graph, "modelPrograms")
            snapshot_json = mxcall(:eval, 1, "jsonencode(mc_pmsm_program_registry('snapshots',''))")
            model_program_results = native_value(JSON3.read(String(snapshot_json)))
            for program_result in model_program_results
                for snapshot in program_result["nodes"]
                    key = String(program_result["programId"]) * "::" * String(program_result["entrypoint"]) * "::" * String(snapshot["id"])
                    node_results[key] = snapshot
                end
            end
        end
        public_outputs = Dict{String, Any}()
        for item in get(graph, "publicOutputs", Any[])
            item isa AbstractDict || continue
            source_node_id = String(get(item, "sourceNodeId", ""))
            source_port = String(get(item, "sourcePort", ""))
            output_name = String(get(item, "name", source_port))
            if haskey(node_results, source_node_id)
                outputs = node_results[source_node_id]["outputs"]
                if outputs isa AbstractDict && haskey(outputs, source_port)
                    public_outputs[output_name] = Dict{String, Any}(
                        "value" => outputs[source_port],
                        "sourceNodeId" => source_node_id,
                        "sourcePort" => source_port,
                        "originPath" => get(item, "originPath",
                            get(node_results[source_node_id], "originPath", Any[])),
                    )
                end
            end
        end
        write_json(result_path, Dict{String, Any}(
            "success" => true,
            "engineType" => "matlab",
            "executorType" => "julia-matlab-graph",
            "executionOrder" => execution_order,
            "nodeResults" => node_results,
            "finalOutputs" => final_outputs,
            "publicOutputs" => public_outputs,
            "modelProgramResults" => model_program_results,
        ))
        return 0
    catch exception
        error_message = sprint(showerror, exception, catch_backtrace())
        if execution_stage == "serialize-output"
            output_port = get(serialization_details, "outputPort", "")
            fields = get(serialization_details, "complexFields", Any[])
            paths = [String(field["path"]) for field in (fields isa AbstractDict ? [fields] : fields)]
            error_message = "输出端口=$(output_port)" * (isempty(paths) ? "" : "，复数字段=" * join(paths, ", ")) * "\n" * error_message
        end
        failed_node_id = runtime === nothing ? "" : runtime.current_node_id
        failure = Dict{String, Any}(
            "success" => false,
            "engineType" => "matlab",
            "executorType" => "julia-matlab-graph",
            "failedNodeId" => failed_node_id,
            "stage" => execution_stage,
            "details" => serialization_details,
            "errorMessage" => first(error_message, min(length(error_message), 4000)),
        )
        if runtime !== nothing && haskey(runtime.specifications, failed_node_id)
            specification = runtime.specifications[failed_node_id]
            haskey(specification, "originPath") &&
                (failure["originPath"] = specification["originPath"])
            haskey(specification, "sourceNodeId") &&
                (failure["sourceNodeId"] = specification["sourceNodeId"])
        end
        if runtime !== nothing && haskey(graph, "modelPrograms")
            try
                program_error_json = mxcall(:eval, 1,
                    "jsonencode(mc_pmsm_program_registry('error',''))")
                program_error = native_value(JSON3.read(String(program_error_json)))
                if program_error isa AbstractDict && haskey(program_error, "nodeId")
                    failure["details"]["modelProgram"] = program_error
                    failure["originPath"] = get(program_error, "originPath", Any[])
                    failure["sourceNodeId"] = get(program_error, "sourceNodeId", "")
                end
            catch diagnostic_error
                failure["details"]["modelProgramDiagnosticError"] = sprint(showerror, diagnostic_error)
            end
        end
        write_json(result_path, failure)
        println(stderr, error_message)
        return 1
    finally
        if runtime !== nothing
            try
                mxcall(:mc_pmsm_program_registry, 0, "clear", "")
            catch
                # Graphs without PMSM need no registry and keep the existing path.
            end
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    if length(ARGS) != 3
        println(stderr,
            "用法: julia run_matlab_graph.jl trusted_graph.json result.json generated_workflow.jl")
        exit(2)
    end
    exit(execute_graph(ARGS[1], ARGS[2], ARGS[3]))
end
