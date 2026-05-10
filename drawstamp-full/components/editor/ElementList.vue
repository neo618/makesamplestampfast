<template>
  <div class="element-list-panel">
    <div class="panel-header">
      <h3>{{ t('elementList.title') }}</h3>
    </div>
    <input
      ref="svgFileInput"
      type="file"
      accept=".svg"
      style="display: none"
      @change="handleSvgFileChange"
    />
    <div class="panel-content">
      <div class="element-category">
        <div class="element-item"
             :class="{ active: selectedElement === 'basic-settings' }"
             @click.stop="selectElement('basic-settings', 'basic', 0)">
          <span class="element-icon">⚙️</span>
          <span class="element-name">{{ t('elementList.elements.basicSettings') }}</span>
        </div>
        <div class="element-item"
             v-for="(company, index) in companyList"
             :key="`company-${index}`"
             :class="{ active: selectedElement === `company-${index}` }"
             @click.stop="selectElement(`company-${index}`, 'company', index)">
          <span class="element-icon">①</span>
          <span class="element-name">
            {{ company.companyName || t('elementList.defaults.companyNameIndex', { index: index + 1 }) }}
          </span>
<!--          <span class="element-type">{{ company.shape === 'rectangle' ? '矩形' : '椭圆' }}</span>-->
        </div>
        <div class="element-item"
             v-for="(type, index) in stampTypeList"
             :key="`stampType-${index}`"
             :class="{ active: selectedElement === `stampType-${index}` }"
             @click.stop="selectElement(`stampType-${index}`, 'stampType', index)">
          <span class="element-icon">②</span>
          <span class="element-name">
            {{ type.stampType || t('elementList.defaults.stampTypeIndex', { index: index + 1 }) }}
          </span>
<!--          <span class="element-type">类型</span>-->
        </div>
        <div
          class="element-item"
          v-for="(code, index) in stampCodeList"
          :key="`code-${index}`"
          :class="{ active: selectedElement === `code-${index}` }"
          @click.stop="selectElement(`code-${index}`, 'code', index)"
        >
          <span class="element-icon">③</span>
          <span class="element-name">
            {{ code.code || t('elementList.elements.code') + ' ' + (index + 1) }}
          </span>

        </div>

        <div class="element-item"
             :class="{ active: selectedElement === 'star' }"
             @click.stop="selectElement('star', 'star', 0)">
          <span class="element-icon">④</span>
          <span class="element-name">{{ t('elementList.elements.star') }}</span>
          <span class="element-type">{{ drawStar.drawStar ? t('elementList.status.enabled') : t('elementList.status.disabled') }}</span>
        </div>
        <div class="element-item"
             v-for="(_, index) in innerCircleList"
             :key="`circle-all-${index}`"
             :class="{ active: selectedElement === `circle-${index}` }"
             @click.stop="selectElement(`circle-${index}`, 'circle', index)">
          <span class="element-icon">④</span>
          <span class="element-name">{{ t('elementList.defaults.innerCircleIndex', { index: index + 1 }) }}</span>
        </div>
        <div class="element-item"
             v-for="imageInfo in visibleImages"
             :key="`image-${imageInfo.index}`"
             :class="{ active: selectedElement === `image-${imageInfo.index}` }"
             @click.stop="selectElement(`image-${imageInfo.index}`, 'image', imageInfo.index)">
          <span class="element-icon">🖼️</span>
          <span class="element-name">{{ t('elementList.defaults.imageIndex', { index: imageInfo.index + 1 }) }}</span>
        </div>
        <div class="element-item"
             v-for="(line, index) in lineList"
             :key="line.id || `line-${index}`"
             :class="{ active: selectedElement === `line-${index}` }"
             @click.stop="selectElement(`line-${index}`, 'line', index)">
          <span class="element-icon">{{ line.type === 'vertical' ? '↕️' : '↔️' }}</span>
          <span class="element-name">{{ line.type === 'vertical' ? t('elementList.defaults.verticalLineIndex', { index: index + 1 }) : t('elementList.defaults.horizontalLineIndex', { index: index + 1 }) }}</span>
          <div class="element-actions show-always" @click.stop>
            <button class="action-btn delete-btn" @click="deleteElement('line', index)" title="删除">❌</button>
          </div>
        </div>
        <div class="element-item"
             v-for="(svg, index) in svgList"
             :key="`svg-all-${svg.id || index}`"
             :class="{ active: selectedElement === `svg-${index}` }"
             @click.stop="selectElement(`svg-${index}`, 'svg', index)">
          <span class="element-icon">🧩</span>
          <span class="element-name">{{ svg.name || t('elementList.defaults.svgIndex', { index: index + 1 }) }}</span>
          <div class="element-actions show-always" @click.stop>
            <button class="action-btn delete-btn" @click="deleteElement('svg', index)" title="删除">❌</button>
          </div>
        </div>
        <div class="element-item"
             :class="{ active: selectedElement === 'aging' }"
             @click.stop="selectElement('aging', 'aging', 0)">
          <span class="element-icon">🕰️</span>
          <span class="element-name">{{ t('elementList.elements.agingEffect') }}</span>
          <span class="element-type">{{ agingEffect.applyAging ? t('elementList.status.enabled') : t('elementList.status.disabled') }}</span>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'
