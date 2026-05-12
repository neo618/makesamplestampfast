<template>
  <!-- 导出格式弹窗 -->
  <div v-if="showFormatDialog" class="legal-dialog-overlay" @click.self="closeFormatDialog">
    <div class="legal-dialog">
      <h3>{{ t('stamp.exportFormat.title') }}</h3>
      <div class="legal-content">
        <p>{{ t('stamp.exportFormat.description') }}</p>
        <div class="format-options">
          <button
            v-for="format in exportFormats"
            :key="format.value"
            type="button"
            class="format-button"
            :class="{ active: selectedFormat === format.value }"
            @click="selectedFormat = format.value"
          >
            <span class="format-icon">{{ format.icon }}</span>
            <span class="format-name">{{ format.name }}</span>
            <span class="format-desc">{{ format.desc }}</span>
          </button>
        </div>
        <div v-if="selectedFormat === 'jpeg'" class="quality-setting">
          <label>{{ t('stamp.exportFormat.quality') }}: {{ jpegQuality }}%</label>
          <input
            type="range"
            v-model.number="jpegQuality"
            min="10"
            max="100"
            step="5"
            class="quality-slider"
          />
        </div>
        <div class="aging-options-section">
          <label class="checkbox-label">
            <input
              type="checkbox"
              v-model="exportMultipleAging"
            />
            {{ t('stamp.exportFormat.exportMultipleAging') }}
          </label>
          <div v-if="exportMultipleAging" class="aging-levels-info">
          <span class="aging-level-tag">10% - {{ t('stamp.exportFormat.noAging') }}</span>
          <span class="aging-level-tag">20% - {{ t('stamp.exportFormat.lightAging') }}</span>
          <span class="aging-level-tag">30% - {{ t('stamp.exportFormat.mediumAging') }}</span>
          <span class="aging-level-tag">40% - {{ t('stamp.exportFormat.heavyAging') }}</span>
        </div>
        </div>
        <div class="qr-code-section">
          <div class="qr-code-title">{{ t('stamp.exportFormat.qrCodeTitle') }}</div>
          <div class="qr-code-placeholder">
            <img src="/pay_qr.png" alt="付款码" class="qr-code-img" />
          </div>
          <p class="qr-hint">{{ t('stamp.exportFormat.qrHint') }}</p>
        </div>
      </div>
      <div class="dialog-buttons">
        <button @click="closeFormatDialog" class="cancel-button">{{ t('stamp.exportFormat.cancel') }}</button>
        <button v-if="!hasPaid" @click="confirmPayment" class="confirm-button">导出</button>
        <button v-else @click="confirmExport" class="confirm-button">{{ t('stamp.exportFormat.export') }}</button>
      </div>
    </div>
  </div>

  <!-- 导出模板元信息弹窗 -->
  <div v-if="showTemplateMetaDialog" class="legal-dialog-overlay" @click.self="closeTemplateMetaDialog">
    <div class="legal-dialog">
      <h3>{{ t('homepage.canvas.exportTemplate') }}</h3>
      <div class="legal-content">
        <div class="meta-field">
          <label>{{ t('stamp.templateMeta.titlePrompt') }}</label>
          <input
            v-model="templateTitle"
            type="text"
            class="meta-input"
            :placeholder="t('stamp.templateMeta.titlePrompt')"
          />
        </div>
        <div class="meta-field">
          <label>{{ t('stamp.templateMeta.categoryPrompt') }}</label>
          <input
            v-model="templateCategories"
            type="text"
            class="meta-input"
            :placeholder="t('stamp.templateMeta.categoryPrompt')"
          />
        </div>
      </div>
      <div class="dialog-buttons">
        <button @click="closeTemplateMetaDialog" class="cancel-button">
          {{ t('stamp.exportFormat.cancel') }}
        </button>
        <button @click="confirmSaveTemplate" class="confirm-button">
          {{ t('stamp.exportFormat.export') }}
        </button>
      </div>
    </div>
  </div>

  <!-- 主内容区域：三栏布局（可复用） -->
  <div class="main-workspace">
    <!-- 顶部标题栏 -->
    <div class="app-title-bar">
      <h1 class="app-title">简易快速制图助手</h1>
      <p class="operation-steps">操作步骤：1. 选择模板 → 2. 点击左侧【参数选择】 → 3. 在【参数设置】下输入名称、调整参数 → 4. 导出图片</p>
    </div>

    <div class="stamp-draw-container">
      <div class="left-panels">
        <!-- 左侧：元素列表 -->
        <ElementList
          v-if="isDrawStampUtilsReady"
          ref="elementListRef"
          :drawStampUtils="drawStampUtils"
          @selectElement="handleSelectElement"
          @update-config="handleElementListUpdate"
          @refresh="handleElementListRefresh"
        />
        <div v-else class="side-panel-loading">
          <div class="loading-spinner"></div>
          <span>{{ t('common.loading') }}</span>
        </div>

        <!-- 属性编辑器 -->
        <PropertiesPanel
          v-if="isDrawStampUtilsReady"
          ref="propertiesPanelRef"
          :drawStampUtils="drawStampUtils"
          :selectedElement="selectedElement"
          :elementType="selectedElementType"
          :elementIndex="selectedElementIndex"
          @updateDrawStamp="updateDrawStamp"
        />
        <div v-else class="side-panel-loading">
          <div class="loading-spinner"></div>
          <span>{{ t('common.loading') }}</span>
        </div>
      </div>

    <!-- 中间：Canvas 绘制区域 -->
    <div class="canvas-area">
      <div class="canvas-header">
        <div class="canvas-tabs">
          <div class="canvas-tab active">
            <span class="template-select-label">模板选择</span>
          </div>
        </div>
      </div>
      <div class="template-selector">
        <div class="template-selector-scroll">
          <div
            v-for="(template, index) in templates"
            :key="'tmpl-' + index"
            class="template-thumbnail"
            :class="{ active: selectedTemplateIndex === index }"
            @click="selectTemplate(template, index)"
          >
            <img v-if="template.preview" :src="template.preview" :alt="template.name" />
            <span class="template-thumbnail-name">{{ template.name }}</span>
          </div>
        </div>
      </div>
      <div class="canvas-main-content">
        <div class="canvas-and-previews">
          <!-- Canvas 主画布 -->
          <div class="canvas-wrapper">
            <canvas ref="stampCanvas" width="366" height="366"></canvas>
          </div>
          <!-- 右侧上方预览 -->
          <div class="aging-preview-item aging-right-top">
            <div class="aging-preview-label">10% - 轻度</div>
            <div class="aging-preview-image">
              <img v-if="agingPreviews[10]" :src="agingPreviews[10]" alt="轻度做旧" />
              <div v-else class="aging-preview-placeholder">加载中...</div>
            </div>
          </div>
          <!-- 右侧下方预览 -->
          <div class="aging-preview-item aging-right-bottom">
            <div class="aging-preview-label">20% - 中度</div>
            <div class="aging-preview-image">
              <img v-if="agingPreviews[20]" :src="agingPreviews[20]" alt="中度做旧" />
              <div v-else class="aging-preview-placeholder">加载中...</div>
            </div>
          </div>
          <!-- 下侧左侧预览 -->
          <div class="aging-preview-item aging-bottom-left">
            <div class="aging-preview-label">30% - 重度</div>
            <div class="aging-preview-image">
              <img v-if="agingPreviews[30]" :src="agingPreviews[30]" alt="重度做旧" />
              <div v-else class="aging-preview-placeholder">加载中...</div>
            </div>
          </div>
          <!-- 下侧右侧预览 -->
          <div class="aging-preview-item aging-bottom-right">
            <div class="aging-preview-label">40% - 极重度</div>
            <div class="aging-preview-image">
              <img v-if="agingPreviews[40]" :src="agingPreviews[40]" alt="极重度做旧" />
              <div v-else class="aging-preview-placeholder">加载中...</div>
            </div>
          </div>
        </div>
        <div class="aging-preview-footer">
          <button @click="showDownloadCodeDialog = true" class="export-all-btn">下载全部4个版本</button>
        </div>
      </div>
    </div>
    </div>
    
    <!-- 下载码验证对话框 -->
    <Teleport to="body">
      <Transition name="dialog-fade">
        <div v-if="showDownloadCodeDialog" class="download-code-dialog-overlay" @click.self="closeDownloadCodeDialog">
          <div class="download-code-dialog">
            <div class="dialog-title">下载码验证</div>
            <div class="dialog-content">
              <p>请联系管理员获取下载码（有效期一天），进行下载</p>
              <p class="dialog-link">链接：<a href="https://m.tb.cn/h.RZRs4Wc?tk=s2GD5qXCAPO" target="_blank">m.tb.cn/h.RZRs4Wc</a></p>
              <div class="dialog-input-wrapper">
                <input
                  v-model="downloadCode"
                  type="text"
                  class="dialog-input"
                  placeholder="请输入下载码"
                  @keyup.enter="verifyDownloadCode"
                  ref="downloadCodeInput"
                />
              </div>
              <div v-if="downloadCodeError" class="dialog-error">
                <span class="error-icon">⚠️</span>
                <span>{{ downloadCodeError }}</span>
              </div>
            </div>
            <div class="dialog-footer">
              <button class="dialog-btn dialog-btn-cancel" @click="closeDownloadCodeDialog">取消</button>
              <button class="dialog-btn dialog-btn-confirm" @click="verifyDownloadCode">验证</button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
    
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick, computed, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { DrawStampUtils } from '../../DrawStampUtils'
import { getSystemFonts } from '../../utils/fontUtils'
import { IDrawStampConfig } from '../../DrawStampTypes'
import ElementList from './ElementList.vue'
import PropertiesPanel from './PropertiesPanel.vue'
import { useStampStore } from '../../stores/stampStore'

