<template>
  <el-dialog
    v-model="visibleInner"
    :title="title"
    width="600px"
    @close="resetForm"
    destroy-on-close
  >
    <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
      <el-form-item label="模型名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入模型名称" />
      </el-form-item>
      <el-form-item label="描述" prop="description">
        <el-input v-model="form.description" type="textarea" placeholder="请输入模型描述" :rows="3" />
      </el-form-item>
      <el-form-item label="共享协议" prop="license">
        <el-select v-model="form.license" placeholder="请选择共享协议" style="width: 100%">
          <el-option label="MulanPSL v2" value="MulanPSL v2" />
          <el-option label="Apache 2.0" value="Apache 2.0" />
          <el-option label="MIT许可证" value="MIT许可证" />
          <el-option label="GPL" value="GPL" />
          <el-option label="BSD许可证" value="BSD许可证" />
        </el-select>
      </el-form-item>
      <el-form-item label="模型格式" prop="format">
        <el-select v-model="form.format" placeholder="请选择模型格式" style="width: 100%">
          <el-option v-for="label in formatList" :key="label.id" :label="label.name" :value="label.name" />
        </el-select>
      </el-form-item>
      <el-form-item label="模型标签" prop="tags">
        <el-select v-model="form.tags" multiple placeholder="请选择相关标签" style="width: 100%">
          <el-option v-for="label in modelLabelList" :key="label.id" :label="label.displayName" :value="label.name" />
        </el-select>
      </el-form-item>
      <el-form-item label="是否公开" prop="isPublic">
        <el-radio-group v-model="form.isPublic">
          <el-radio :label="0">不公开</el-radio>
          <el-radio :label="1">公开</el-radio>
        </el-radio-group>
        <el-text type="info" size="small" style="display: block; margin-top: 5px">
          {{ isAdmin ? '' : '普通用户公开模型需要管理员审核后才能展示' }}
        </el-text>
      </el-form-item>
      <el-form-item label="封面图片" prop="coverImage">
        <el-upload
          class="avatar-uploader"
          action="#"
          :show-file-list="false"
          :auto-upload="false"
          :on-change="handleCoverChange"
          :accept="imageAccept"
          :before-upload="beforeCoverUpload"
        >
          <img v-if="coverPreview" :src="coverPreview" class="avatar" />
          <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
        </el-upload>
        <div class="el-upload__tip" style="margin-top: 5px; color: #909399; font-size: 12px">
          仅支持图片格式：PNG、JPG、JPEG、GIF、BMP、WEBP
        </div>
      </el-form-item>
      <el-form-item label="模型文件" prop="modelFile">
        <el-upload
          ref="modelFileUploadRef"
          class="upload-demo"
          action="#"
          :auto-upload="false"
          :on-change="handleFileChange"
          :on-remove="handleFileRemove"
          :limit="1"
          :accept="modelFileAccept"
          :before-upload="beforeModelFileUpload"
        >
          <template #trigger>
            <el-button type="primary">选择文件</el-button>
          </template>
          <template #tip>
            <div class="el-upload__tip">
              <div>文件大小不超过 500MB</div>
              <div v-if="form.format" style="margin-top: 5px">
              
              </div>
              <div v-else style="margin-top: 5px; color: #f56c6c">
                请先选择模型格式
              </div>
            </div>
          </template>
        </el-upload>
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="visibleInner = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="submitForm">确定</el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch, computed, nextTick } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, type FormInstance, type UploadFile } from 'element-plus'
import { modelApi } from '@/api/model'
import { useUserStore } from '@/stores/user'
import { refreshHomeStats } from '@/utils/stats'

const props = defineProps<{
  modelValue: boolean
  title?: string
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
  (e: 'success'): void
}>()

const userStore = useUserStore()
const isAdmin = computed(() => userStore.isAdmin || userStore.isSuperAdmin)

const visibleInner = computed({
  get: () => props.modelValue,
  set: (val: boolean) => emit('update:modelValue', val),
})

const formRef = ref<FormInstance>()
const submitLoading = ref(false)
const coverPreview = ref('')
const labelList = ref<any[]>([])
const categoryList = ref<any[]>([])
const modelFileUploadRef = ref()

const form = ref({
  name: '',
  description: '',
  license: '',
  format: '',
  tags: [] as string[],
  isPublic: 0,
  coverImage: null as File | null,
  modelFile: null as File | null,
})

