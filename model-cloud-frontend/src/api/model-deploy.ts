import request from './request'

/**
 * 组件相关接口
 */
export interface Connector {
  name: string
  type: string
}

export interface Component {
  id: number
  name: string
  description?: string
  coverImage?: string
  sourceCode?: string
  fileName?: string
  parameters?: Record<string, any>
  ports?: {
    input: string[]
    output: string[]
    list?: Connector[]
  }
  connectors?: {
    list?: Connector[]
    input?: string[]
    output?: string[]
  }
}

/**
 * 建模项目相关接口
 */
export interface ModelingProject {
  id: number
  userId: number
  name: string
  description?: string
  projectData: string // JSON字符串
  modelicaCode?: string
  createTime: string
  updateTime: string
}

/**
 * 仿真任务相关接口
 */
export interface SimulationTask {
  id: number
  userId: number
  projectId?: number
  taskId: string
  modelCode: string
  simulationParams: string // JSON字符串
  status: 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'
  progress: number
  resultFileUrl?: string
  resultData?: string // JSON字符串
  errorMessage?: string
  startTime?: string
  endTime?: string
  createTime: string
  updateTime: string
}

/**
 * 建模项目请求
 */
export interface ModelingProjectRequest {
  name: string
  description?: string
  projectData: string // JSON字符串
  modelicaCode?: string
}

/**
 * 仿真请求
 */
export interface SimulationRequest {
  projectId?: number
  modelCode?: string
  simulationParams: {
    startTime?: number
    stopTime: number
    stepSize: number
    solver: string
    inputParams?: Record<string, any>
  }
}

export const modelDeployApi = {
  /**
   * 获取组件列表
   */
  getComponents(category?: string, keyword?: string) {
    return request.get<Component[]>('/business/model-deploy/components', {
      params: { category, keyword }
    })
  },

  /**
   * 获取组件详情
   */
  getComponentDetail(componentId: number) {
    return request.get<Component>('/business/model-deploy/components/' + componentId)
  },

  /**
   * 保存建模项目
   */
  saveProject(data: ModelingProjectRequest) {
    return request.post<number>('/business/model-deploy/projects', data)
  },

  /**
   * 更新建模项目
   */
  updateProject(projectId: number, data: ModelingProjectRequest) {
    return request.put('/business/model-deploy/projects/' + projectId, data)
  },

  /**
   * 获取建模项目
   */
  getProject(projectId: number) {
    return request.get<ModelingProject>('/business/model-deploy/projects/' + projectId)
  },

  /**
   * 删除建模项目
   */
  deleteProject(projectId: number) {
    return request.delete('/business/model-deploy/projects/' + projectId)
  },

  /**
   * 获取用户的项目列表
   */
  getUserProjects(pageNum = 1, pageSize = 10) {
    return request.get<{
      records: ModelingProject[]
      total: number
      pageNum: number
      pageSize: number
    }>('/business/model-deploy/projects', {
      params: { pageNum, pageSize }
    })
  },

  /**
   * 提交仿真任务
   */
  submitSimulation(data: SimulationRequest) {
    return request.post<number>('/business/model-deploy/simulation/submit', data)
  },

  /**
   * 查询仿真任务状态
   */
  getSimulationStatus(taskId: number) {
    return request.get<SimulationTask>('/business/model-deploy/simulation/' + taskId + '/status')
  },

  /**
   * 获取用户的仿真任务列表
   */
  getUserSimulationTasks(pageNum = 1, pageSize = 10) {
    return request.get<{
      records: SimulationTask[]
      total: number
      pageNum: number
      pageSize: number
    }>('/business/model-deploy/simulation/tasks', {
      params: { pageNum, pageSize }
    })
  }
}

