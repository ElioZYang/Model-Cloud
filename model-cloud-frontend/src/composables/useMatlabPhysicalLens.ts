import { computed, inject, provide, ref, watch, type ComputedRef, type InjectionKey, type Ref } from 'vue'
import type { Edge } from '@vue-flow/core'

export type PhysicalRelation = 'flow' | 'shaft' | 'bleed'
export type PhysicalLensMode = 'overview' | PhysicalRelation

type PhysicalLensContext = {
  mode: Ref<PhysicalLensMode>
  isPhysical: ComputedRef<boolean>
  isNodeFocused: (id: string) => boolean
  isEdgeFocused: (id: string) => boolean
}

const physicalLensKey: InjectionKey<PhysicalLensContext> = Symbol('matlabPhysicalLens')

export function useMatlabPhysicalLens(sceneId: Ref<string>, physicalContext: ComputedRef<boolean>, edges: Ref<Edge[]>) {
  const mode = ref<PhysicalLensMode>('overview')
  const isPhysical = physicalContext
  const focusedEdges = computed(() => new Set(edges.value
    .filter((edge) => edge.data?.physicalProjection && edge.data?.relation === mode.value)
    .map((edge) => edge.id)))
  // Every gas-path component stays interactive: it may be the first member of
  // a new shaft or bleed group, even when that relation has no edges yet.
  const isNodeFocused = (_id: string) => true
  const isEdgeFocused = (id: string) => !isPhysical.value || mode.value === 'overview' || focusedEdges.value.has(id)
  watch(sceneId, () => { mode.value = 'overview' })
  provide(physicalLensKey, { mode, isPhysical, isNodeFocused, isEdgeFocused })
  return { mode, isPhysical, isNodeFocused, isEdgeFocused }
}

export function injectMatlabPhysicalLens() {
  return inject(physicalLensKey, null)
}
