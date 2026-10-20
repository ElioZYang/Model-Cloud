import type { Edge, GraphNode, Node } from '@vue-flow/core'
import ELK from 'elkjs/lib/elk-api.js'
import ElkWorker from 'elkjs/lib/elk-worker.min.js?worker'
import type { ELK as ElkInstance, ElkExtendedEdge, ElkNode, ElkPoint, ElkPort } from 'elkjs/lib/elk-api'
import type { MatlabPort } from '@/api/matlab-model-deploy'

export type MatlabElkPoint = { x: number; y: number }
export type MatlabElkLayoutMode = 'full' | 'routing'

export type MatlabElkLayoutResult = {
  positions: Record<string, MatlabElkPoint>
  routes: Record<string, MatlabElkPoint[]>
  warnings: string[]
  requestId: number
  durationMs: number
  mode: MatlabElkLayoutMode
}

type LayoutNode = Node | GraphNode

type ActiveRequest = {
  requestId: number
  reject: (error: Error) => void
  timeoutId: number
}

const NODE_WIDTH = 360
const NODE_BASE_HEIGHT = 96
const PORT_ROW_HEIGHT = 28
const LAYOUT_TIMEOUT_MS = 10_000

const inputPortId = (nodeId: string, portName: string) => `${nodeId}::input::${portName}`
const outputPortId = (nodeId: string, portName: string) => `${nodeId}::output::${portName}`

const validPorts = (value: unknown): MatlabPort[] => Array.isArray(value)
  ? value.filter((port): port is MatlabPort => Boolean(
    port && typeof port.name === 'string' && port.name.trim()
  ))
  : []

const estimatedHeight = (node: LayoutNode) => {
  const inputCount = validPorts(node.data?.inputPorts).length
  const outputCount = validPorts(node.data?.outputPorts).length
  if (node.data?.nodeKind === 'busCreator' || node.data?.nodeKind === 'busSelector') {
    return Math.max(72, Math.max(inputCount, outputCount, 1) * 28 + 16)
  }
  return NODE_BASE_HEIGHT + Math.max(inputCount, outputCount) * PORT_ROW_HEIGHT
}

const presentationDimension = (node: LayoutNode, key: 'width' | 'height') => {
  const value = Number(node.data?.presentationSize?.[key])
  return Number.isFinite(value) && value > 0 ? value : null
}

const measuredDimension = (value: unknown) => {
  const number = Number(value)
  return Number.isFinite(number) && number > 0 ? number : null
}

const portCenterY = (
  node: LayoutNode,
  port: MatlabPort,
  direction: 'input' | 'output',
  index: number
) => {
  const graphNode = node as Partial<GraphNode>
  const bounds = direction === 'input'
    ? graphNode.handleBounds?.target
    : graphNode.handleBounds?.source
  const measured = bounds?.find((handle) => handle.id === port.name)
  return measured && Number.isFinite(measured.y)
    ? measured.y + measured.height / 2
    : 86 + index * PORT_ROW_HEIGHT + PORT_ROW_HEIGHT / 2
}

const toElkPort = (
  node: LayoutNode,
  port: MatlabPort,
  direction: 'input' | 'output',
  index: number,
  width: number
): ElkPort => ({
  id: direction === 'input'
    ? inputPortId(node.id, port.name)
    : outputPortId(node.id, port.name),
  // Route at the node boundary at the actual Handle height. The short horizontal
  // segment inside the node is drawn by MatlabElkEdge, not routed by ELK.
  x: direction === 'input' ? 0 : width,
  y: portCenterY(node, port, direction, index),
  width: 0,
  height: 0,
  layoutOptions: {
    'org.eclipse.elk.port.side': direction === 'input' ? 'WEST' : 'EAST'
  }
})

