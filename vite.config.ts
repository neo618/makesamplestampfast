import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: '/makesamplestampfast/', // GitHub Pages 部署在子路径
  build: {
    outDir: "dist",
    minify: 'esbuild',
    sourcemap: false
  }
})

