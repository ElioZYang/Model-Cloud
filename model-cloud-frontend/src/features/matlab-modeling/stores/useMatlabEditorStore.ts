import { defineStore } from 'pinia'
import type { Edge, Node } from '@vue-flow/core'
import type { PhysicalAssembly } from '../domain/physicalAssembly'
import type { RuntimeSceneData } from '../domain/sceneCommands'

export const DEFAULT_MATLAB_ROOT_SCENE_ID = 'scene_root'

const defaultRootScene = (): RuntimeSceneData => ({
  id: DEFAULT_MATLAB_ROOT_SCENE_ID,
  title: '根场景',
  nodes: [],
  dataEdges: [],
  boundaryPorts: [],
  viewport: { x: 0, y: 0, zoom: 1 }
})

/**
 * MATLAB 建模编辑器的唯一 Scene 状态源（V3）。
 *
 * scenes 只保存通用 Scene（节点 + 数据边 + 边界端口）；发动机物理关系
 * 保存在 physicalAssemblies（装配域），成员与关系使用项目唯一节点 ID。
 * layoutRevisions 在每次切换场景时递增，用于使未完成的布局任务失效。
 */
export const useMatlabEditorStore = defineStore('matlabEditor', {
  state: () => ({
    scenes: {
      [DEFAULT_MATLAB_ROOT_SCENE_ID]: defaultRootScene()
    } as Record<string, RuntimeSceneData>,
    rootSceneId: DEFAULT_MATLAB_ROOT_SCENE_ID,
    activeSceneId: DEFAULT_MATLAB_ROOT_SCENE_ID,
    physicalAssemblies: {} as Record<string, PhysicalAssembly>,
    /** 当前编辑的装配（物理关系上下文入口）。 */
    activeAssemblyId: '' as string,
    layoutRevisions: {} as Record<string, number>
  }),
  getters: {
    activeScene(state): RuntimeSceneData | undefined {
      return state.scenes[state.activeSceneId]
    },
    activeSceneNodes(state): Node[] {
      return state.scenes[state.activeSceneId]?.nodes ?? []
    },
    activeSceneEdges(state): Edge[] {
      return state.scenes[state.activeSceneId]?.dataEdges ?? []
    },
    sceneRevision(state): number {
      return state.layoutRevisions[state.activeSceneId] ?? 0
    },
    activeAssembly(state): PhysicalAssembly | undefined {
      return state.physicalAssemblies[state.activeAssemblyId]
    }
  },
  actions: {
    resetProject(
      scenes: Record<string, RuntimeSceneData>,
      rootSceneId: string,
      physicalAssemblies: Record<string, PhysicalAssembly> = {}
    ) {
      this.scenes = scenes
      this.rootSceneId = rootSceneId
      this.physicalAssemblies = physicalAssemblies
      this.activeAssemblyId = Object.keys(physicalAssemblies)[0] || ''
      this.layoutRevisions = {}
      this.setActiveScene(rootSceneId)
    },
    putScene(scene: RuntimeSceneData) {
      this.scenes[scene.id] = scene
    },
    removeScene(sceneId: string) {
      delete this.scenes[sceneId]
    },
    setActiveScene(sceneId: string) {
      if (!this.scenes[sceneId]) return
      this.activeSceneId = sceneId
      this.layoutRevisions[sceneId] = (this.layoutRevisions[sceneId] ?? 0) + 1
      const visibleIds = new Set<string>()
      const collect = (id: string, visited = new Set<string>()) => {
        if (visited.has(id)) return
        visited.add(id)
        this.scenes[id]?.nodes.forEach(node => {
          visibleIds.add(node.id)
          if (node.data?.childSceneId) collect(node.data.childSceneId, visited)
        })
      }
      collect(sceneId)
      const candidates = Object.values(this.physicalAssemblies).filter(assembly => assembly.memberNodeIds.some(id => visibleIds.has(id)))
      if (candidates.length && !candidates.some(assembly => assembly.id === this.activeAssemblyId)) {
        this.activeAssemblyId = candidates[0].id
      }
    },
    setActiveSceneNodes(nodes: Node[]) {
      const scene = this.scenes[this.activeSceneId]
      if (scene) scene.nodes = nodes
    },
    setActiveSceneEdges(edges: Edge[]) {
      const scene = this.scenes[this.activeSceneId]
      if (scene) scene.dataEdges = edges
    },
    saveViewport(sceneId: string, transform: { x?: number; y?: number; zoom?: number }) {
      const scene = this.scenes[sceneId]
      if (!scene) return
      scene.viewport = {
        x: Number(transform?.x) || 0,
        y: Number(transform?.y) || 0,
        zoom: Number(transform?.zoom) || 1
      }
    },
    bumpLayoutRevision(sceneId: string) {
      this.layoutRevisions[sceneId] = (this.layoutRevisions[sceneId] ?? 0) + 1
    },
    upsertAssembly(assembly: PhysicalAssembly) {
      const previous = this.physicalAssemblies[assembly.id]
      this.physicalAssemblies[assembly.id] = assembly
      const previousIds = (previous?.shaftGroups || []).slice().sort((a, b) => a.order - b.order).map(group => group.id)
      const nextGroups = assembly.shaftGroups.slice().sort((a, b) => a.order - b.order)
      const nextIds = nextGroups.map(group => group.id)
      if (previous && (previousIds.length !== nextIds.length || previousIds.some((id, index) => id !== nextIds[index]))) {
        const oldIndex = new Map(previousIds.map((id, index) => [id, index]))
        const ownerScene = Object.values(this.scenes).find(scene => scene.nodes.some(node =>
          node.data?.physicalAssemblyId === assembly.id))
        let childSceneId = ownerScene?.id
        const visited = new Set<string>()
        while (childSceneId && !visited.has(childSceneId)) {
          visited.add(childSceneId)
          const parent = Object.values(this.scenes).find(scene => scene.nodes.some(node =>
            node.data?.childSceneId === childSceneId))
          if (!parent) break
          parent.nodes = parent.nodes.map(node => {
            if (node.data?.childSceneId !== childSceneId) return node
            const values = node.data?.values as Record<string, unknown> | undefined
            const ports = Array.isArray(node.data?.inputPorts) ? node.data.inputPorts : []
            const dynamicPort = ports.find((port: any) => port?.dynamicLength?.source === 'shaftGroups')
            if (!dynamicPort || !values || !(dynamicPort.name in values)) return node
            const raw = values[dynamicPort.name]
            const vector = Array.isArray(raw) ? raw : (typeof raw === 'number' ? [raw] : null)
            if (!vector || vector.length !== previousIds.length) return node
            const remapped = nextGroups.map(group => {
              const index = oldIndex.get(group.id)
              return index == null ? dynamicPort.dynamicLength.defaultValue : vector[index]
            })
            return { ...node, data: { ...node.data, values: { ...values, [dynamicPort.name]: remapped } } }
          })
          childSceneId = parent.id
        }
      }
      if (!this.activeAssemblyId) this.activeAssemblyId = assembly.id
    },
    removeAssembly(assemblyId: string) {
      delete this.physicalAssemblies[assemblyId]
      if (this.activeAssemblyId === assemblyId) {
        this.activeAssemblyId = Object.keys(this.physicalAssemblies)[0] || ''
      }
    }
  }
})
