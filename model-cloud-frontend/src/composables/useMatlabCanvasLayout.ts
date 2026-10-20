import { computed, nextTick, onUnmounted, ref, watch, type Ref } from 'vue'
import { MarkerType, useVueFlow } from '@vue-flow/core'
import type { Edge, Node } from '@vue-flow/core'
import { ElMessage } from 'element-plus'
import { useMatlabElkLayout, type MatlabElkLayoutMode } from '@/composables/useMatlabElkLayout'

type Dependencies = {
  nodes: Ref<Node[]>
  /** Persisted workflow edges. ELK route metadata for these edges may be written back. */
  edges: Ref<Edge[]>
  /** Edges that determine node levels during a full layout. */
  layoutEdges?: Ref<Edge[]>
  /** Edges that need routes after node placement, including view-only projections. */
  routingEdges?: Ref<Edge[]>
  /** Store routes for view-only edges without writing them into projectData. */
  applyTransientRoutes?: (routes: Record<string, Array<{ x: number; y: number }>>) => void
  sceneId?: Ref<string>
  sceneHydrating?: Ref<boolean>
  /** 每次切层递增；布局任务写回前必须复核，防止旧任务污染新场景。 */
  sceneRevision?: Ref<number>
  getValidPorts: (ports: unknown) => Array<{ name: string; type: string }>
  addLog: (type: string, message: string) => void
}