const templateModules = import.meta.glob('../../assets/templates/*.json', { eager: true })

interface TemplateOption {
  name: string
  preview: string
  config: IDrawStampConfig
}

const templates = ref<TemplateOption[]>([])

const loadTemplates = () => {
  const loadedTemplates: TemplateOption[] = []
  for (const path in templateModules) {
    const fileName = path.split('/').pop()?.replace('.json', '') || 'template'
    const module = templateModules[path] as { default: IDrawStampConfig }
    loadedTemplates.push({
      name: fileName,
      preview: '',
      config: module.default as IDrawStampConfig
    })
  }
  templates.value = loadedTemplates
}

loadTemplates()

const props = defineProps<{
  /** 传入的印章模板配置，用于初始化或联动 */
  modelValue?: IDrawStampConfig | null
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: IDrawStampConfig): void
  (e: 'selectElement', payload: { id: string; type: string; index: number }): void
}>()

const { t } = useI18n()
const stampStore = useStampStore()

// 控制内部逻辑是否已就绪
const isDrawStampUtilsReady = ref(false)
const propertiesPanelRef = ref<InstanceType<typeof PropertiesPanel> | null>(null)
const elementListRef = ref<any | null>(null)

// 选中的元素
const selectedElement = ref<string>('')
const selectedElementType = ref<string>('')
const selectedElementIndex = ref<number>(-1)

// 处理元素选择（对外联动）
const handleSelectElement = (elementId: string, elementType: string, index: number) => {
  selectedElement.value = elementId
  selectedElementType.value = elementType
  selectedElementIndex.value = index
  emit('selectElement', { id: elementId, type: elementType, index })
}

