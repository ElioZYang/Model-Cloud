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
   * 获取标签分类列表
   */
  getCategoryList() {
    return request.get('/business/label/category/list')
  },
  
  /**
   * 获取模型统计信息
   */
  getStatistics() {
    return request.get('/business/model/statistics')
  },
  
  /**
   * 收藏模型
   */
  collectModel(modelId: number) {
    return request.post(`/business/collect/${modelId}`)
  },
  
  /**
   * 取消收藏
   */
  uncollectModel(modelId: number) {
    return request.delete(`/business/collect/${modelId}`)
  },
  
  /**
   * 检查是否已收藏
   */
  checkCollected(modelId: number) {
    return request.get(`/business/collect/check/${modelId}`)
  },
  
  /**
   * 获取我的收藏列表
   */
  getMyCollects(params: any) {
    return request.get('/business/collect/list', { params })
  },

  /**
   * 获取我的模型列表
   */
  getMyModels(params: any) {
    return request.get('/business/model/my', { params })
  },

  /**
   * 更新模型公开状态
   */
  updateModelPublic(id: number, isPublic: number) {
    return request.put(`/business/model/${id}/public`, { isPublic })
  },

  /**
   * 获取待审核模型列表（管理员）
   */
  getPendingModels(params: any) {
    return request.get('/business/model/pending', { params })
  },

  /**
   * 审核模型（管理员）
   */
  auditModel(id: number, approved: boolean) {
    return request.post(`/business/model/${id}/audit`, { approved })
  },

  /**
   * 获取我的最近活动
   */
  getMyActivities(limit = 10) {
    return request.get('/business/model/my-activities', { params: { limit } })
  },

  /**
   * 更新模型封面图片
   */
  updateModelCover(id: number, coverImage: File) {
    const formData = new FormData()
    formData.append('coverImage', coverImage)
    return request.put(`/business/model/${id}/cover`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  /**
   * 更新模型描述
   */
  updateModelDescription(id: number, description: string) {
    return request.put(`/business/model/${id}/description`, { description })
  },

  /**
   * 获取模型源码
   */
  getModelSourceCode(id: number) {
    return request.get(`/business/model/${id}/source`)
  },

  /**
   * 更新模型源码
   */
  updateModelSourceCode(id: number, sourceCode: string, fileName: string) {
    return request.put(`/business/model/${id}/source`, { sourceCode, fileName })
  }
}

