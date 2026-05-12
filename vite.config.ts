import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: '/', // Zeabur 部署在根路径
  build: {
    outDir: "dist",
    minify: 'esbuild',
    sourcemap: false
  }
})