// 处理元素列表配置更新
const handleElementListUpdate = () => {
  // 配置已通过 stampStore 更新，这里触发重新绘制
  drawStamp()
}

// 处理元素列表刷新
const handleElementListRefresh = () => {
  // 刷新绘制
  drawStamp()
}

// 顶部工具栏快速添加元素
const toolbarAddCompany = () => {
  elementListRef.value?.addCompanyItem?.()
}

const toolbarAddStampType = () => {
  elementListRef.value?.addStampTypeItem?.()
}

const toolbarAddInnerCircle = () => {
  elementListRef.value?.addInnerCircle?.()
}

const toolbarAddImage = () => {
  elementListRef.value?.addImage?.()
}

const toolbarAddSvg = () => {
  elementListRef.value?.triggerSvgUpload?.()
}

const toolbarAddHorizontalLine = () => {
  elementListRef.value?.addLine?.('horizontal')
}

const toolbarAddVerticalLine = () => {
  elementListRef.value?.addLine?.('vertical')
}

const stampCanvas = ref<any | null>(null)
const MM_PER_PIXEL = 6.67 // 毫米换算像素（适配 400x400 canvas）
const isDraggable = ref(false) // 是否开启拖动
const showFormatDialog = ref(false)
const selectedFormat = ref<'png' | 'jpeg' | 'svg'>('png')
const jpegQuality = ref(92)
const defaultExportWidth = ref(0)
const defaultExportHeight = ref(0)
const hasPaid = ref(false)
const exportMultipleAging = ref(false)

// 做旧预览
const agingPreviews = ref<Record<number, string>>({})
const agingPreviewLevels = [
  { intensity: 10, label: '轻度做旧' },
  { intensity: 20, label: '中度做旧' },
  { intensity: 30, label: '重度做旧' },
  { intensity: 40, label: '极重度做旧' }
]
let agingPreviewTimer: number | null = null

// 下载码验证
const showDownloadCodeDialog = ref(false)
const downloadCode = ref('')
const downloadCodeError = ref('')
const downloadCodeInput = ref<HTMLInputElement | null>(null)

// 正确的下载码（可替换为后端验证）
const CORRECT_DOWNLOAD_CODE = '0315'

// 模拟付款
const confirmPayment = () => {
  hasPaid.value = true
  // 付款后自动触发导出
  confirmExport()
}

// 导出模板元信息弹窗状态
const showTemplateMetaDialog = ref(false)
const templateTitle = ref('')
const templateCategories = ref('')
const pendingTemplateConfig = ref<IDrawStampConfig | null>(null)

const exportFormats = computed(() => [
  { value: 'png' as const, name: 'PNG', icon: '🖼️', desc: t('stamp.exportFormat.pngDesc') },
  { value: 'jpeg' as const, name: 'JPEG', icon: '📷', desc: t('stamp.exportFormat.jpegDesc') },
  { value: 'svg' as const, name: 'SVG', icon: '📐', desc: t('stamp.exportFormat.svgDesc') }
])

const selectedTemplateIndex = ref<number>(-1)

const generateTemplatePreviews = async () => {
  for (const template of templates.value) {
    const tempCanvas = document.createElement('canvas')
    tempCanvas.width = 500
    tempCanvas.height = 500
    const tempDrawStampUtils = new DrawStampUtils(tempCanvas, 8)
    template.config.ruler.showRuler = false
    tempDrawStampUtils.setDrawConfigs(template.config)
    tempDrawStampUtils.refreshStamp()
    template.preview = tempCanvas.toDataURL('image/png')
  }
  // 生成预览后，选中模板1作为默认
  if (templates.value.length > 0 && drawStampUtils) {
    selectTemplate(templates.value[0], 0)
  }
}

const selectTemplate = async (template: TemplateOption, index: number) => {
  if (!drawStampUtils) return
  selectedTemplateIndex.value = index
  const newConfig = JSON.parse(JSON.stringify(template.config)) as IDrawStampConfig
  newConfig.ruler.showRuler = true
  newConfig.ruler.showFullRuler = true
  newConfig.ruler.showSideRuler = true
  newConfig.ruler.showCrossLine = true
  newConfig.ruler.showCurrentPositionText = true
  newConfig.ruler.showDashLine = true
  if (newConfig.company) {
    newConfig.company.startAngle = template.config.company.startAngle
    newConfig.company.rotateDirection = template.config.company.rotateDirection
  }
  if (!newConfig.svgList) {
    newConfig.svgList = []
  }
  drawStampUtils.setDrawConfigs(newConfig)
  stampStore.setConfig(newConfig)
  syncConfigToParent()
  drawStamp()
  await nextTick()
  propertiesPanelRef.value?.restoreDrawConfigs()
}

// 绘制工具
let drawStampUtils: DrawStampUtils
// 标记当前是否为父组件驱动的配置同步，避免 v-model 循环更新
let isUpdatingFromParent = false

// 获取所有文字路径（公司名称、编码和印章类型）
let allTextPaths: any[] = []
let companyTextPaths: any[] = []
let codeTextPaths: any[] = []
let stampTypeTextPaths: any[] = []
let taxNumberTextPaths: any[] = []

// 初始化绘制印章参数
const initDrawStampUtils = () => {
  drawStampUtils = new DrawStampUtils(stampCanvas.value, MM_PER_PIXEL)

  // 如果父组件传入了模板配置，优先使用该配置初始化
  if (props.modelValue) {
    const initialConfig = JSON.parse(JSON.stringify(props.modelValue)) as IDrawStampConfig
    drawStampUtils.setDrawConfigs(initialConfig)
    stampStore.setConfig(initialConfig)
  } else if (templates.value.length > 0) {
    // 否则使用模板1作为默认配置
    const defaultConfig = JSON.parse(JSON.stringify(templates.value[0].config)) as IDrawStampConfig
    drawStampUtils.setDrawConfigs(defaultConfig)
    stampStore.setConfig(defaultConfig)
  } else {
    stampStore.setConfig(drawStampUtils.getDrawConfigs())
  }
}

