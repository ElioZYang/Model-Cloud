<template>
  <span
    v-for="handle in handles"
    :key="handle"
    class="matlab-resize-handle nodrag nopan"
    :class="`resize-${handle}`"
    :aria-label="`调整节点${handle}`"
    @pointerdown.stop.prevent="startResize($event, handle)"
  />
</template>

<script setup lang="ts">
import { nextTick, onUnmounted } from 'vue'
import { useVueFlow } from '@vue-flow/core'

const props = withDefaults(defineProps<{
  id: string
  width?: number
  height?: number
  minWidth?: number
  minHeight?: number
  position?: { x?: number; y?: number }
}>(), {
  width: 360,
  height: 180,
  minWidth: 220,
  minHeight: 96
})

const handles = ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'] as const
type ResizeHandle = typeof handles[number]
const { updateNode, updateNodeData, updateNodeInternals, viewport, getNodes } = useVueFlow()

let active: {
  pointerId: number
  handle: ResizeHandle
  startX: number
  startY: number
  startWidth: number
  startHeight: number
  startPosition: { x: number; y: number }
  target: HTMLElement | null
} | null = null

let pendingEvent: PointerEvent | null = null
let resizeFrame: number | null = null

const refreshInternals = () => {
  void nextTick(() => updateNodeInternals([props.id]))
}

const applyResize = (event: PointerEvent) => {
  if (!active) return
  if (event.pointerId !== active.pointerId) return
  const viewportState = (viewport as any)?.value ?? viewport
  const zoom = Number(viewportState?.zoom ?? viewportState?.z ?? 1) || 1
  const dx = (event.clientX - active.startX) / zoom
  const dy = (event.clientY - active.startY) / zoom
  let width = active.startWidth
  let height = active.startHeight
  if (active.handle.includes('e')) width += dx
  if (active.handle.includes('w')) width -= dx
  if (active.handle.includes('s')) height += dy
  if (active.handle.includes('n')) height -= dy
  width = Math.max(props.minWidth, Math.round(width))
  height = Math.max(props.minHeight, Math.round(height))
  updateNode(props.id, { style: { width: `${width}px`, height: `${height}px` } })
  if (active.handle.includes('w') || active.handle.includes('n')) {
    updateNode(props.id, {
      position: {
        x: active.startPosition.x + (active.handle.includes('w') ? active.startWidth - width : 0),
        y: active.startPosition.y + (active.handle.includes('n') ? active.startHeight - height : 0)
      }
    })
  }
  updateNodeData(props.id, { presentationSize: { width, height }, resizing: true })
  refreshInternals()
}

const resize = (event: PointerEvent) => {
  if (!active || event.pointerId !== active.pointerId) return
  pendingEvent = event
  if (resizeFrame !== null) return
  resizeFrame = window.requestAnimationFrame(() => {
    resizeFrame = null
    const latest = pendingEvent
    pendingEvent = null
    if (latest) applyResize(latest)
  })
}

const finishResize = (event?: PointerEvent) => {
  if (!active) return
  if (event && event.pointerId !== active.pointerId) return
  if (resizeFrame !== null) {
    window.cancelAnimationFrame(resizeFrame)
    resizeFrame = null
  }
  if (pendingEvent) {
    const latest = pendingEvent
    pendingEvent = null
    applyResize(latest)
  }
  if (event && active.target?.hasPointerCapture?.(event.pointerId)) active.target.releasePointerCapture(event.pointerId)
  updateNodeData(props.id, { resizing: false })
  refreshInternals()
  window.removeEventListener('pointermove', resize)
  window.removeEventListener('pointerup', finishResize)
  window.removeEventListener('pointercancel', finishResize)
  window.removeEventListener('blur', handleBlur)
  active = null
}

const handleBlur = () => finishResize()

const startResize = (event: PointerEvent, handle: ResizeHandle) => {
  const currentNode = getNodes.value.find((node) => node.id === props.id)
  const currentPosition = (currentNode as any)?.position || props.position || {}
  active = {
    pointerId: event.pointerId,
    handle,
    startX: event.clientX,
    startY: event.clientY,
    startWidth: Math.max(props.minWidth, Number(props.width) || props.minWidth),
    startHeight: Math.max(props.minHeight, Number(props.height) || props.minHeight),
    startPosition: { x: Number(currentPosition.x) || 0, y: Number(currentPosition.y) || 0 },
    target: event.currentTarget instanceof HTMLElement ? event.currentTarget : null
  }
  ;(event.currentTarget as HTMLElement).setPointerCapture?.(event.pointerId)
  updateNodeData(props.id, { resizing: true })
  window.addEventListener('pointermove', resize)
  window.addEventListener('pointerup', finishResize)
  window.addEventListener('pointercancel', finishResize)
  window.addEventListener('blur', handleBlur)
}

onUnmounted(() => finishResize())
</script>

<style scoped>
.matlab-resize-handle { position: absolute; z-index: 20; display: block; background: transparent; touch-action: none; user-select: none; }
.matlab-resize-handle:hover { background: rgba(64, 158, 255, .28); }
.resize-n, .resize-s { left: 10px; right: 10px; height: 7px; cursor: ns-resize; }
.resize-n { top: -4px; }
.resize-s { bottom: -4px; }
.resize-e, .resize-w { top: 10px; bottom: 10px; width: 7px; cursor: ew-resize; }
.resize-e { right: -4px; }
.resize-w { left: -4px; }
.resize-ne, .resize-sw, .resize-se, .resize-nw { width: 11px; height: 11px; }
.resize-ne { top: -5px; right: -5px; cursor: nesw-resize; }
.resize-sw { bottom: -5px; left: -5px; cursor: nesw-resize; }
.resize-se { right: -5px; bottom: -5px; cursor: nwse-resize; }
.resize-nw { top: -5px; left: -5px; cursor: nwse-resize; }
</style>