const buildElkGraph = (nodes: LayoutNode[], edges: Edge[]) => {
  const availablePorts = new Set<string>()
  const children = nodes.map((node) => {
    const graphNode = node as Partial<GraphNode>
    const width = presentationDimension(node, 'width')
      || measuredDimension(graphNode.dimensions?.width)
      || (node.data?.nodeKind ? 24 : NODE_WIDTH)
    const height = presentationDimension(node, 'height')
      || measuredDimension(graphNode.dimensions?.height)
      || estimatedHeight(node)
    const inputs = validPorts(node.data?.inputPorts)
    const outputs = validPorts(node.data?.outputPorts)
    const ports = [
      ...inputs.map((port, index) => toElkPort(node, port, 'input', index, width)),
      ...outputs.map((port, index) => toElkPort(node, port, 'output', index, width))
    ]
    ports.forEach((port) => availablePorts.add(port.id))
    return {
      id: node.id,
      width,
      height,
      ports,
      layoutOptions: {
        'org.eclipse.elk.portConstraints': 'FIXED_POS'
      }
    }
  })

  const warnings: string[] = []
  const elkEdges: ElkExtendedEdge[] = []
  edges.forEach((edge) => {
    const source = outputPortId(edge.source, String(edge.sourceHandle || ''))
    const target = inputPortId(edge.target, String(edge.targetHandle || ''))
    if (!availablePorts.has(source) || !availablePorts.has(target)) {
      warnings.push(
        `连线 ${edge.id} 引用了不存在的端口：${edge.source}.${String(edge.sourceHandle || '')}`
          + ` → ${edge.target}.${String(edge.targetHandle || '')}`
      )
      return
    }
    elkEdges.push({ id: edge.id, sources: [source], targets: [target] })
  })

  const graph: ElkNode = {
    id: 'matlab-workflow',
    children,
    edges: elkEdges,
    layoutOptions: {
      'elk.algorithm': 'layered',
      'elk.direction': 'RIGHT',
      'elk.edgeRouting': 'ORTHOGONAL',
      'elk.spacing.nodeNode': '60',
      'elk.layered.spacing.nodeNodeBetweenLayers': '140',
      'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
      'elk.layered.nodePlacement.strategy': 'NETWORK_SIMPLEX',
      'elk.layered.cycleBreaking.strategy': 'GREEDY',
      'elk.layered.considerModelOrder.strategy': 'NODES_AND_EDGES'
    }
  }
  return { graph, warnings }
}

const flattenSections = (edge: ElkExtendedEdge): ElkPoint[] => {
  if (!edge.sections?.length) return []
  const points: ElkPoint[] = []
  edge.sections.forEach((section) => {
    const sectionPoints = [section.startPoint, ...(section.bendPoints || []), section.endPoint]
    sectionPoints.forEach((point) => {
      const previous = points[points.length - 1]
      if (!previous || previous.x !== point.x || previous.y !== point.y) points.push(point)
    })
  })
  return points
}

type RoutingNode = {
  id: string
  x: number
  y: number
  width: number
  height: number
  node: LayoutNode
}

type RoutingRect = {
  left: number
  right: number
  top: number
  bottom: number
}

const routingNode = (node: LayoutNode): RoutingNode => {
  const graphNode = node as Partial<GraphNode>
  return {
    id: node.id,
    x: Number(graphNode.computedPosition?.x ?? node.position.x) || 0,
    y: Number(graphNode.computedPosition?.y ?? node.position.y) || 0,
    width: presentationDimension(node, 'width') || measuredDimension(graphNode.dimensions?.width)
      || (node.data?.nodeKind ? 24 : NODE_WIDTH),
    height: presentationDimension(node, 'height') || measuredDimension(graphNode.dimensions?.height)
      || estimatedHeight(node),
    node
  }
}

const routingHandlePoint = (
  geometry: RoutingNode,
  portName: string,
  direction: 'input' | 'output'
): MatlabElkPoint | null => {
  const graphNode = geometry.node as Partial<GraphNode>
  const bounds = direction === 'input'
    ? graphNode.handleBounds?.target
    : graphNode.handleBounds?.source
  const handle = bounds?.find((candidate) => candidate.id === portName)
  if (!handle) return null
  return {
    x: geometry.x + handle.x + (direction === 'output' ? handle.width : 0),
    y: geometry.y + handle.y + handle.height / 2
  }
}

