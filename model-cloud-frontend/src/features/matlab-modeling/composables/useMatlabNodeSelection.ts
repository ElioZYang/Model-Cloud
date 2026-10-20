import type { Ref } from 'vue'
import type { Node } from '@vue-flow/core'

/** Preserve the pre-pointer selection before Vue Flow applies its own click selection. */
export function useMatlabNodeSelection(nodes: Ref<Node[]>) {
  let beforePointer = new Set<string>()
  const captureNodeSelection = () => {
    beforePointer = new Set(nodes.value.filter(node => 'selected' in node && node.selected).map(node => node.id))
  }
  const applyAdditiveSelection = (id: string) => {
    const selected = !beforePointer.has(id)
    if (selected) beforePointer.add(id)
    else beforePointer.delete(id)
    nodes.value = nodes.value.map(node => ({ ...node, selected: beforePointer.has(node.id) }))
    return selected
  }
  return { captureNodeSelection, applyAdditiveSelection }
}
