import { modelApi } from '@/api/model'

/**
 * 刷新首页统计数据，并写入 sessionStorage，供首页恢复使用
 */
export const refreshHomeStats = async () => {
  try {
    const res: any = await modelApi.getStatistics()
    if (res.code === 200) {
      sessionStorage.setItem('modelStats', JSON.stringify(res.data || {}))
    }
  } catch (error) {
    console.error('更新首页统计信息失败', error)
  }
}


