import { describe, expect, it } from 'vitest'
import { ref } from 'vue'
import type { Node } from '@vue-flow/core'
import { useMatlabNodeSelection } from '../../composables/useMatlabNodeSelection'

describe('Shift 节点选区', () => {
  it('Vue Flow 提前更改点击选区后仍保留加选和取消选择的语义', () => {
    const nodes = ref<Array<Node & { selected: boolean }>>([
      { id: 'a', selected: true, position: { x: 0, y: 0 } },
      { id: 'b', selected: false, position: { x: 50, y: 0 } }
    ])
    const selection = useMatlabNodeSelection(nodes)
    selection.captureNodeSelection()
    nodes.value = nodes.value.map(node => ({ ...node, selected: node.id === 'b' }))
    expect(selection.applyAdditiveSelection('b')).toBe(true)
    expect(nodes.value.filter(node => 'selected' in node && node.selected).map(node => node.id)).toEqual(['a', 'b'])
    selection.captureNodeSelection()
    expect(selection.applyAdditiveSelection('a')).toBe(false)
    expect(nodes.value.filter(node => 'selected' in node && node.selected).map(node => node.id)).toEqual(['b'])
  })
})