const rules = {
  name: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  description: [{ required: true, message: '请输入模型描述', trigger: 'blur' }],
  format: [{ required: true, message: '请选择模型格式', trigger: 'change' }],
  modelFile: [{ required: true, message: '请上传模型文件', trigger: 'change' }],
}

// 图片文件类型限制
const imageAccept = 'image/png,image/jpeg,image/jpg,image/gif,image/bmp,image/webp'

// 模型格式到文件扩展名的映射
// 注意：格式名称需要与数据库中 bs_model_label 表的 name 字段完全匹配（区分大小写）
const formatExtensions: Record<string, string[]> = {
  'FMU': ['.fmu'],
  'M': ['.m'],
  'MO': ['.mo'],
  'INP': ['.inp'],
}

// 获取模型格式对应的文件扩展名
const getFormatExtensions = (format: string): string => {
  if (!format) return ''
  const extensions = formatExtensions[format] || []
  if (extensions.length === 0) {
    // 如果映射中没有找到，尝试根据格式名称自动生成（小写转大写）
    const upperFormat = format.toUpperCase()
    if (formatExtensions[upperFormat]) {
      return formatExtensions[upperFormat].join('、').toUpperCase()
    }
  }
  return extensions.join('、').toUpperCase()
}

// 模型格式列表（classify_id = 2）
const formatList = computed(() => {
  return labelList.value.filter((label: any) => label.categoryId === 2)
})

// 根据选择的模型格式动态生成 accept 属性
const modelFileAccept = computed(() => {
  if (!form.value.format) return ''
  let extensions = formatExtensions[form.value.format] || []
  if (extensions.length === 0) {
    // 尝试大写格式匹配
    const upperFormat = form.value.format.toUpperCase()
    extensions = formatExtensions[upperFormat] || []
  }
  // accept 属性支持 .ext 格式
  return extensions.join(',')
})

// 模型标签列表（classify_id != 2，按分类sort排序，显示格式：分类名:标签名）
const modelLabelList = computed(() => {
  const labels = labelList.value.filter((label: any) => label.categoryId !== 2)
  // 按分类的sort排序
  labels.sort((a: any, b: any) => {
    const categoryA = categoryList.value.find((cat: any) => cat.id === a.categoryId)
    const categoryB = categoryList.value.find((cat: any) => cat.id === b.categoryId)
    const sortA = categoryA?.sort || 0
    const sortB = categoryB?.sort || 0
    if (sortA !== sortB) {
      return sortA - sortB
    }
    return a.id - b.id
  })
  // 添加显示名称
  return labels.map((label: any) => {
    const category = categoryList.value.find((cat: any) => cat.id === label.categoryId)
    return {
      ...label,
      displayName: category ? `${category.name}:${label.name}` : label.name
    }
  })
})

const fetchLabelsIfNeeded = async () => {
  if (labelList.value.length > 0 && categoryList.value.length > 0) return
  try {
    const res: any = await modelApi.getLabelList()
    if (res.code === 200) {
      labelList.value = res.data || []
    }
    // 获取分类列表
    const categoryRes: any = await modelApi.getCategoryList()
    if (categoryRes.code === 200) {
      categoryList.value = categoryRes.data || []
    }
  } catch (error) {
    console.error('获取标签列表失败', error)
  }
}

watch(
  () => visibleInner.value,
  (val) => {
    if (val) {
      fetchLabelsIfNeeded()
    }
  }
)

// 监听模型格式变化，如果已选择的文件不匹配则清空
watch(
  () => form.value.format,
  (newFormat) => {
    if (form.value.modelFile && newFormat) {
      const extensions = formatExtensions[newFormat] || []
      const fileName = form.value.modelFile.name.toLowerCase()
      const isValidExtension = extensions.some(ext => fileName.endsWith(ext.toLowerCase()))
      
      if (!isValidExtension) {
        form.value.modelFile = null
        ElMessage.warning('模型格式已更改，请重新选择匹配的模型文件')
      }
    } else if (form.value.modelFile && !newFormat) {
      // 如果格式被清空，也清空文件
      form.value.modelFile = null
    }
  }
)

// 封面图片上传前的验证
const beforeCoverUpload = (file: File) => {
  const isImage = file.type.startsWith('image/')
  const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/bmp', 'image/webp']
  const isValidType = validTypes.includes(file.type.toLowerCase())
  
  if (!isImage || !isValidType) {
    ElMessage.error('封面图片仅支持 PNG、JPG、JPEG、GIF、BMP、WEBP 格式')
    return false
  }
  return true
}

