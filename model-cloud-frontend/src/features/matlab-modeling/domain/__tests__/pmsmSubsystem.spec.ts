import { describe, expect, it } from 'vitest'
import fixture from '../../../../../../contracts/matlab/fixtures/pmsm/standalone.project-v3.json'
import { instantiateWorkflowTemplate } from '../templateInstantiation'
import { parseMatlabProject, serializeMatlabProject } from '../projectCodec'
import { synchronizeProjectInterfaces } from '../boundaryComponents'


describe('editable PMSM programs', () => {
  it('remaps every entrypoint to its own instance and survives serialization', () => {
    const instantiate = (token: string) => instantiateWorkflowTemplate({
      template: fixture, templateInputs: [], templateOutputs: [], instanceToken: token,
      instanceName: token, componentId: 'pmsm.project.standalone', componentName: 'PMSM'
    })
    const left = instantiate('left')
    const right = instantiate('right')
    expect(left.ok && right.ok).toBe(true)
    if (!left.ok || !right.ok) return
    const leftNodes = left.scenes.flatMap(scene => scene.savedNodes)
    const rightEntries = right.scenes.flatMap(scene => scene.savedNodes).flatMap(node => Object.values(node.modelEntrypoints || {}))
    const scenes = Object.fromEntries(left.scenes.map(scene => [scene.sceneId, {
      id: scene.sceneId, title: scene.title, parentSceneId: scene.parentSceneId,
      viewport: scene.viewport, boundaryPorts: scene.boundaryPorts,
      nodes: scene.savedNodes.map(node => ({ id: node.id, position: node.position!, data: node })), dataEdges: []
    }]))
    const saved = serializeMatlabProject(scenes, {}, left.rootChildId)
    const restored = parseMatlabProject(JSON.stringify(saved)).project
    for (const node of leftNodes.filter(node => node.modelEntrypoints)) {
      expect(Object.values(restored.scenes).flatMap(scene => scene.nodes).find(item => item.id === node.id)?.modelEntrypoints)
        .toEqual(node.modelEntrypoints)
      for (const id of Object.values(node.modelEntrypoints!)) {
        expect(restored.scenes[id]).toBeDefined()
        expect(rightEntries).not.toContain(id)
      }
    }
  })

  it('keeps callable ports when navigating an overview scene', () => {
    const ports = [{ id: 'INPUT', name: 'INPUT', kind: 'data', direction: 'input', dataType: 'bus' }]
    const scenes = synchronizeProjectInterfaces({
      root: { nodes: [{ id: 'motor', data: { childSceneId: 'overview', modelEntrypoints: { design: 'design' }, boundaryPorts: ports } }], dataEdges: [], boundaryPorts: [] },
      overview: { nodes: [], dataEdges: [], boundaryPorts: [] }
    })
    expect(scenes.root.nodes[0].data.boundaryPorts).toEqual(ports)
  })
})