const segmentIntersectsRect = (
  start: MatlabElkPoint,
  end: MatlabElkPoint,
  rect: RoutingRect
) => {
  if (start.y === end.y) {
    return start.y >= rect.top && start.y <= rect.bottom
      && Math.max(start.x, end.x) >= rect.left
      && Math.min(start.x, end.x) <= rect.right
  }
  if (start.x === end.x) {
    return start.x >= rect.left && start.x <= rect.right
      && Math.max(start.y, end.y) >= rect.top
      && Math.min(start.y, end.y) <= rect.bottom
  }
  return false
}

const routeHitsOtherNode = (
  points: MatlabElkPoint[],
  geometries: RoutingNode[],
  excludedNodeIds: Set<string>
) => geometries.some((geometry) => {
  if (excludedNodeIds.has(geometry.id)) return false
  const margin = 12
  const rect = {
    left: geometry.x - margin,
    right: geometry.x + geometry.width + margin,
    top: geometry.y - margin,
    bottom: geometry.y + geometry.height + margin
  }
  return points.slice(1).some((point, index) => (
    segmentIntersectsRect(points[index], point, rect)
  ))
})

const compactPoints = (points: MatlabElkPoint[]) => points.filter((point, index) => {
  if (index === 0) return true
  const previous = points[index - 1]
  return previous.x !== point.x || previous.y !== point.y
})

const orthogonalRoute = (
  source: MatlabElkPoint,
  target: MatlabElkPoint,
  sourceNode: RoutingNode,
  targetNode: RoutingNode,
  geometries: RoutingNode[]
) => {
  const excluded = new Set([sourceNode.id, targetNode.id])
  const corridorStart = sourceNode.x + sourceNode.width + 24
  const corridorEnd = targetNode.x - 24
  if (corridorEnd > corridorStart) {
    const middle = (corridorStart + corridorEnd) / 2
    const candidates = [middle]
    for (let offset = 24; offset < corridorEnd - corridorStart; offset += 24) {
      if (middle - offset > corridorStart) candidates.push(middle - offset)
      if (middle + offset < corridorEnd) candidates.push(middle + offset)
    }
    for (const x of candidates) {
      const points = compactPoints([
        source,
        { x, y: source.y },
        { x, y: target.y },
        target
      ])
      if (!routeHitsOtherNode(points, geometries, excluded)) return points
    }
  }

  const graphTop = Math.min(...geometries.map((node) => node.y))
  const graphBottom = Math.max(...geometries.map((node) => node.y + node.height))
  const topY = graphTop - 48
  const bottomY = graphBottom + 48
  const detourY = Math.abs(source.y - topY) + Math.abs(target.y - topY)
    <= Math.abs(source.y - bottomY) + Math.abs(target.y - bottomY)
    ? topY
    : bottomY
  const sourceExitX = sourceNode.x + sourceNode.width + 24
  const targetEntryX = targetNode.x - 24
  return compactPoints([
    source,
    { x: sourceExitX, y: source.y },
    { x: sourceExitX, y: detourY },
    { x: targetEntryX, y: detourY },
    { x: targetEntryX, y: target.y },
    target
  ])
}

const routeCurrentLayout = (nodes: LayoutNode[], edges: Edge[]) => {
  const geometries = nodes.map(routingNode)
  const byId = new Map(geometries.map((node) => [node.id, node]))
  const routes: Record<string, MatlabElkPoint[]> = {}
  const warnings: string[] = []
  edges.forEach((edge) => {
    const sourceNode = byId.get(edge.source)
    const targetNode = byId.get(edge.target)
    const source = sourceNode && routingHandlePoint(
      sourceNode,
      String(edge.sourceHandle || ''),
      'output'
    )
    const target = targetNode && routingHandlePoint(
      targetNode,
      String(edge.targetHandle || ''),
      'input'
    )
    if (!sourceNode || !targetNode || !source || !target) {
      warnings.push(`连线 ${edge.id} 无法找到当前端口位置，暂时使用直线显示`)
      return
    }
    routes[edge.id] = orthogonalRoute(source, target, sourceNode, targetNode, geometries)
  })
  return { routes, warnings }
}