const handleCoverChange = (file: UploadFile) => {
  if (file.raw) {
    if (beforeCoverUpload(file.raw)) {
      form.value.coverImage = file.raw
      coverPreview.value = URL.createObjectURL(file.raw)
    } else {
      // 验证失败，清空文件
      form.value.coverImage = null
      coverPreview.value = ''
    }
  }
}

// 模型文件上传前的验证
const beforeModelFileUpload = (file: File) => {
  if (!form.value.format) {
    ElMessage.error('请先选择模型格式')
    return false
  }
  
  const extensions = formatExtensions[form.value.format] || []
  if (extensions.length === 0) {
    ElMessage.error('该模型格式暂不支持文件上传')
    return false
  }
  
  const fileName = file.name.toLowerCase()
  const isValidExtension = extensions.some(ext => fileName.endsWith(ext.toLowerCase()))
  
  if (!isValidExtension) {
    ElMessage.error(`模型格式为 ${form.value.format}，仅支持 ${getFormatExtensions(form.value.format)} 格式的文件`)
    return false
  }
  return true
}

const handleFileChange = (file: UploadFile) => {
  if (file.raw) {
    // 严格验证文件格式
    if (!form.value.format) {
      ElMessage.error('请先选择模型格式')
      // 立即移除文件
      nextTick(() => {
        if (modelFileUploadRef.value) {
          modelFileUploadRef.value.clearFiles()
        }
      })
      form.value.modelFile = null
      return
    }
    
    // 获取格式对应的扩展名，支持大小写不敏感匹配
    let extensions = formatExtensions[form.value.format] || []
    if (extensions.length === 0) {
      // 尝试大写格式匹配
      const upperFormat = form.value.format.toUpperCase()
      extensions = formatExtensions[upperFormat] || []
    }
    
    if (extensions.length === 0) {
      ElMessage.error(`模型格式"${form.value.format}"暂不支持文件上传，请联系管理员添加该格式的文件扩展名映射`)
      nextTick(() => {
        if (modelFileUploadRef.value) {
          modelFileUploadRef.value.clearFiles()
        }
      })
      form.value.modelFile = null
      return
    }
    
    const fileName = file.raw.name.toLowerCase()
    const isValidExtension = extensions.some(ext => fileName.endsWith(ext.toLowerCase()))
    
    if (!isValidExtension) {
      ElMessage.error(`模型格式为 ${form.value.format}，仅支持 ${getFormatExtensions(form.value.format)} 格式的文件`)
      // 立即移除不匹配的文件
      nextTick(() => {
        if (modelFileUploadRef.value) {
          modelFileUploadRef.value.clearFiles()
        }
      })
      form.value.modelFile = null
      return
    }
    
    // 验证通过，保存文件
    form.value.modelFile = file.raw
  }
}

const handleFileRemove = () => {
  form.value.modelFile = null
}

const submitForm = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        const formData = new FormData()
        formData.append('name', form.value.name)
        formData.append('description', form.value.description)
        formData.append('isPublic', form.value.isPublic.toString())
        if (form.value.license) {
          formData.append('license', form.value.license)
        }
        if (form.value.format) {
          formData.append('format', form.value.format)
        }
        form.value.tags.forEach((tag) => formData.append('tags', tag))
        if (form.value.coverImage) {
          formData.append('coverImage', form.value.coverImage)
        }
        if (form.value.modelFile) {
          formData.append('modelFile', form.value.modelFile)
        }

        const res: any = await modelApi.createModel(formData)
        if (res.code === 200) {
          ElMessage.success('上传成功')
          await refreshHomeStats()
          visibleInner.value = false
          emit('success')
        } else {
          ElMessage.error(res.message || '上传失败')
        }
      } catch (error) {
        console.error('上传失败', error)
        ElMessage.error('上传失败')
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const resetForm = () => {
  form.value = {
    name: '',
    description: '',
    license: '',
    format: '',
    tags: [],
    isPublic: 0,
    coverImage: null,
    modelFile: null,
  }
  coverPreview.value = ''
  formRef.value?.resetFields()
}

const title = computed(() => props.title || '上传模型')
</script>

<style scoped>
.avatar-uploader .avatar {
  width: 178px;
  height: 178px;
  display: block;
  object-fit: cover;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  line-height: 178px;
}
</style>


