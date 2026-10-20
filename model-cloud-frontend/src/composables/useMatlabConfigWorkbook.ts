import { ref, type ComputedRef, type Ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as XLSX from 'xlsx'
import { matlabModelDeployApi, type MatlabConfigRecord, type MatlabConfigSchema } from '@/api/matlab-model-deploy'
import type { Node } from '@vue-flow/core'

type Dependencies = { selectedNode: ComputedRef<Node | null>; nodes: Ref<Node[]>; resetResultData: () => void; selectedConfigRecord: () => MatlabConfigRecord | null }

export function useMatlabConfigWorkbook(deps: Dependencies) {
  const configSchema = ref<MatlabConfigSchema | null>(null)
  const configFileInput = ref<HTMLInputElement>()
  
  const configPreviewVisible = ref(false)
  
  const configUploading = ref(false)
  
  const pendingConfigFile = ref<File | null>(null)
  
  const configPreviewRows = ref<Array<Record<string, any>>>([])
  
  const configPreviewMaterialCount = ref(0)
  
  const configPreviewOptimizationCount = ref(0)
  
  const configPreviewWarnings = ref<string[]>([])
  
  const handleDownloadConfigTemplate = async () => {
    try {
      const blob = await matlabModelDeployApi.downloadConfigTemplate(deps.selectedNode.value?.data?.componentId)
      const url = URL.createObjectURL(blob)
      const anchor = document.createElement('a')
      anchor.href = url
      anchor.download = 'PMSM电机配置模板.xlsx'
      anchor.click()
      URL.revokeObjectURL(url)
    } catch (error: any) {
      ElMessage.error(error.message || '配置模板下载失败')
    }
  }
  
  const formatFileSize = (size: number) => size < 1024
    ? `${size} B` : `${(size / 1024).toFixed(1)} KB`
  
  const openConfigFilePicker = () => configFileInput.value?.click()
  
  const requireWorkbookColumns = (
    rows: Array<Record<string, any>>,
    columns: string[],
    sheetName: string
  ) => {
    if (rows.length === 0) throw new Error(`${sheetName}工作表不能为空`)
    const actual = new Set(Object.keys(rows[0]))
    const missing = columns.filter((column) => !actual.has(column))
    if (missing.length) throw new Error(`${sheetName}工作表缺少列：${missing.join(', ')}`)
  }
  
  const parseConfigWorkbook = async (file: File) => {
    const response = await matlabModelDeployApi.getConfigSchema(deps.selectedNode.value?.data?.componentId)
    const schema = response.data
    configSchema.value = schema
    if (!schema) throw new Error('配置规范尚未加载')
    if (!file.name.toLowerCase().endsWith('.xlsx')) throw new Error('请选择.xlsx文件')
    if (file.size > 10 * 1024 * 1024) throw new Error('配置文件不能超过10MB')
    const workbook = XLSX.read(await file.arrayBuffer(), { type: 'array' })
    if (!workbook.SheetNames.includes(schema.designSheet)) {
      throw new Error(`缺少${schema.designSheet}工作表`)
    }
    if (!workbook.SheetNames.includes(schema.materialSheet)) {
      throw new Error(`缺少${schema.materialSheet}工作表`)
    }
    const designRows = XLSX.utils.sheet_to_json<Record<string, any>>(
      workbook.Sheets[schema.designSheet], { defval: null }
    ).filter((row) => String(row.variables ?? '').trim())
    const materialRows = XLSX.utils.sheet_to_json<Record<string, any>>(
      workbook.Sheets[schema.materialSheet], { defval: null }
    ).filter((row) => String(row.material ?? '').trim())
    requireWorkbookColumns(designRows, schema.designColumns, schema.designSheet)
    requireWorkbookColumns(materialRows, schema.materialColumns, schema.materialSheet)
    const names = designRows.map((row) => String(row.variables).trim())
    if (new Set(names).size !== names.length) throw new Error('设计变量名不能重复')
    const missingVariables = schema.requiredVariables.filter((name) => !names.includes(name))
    if (missingVariables.length) throw new Error(`缺少必要变量：${missingVariables.join(', ')}`)
    const warnings: string[] = []
    designRows.forEach((row) => {
      const name = String(row.variables).trim()
      const value = Number(row.value)
      const opt = Number(row.opt)
      if (!Number.isFinite(value)) throw new Error(`${name}.value必须是有限数值`)
      if (opt !== 0 && opt !== 1) throw new Error(`${name}.opt必须为0或1`)
      if (opt === 1) {
        const min = Number(row.min)
        const max = Number(row.max)
        if (!Number.isFinite(min) || !Number.isFinite(max) || min > max) {
          throw new Error(`${name}的优化范围无效`)
        }
        if (value < min || value > max) warnings.push(`${name}默认值不在优化范围内`)
      }
    })
    return {
      designRows,
      materialCount: materialRows.length,
      optimizationCount: designRows.filter((row) => Number(row.opt) === 1).length,
      warnings
    }
  }
  
  const handleConfigFileSelected = async (event: Event) => {
    const input = event.target as HTMLInputElement
    const file = input.files?.[0]
    input.value = ''
    if (!file) return
    try {
      const preview = await parseConfigWorkbook(file)
      pendingConfigFile.value = file
      configPreviewRows.value = preview.designRows
      configPreviewMaterialCount.value = preview.materialCount
      configPreviewOptimizationCount.value = preview.optimizationCount
      configPreviewWarnings.value = preview.warnings
      configPreviewVisible.value = true
    } catch (error: any) {
      ElMessage.error(error.message || 'Excel配置解析失败')
    }
  }
  
  const cancelConfigPreview = () => {
    configPreviewVisible.value = false
    pendingConfigFile.value = null
    configPreviewRows.value = []
    configPreviewOptimizationCount.value = 0
    configPreviewWarnings.value = []
  }
  
  const updateSelectedConfig = (record: MatlabConfigRecord | null) => {
    if (!deps.selectedNode.value) return
    const selectedId = deps.selectedNode.value.id
    deps.nodes.value = deps.nodes.value.map((node) => node.id === selectedId
      ? {
          ...node,
          data: {
            ...node.data,
            resources: record ? { motorConfigId: record.configId } : {},
            motorConfig: record
          }
        }
      : node)
    deps.resetResultData()
  }
  
  const confirmConfigUpload = async () => {
    if (!pendingConfigFile.value || !deps.selectedNode.value) return
    configUploading.value = true
    try {
      const displayName = pendingConfigFile.value.name.replace(/\.xlsx$/i, '')
      const response = await matlabModelDeployApi.uploadConfig(
        pendingConfigFile.value, displayName, deps.selectedNode.value.data?.componentId)
      updateSelectedConfig(response.data)
      configPreviewVisible.value = false
      pendingConfigFile.value = null
      configPreviewRows.value = []
      configPreviewOptimizationCount.value = 0
      configPreviewWarnings.value = []
      ElMessage.success('电机配置已保存并绑定到当前节点')
    } catch (error: any) {
      ElMessage.error(error.message || '电机配置上传失败')
    } finally {
      configUploading.value = false
    }
  }
  
  const handleRestoreDefaultConfig = () => {
    updateSelectedConfig(null)
    ElMessage.success('已恢复系统默认PMSM配置')
  }
  
  const handleViewCurrentConfig = () => {
    const config = deps.selectedConfigRecord()
    if (!config) return
    ElMessageBox.alert(
      `配置名称：${config.name}\n文件名：${config.fileName}\n模板版本：${config.templateVersion}`
        + `\n参数数量：${config.summary?.designParameterCount ?? '-'}\n优化参数：${config.summary?.optimizationParameterCount ?? '-'}`
        + `\n材料数量：${config.summary?.materialCount ?? '-'}\nSHA-256：${config.sha256}`,
      '当前电机配置',
      { confirmButtonText: '关闭' }
    )
  }
  return { configSchema, configFileInput, configPreviewVisible, configUploading, pendingConfigFile, configPreviewRows, configPreviewMaterialCount, configPreviewOptimizationCount, configPreviewWarnings, handleDownloadConfigTemplate, formatFileSize, openConfigFilePicker, handleConfigFileSelected, cancelConfigPreview, confirmConfigUpload, handleRestoreDefaultConfig, handleViewCurrentConfig }
}
