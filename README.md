# MakeSampleStampFast - 快速印章制作工具

[![npm](https://img.shields.io/npm/v/drawstamputils.svg)](https://www.npmjs.com/package/drawstamputils)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

---

> ### 安全警告
> 
> 本项目仅供学习和参考！严禁用于任何非法用途！
> 
> 1. 本项目开源代码仅用于技术学习和交流
> 2. 使用本项目生成的任何图片请勿用于任何非法用途
> 3. 因违法使用本项目造成的任何法律责任和损失，需自行承担，与本项目无关
> 4. 如果使用本项目请遵守相关法律法规

---

## 简介

**MakeSampleStampFast** 是一个专注于**快速制作简单印章**的轻量级工具。

与复杂的印章设计工具不同，本项目的设计理念是：

- 用最少的参数完成印章制作
- 无需学习复杂的配置选项
- 快速生成标准的圆形/椭圆形印章
- 所有处理在浏览器本地完成，保护隐私

核心功能：公司名称、印章类型、防伪编码一键生成，支持导出 PNG/JPEG/SVG 格式。


## 快速开始

### 安装

```bash
# 作为 npm 包使用
npm install drawstamputils

# 或克隆源码运行
git clone https://github.com/xxss0903/drawstamputils.git
cd drawstamputils
npm install
```

### 运行

```bash
# 开发模式
npm run dev

# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

构建完成后，`dist` 目录可直接部署到任何静态服务器。

## 界面说明

项目包含一个简洁的编辑器界面（`StampWorkspace.vue`），布局如下：

- **左侧** - 元素列表（公司名称、印章类型、内圈、图片等）
- **中间** - 画布区域（实时预览印章效果）
- **右侧** - 属性面板（调整字体、大小、颜色等参数）
- **底部** - 工具按钮（导入/导出模板、重置、下载图片）

## 核心配置

DrawStampUtils 支持以下主要配置选项：

| 配置项 | 说明 |
|--------|------|
| `companyName` | 公司名称 |
| `stampType` | 印章类型（如"合同专用章"） |
| `code` | 防伪编码 |
| `width` / `height` | 印章尺寸（mm） |
| `primaryColor` | 印章颜色 |
| `fontFamily` | 字体 |
| `starDiameter` | 五角星直径 |

完整配置请参考 `src/DrawStampTypes.ts` 或在线 Demo 中的实现。

## 模板功能

### 保存模板

```typescript
const configs = drawStampUtils.getDrawConfigs()
const jsonStr = JSON.stringify(configs, null, 2)
// 将 jsonStr 保存为 .json 文件
```

### 加载模板

```typescript
const jsonStr = await readTemplateFile()
const configs = JSON.parse(jsonStr)
drawStampUtils.setDrawConfigs(configs)
```

## 部署

本项目可直接部署到：

- GitHub Pages
- Vercel
- Netlify
- 任何静态服务器

构建产物在 `dist` 目录，直接上传即可。

## 技术栈

- Vue 3 + TypeScript
- Vite 构建工具
- Canvas API 渲染

## 许可证

Apache License 2.0

## 更新日志

### v1.0.0 (2025-12-16)

- 首个正式版发布
- 优化印章编辑器 UI 和交互体验
- 支持导入/导出模板、重置、多格式图片导出
- 支持更多字体、边框、毛边和防伪纹理效果

### v0.2.1 (2024-11-16)

- 新增内圈圆形列表，支持动态添加/删除
- 新增印章模板保存和加载功能

### v0.2.0 (2024-11-15)

- 新增公司名称和印章类型的数组支持
- 新增图片绘制功能

---

**本项目仅用于技术学习和交流，请勿用于任何非法用途。**