const syncConfigToParent = () => {
  if (!drawStampUtils || isUpdatingFromParent) return
  const currentConfig = drawStampUtils.getDrawConfigs()
  emit('update:modelValue', currentConfig)
}

const drawStamp = (refreshSecurityPattern: boolean = false, refreshOld: boolean = false, refreshRoughEdge: boolean = false) => {
  // 使用 drawStampUtils 进行绘制
  drawStampUtils.refreshStamp(refreshSecurityPattern, refreshOld, refreshRoughEdge)

  // 确保拖动设置与当前状态一致
  drawStampUtils.setDraggable(isDraggable.value)
  stampStore.setConfig(drawStampUtils.getDrawConfigs())
  syncConfigToParent()

  // 更新文字路径
  companyTextPaths = drawStampUtils.drawCompanyUtils.getTextPaths()
  codeTextPaths = drawStampUtils.drawCodeUtils.getTextPaths()
  stampTypeTextPaths = drawStampUtils.drawStampTypeUtils.getTextPaths()
  taxNumberTextPaths = drawStampUtils.drawTaxNumberUtils.getTextPaths()
  allTextPaths = [...companyTextPaths, ...codeTextPaths, ...stampTypeTextPaths, ...taxNumberTextPaths]

  // 生成做旧效果预览
  generateAgingPreviews()
}

// 保存图片（本地下载，无后端限制）
const saveStampAsPNG = () => {
  if (!drawStampUtils) return
  const baseSize = drawStampUtils.getExportBaseSize()
  defaultExportWidth.value = Math.round(baseSize.width)
  defaultExportHeight.value = Math.round(baseSize.height)
  selectedFormat.value = 'png'
  jpegQuality.value = 92

  showFormatDialog.value = true
}

const closeFormatDialog = () => {
  showFormatDialog.value = false
  hasPaid.value = false
}

const confirmExport = async () => {
  closeFormatDialog()

  if (!drawStampUtils) return
  const quality = selectedFormat.value === 'jpeg' ? jpegQuality.value / 100 : 0.92
  const width = Math.round(defaultExportWidth.value) || 400
  const height = Math.round(defaultExportHeight.value) || 400

  if (exportMultipleAging.value) {
    // 导出4个不同做旧程度的版本
    const agingLevels = [0, 25, 50, 75]
    const versions = await drawStampUtils.exportMultipleAgingVersions(
      selectedFormat.value === 'svg' ? 'png' : selectedFormat.value,
      quality,
      width,
      height,
      agingLevels
    )

    // 依次下载每个版本
    for (const version of versions) {
      await downloadFile(version.dataURL, version.filename)
      // 每个下载之间添加短暂延迟，避免浏览器阻止
      await new Promise(resolve => setTimeout(resolve, 200))
    }
  } else {
    // 执行单个下载
    drawStampUtils.saveStampAsPNG(selectedFormat.value, quality, width, height)
  }

  // 重置多版本导出选项
  exportMultipleAging.value = false
}

const downloadFile = (dataURL: string, filename: string): Promise<void> => {
  return new Promise((resolve) => {
    const link = document.createElement('a')
    link.href = dataURL
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    resolve()
  })
}

// 生成做旧预览
const generateAgingPreviews = async () => {
  if (!drawStampUtils) return

  // 清除之前的定时器
  if (agingPreviewTimer) {
    clearTimeout(agingPreviewTimer)
  }

  // 延迟执行，避免频繁刷新
  agingPreviewTimer = window.setTimeout(async () => {
    try {
      const intensities = [10, 20, 30, 40]
      const previews: Record<number, string> = {}

      for (const intensity of intensities) {
        // 临时保存原始配置
        const originalApplyAging = drawStampUtils.drawStampConfigs.agingEffect.applyAging
        const originalAgingIntensity = drawStampUtils.drawStampConfigs.agingEffect.agingIntensity
        const originalAgingParams = [...drawStampUtils.drawStampConfigs.agingEffect.agingEffectParams]
        const originalShowRuler = drawStampUtils.drawStampConfigs.ruler.showRuler
        const originalShowCrossLine = drawStampUtils.drawStampConfigs.ruler.showCrossLine

        // 隐藏标尺
        drawStampUtils.drawStampConfigs.ruler.showRuler = false
        drawStampUtils.drawStampConfigs.ruler.showCrossLine = false

        // 设置当前做旧强度
        if (intensity > 0) {
          drawStampUtils.drawStampConfigs.agingEffect.applyAging = true
          drawStampUtils.drawStampConfigs.agingEffect.agingIntensity = intensity
          drawStampUtils.drawStampConfigs.agingEffect.agingEffectParams = []
        } else {
          drawStampUtils.drawStampConfigs.agingEffect.applyAging = false
        }

        // 刷新绘制
        drawStampUtils.refreshStamp()

        // 等待渲染完成
        await new Promise(resolve => setTimeout(resolve, 50))

        // 生成预览图
        const previewCanvas = document.createElement('canvas')
        const previewSize = 150
        previewCanvas.width = previewSize
        previewCanvas.height = previewSize
        const previewCtx = previewCanvas.getContext('2d')

        if (previewCtx) {
          // 直接绘制当前画布内容到预览图（做旧已在 refreshStamp 中应用）
          previewCtx.drawImage(drawStampUtils.canvas, 0, 0, previewSize, previewSize)
          previews[intensity] = previewCanvas.toDataURL('image/png')
        }

        // 恢复原始配置
        drawStampUtils.drawStampConfigs.agingEffect.applyAging = originalApplyAging
        drawStampUtils.drawStampConfigs.agingEffect.agingIntensity = originalAgingIntensity
        drawStampUtils.drawStampConfigs.agingEffect.agingEffectParams = originalAgingParams
        drawStampUtils.drawStampConfigs.ruler.showRuler = originalShowRuler
        drawStampUtils.drawStampConfigs.ruler.showCrossLine = originalShowCrossLine
      }

      agingPreviews.value = previews
    } catch (error) {
      console.error('生成做旧预览失败:', error)
    }
  }, 500)
}

