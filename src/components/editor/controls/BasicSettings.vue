<template>
  <div class="control-group">
    <div class="group-header" @click="$emit('toggle')">
      <h3>
        {{ t('stamp.basic.title') }}
        <span class="expand-icon" :class="{ expanded: expanded }">▼</span>
      </h3>
    </div>
    <div class="group-content" v-show="expanded">
      <label class="checkbox-label">
        <input type="checkbox" v-model="state.isCircleDetect.value" />
        {{ t('stamp.basic.extractCircle') }}
      </label>
      <label>
        {{ t('stamp.basic.width') }}:
        <input
          type="number"
          v-model.number="state.drawStampWidth.value"
          min="1"
          max="50"
          step="0.1"
        />
      </label>
      <label>
        {{ t('stamp.basic.height') }}:
        <input
          type="number"
          v-model.number="state.drawStampHeight.value"
          min="1"
          max="50"
          step="0.1"
        />
      </label>
      <label>
        {{ t('stamp.basic.borderWidth') }}:
        <input
          type="number"
          step="0.1"
          v-model.number="state.circleBorderWidth.value"
        />
      </label>
      <label>
        {{ t('stamp.basic.color') }}:
        <input type="color" v-model="state.primaryColor.value" />
      </label>
      <label class="checkbox-label">
        <input type="checkbox" v-model="state.drawOutBorder.value" />
        {{ t('stamp.outBorder.enable') }}
      </label>
      <label v-if="state.drawOutBorder.value">
        {{ t('stamp.outBorder.lineWidth') }}:
        <input
          type="number"
          v-model.number="state.outBorderLineWidth.value"
          min="0.1"
          max="5"
          step="0.1"
        />
      </label>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { Ref } from 'vue'

interface BasicState {
  isCircleDetect: Ref<boolean>
  drawStampWidth: Ref<number>
  drawStampHeight: Ref<number>
  circleBorderWidth: Ref<number>
  primaryColor: Ref<string>
  drawOutBorder: Ref<boolean>
  outBorderLineWidth: Ref<number>
}

const props = defineProps<{
  expanded: boolean
  state: BasicState
}>()

const emit = defineEmits<{
  (e: 'toggle'): void
}>()

const { t } = useI18n()
</script>

<style scoped>
.control-group {
  margin-bottom: 16px;
  background: var(--bg-primary);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border-light);
  overflow: hidden;
  transition: all 0.2s ease;
}

.control-group:hover {
  box-shadow: var(--shadow-md);
  border-color: var(--primary-border);
}

.group-header {
  padding: 14px 16px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  user-select: none;
}

.group-header h3 {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: var(--text-primary);
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.expand-icon {
  transition: transform 0.2s ease;
  margin-left: 8px;
  font-size: 12px;
  color: var(--text-tertiary);
}

.expand-icon.expanded {
  transform: rotate(180deg);
}

.group-content {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: var(--bg-primary);
}

label {
  display: flex;
  flex-direction: column;
  font-size: 13px;
  color: var(--text-secondary);
  gap: 6px;
  font-weight: 500;
}

.checkbox-label {
  flex-direction: row !important;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.checkbox-label input[type='checkbox'] {
  width: 16px;
  height: 16px;
  cursor: pointer;
  accent-color: var(--primary-color);
}

input[type='number'],
input[type='color'] {
  padding: 8px 12px;
  border: 1px solid var(--border-color);
  border-radius: var(--radius);
  font-size: 13px;
  background: var(--bg-primary);
  color: var(--text-primary);
  transition: all 0.2s ease;
}

input[type='number']:focus,
input[type='color']:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px var(--primary-light);
  outline: none;
}

input[type='number']:hover,
input[type='color']:hover {
  border-color: var(--primary-border);
}

input[type='color'] {
  height: 38px;
  padding: 4px;
  cursor: pointer;
}
</style>

