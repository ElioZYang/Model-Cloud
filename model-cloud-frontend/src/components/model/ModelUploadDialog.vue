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
      <el-form-item label="是否公开" prop="isPublic">
        <el-radio-group v-model="form.isPublic">
          <el-radio :label="0">不公开</el-radio>
          <el-radio :label="1">公开</el-radio>
        </el-radio-group>
        <el-text type="info" size="small" style="display: block; margin-top: 5px">
          {{ isAdmin ? '' : '普通用户公开模型需要管理员审核后才能展示' }}
        </el-text>
      </el-form-item>
      <el-form-item label="标签" prop="tags">
        <el-select v-model="form.tags" multiple placeholder="请选择相关标签" style="width: 100%">
          <el-option v-for="label in labelList" :key="label.id" :label="label.name" :value="label.name" />
        </el-select>
      </el-form-item>
      <el-form-item label="封面图片" prop="coverImage">
        <el-upload
          class="avatar-uploader"
          action="#"
          :show-file-list="false"
          :auto-upload="false"
          :on-change="handleCoverChange"
        >
          <img v-if="coverPreview" :src="coverPreview" class="avatar" />
          <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
        </el-upload>
      </el-form-item>
      <el-form-item label="模型文件" prop="modelFile">
        <el-upload
          class="upload-demo"
          action="#"
          :auto-upload="false"
          :on-change="handleFileChange"
          :limit="1"
        >
          <template #trigger>
            <el-button type="primary">选择文件</el-button>
          </template>
          <template #tip>
            <div class="el-upload__tip">文件大小不超过 500MB</div>
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
import { ref, watch, computed } from 'vue'
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

const form = ref({
  name: '',
  description: '',
  isPublic: 0,
  tags: [] as string[],
  coverImage: null as File | null,
  modelFile: null as File | null,
})

const rules = {
  name: [{ required: true, message: '请输入模型名称', trigger: 'blur' }],
  description: [{ required: true, message: '请输入模型描述', trigger: 'blur' }],
  modelFile: [{ required: true, message: '请上传模型文件', trigger: 'change' }],
}

const fetchLabelsIfNeeded = async () => {
  if (labelList.value.length > 0) return
  try {
    const res: any = await modelApi.getLabelList()
    if (res.code === 200) {
      labelList.value = res.data || []
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

const handleCoverChange = (file: UploadFile) => {
  if (file.raw) {
    form.value.coverImage = file.raw
    coverPreview.value = URL.createObjectURL(file.raw)
  }
}

const handleFileChange = (file: UploadFile) => {
  if (file.raw) {
    form.value.modelFile = file.raw
  }
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
    isPublic: 0,
    tags: [],
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