import { IDrawStampConfig, IDrawImage, ILineConfig, ISvgShape, ICompany, IStampType } from '../../DrawStampTypes'
import { useStampStore } from '../../stores/stampStore'

const { t } = useI18n()

interface Props {
  drawStampUtils?: any
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'selectElement', elementId: string, elementType: string, index: number): void
  (e: 'updateConfig'): void
  (e: 'refresh'): void
}>()

const selectedElement = ref<string>('')

// 编辑相关状态
const svgFileInput = ref<HTMLInputElement | null>(null)

const stampStore = useStampStore()

const config = computed(() => {
  if (stampStore.state.config) {
    return stampStore.state.config
  }
  return (props.drawStampUtils?.getDrawConfigs?.() || {}) as IDrawStampConfig
})

const companyList = computed(() => config.value.companyList || [])
const stampTypeList = computed(() => config.value.stampTypeList || [])
const stampCodeList = computed(() => {
  const cfg = config.value
  if (cfg.stampCodeList && cfg.stampCodeList.length > 0) return cfg.stampCodeList
  return cfg.stampCode ? [cfg.stampCode] : []
})
const stampCode = computed(() => config.value.stampCode || { code: '' })
const taxNumber = computed(() => config.value.taxNumber || { code: '' })
const drawStar = computed(() => config.value.drawStar || { drawStar: false })
const innerCircleList = computed(() => config.value.innerCircleList || [])
const lineList = computed(() => config.value.lineList || [])
const visibleImages = computed(() =>
  (config.value.imageList || [])
    .map((image, index) => ({ image, index }))
)
const svgList = computed(() => config.value.svgList || [])
const agingEffect = computed(() => config.value.agingEffect || { applyAging: false })
const roughEdge = computed(() => config.value.roughEdge || { drawRoughEdge: false })
const securityPattern = computed(() => config.value.securityPattern || { openSecurityPattern: false })

const selectElement = (elementId: string, elementType: string, index: number) => {
  selectedElement.value = elementId
  emit('selectElement', elementId, elementType, index)
}

// 清除文字
const clearText = (elementType: string, index: number) => {
  stampStore.updateConfig((config) => {
    if (elementType === 'company' && config.companyList && config.companyList[index]) {
      config.companyList[index].companyName = ''
    } else if (elementType === 'stampType' && config.stampTypeList && config.stampTypeList[index]) {
      config.stampTypeList[index].stampType = ''
    } else if (elementType === 'code') {
      if (config.stampCodeList && config.stampCodeList[index]) {
        config.stampCodeList[index].code = ''
      } else if (config.stampCode) {
        config.stampCode.code = ''
      }
    } else if (elementType === 'taxNumber') {
      config.taxNumber.code = ''
    }
  })

  emit('updateConfig')
  emit('refresh')
}