export const useMatlabElkLayout = () => {
  let elk: ElkInstance | null = null
  let worker: Worker | null = null
  let activeRequest: ActiveRequest | null = null
  let requestSequence = 0

  const clearActiveRequest = () => {
    if (!activeRequest) return
    window.clearTimeout(activeRequest.timeoutId)
    activeRequest = null
  }

  const terminateEngine = (error?: Error) => {
    const request = activeRequest
    clearActiveRequest()
    if (request && error) request.reject(error)
    elk?.terminateWorker()
    worker?.terminate()
    elk = null
    worker = null
  }

  const createEngine = () => {
    const instance = new ElkWorker()
    worker = instance
    instance.onerror = (event) => {
      if (worker !== instance) return
      event.preventDefault()
      const location = event.filename ? `（${event.filename}:${event.lineno || 0}）` : ''
      terminateEngine(new Error(`ELKJS Worker加载或运行失败：${event.message || '未知错误'}${location}`))
    }
    instance.onmessageerror = () => {
      if (worker !== instance) return
      terminateEngine(new Error('ELKJS Worker返回的数据无法解析'))
    }
    try {
      elk = new ELK({ workerFactory: () => instance })
    } catch (error) {
      instance.terminate()
      worker = null
      throw new Error(`ELKJS Worker初始化失败：${error instanceof Error ? error.message : String(error)}`)
    }
    return elk
  }

  const ensureEngine = () => elk || createEngine()

  const layout = (
    nodes: LayoutNode[],
    edges: Edge[],
    mode: MatlabElkLayoutMode = 'full'
  ) => {
    if (activeRequest) {
      terminateEngine(new Error('ELKJS布局已被更新的画布任务替代'))
    }
    const requestId = ++requestSequence
    if (mode === 'routing') {
      const startedAt = performance.now()
      const { routes, warnings } = routeCurrentLayout(nodes, edges)
      return Promise.resolve({
        positions: {} as Record<string, MatlabElkPoint>,
        routes,
        warnings,
        requestId,
        durationMs: performance.now() - startedAt,
        mode
      })
    }

    const engine = ensureEngine()
    const { graph, warnings } = buildElkGraph(nodes, edges)
    return new Promise<MatlabElkLayoutResult>((resolve, reject) => {
      const startedAt = performance.now()
      const timeoutId = window.setTimeout(() => {
        if (activeRequest?.requestId !== requestId) return
        terminateEngine(new Error(`ELKJS布局超时（${LAYOUT_TIMEOUT_MS / 1000}秒）`))
      }, LAYOUT_TIMEOUT_MS)
      activeRequest = { requestId, reject, timeoutId }

      try {
        engine.layout(graph).then((result) => {
          if (activeRequest?.requestId !== requestId) return
          clearActiveRequest()
          const positions: Record<string, MatlabElkPoint> = {}
          result.children?.forEach((node) => {
            positions[node.id] = { x: node.x || 0, y: node.y || 0 }
          })
          const routes: Record<string, MatlabElkPoint[]> = {}
          result.edges?.forEach((edge) => {
            routes[edge.id] = flattenSections(edge)
          })
          resolve({
            positions,
            routes,
            warnings,
            requestId,
            durationMs: performance.now() - startedAt,
            mode
          })
        }).catch((error) => {
          if (activeRequest?.requestId !== requestId) return
          clearActiveRequest()
          reject(new Error(`ELKJS算法执行失败：${error instanceof Error ? error.message : String(error)}`))
        })
      } catch (error) {
        if (activeRequest?.requestId === requestId) clearActiveRequest()
        reject(new Error(`ELKJS布局请求发送失败：${error instanceof Error ? error.message : String(error)}`))
      }
    })
  }

  const dispose = () => {
    terminateEngine(new Error('ELKJS布局已终止'))
  }

  return { layout, dispose }
}