// 导出所有做旧版本
const exportAllAgingVersions = async () => {
  if (!drawStampUtils) return

  const quality = 0.92
  const agingLevels = [10, 20, 30, 40]
  const versions = await drawStampUtils.exportMultipleAgingVersions(
    'png',
    quality,
    0,
    0,
    agingLevels
  )

  // 依次下载每个版本
  for (const version of versions) {
    await downloadFile(version.dataURL, version.filename)
    await new Promise(resolve => setTimeout(resolve, 200))
  }
}

// 关闭下载码对话框
const closeDownloadCodeDialog = () => {
  showDownloadCodeDialog.value = false
  downloadCode.value = ''
  downloadCodeError.value = ''
}

// 验证下载码
const verifyDownloadCode = async () => {
  if (!downloadCode.value.trim()) {
    downloadCodeError.value = '请输入下载码'
    return
  }

  if (downloadCode.value.trim() === CORRECT_DOWNLOAD_CODE) {
    // 验证通过，关闭对话框并执行下载
    closeDownloadCodeDialog()
    await exportAllAgingVersions()
  } else {
    downloadCodeError.value = '验证码错误，请重新输入'
    downloadCode.value = ''
    // 聚焦输入框
    nextTick(() => {
      downloadCodeInput.value?.focus()
    })
  }
}

// 监听对话框打开，自动聚焦输入框
watch(showDownloadCodeDialog, (newValue) => {
  if (newValue) {
    nextTick(() => {
      downloadCodeInput.value?.focus()
    })
  }
})

const resetStamp = () => {
  if (!drawStampUtils) return
  const blankConfig = JSON.parse(JSON.stringify(drawStampUtils.getDrawConfigs())) as IDrawStampConfig
  blankConfig.companyList = []
  blankConfig.company.companyName = ''
  blankConfig.stampTypeList = []
  blankConfig.stampCode.code = ''
  blankConfig.stampCodeList = []
  blankConfig.taxNumber.code = ''
  blankConfig.imageList = []
  blankConfig.lineList = []
  blankConfig.innerCircleList = []
  blankConfig.svgList = []
  blankConfig.drawStar.drawStar = false
  blankConfig.drawStar.starPositionX = 0
  blankConfig.company.shape = 'ellipse'
  if (blankConfig.companyList) {
    blankConfig.companyList.forEach(company => company.shape = 'ellipse')
  }
  blankConfig.securityPattern.openSecurityPattern = false
  blankConfig.roughEdge.drawRoughEdge = false
  blankConfig.agingEffect.applyAging = false
  blankConfig.agingEffect.agingEffectParams = []
  blankConfig.openManualAging = false
  blankConfig.width = 40
  blankConfig.height = 40

  drawStampUtils.setDrawConfigs(blankConfig)
  stampStore.setConfig(blankConfig)
  syncConfigToParent()
  selectedElement.value = ''
  selectedElementType.value = ''
  selectedElementIndex.value = -1
  drawStamp()
  handleSelectElement('basic-settings', 'basic', 0)
}

// 清理未启用的效果数组，减小模板文件大小
const cleanConfigForTemplate = (config: IDrawStampConfig): IDrawStampConfig => {
  const cleanedConfig = JSON.parse(JSON.stringify(config)) as IDrawStampConfig

  // 如果做旧效果未开启，删除做旧参数数组
  if (cleanedConfig.agingEffect && !cleanedConfig.agingEffect.applyAging) {
    (cleanedConfig.agingEffect as any).agingEffectParams = undefined
  }

  // 如果毛边效果未开启，删除毛边参数数组
  if (cleanedConfig.roughEdge && !cleanedConfig.roughEdge.drawRoughEdge) {
    (cleanedConfig.roughEdge as any).roughEdgeParams = undefined
  }

  // 如果防伪纹路未开启，删除防伪纹路参数数组
  if (cleanedConfig.securityPattern && !cleanedConfig.securityPattern.openSecurityPattern) {
    (cleanedConfig.securityPattern as any).securityPatternParams = undefined
  }

  return cleanedConfig
}

// 导出当前设置为模板（弹出元信息对话框）
const saveCurrentAsTemplate = () => {
  if (!drawStampUtils) return

  const currentConfig = drawStampUtils.getDrawConfigs()
  // 清理未启用的效果数组
  const cleanedConfig = cleanConfigForTemplate(currentConfig)

  // 预填标题
  const defaultTitle =
    cleanedConfig.title ||
    cleanedConfig.stampType?.stampType ||
    cleanedConfig.company?.companyName ||
    ''
  templateTitle.value = defaultTitle

  // 预填分类（多个分类使用空格分隔）
  const defaultCategories = Array.isArray(cleanedConfig.categories)
    ? cleanedConfig.categories.join(' ')
    : cleanedConfig.category || ''
  templateCategories.value = defaultCategories

  pendingTemplateConfig.value = cleanedConfig
  showTemplateMetaDialog.value = true
}

const closeTemplateMetaDialog = () => {
  showTemplateMetaDialog.value = false
  pendingTemplateConfig.value = null
}

