import request from './request'

/**
 * 模型相关API
 */
export const modelApi = {
  /**
   * 获取模型列表
   */
  getModelList(params: any) {
    return request.get('/business/model/list', { params })
  },
  
  /**
   * 获取模型详情
   */
  getModelDetail(id: number) {
    return request.get(`/business/model/${id}`)
  },
  
  /**
   * 新增模型
   */
  createModel(data: any) {
    return request.post('/business/model', data)
  },
  
  /**
   * 更新模型
   */
  updateModel(id: number, data: any) {
    return request.put(`/business/model/${id}`, data)
  },
  
  /**
   * 删除模型
   */
  deleteModel(id: number) {
    return request.delete(`/business/model/${id}`)
  }
}



