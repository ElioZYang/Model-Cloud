<template>
  <div class="component-manage-container">
    <el-card class="filter-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="搜索名称/描述/类名"
            clearable
            @keyup.enter="reloadList"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="reloadList">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
          <el-button type="success" @click="showUploadDialog = true">上传组件</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <div class="toolbar">
        <el-button
          type="primary"
          :disabled="selectedComponentIds.length === 0"
          :loading="generatingIcons"
          @click="handleBatchGenerateIcons"
        >
          批量生成图标（{{ selectedComponentIds.length }}）
        </el-button>
      </div>
      <el-table :data="componentRows" stripe style="width: 100%" @selection-change="handleComponentSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="ID" width="90" />
        <el-table-column prop="name" label="名称" min-width="180" />
        <el-table-column prop="className" label="类名" min-width="280" />
        <el-table-column prop="indexPath" label="索引位置" min-width="260" />
        <el-table-column prop="description" label="描述" min-width="220" />
      </el-table>
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="reloadList"
          @current-change="reloadList"
        />
      </div>
    </el-card>

    <el-dialog v-model="showUploadDialog" title="上传基础组件" width="560px" @close="resetUploadForm">
      <el-form ref="uploadFormRef" :model="uploadForm" :rules="uploadRules" label-width="110px">
        <el-form-item label="组件名称" prop="name">
          <el-input v-model="uploadForm.name" placeholder="例如 Resistor" />
        </el-form-item>
        <el-form-item label="组件描述" prop="description">
          <el-input v-model="uploadForm.description" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="本地库路径" prop="localPath">
          <el-input
            v-model="uploadForm.localPath"
            placeholder="例如 D:/Modelica/Modelica/Electrical/Analog/Basic/Resistor.mo"
          />
        </el-form-item>
        <el-form-item label="源码文件" prop="sourceFile">
          <el-upload
            :auto-upload="false"
            :show-file-list="true"
            :limit="1"
            accept=".mo"
            :on-change="handleSourceFileChange"
            :on-remove="() => { uploadForm.sourceFile = null }"
          >
            <el-button type="primary">选择.mo文件</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item label="图标文件(可选)">
          <el-upload
            :auto-upload="false"
            :show-file-list="true"
            :limit="1"
            accept="image/png,image/jpeg,image/jpg,image/gif,image/bmp,image/webp,image/svg+xml"
            :on-change="handleIconFileChange"
            :on-remove="() => { uploadForm.iconFile = null }"
          >
            <el-button>选择图标</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showUploadDialog = false">取消</el-button>
        <el-button type="primary" :loading="uploading" @click="handleUploadComponent">上传</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, type FormInstance, type UploadFile } from 'element-plus'
import { modelApi } from '@/api/model'
const generatingIcons = ref(false)
const total = ref(0)
const componentRows = ref<any[]>([])
const selectedComponentIds = ref<number[]>([])
const showUploadDialog = ref(false)
const uploading = ref(false)
const uploadFormRef = ref<FormInstance>()
const uploadForm = reactive({
  name: '',
  description: '',
  localPath: '',
  sourceFile: null as File | null,
  iconFile: null as File | null
})
const uploadRules = {
  name: [{ required: true, message: '请输入组件名称', trigger: 'blur' }],
  localPath: [{ required: true, message: '请输入本地路径', trigger: 'blur' }],
  sourceFile: [{ required: true, message: '请上传源码文件', trigger: 'change' }]
}

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  keyword: ''
})

const reloadList = async () => {
  try {
    const res: any = await modelApi.getComponentList({
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      keyword: queryParams.keyword
    })
    if (res.code !== 200) {
      throw new Error(res.message || '加载失败')
    }
    total.value = res.data?.totalRow || 0
    componentRows.value = res.data?.records || []
  } catch (error: any) {
    ElMessage.error(error.message || '加载失败')
  }
}

const resetQuery = async () => {
  queryParams.keyword = ''
  queryParams.pageNum = 1
  await reloadList()
}

const handleComponentSelectionChange = (rows: any[]) => {
  selectedComponentIds.value = rows.map((r) => Number(r.id))
}

const handleBatchGenerateIcons = async () => {
  if (selectedComponentIds.value.length === 0) {
    ElMessage.warning('请先选择至少一个组件')
    return
  }
  generatingIcons.value = true
  try {
    const res: any = await modelApi.batchGenerateIcons(selectedComponentIds.value)
    if (res.code !== 200) {
      ElMessage.error(res.message || '生成图标失败')
      return
    }
    const data = res.data || {}
    const success = Object.values(data).filter((v) => String(v || '').length > 0).length
    const fail = selectedComponentIds.value.length - success
    ElMessage.success(`图标生成完成：成功 ${success}，失败 ${fail}`)
    await reloadList()
  } catch (error: any) {
    ElMessage.error(error.message || '生成图标失败')
  } finally {
    generatingIcons.value = false
  }
}

const handleSourceFileChange = (file: UploadFile) => {
  uploadForm.sourceFile = file.raw || null
}

const handleIconFileChange = (file: UploadFile) => {
  uploadForm.iconFile = file.raw || null
}

const resetUploadForm = () => {
  uploadForm.name = ''
  uploadForm.description = ''
  uploadForm.localPath = ''
  uploadForm.sourceFile = null
  uploadForm.iconFile = null
}

const handleUploadComponent = async () => {
  if (!uploadFormRef.value) return
  await uploadFormRef.value.validate(async (valid) => {
    if (!valid) return
    uploading.value = true
    try {
      const formData = new FormData()
      formData.append('name', uploadForm.name)
      formData.append('description', uploadForm.description || '')
      formData.append('localPath', uploadForm.localPath)
      if (uploadForm.sourceFile) {
        formData.append('sourceFile', uploadForm.sourceFile)
      }
      if (uploadForm.iconFile) {
        formData.append('iconFile', uploadForm.iconFile)
      }
      const res: any = await modelApi.createComponent(formData)
      if (res.code === 200) {
        ElMessage.success('组件上传成功')
        showUploadDialog.value = false
        resetUploadForm()
        queryParams.pageNum = 1
        await reloadList()
      } else {
        ElMessage.error(res.message || '组件上传失败')
      }
    } catch (error: any) {
      ElMessage.error(error.message || '组件上传失败')
    } finally {
      uploading.value = false
    }
  })
}

onMounted(async () => {
  await reloadList()
})
</script>

<style scoped>
.component-manage-container {
  padding: 0;
}

.filter-card {
  margin-bottom: 16px;
}

.toolbar {
  margin-bottom: 12px;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}
</style>