const confirmSaveTemplate = () => {
  if (!pendingTemplateConfig.value) {
    closeTemplateMetaDialog()
    return
  }

  const config = pendingTemplateConfig.value

  const title = templateTitle.value.trim()
  if (title) {
    config.title = title
  }

  const categoriesInput = templateCategories.value.trim()
  if (categoriesInput) {
    const parts = categoriesInput.split(/\s+/).filter(Boolean)
    if (parts.length > 0) {
      config.category = parts[0]
      config.categories = parts
    }
  }

  // 使用紧凑格式（无缩进和换行）来减小文件大小，并排除 undefined 字段
  const jsonStr = JSON.stringify(config, (_key, value) => {
    // JSON.stringify 会自动排除 undefined 值，所以直接返回 value 即可
    return value
  })
  const blob = new Blob([jsonStr], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  const safeTitle = (config.title && config.title.trim()) || 'stamp_template'
  // 将中文标题中的空格替换为下划线，避免文件名问题
  const fileName = `${safeTitle.replace(/\s+/g, '_')}.json`
  link.download = fileName
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)

  closeTemplateMetaDialog()
}

// 更新印章绘制，从 PropertiesPanel 组件中调用
const updateDrawStamp = (newConfig: IDrawStampConfig, refreshSecurityPattern: boolean, refreshOld: boolean, refreshRoughEdge: boolean) => {
  drawStampUtils.setDrawConfigs(newConfig)
  drawStampUtils.refreshStamp(refreshSecurityPattern, refreshOld, refreshRoughEdge)
  stampStore.setConfig(newConfig)
  syncConfigToParent()
}

// 修改字体预览更新函数
const updateFontPreview = (event: Event) => {
  const element = event.target as HTMLElement
  const fontFamily = element.tagName === 'SELECT'
    ? (element as HTMLSelectElement).value
    : (element as HTMLInputElement).value

  element.style.setProperty('--current-font', fontFamily)

  // 如果是 select 变化，同步更新 input
  if (element.tagName === 'SELECT') {
    const inputEl = element.parentElement?.querySelector('.font-input') as HTMLInputElement
    if (inputEl) {
      inputEl.value = fontFamily
      inputEl.style.setProperty('--current-font', fontFamily)
    }
  }

  // 如果 input 变化，同步更新 select
  if (element.tagName === 'INPUT') {
    const selectEl = element.parentElement?.querySelector('.font-select') as HTMLSelectElement
    if (selectEl) {
      selectEl.value = fontFamily
      selectEl.style.setProperty('--current-font', fontFamily)
    }
  }
}

// 添加鼠标移动检测
const handleMouseMove = (event: MouseEvent) => {
  if (!drawStampUtils?.canvas) return

  const rect = drawStampUtils.canvas.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top

  // 检查是否悬停在文字上
  let isOverText = false
  for (const textPath of allTextPaths) {
    if (x >= textPath.bounds.x &&
        x <= textPath.bounds.x + textPath.bounds.width &&
        y >= textPath.bounds.y &&
        y <= textPath.bounds.y + textPath.bounds.height) {
      isOverText = true
      drawStampUtils.canvas.style.cursor = 'pointer'
      return
    }
  }

  if (!isOverText) {
    drawStampUtils.canvas.style.cursor = 'default'
  }
}

// 添加点击事件处理
const handleCanvasClick = (event: MouseEvent) => {
  if (!drawStampUtils?.canvas) return

  const rect = drawStampUtils.canvas.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top

  // 检查点击的文字
  for (const textPath of allTextPaths) {
    if (x >= textPath.bounds.x &&
        x <= textPath.bounds.x + textPath.bounds.width &&
        y >= textPath.bounds.y &&
        y <= textPath.bounds.y + textPath.bounds.height) {
      // 可以在这里添加点击文字的处理逻辑
      return
    }
  }
}

// 父组件如果更新了传入的模板配置，这里做一次同步
watch(
  () => props.modelValue,
  (newVal) => {
    if (!drawStampUtils || !newVal) return
    const cloned = JSON.parse(JSON.stringify(newVal)) as IDrawStampConfig
    isUpdatingFromParent = true
    try {
      drawStampUtils.setDrawConfigs(cloned)
      stampStore.setConfig(cloned)
      // 这里仅刷新画面，但不会通过 syncConfigToParent 再次向父组件回推，避免递归
      drawStamp(false, false, false)
    } finally {
      isUpdatingFromParent = false
    }
  }
)

// 在组件挂载时初始化
onMounted(async () => {
  initDrawStampUtils()
  await getSystemFonts()

  // 设置初始拖动状态
  drawStampUtils.setDraggable(isDraggable.value)
  if (stampCanvas.value) {
    stampCanvas.value.style.cursor = isDraggable.value ? 'move' : 'default'
  }

  drawStamp()
  // 初始化所有字体选择器的预览
  document.querySelectorAll('.font-select, .font-input').forEach((element) => {
    if (element instanceof HTMLElement) {
      updateFontPreview({ target: element } as unknown as Event)
    }
  })
  isDrawStampUtilsReady.value = true

  generateTemplatePreviews()

  // 默认选中基础设置
  await nextTick()
  handleSelectElement('basic-settings', 'basic', 0)

  window.addEventListener('mousemove', handleMouseMove)
  drawStampUtils?.canvas?.addEventListener('click', handleCanvasClick)
})

// 在组件卸载时移除事件监听
onUnmounted(() => {
  window.removeEventListener('mousemove', handleMouseMove)
  drawStampUtils?.canvas?.removeEventListener('click', handleCanvasClick)
})
</script>

<style scoped>
/* 顶部标题栏 */
.app-title-bar {
  padding: 12px 24px;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
  box-shadow: var(--shadow-md);
  border-bottom: 1px solid var(--border-color);
}

