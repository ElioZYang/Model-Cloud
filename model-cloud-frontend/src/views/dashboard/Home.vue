<template>
  <div class="home-container">
    <el-card class="welcome-card">
      <template #header>
        <div class="card-header">
          <span>欢迎使用模型管理系统</span>
        </div>
      </template>
      <div class="welcome-content">
        <el-icon class="welcome-icon"><User /></el-icon>
        <h2>您好，{{ userStore.nickname }}！</h2>
        <p class="welcome-text">欢迎来到模型管理系统，您可以在这里管理您的模型资源。</p>
      </div>
    </el-card>
    
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #409eff;">
              <el-icon><Box /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">0</div>
              <div class="stat-label">模型总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #67c23a;">
              <el-icon><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">0</div>
              <div class="stat-label">我的收藏</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #e6a23c;">
              <el-icon><Upload /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">0</div>
              <div class="stat-label">已上传</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #f56c6c;">
              <el-icon><View /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">0</div>
              <div class="stat-label">浏览量</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" class="quick-actions-row">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>快速操作</span>
          </template>
          <div class="quick-actions">
            <el-button type="primary" :icon="Plus">上传模型</el-button>
            <el-button type="success" :icon="Search">搜索模型</el-button>
            <el-button type="info" :icon="Setting">系统设置</el-button>
          </div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>最近活动</span>
          </template>
          <el-empty description="暂无活动记录" :image-size="80" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { User, Box, Star, Upload, View, Plus, Search, Setting } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
</script>

<style scoped>
.home-container {
  padding: 0;
}

.welcome-card {
  margin-bottom: 20px;
}

.card-header {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.welcome-content {
  text-align: center;
  padding: 40px 20px;
}

.welcome-icon {
  font-size: 64px;
  color: #409eff;
  margin-bottom: 20px;
}

.welcome-content h2 {
  margin: 20px 0 10px 0;
  color: #303133;
  font-size: 24px;
}

.welcome-text {
  color: #909399;
  font-size: 14px;
  margin: 0;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 28px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.quick-actions-row {
  margin-bottom: 20px;
}

.quick-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}
</style>


