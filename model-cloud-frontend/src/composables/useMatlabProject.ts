import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { modelDeployApi, type ModelingProject } from '@/api/model-deploy'

type Dependencies = { buildProjectData: () => string }

export function useMatlabProject(deps: Dependencies) {
  const projectDialogVisible = ref(false)
  
  const saveProjectDialogVisible = ref(false)
  
  const projectLoading = ref(false)
  
  const projectSaving = ref(false)
  
  const projectList = ref<ModelingProject[]>([])
  
  const currentProject = ref<Pick<ModelingProject, 'id' | 'name' | 'description'> | null>(null)
  
  const saveProjectForm = ref({ name: '', description: '' })
  
  const loadProjectList = async () => {
    projectLoading.value = true
    try {
      const response = await modelDeployApi.getUserProjects(1, 200, 'JULIA_MATLAB')
      projectList.value = response.data?.records || []
    } catch (error: any) {
      ElMessage.error(`MATLAB项目列表加载失败：${error.message || '未知错误'}`)
    } finally {
      projectLoading.value = false
    }
  }
  
  const handleOpenProjectDialog = async () => {
    projectDialogVisible.value = true
    await loadProjectList()
  }
  
  const handleSaveProject = () => {
    saveProjectForm.value.name = currentProject.value?.name || ''
    saveProjectForm.value.description = currentProject.value?.description || ''
    saveProjectDialogVisible.value = true
  }
  
  const handleConfirmSaveProject = async () => {
    const name = saveProjectForm.value.name.trim()
    if (!name) {
      ElMessage.warning('请输入项目名称')
      return
    }
    projectSaving.value = true
    try {
      const payload = {
        name,
        description: saveProjectForm.value.description.trim(),
        projectType: 'JULIA_MATLAB' as const,
        projectData: deps.buildProjectData()
      }
      let projectId = currentProject.value?.id
      if (projectId) {
        await modelDeployApi.updateProject(projectId, payload)
      } else {
        const response = await modelDeployApi.saveProject(payload)
        projectId = response.data
      }
      currentProject.value = { id: projectId, name, description: payload.description }
      saveProjectDialogVisible.value = false
      await loadProjectList()
      ElMessage.success('MATLAB项目已保存')
    } catch (error: any) {
      ElMessage.error(`MATLAB项目保存失败：${error.message || '未知错误'}`)
    } finally {
      projectSaving.value = false
    }
  }
  
  const handleDeleteProject = async (project: ModelingProject) => {
    try {
      await ElMessageBox.confirm(
        `确定删除 MATLAB 项目“${project.name}”吗？删除后将不再出现在项目列表中。`,
        '删除项目',
        { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }
      )
      await modelDeployApi.deleteProject(project.id)
      if (currentProject.value?.id === project.id) {
        currentProject.value = null
      }
      await loadProjectList()
      ElMessage.success('项目已删除')
    } catch (error: any) {
      if (error === 'cancel' || error === 'close') return
      ElMessage.error(`MATLAB项目删除失败：${error.message || '未知错误'}`)
    }
  }
  return { projectDialogVisible, saveProjectDialogVisible, projectLoading, projectSaving, projectList, currentProject, saveProjectForm, loadProjectList, handleOpenProjectDialog, handleSaveProject, handleConfirmSaveProject, handleDeleteProject }
}