.app-title {
  margin: 0 0 4px 0;
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  letter-spacing: 1px;
  text-align: center;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

.operation-steps {
  margin: 0;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.95);
  text-align: center;
  font-weight: 400;
  line-height: 1.4;
  opacity: 0.95;
}

/* 主工作区：三栏布局 */
.main-workspace {
  display: flex;
  flex-direction: column;
  background: var(--bg-primary);
  border-radius: 0;
  margin-top: 0;
  min-height: 600px;
  box-shadow: none;
  border: none;
}

/* Canvas 区域 */
.canvas-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: var(--bg-primary);
  border-radius: 0;
  box-shadow: var(--shadow-sm);
  overflow: hidden;
}

.canvas-header {
  height: 56px;
  padding: 0 20px;
  display: flex;
  align-items: center;
  border: none;
  border-bottom: 1px solid var(--border-color);
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
  flex-shrink: 0;
  box-shadow: var(--shadow-sm);
}

.canvas-tabs {
  display: flex;
  gap: 8px;
}

.template-selector {
  width: 100%;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  padding: 10px 0;
  flex-shrink: 0;
}

.template-selector-scroll {
  display: flex;
  gap: 12px;
  padding: 0 16px;
  overflow-x: auto;
  scroll-behavior: smooth;
}

.template-selector-scroll::-webkit-scrollbar {
  height: 6px;
}

.template-selector-scroll::-webkit-scrollbar-track {
  background: var(--bg-tertiary);
  border-radius: 3px;
}

.template-selector-scroll::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 3px;
}

.template-selector-scroll::-webkit-scrollbar-thumb:hover {
  background: var(--text-tertiary);
}

.template-thumbnail {
  flex-shrink: 0;
  width: 80px;
  height: 80px;
  border: 2px solid var(--border-color);
  border-radius: var(--radius-md);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  background: var(--bg-primary);
}

.template-thumbnail:hover {
  border-color: var(--primary-border);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.template-thumbnail.active {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px var(--primary-light);
}

.template-thumbnail img {
  width: 100%;
  height: 60px;
  object-fit: contain;
  background: var(--bg-secondary);
}

.template-thumbnail-name {
  height: 20px;
  line-height: 20px;
  text-align: center;
  font-size: 11px;
  color: var(--text-secondary);
  background: var(--bg-tertiary);
  font-weight: 500;
}

.canvas-tab {
  padding: 6px 12px;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.9);
  transition: all 0.2s;
}

.canvas-tab.active {
  color: #fff;
}

.template-select-label {
  padding: 4px 12px;
  font-size: 15px;
  font-weight: 600;
  color: #fff;
  letter-spacing: 0.5px;
}

.canvas-main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 16px;
  overflow: hidden;
}

.canvas-and-previews {
  flex: 1;
  display: grid;
  grid-template-columns: 366px 150px 150px;
  grid-template-rows: 183px 183px 150px;
  gap: 8px;
}

.canvas-wrapper {
  grid-column: 1;
  grid-row: 1 / 3;
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
  background:
    linear-gradient(45deg, var(--bg-tertiary) 25%, transparent 25%),
    linear-gradient(-45deg, var(--bg-tertiary) 25%, transparent 25%),
    linear-gradient(45deg, transparent 75%, var(--bg-tertiary) 75%),
    linear-gradient(-45deg, transparent 75%, var(--bg-tertiary) 75%);
  background-size: 20px 20px;
  background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
  border-radius: var(--radius-md);
  border: 1px solid var(--border-color);
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.canvas-wrapper canvas {
  display: block;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.aging-preview-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius);
  padding: 6px;
  transition: all 0.2s ease;
  overflow: hidden;
}

.aging-right-top {
  grid-column: 2;
  grid-row: 1;
}

.aging-right-bottom {
  grid-column: 2;
  grid-row: 2;
}

.aging-bottom-left {
  grid-column: 1;
  grid-row: 3;
}

.aging-bottom-right {
  grid-column: 2;
  grid-row: 3;
}

.aging-preview-item:hover {
  border-color: var(--primary-color);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.aging-preview-label {
  font-size: 11px;
  font-weight: 500;
  color: var(--text-secondary);
  text-align: center;
  white-space: nowrap;
}

.aging-preview-image {
  width: 100%;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-tertiary);
  border-radius: var(--radius-sm);
  overflow: hidden;
}

.aging-preview-image img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.aging-preview-placeholder {
  font-size: 11px;
  color: var(--text-tertiary);
  text-align: center;
}

.aging-preview-footer {
  padding: 12px;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
}

.export-all-btn {
  width: 100%;
  height: 40px;
  border: none;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: var(--shadow-md);
}

.export-all-btn:hover {
  background: linear-gradient(135deg, var(--primary-hover) 0%, var(--primary-color) 100%);
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.export-all-btn:active {
  transform: translateY(0);
}

/* 下载码验证对话框 */
.download-code-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.download-code-dialog {
  background: var(--bg-primary);
  border-radius: var(--radius-lg);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 420px;
  width: 90%;
  overflow: hidden;
  animation: dialog-scale-in 0.2s ease-out;
}

@keyframes dialog-scale-in {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.dialog-fade-enter-active,
.dialog-fade-leave-active {
  transition: opacity 0.2s ease;
}

.dialog-fade-enter-from,
.dialog-fade-leave-to {
  opacity: 0;
}

.dialog-title {
  padding: 20px 24px 16px;
  font-size: 18px;
  font-weight: 600;
  color: #d40000;
  border-bottom: 1px solid var(--border-color);
}

.dialog-content {
  padding: 20px 24px;
}

.dialog-content p {
  margin: 0 0 12px;
  font-size: 16px;
  color: var(--text-primary);
  line-height: 1.6;
  text-align: center;
}

.dialog-link {
  color: var(--text-secondary) !important;
  font-size: 15px !important;
}

.dialog-link a {
  color: var(--primary-color);
  text-decoration: none;
}

.dialog-link a:hover {
  text-decoration: underline;
}

.dialog-input-wrapper {
  margin-top: 16px;
}

.dialog-input {
  width: 100%;
  height: 44px;
  padding: 0 16px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius);
  background: var(--bg-tertiary);
  font-size: 14px;
  color: var(--text-primary);
  outline: none;
  transition: all 0.2s ease;
  text-align: center;
  letter-spacing: 2px;
}

.dialog-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.15);
}

