<template>
  <div class="properties-panel">
    <div class="panel-header">
      <h3>{{ t('common.properties.title') }}</h3>
    </div>
    <div class="panel-content">
      <EditorControls
        v-if="drawStampUtils"
        ref="editorControlsRef"
        :drawStampUtils="drawStampUtils"
        :selected-element-type="elementType"
        :selected-element-index="elementIndex"
        :show-all="showAll"
        @updateDrawStamp="handleUpdateDrawStamp"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import EditorControls from '../../EditorControls.vue'
import { IDrawStampConfig } from '../../DrawStampTypes'

const { t } = useI18n()

interface Props {
  drawStampUtils: any
  selectedElement?: string
  elementType?: string
  elementIndex?: number
}

const props = defineProps<Props>()

// 控制是否显示全部设置面板，默认关闭
const showAll = ref(false)

const emit = defineEmits<{
  (e: 'updateDrawStamp', config: IDrawStampConfig, refreshSecurityPattern: boolean, refreshOld: boolean, refreshRoughEdge: boolean): void
}>()

const editorControlsRef = ref<InstanceType<typeof EditorControls> | null>(null)

const handleUpdateDrawStamp = (
  config: IDrawStampConfig,
  refreshSecurityPattern: boolean,
  refreshOld: boolean,
  refreshRoughEdge: boolean
) => {
  emit('updateDrawStamp', config, refreshSecurityPattern, refreshOld, refreshRoughEdge)
}

// 元素类型到设置组名称的映射
const elementTypeToGroupMap: Record<string, 'basic' | 'company' | 'stampType' | 'code' | 'taxNumber' | 'star' | 'innerCircle' | 'images' | 'svg' | 'aging' | 'roughEdge' | 'security' | 'lines'> = {
  'basic': 'basic',
  'company': 'company',
  'stampType': 'stampType',
  'code': 'code',
  'taxNumber': 'taxNumber',
  'star': 'star',
  'circle': 'innerCircle',
  'image': 'images',
  'svg': 'svg',
  'aging': 'aging',
  'roughEdge': 'roughEdge',
  'security': 'security',
  'line': 'lines'
}

// 元素类型变化时，EditorControls 会根据 selectedElementType 自动显示/隐藏对应的 control-group
// 这里不需要额外的处理逻辑

// 暴露方法供父组件调用
defineExpose({
  restoreDrawConfigs: () => {
    editorControlsRef.value?.restoreDrawConfigs()
  },
  scrollToCompanyText: (index: number) => {
    editorControlsRef.value?.scrollToCompanyText(index)
  },
  scrollToCode: () => {
    editorControlsRef.value?.scrollToCode()
  },
  scrollToStampType: (index: number) => {
    editorControlsRef.value?.scrollToStampType(index)
  },
  scrollToTaxNumber: () => {
    editorControlsRef.value?.scrollToTaxNumber()
  }
})
</script>

<style scoped>
.properties-panel {
  width: 380px;
  background: var(--bg-primary);
  border-left: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  height: 60vh;
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.panel-header {
  height: 56px;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
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
  flex: 1;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
  letter-spacing: 0.5px;
}

.show-all-toggle {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.9);
  cursor: pointer;
  user-select: none;
  font-weight: 500;
}

.show-all-toggle input[type="checkbox"] {
  cursor: pointer;
  width: 16px;
  height: 16px;
  accent-color: var(--primary-color);
}

.show-all-toggle span {
  cursor: pointer;
}

.panel-content {
  flex: 1;
  overflow-y: auto;
  background-color: var(--bg-secondary);
  padding: 12px;
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
</style>