// 删除元素
const deleteElement = (elementType: string, index: number) => {
  if (confirm(t('elementList.confirm.deleteElement'))) {
    stampStore.updateConfig((config) => {
      if (elementType === 'company' && config.companyList) {
        config.companyList.splice(index, 1)
        // 如果删除后列表为空，取消选中
        if (config.companyList.length === 0) {
          selectedElement.value = ''
        }
      } else if (elementType === 'stampType' && config.stampTypeList) {
        config.stampTypeList.splice(index, 1)
        // 如果删除后列表为空，取消选中
        if (config.stampTypeList.length === 0) {
          selectedElement.value = ''
        }
      } else if (elementType === 'code') {
        if (config.stampCodeList) {
          config.stampCodeList.splice(index, 1)
        }
        config.stampCode = (config.stampCodeList && config.stampCodeList[0]) || config.stampCode
        if (selectedElement.value === `code-${index}`) {
          selectedElement.value = ''
        }
      } else if (elementType === 'taxNumber') {
        config.taxNumber.code = ''
        if (selectedElement.value === 'taxNumber') {
          selectedElement.value = ''
        }
      } else if (elementType === 'star' && config.drawStar) {
        config.drawStar.drawStar = false
        if (selectedElement.value === 'star') {
          selectedElement.value = ''
        }
      } else if (elementType === 'image' && config.imageList) {
        config.imageList.splice(index, 1)
        if (config.imageList.length === 0) {
          selectedElement.value = ''
        }
      } else if (elementType === 'line' && config.lineList) {
        config.lineList.splice(index, 1)
        if (config.lineList.length === 0) {
          selectedElement.value = ''
        }
      } else if (elementType === 'svg' && config.svgList) {
        config.svgList.splice(index, 1)
        if (config.svgList.length === 0) {
          selectedElement.value = ''
        }
      } else if (elementType === 'circle' && config.innerCircleList) {
        config.innerCircleList.splice(index, 1)
        if (config.innerCircleList.length === 0) {
          selectedElement.value = ''
        }
      }
    })

    emit('updateConfig')
    emit('refresh')
  }
}

const generateLineId = () => `line-${Date.now()}-${Math.floor(Math.random() * 1000)}`

const createLineConfig = (type: 'horizontal' | 'vertical', cfg: IDrawStampConfig): ILineConfig => ({
  id: generateLineId(),
  type,
  positionX: 0,
  positionY: 0,
  length: type === 'horizontal' ? cfg.width || 30 : cfg.height || 30,
  lineWidth: 0.5,
  color: cfg.primaryColor || '#d40000',
  style: 'solid',
  dashLength: 2,
  gapLength: 1,
  opacity: 1
})

const addLine = (type: 'horizontal' | 'vertical') => {
  stampStore.updateConfig((config) => {
    if (!config.lineList) {
      config.lineList = []
    }
    config.lineList.push(createLineConfig(type, config))
    const newIndex = config.lineList.length - 1
    nextTick(() => {
      selectElement(`line-${newIndex}`, 'line', newIndex)
    })
  })

  emit('updateConfig')
  emit('refresh')
}

const createCompanyConfig = (cfg: IDrawStampConfig): ICompany => {
  const list = cfg.companyList || []
  const last = list[list.length - 1]
  const currentShape = cfg.company?.shape || 'ellipse'

  if (currentShape === 'rectangle') {
    const usedPositions = new Set(list.map(c => c.rectangleTextPosition))
    const availablePositions: Array<'top' | 'bottom' | 'left' | 'right' | 'center'> = ['top', 'bottom', 'left', 'right', 'center']
    const nextPosition = availablePositions.find(pos => !usedPositions.has(pos)) || 'center'

    return {
      companyName: t('elementList.defaults.newCompanyName'),
      compression: 1,
      borderOffset: 1,
      textDistributionFactor: 3,
      fontFamily: last?.fontFamily || 'SimSun',
      fontHeight: last?.fontHeight || 4.2,
      fontWeight: last?.fontWeight || 'normal',
      shape: 'rectangle',
      adjustEllipseText: false,
      adjustEllipseTextFactor: 0.5,
      startAngle: 0,
      rotateDirection: 'counterclockwise',
      rectangleTextDirection: last?.rectangleTextDirection || 'horizontal',
      rectangleTextPosition: nextPosition,
      rectangleTextAlignment: last?.rectangleTextAlignment || 'center',
      rectangleVerticalAlignment: last?.rectangleVerticalAlignment || 'center',
      rectangleLineSpacing: last?.rectangleLineSpacing || 0,
      rectangleTextMargin: last?.rectangleTextMargin || 1,
      rectanglePositionX: last?.rectanglePositionX || 0,
      rectanglePositionY: last?.rectanglePositionY || 0
    }
  }

  const nextBorderOffset = last ? last.borderOffset + last.fontHeight : 1
  return {
    companyName: '新公司名称',
    compression: 1,
    borderOffset: nextBorderOffset,
    textDistributionFactor: 3,
    fontFamily: last?.fontFamily || 'SimSun',
    fontHeight: last?.fontHeight || 4.2,
    fontWeight: last?.fontWeight || 'normal',
    shape: 'ellipse',
    adjustEllipseText: false,
    adjustEllipseTextFactor: 0.5,
    startAngle: last?.startAngle || 0,
    rotateDirection: last?.rotateDirection || 'counterclockwise',
    rectangleTextDirection: 'horizontal',
    rectangleTextPosition: 'center',
    rectangleTextAlignment: 'center',
    rectangleVerticalAlignment: 'center',
    rectangleLineSpacing: 0,
    rectangleTextMargin: 1
  }
}

