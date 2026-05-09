<script setup lang="ts">
import StampWorkspace from './components/editor/StampWorkspace.vue'
</script>

<template>
  <div class="app-root">
    <div class="demo-wrapper">
      <StampWorkspace />
    </div>
  </div>
</template>

<style scoped>
.app-root {
  min-height: 100vh;
  display: flex;
  justify-content: flex-start;
  align-items: flex-start;
  padding: 0;
  margin: 0;
  background-color: var(--bg-secondary);
  box-sizing: border-box;
}

.demo-wrapper {
  width: 100%;
  max-width: 100%;
}
</style>