.dialog-input::placeholder {
  color: var(--text-tertiary);
  letter-spacing: 0;
}

.dialog-error {
  margin-top: 12px;
  padding: 10px 14px;
  background: #ffe6e6;
  border: 1px solid #ffb3b3;
  border-radius: var(--radius);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #cc0000;
}

.error-icon {
  font-size: 16px;
}

.dialog-footer {
  padding: 16px 24px 20px;
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.dialog-btn {
  height: 40px;
  padding: 0 24px;
  border: none;
  border-radius: var(--radius);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.dialog-btn-cancel {
  background: var(--bg-tertiary);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}

.dialog-btn-cancel:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
}

.dialog-btn-confirm {
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
  color: #fff;
  box-shadow: 0 2px 8px rgba(0, 122, 255, 0.3);
}

.dialog-btn-confirm:hover {
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.4);
  transform: translateY(-1px);
}

.dialog-btn-confirm:active {
  transform: translateY(0);
}


.canvas-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 20px;
  border-top: 1px solid var(--border-color);
  background: var(--bg-secondary);
  flex-shrink: 0;
}

.canvas-download-btn {
  min-width: 110px;
  height: 40px;
  border-radius: var(--radius-md);
  border: none;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 0 20px;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.2s ease;
  box-shadow: var(--shadow-md);
}

.canvas-download-btn:hover {
  background: linear-gradient(135deg, var(--primary-hover) 0%, var(--primary-color) 100%);
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.canvas-download-btn span:first-child {
  font-size: 16px;
}

.canvas-action-btn {
  width: 40px;
  height: 36px;
  border-radius: var(--radius);
  border: 1px solid var(--border-color);
  background: var(--bg-primary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: all 0.2s ease;
  color: var(--text-secondary);
}

.canvas-action-btn:hover {
  background: var(--primary-light);
  border-color: var(--primary-color);
  color: var(--primary-color);
  transform: scale(1.05);
  box-shadow: var(--shadow-sm);
}

.save-count-small {
  font-size: 12px;
  color: var(--text-secondary);
}

.qr-code-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 16px 0;
}

.qr-code-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--text-primary);
  text-align: center;
}

.qr-code-placeholder {
  width: 200px;
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.qr-code-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.qr-hint {
  font-size: 13px;
  color: var(--text-secondary);
  text-align: center;
  margin: 0;
}

.meta-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 12px;
}

.meta-input {
  padding: 8px 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius);
  font-size: 13px;
  background: var(--bg-primary);
  color: var(--text-primary);
  transition: all 0.2s ease;
}

.meta-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px var(--primary-light);
  outline: none;
}

.meta-input::placeholder {
  color: var(--text-tertiary);
}

/* 左右侧面板 loading 状态 */
.side-panel-loading,
.right-panel-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 16px;
  color: var(--text-secondary);
  font-size: 13px;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--border-color);
  border-top-color: var(--primary-color);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.stamp-draw-container {
  display: flex;
  flex-direction: row;
}

.left-panels {
  display: flex;
  flex-direction: row;
  position: relative;
}

.left-panels::after {
  content: '';
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 1px;
  background: linear-gradient(to bottom, transparent 0%, var(--border-color) 10%, var(--border-color) 90%, transparent 100%);
  z-index: 10;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.save-count-small {
  font-size: 12px;
}

@media (max-width: 768px) {
  .main-workspace {
    flex-direction: column;
    min-height: auto;
  }

  .canvas-area {
    min-height: 400px;
  }
}

.quality-slider {
  width: 100%;
  margin-top: 8px;
  height: 6px;
  border-radius: 3px;
  background: var(--bg-tertiary);
  outline: none;
  -webkit-appearance: none;
}

.quality-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: var(--primary-color);
  cursor: pointer;
  transition: all 0.2s ease;
}

.quality-slider::-webkit-slider-thumb:hover {
  background: var(--primary-hover);
  transform: scale(1.1);
}

.quality-slider::-moz-range-thumb {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: var(--primary-color);
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

.quality-slider::-moz-range-thumb:hover {
  background: var(--primary-hover);
  transform: scale(1.1);
}

/* 做旧效果选项区域 */
.aging-options-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px;
  background: var(--bg-tertiary);
  border-radius: var(--radius-md);
  border: 1px solid var(--border-color);
}

.aging-options-section .checkbox-label {
  flex-direction: row !important;
  align-items: center;
  cursor: pointer;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
  color: var(--text-primary);
}

.aging-options-section .checkbox-label input[type="checkbox"] {
  margin: 0;
  width: 16px;
  height: 16px;
  cursor: pointer;
  accent-color: var(--primary-color);
}

.aging-levels-info {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding-top: 8px;
  border-top: 1px solid var(--border-color);
}

.aging-level-tag {
  padding: 4px 10px;
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius);
  font-size: 12px;
  color: var(--text-secondary);
  font-weight: 500;
  transition: all 0.2s ease;
}

.aging-level-tag:hover {
  background: var(--primary-light);
  border-color: var(--primary-color);
  color: var(--primary-color);
}
</style>