const createStampTypeConfig = (cfg: IDrawStampConfig): IStampType => {
  const list = cfg.stampTypeList || []
  const last = list[list.length - 1]
  let newPositionY = -3
  if (last) {
    newPositionY = last.positionY + last.fontHeight
  }
  return {
    stampType: t('elementList.defaults.newStampType'),
    fontHeight: last?.fontHeight || 4.0,
    fontFamily: last?.fontFamily || 'SimSun',
    compression: last?.compression ?? 0.75,
    letterSpacing: last?.letterSpacing ?? 0,
    positionY: newPositionY,
    positionX: last?.positionX ?? 0,
    fontWeight: last?.fontWeight || 'normal',
    lineSpacing: last?.lineSpacing ?? 2,
    fontWidth: last?.fontWidth ?? 3,
    orientation: last?.orientation || 'horizontal',
    color: last?.color || cfg.primaryColor,
    rotation: last?.rotation ?? 0
  }
}

const addCompanyItem = () => {
  stampStore.updateConfig((config) => {
    if (!config.companyList) {
      config.companyList = []
    }
    const newCompany = createCompanyConfig(config)
    config.companyList.push(newCompany)
    const newIndex = config.companyList.length - 1
    nextTick(() => {
      selectElement(`company-${newIndex}`, 'company', newIndex)
    })
  })

  emit('updateConfig')
  emit('refresh')
}

const addStampTypeItem = () => {
  stampStore.updateConfig((config) => {
    if (!config.stampTypeList) {
      config.stampTypeList = []
    }
    const newType = createStampTypeConfig(config)
    config.stampTypeList.push(newType)
    const newIndex = config.stampTypeList.length - 1
    nextTick(() => {
      selectElement(`stampType-${newIndex}`, 'stampType', newIndex)
    })
  })

  emit('updateConfig')
  emit('refresh')
}

const addCodeItem = () => {
  stampStore.updateConfig((config) => {
    if (!config.stampCodeList) {
      config.stampCodeList = []
      if (config.stampCode) {
        config.stampCodeList.push({ ...config.stampCode })
      }
    }
    const base = config.stampCodeList[config.stampCodeList.length - 1] || config.stampCode || {
      code: '',
      compression: 1,
      fontHeight: 1.2,
      fontFamily: 'Arial',
      borderOffset: 1,
      fontWidth: 1.2,
      textDistributionFactor: 50,
      fontWeight: 'normal',
      color: config.primaryColor || '#d40000'
    }
    config.stampCodeList.push({ ...base, code: '' })
    const newIndex = config.stampCodeList.length - 1
    nextTick(() => {
      selectElement(`code-${newIndex}`, 'code', newIndex)
    })
    config.stampCode = config.stampCodeList[0]
  })

  emit('updateConfig')
  emit('refresh')
}

// 添加图片
const addImage = () => {
  stampStore.updateConfig((config) => {
    if (!config.imageList) {
      config.imageList = []
    }
    if (config.imageList.length < 10) {
      config.imageList.push({
        imageUrl: '',
        imageWidth: 10,
        imageHeight: 10,
        positionX: 0,
        positionY: 0,
        keepAspectRatio: true,
        rotation: 0
      } as IDrawImage)
      // 自动选中新添加的图片
      const newIndex = config.imageList.length - 1
      nextTick(() => {
        selectElement(`image-${newIndex}`, 'image', newIndex)
      })
    }
  })

  emit('updateConfig')
  emit('refresh')
}

// 添加内圈圆
const addInnerCircle = () => {
  stampStore.updateConfig((config) => {
    if (!config.innerCircleList) {
      config.innerCircleList = []
    }
    config.innerCircleList.push({
      drawInnerCircle: true,
      innerCircleLineWidth: 0.5,
      innerCircleLineRadiusX: 16,
      innerCircleLineRadiusY: 12,
      lineStyle: 'solid',
      dashLength: 2,
      gapLength: 1
    })
    const newIndex = config.innerCircleList.length - 1
    nextTick(() => {
      selectElement(`circle-${newIndex}`, 'circle', newIndex)
    })
  })

  emit('updateConfig')
  emit('refresh')
}