export function useMatlabCanvasLayout(deps: Dependencies) {
  const { fitView, getNodes, updateNodeInternals } = useVueFlow()
  const elkLayout = useMatlabElkLayout()
  
  let elkLayoutTimer: number | null = null
  
  let elkLayoutRequest = 0
  
  let fitNextElkLayout = false
  
  let nextElkLayoutMode: MatlabElkLayoutMode = 'routing'
  
  const elkLayoutBusy = ref(false)
  
  const runElkLayout = async (
    fitAfterLayout = false,
    mode: MatlabElkLayoutMode = 'routing'
  ) => {
    if (deps.nodes.value.length === 0) {
      elkLayoutBusy.value = false
      return
    }
    const requestId = ++elkLayoutRequest
    const layoutSceneId = deps.sceneId?.value
    const layoutSceneRevision = deps.sceneRevision?.value
    const orderingEdges = deps.layoutEdges?.value || deps.edges.value
    const routeEdges = deps.routingEdges?.value || deps.edges.value
    elkLayoutBusy.value = true
    const startedAt = performance.now()
    console.info(
      `[ELKJS] 开始${mode === 'full' ? '完整整理' : '重新布线'} #${requestId}：`
        + `${deps.nodes.value.length} 个节点，${orderingEdges.length} 条布局连线，`
        + `${routeEdges.length} 条显示连线`
    )
    try {
      await nextTick()
      updateNodeInternals(deps.nodes.value.map((node) => node.id))
      await new Promise<void>((resolve) => requestAnimationFrame(() => resolve()))
      await nextTick()
      if (requestId !== elkLayoutRequest || layoutSceneId !== deps.sceneId?.value
        || layoutSceneRevision !== deps.sceneRevision?.value
        || deps.sceneHydrating?.value) return
      const measuredById = new Map(getNodes.value.map((node) => [node.id, node]))
      const measuredNodes = deps.nodes.value.map((node) => measuredById.get(node.id) || node)
      const result = await elkLayout.layout(
        measuredNodes,
        mode === 'full' ? orderingEdges : routeEdges,
        mode
      )
      if (requestId !== elkLayoutRequest || layoutSceneId !== deps.sceneId?.value
        || layoutSceneRevision !== deps.sceneRevision?.value
        || deps.sceneHydrating?.value) return
      if (mode === 'full') {
        deps.nodes.value = deps.nodes.value.map((node) => ({
          ...node,
          position: result.positions[node.id] || node.position
        }))
      }
      let routes = result.routes
      const warnings = [...result.warnings]
      if (mode === 'full') {
        // Node placement changes handle coordinates. Route every visible edge again
        // against the mounted positions so shaft/bleed overlays follow the gas-path
        // layout without participating in its ordering.
        await nextTick()
        updateNodeInternals(deps.nodes.value.map((node) => node.id))
        await new Promise<void>((resolve) => requestAnimationFrame(() => resolve()))
        await nextTick()
        if (requestId !== elkLayoutRequest || layoutSceneId !== deps.sceneId?.value
          || layoutSceneRevision !== deps.sceneRevision?.value
          || deps.sceneHydrating?.value) return
        const rerouteMeasuredById = new Map(getNodes.value.map((node) => [node.id, node]))
        const rerouteNodes = deps.nodes.value.map((node) => rerouteMeasuredById.get(node.id) || node)
        const routingResult = await elkLayout.layout(rerouteNodes, routeEdges, 'routing')
        routes = routingResult.routes
        warnings.push(...routingResult.warnings)
      }
      deps.edges.value = deps.edges.value.map((edge) => ({
        ...edge,
        type: 'matlabElk',
        zIndex: 1001,
        animated: false,
        markerEnd: MarkerType.ArrowClosed,
        data: {
          ...(edge.data || {}),
          elkPoints: routes[edge.id] || []
        }
      }))
      deps.applyTransientRoutes?.(routes)
      await nextTick()
      if (fitAfterLayout) {
        await fitView({ padding: 0.12, duration: 300 })
      }
      warnings.forEach((warning) => {
        console.warn(`[ELKJS] ${warning}`)
        deps.addLog('warning', `ELKJS：${warning}`)
      })
      console.info(
        `[ELKJS] ${mode === 'full' ? '完整整理' : '重新布线'} #${requestId} 完成：`
          + `计算 ${result.durationMs.toFixed(1)}ms，`
          + `总耗时 ${(performance.now() - startedAt).toFixed(1)}ms`
      )
    } catch (error: any) {
      if (requestId === elkLayoutRequest) {
        const message = error.message || '未知错误'
        console.error(`[ELKJS] 布局 #${requestId} 失败`, error)
        deps.addLog('error', `ELKJS排版失败：${message}`)
        ElMessage.error(`ELKJS排版失败：${message}`)
      }
    } finally {
      if (requestId === elkLayoutRequest) elkLayoutBusy.value = false
    }
  }
  
  const scheduleElkLayout = (
    fitAfterLayout = false,
    mode: MatlabElkLayoutMode = 'routing'
  ) => {
    fitNextElkLayout = fitNextElkLayout || fitAfterLayout
    if (mode === 'full') nextElkLayoutMode = 'full'
    if (elkLayoutTimer != null) window.clearTimeout(elkLayoutTimer)
    elkLayoutTimer = window.setTimeout(() => {
      elkLayoutTimer = null
      const shouldFit = fitNextElkLayout
      const scheduledMode = nextElkLayoutMode
      fitNextElkLayout = false
      nextElkLayoutMode = 'routing'
      void runElkLayout(shouldFit, scheduledMode)
    }, 200)
  }
  
  const handleManualLayout = () => {
    if (elkLayoutTimer != null) {
      window.clearTimeout(elkLayoutTimer)
      elkLayoutTimer = null
    }
    fitNextElkLayout = false
    nextElkLayoutMode = 'routing'
    void runElkLayout(true, 'full')
  }

  const cancelLayout = () => {
    elkLayoutRequest += 1
    if (elkLayoutTimer != null) {
      window.clearTimeout(elkLayoutTimer)
      elkLayoutTimer = null
    }
    fitNextElkLayout = false
    nextElkLayoutMode = 'routing'
    elkLayout.dispose()
    deps.applyTransientRoutes?.({})
    elkLayoutBusy.value = false
  }
  
  const elkTopologySignature = computed(() => JSON.stringify({
    nodes: deps.nodes.value.map((node) => ({
      id: node.id,
      instanceName: node.data?.instanceName,
      inputs: deps.getValidPorts(node.data?.inputPorts).map((port) => `${port.name}:${port.type}`),
      outputs: deps.getValidPorts(node.data?.outputPorts).map((port) => `${port.name}:${port.type}`)
    })),
    layoutEdges: (deps.layoutEdges?.value || deps.edges.value).map((edge) => ({
      id: edge.id,
      source: edge.source,
      sourceHandle: edge.sourceHandle,
      target: edge.target,
      targetHandle: edge.targetHandle
    })),
    routingEdges: (deps.routingEdges?.value || deps.edges.value).map((edge) => ({
      id: edge.id,
      source: edge.source,
      sourceHandle: edge.sourceHandle,
      target: edge.target,
      targetHandle: edge.targetHandle
    }))
  }))
  
  const elkNodeMeasureSignature = computed(() => JSON.stringify(getNodes.value.map((node) => ({
    id: node.id,
    resizing: Boolean(node.data?.resizing),
    presentationWidth: Math.round(Number(node.data?.presentationSize?.width) || 0),
    presentationHeight: Math.round(Number(node.data?.presentationSize?.height) || 0),
    width: Math.round(Number(node.dimensions?.width) || 0),
    height: Math.round(Number(node.dimensions?.height) || 0),
    targets: (node.handleBounds?.target || []).map((handle) => [
      handle.id,
      Math.round(handle.x),
      Math.round(handle.width),
      Math.round(handle.y),
      Math.round(handle.height)
    ]),
    sources: (node.handleBounds?.source || []).map((handle) => [
      handle.id,
      Math.round(handle.x),
      Math.round(handle.width),
      Math.round(handle.y),
      Math.round(handle.height)
    ])
  }))))
  
  watch(elkTopologySignature, (nextValue, previousValue) => {
    if (nextValue === previousValue || deps.nodes.value.length === 0) return
    scheduleElkLayout(false, 'routing')
  })
  
  watch(elkNodeMeasureSignature, (nextValue, previousValue) => {
    if (nextValue === previousValue || getNodes.value.length === 0) return
    if (getNodes.value.some((node) => node.data?.resizing)) return
    const hasMeasuredNode = getNodes.value.some((node) => (
      Number(node.dimensions?.width) > 0 && Number(node.dimensions?.height) > 0
    ))
    if (hasMeasuredNode && !elkLayoutBusy.value) scheduleElkLayout(false, 'routing')
  })

  onUnmounted(() => {
    elkLayoutRequest += 1
    if (elkLayoutTimer != null) window.clearTimeout(elkLayoutTimer)
    elkLayout.dispose()
    deps.applyTransientRoutes?.({})
  })
  return { elkLayoutBusy, scheduleElkLayout, handleManualLayout, cancelLayout }
}
