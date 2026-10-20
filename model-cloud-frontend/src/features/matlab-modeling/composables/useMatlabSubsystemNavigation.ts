import { nextTick, type ComputedRef, type Ref } from 'vue'
import type { NodeMouseEvent } from '@vue-flow/core'
import { useMatlabEditorStore } from '../stores/useMatlabEditorStore'
import { synchronizeProjectInterfaces } from '../domain/boundaryComponents'

/**
 * 子系统层级导航：进入/返回场景（面包屑与双击）、viewport 恢复。
 * 图数据只有编辑器 store 一份：切层仅切换 activeSceneId，零复制。
 */
export function useMatlabSubsystemNavigation(deps: {
  activeSceneId: Ref<string> | ComputedRef<string> & { value: string }
  sceneHydrating: Ref<boolean>
  selectedEdgeId: Ref<string | null>
  activeRelationGroupId: Ref<string | null>
  physicalRelation: Ref<'flow' | 'shaft' | 'bleed'>
  isNodeFocused: (nodeId: string) => boolean
  cancelCanvasLayout: () => void
  clearAutoConnectSource: () => void
  clearNodeSelection: () => void
  setViewport: (viewport: { x: number; y: number; zoom: number }) => Promise<unknown>
  scheduleElkLayout: (fitAfterLayout?: boolean, mode?: 'full' | 'routing') => void
  nodesCount: ComputedRef<number> | { value: number }
}) {
  const editorStore = useMatlabEditorStore()

  const hydrateActiveScene = async (sceneId: string) => {
    const scene = editorStore.scenes[sceneId]
    if (!scene) return
    const boundInitializerIds = new Set(Object.values(editorStore.physicalAssemblies)
      .map(assembly => assembly.initializerBinding.nodeId).filter(Boolean))
    editorStore.scenes = synchronizeProjectInterfaces(editorStore.scenes, boundInitializerIds)
    deps.cancelCanvasLayout()
    deps.sceneHydrating.value = true
    editorStore.setActiveScene(sceneId)
    deps.selectedEdgeId.value = null
    deps.activeRelationGroupId.value = null
    deps.physicalRelation.value = 'flow'
    deps.clearAutoConnectSource()
    deps.clearNodeSelection()
    await nextTick()
    deps.sceneHydrating.value = false
    if (deps.nodesCount.value > 0) {
      // Layout may update node positions, but it must not replace the
      // scene's saved camera when entering or returning to a child scene.
      await nextTick()
      await deps.setViewport(scene.viewport)
      deps.scheduleElkLayout(false, 'routing')
    }
  }

  const handleSceneBreadcrumbClick = (sceneId: string) => {
    if (sceneId === deps.activeSceneId.value || !editorStore.scenes[sceneId]) return
    void hydrateActiveScene(sceneId)
  }

  const handleViewportChange = (transform: { x?: number; y?: number; zoom?: number }) => {
    if (deps.sceneHydrating.value) return
    // viewport 属于工程数据：随场景显式保存在 store 中。
    editorStore.saveViewport(deps.activeSceneId.value, transform)
  }

  const handleNodeDoubleClick = (event: NodeMouseEvent) => {
    if (!deps.isNodeFocused(event.node.id)) return
    const node = event.node
    const childSceneId = String(node?.data?.childSceneId || '')
    if (!childSceneId || !editorStore.scenes[childSceneId]) return
    void hydrateActiveScene(childSceneId)
  }

  return { hydrateActiveScene, handleSceneBreadcrumbClick, handleViewportChange, handleNodeDoubleClick }
}
