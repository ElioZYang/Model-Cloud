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
    // 不设置 Content-Type，让浏览器自动设置（包含 boundary）
    return request.post('/business/model/upload', data)
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
  },
  
  /**
   * 获取标签列表
   */
  getLabelList() {
    return request.get('/business/label/list')
  },
  
  /**
   * 获取模型统计信息
   */
  getStatistics() {
    return request.get('/business/model/statistics')
  }
}