const createSvgItem = (name: string, content: string, cfg: IDrawStampConfig): ISvgShape => ({
  id: crypto?.randomUUID ? crypto.randomUUID() : `svg-${Date.now()}`,
  name: name || `SVG ${cfg.svgList ? cfg.svgList.length + 1 : 1}`,
  svgContent: content,
  color: cfg.primaryColor || '#d40000',
  width: 12,
  height: 12,
  positionX: 0,
  positionY: 0,
  rotation: 0,
  scale: 1,
  keepAspectRatio: true,
  version: Date.now()
})

const addSvgFromContent = (name: string, content: string) => {
  stampStore.updateConfig((config) => {
    if (!config.svgList) {
      config.svgList = []
    }
    config.svgList.push(createSvgItem(name, content, config))
    const newIndex = config.svgList.length - 1
    nextTick(() => {
      selectElement(`svg-${newIndex}`, 'svg', newIndex)
    })
  })

  emit('updateConfig')
  emit('refresh')
}

const triggerSvgUpload = () => {
  svgFileInput.value?.click()
}

const handleSvgFileChange = async (event: Event) => {
  const input = event.target as HTMLInputElement
  if (!input.files?.length) return
  const file = input.files[0]
  try {
    const text = await file.text()
    addSvgFromContent(file.name.replace(/\.svg$/i, ''), text)
  } catch (error) {
    console.error(t('errors.readSvgFailed') + ':', error)
  } finally {
    input.value = ''
  }
}

// 暴露给父组件调用，方便从工具栏快速添加元素
defineExpose({
  addCompanyItem,
  addStampTypeItem,
  addCodeItem,
  addImage,
  addInnerCircle,
  addLine,
  triggerSvgUpload
})
</script>

<style scoped>
.element-list-panel {
  width: 240px;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  height: 89vh;
  box-shadow: var(--shadow-sm);
}

.panel-header {
  height: 56px;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid var(--border-color);
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-hover) 100%);
  flex-shrink: 0;
  box-shadow: var(--shadow-sm);
}

.panel-header h3 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #fff;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
  letter-spacing: 0.5px;
}

.panel-content {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  background-color: var(--bg-secondary);
}

.panel-content::-webkit-scrollbar {
  width: 6px;
}

.panel-content::-webkit-scrollbar-track {
  background: var(--bg-tertiary);
}

.panel-content::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 3px;
}

.panel-content::-webkit-scrollbar-thumb:hover {
  background: var(--text-tertiary);
}

.element-category {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.element-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid transparent;
  background: var(--bg-primary);
  box-shadow: var(--shadow-sm);
}

.element-item:hover {
  background: var(--bg-primary);
  border-color: var(--primary-border);
  box-shadow: var(--shadow-md);
  transform: translateX(2px);
}

.element-item.active {
  background: var(--primary-light);
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.element-icon {
  font-size: 18px;
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.element-name {
  flex: 1;
  font-size: 13px;
  color: var(--text-primary);
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.element-type {
  font-size: 11px;
  color: var(--text-secondary);
  padding: 3px 8px;
  background: var(--bg-tertiary);
  border-radius: var(--radius-sm);
  font-weight: 500;
}

.element-actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.element-actions.show-always {
  opacity: 1;
}

.element-item:hover .element-actions {
  opacity: 1;
}

.action-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 6px;
  font-size: 14px;
  border-radius: var(--radius);
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  color: var(--text-secondary);
}

.action-btn:hover {
  background: var(--bg-tertiary);
  color: var(--primary-color);
  transform: scale(1.05);
}

.add-image-button {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  padding: 12px;
  margin-top: 8px;
  background: var(--bg-primary);
  border: 1px dashed var(--border-color);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 13px;
  color: var(--text-secondary);
  font-weight: 500;
}

.add-image-button:hover {
  background: var(--primary-light);
  border-color: var(--primary-color);
  color: var(--primary-color);
  box-shadow: var(--shadow-sm);
}

.line-action-buttons {
  display: flex;
  gap: 8px;
  margin: 8px 0;
  flex-direction: column;
}

.add-line-button {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px;
  background: var(--bg-primary);
  border: 1px dashed var(--border-color);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 13px;
  color: var(--text-secondary);
  font-weight: 500;
}

.add-line-button:hover {
  background: var(--primary-light);
  border-color: var(--primary-color);
  color: var(--primary-color);
  box-shadow: var(--shadow-sm);
}

.add-icon {
  font-size: 16px;
}

.edit-btn:hover {
  background: var(--primary-light);
  color: var(--primary-color);
}

.clear-btn:hover {
  background: #fff7ed;
  color: var(--warning-color);
}

.delete-btn:hover {
  background: #fef2f2;
  color: var(--error-color);
}
</style>

