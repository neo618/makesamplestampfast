@echo off
chcp 65001 >nul
title 印章制作工具 - 一键启动（无需安装环境）

echo.
echo ================================================
echo     印章制作工具 - 一键启动（便携版）
echo ================================================
echo.

:: 检查 dist 目录是否存在
if not exist "dist\index.html" (
    echo [错误] 未找到 dist 目录！
    echo.
    echo 请确保已将整个项目文件夹完整复制过来。
    echo.
    pause
    exit /b 1
)

echo 检测到印章工具文件，正在启动...
echo.
echo ================================================
echo  启动方式：
echo  1. 自动在浏览器中打开
echo  2. 无需安装任何软件或环境
echo ================================================
echo.

:: 尝试检测 Python 并启动简易服务器
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [方案 1] 检测到 Python，启动本地服务器...
    echo.
    echo 正在启动服务器，请稍候...
    start "印章制作工具 - 本地服务器" cmd /k "cd dist && python -m http.server 8080"
    timeout /t 3 /nobreak >nul
    start http://localhost:8080/
    echo.
    echo [成功] 服务器已启动！
    echo 访问地址：http://localhost:8080/
    goto :end
)

:: 尝试检测 PowerShell 高级版本
powershell -Command "if ($PSVersionTable.PSVersion.Major -ge 3) { exit 0 } else { exit 1 }" >nul 2>&1
if %errorlevel% equ 0 (
    echo [方案 2] 使用 PowerShell 启动本地服务器...
    echo.
    echo 正在启动服务器，请稍候...
    start "印章制作工具 - 本地服务器" powershell -Command "$listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add('http://localhost:8080/'); $listener.Start(); Write-Host '服务器已启动在 http://localhost:8080/'; while ($listener.IsListening) { $context = $listener.GetContext(); $requestPath = $context.Request.Url.LocalPath; if ($requestPath -eq '/') { $requestPath = '/index.html' }; $filePath = Join-Path 'dist' $requestPath.Replace('/', '\\'); if (Test-Path $filePath) { $bytes = [System.IO.File]::ReadAllBytes($filePath); $ext = [System.IO.Path]::GetExtension($filePath); $mimeTypes = @{'.html'='text/html';'.js'='application/javascript';'.css'='text/css';'.png'='image/png';'.jpg'='image/jpeg';'.gif'='image/gif';'.svg'='image/svg+xml';'.json'='application/json';'.woff'='font/woff';'.woff2'='font/woff2';'.ttf'='font/ttf'}; $contentType = $mimeTypes[$ext]; if (-not $contentType) { $contentType = 'application/octet-stream' }; $context.Response.ContentType = $contentType; $context.Response.ContentLength64 = $bytes.Length; $context.Response.OutputStream.Write($bytes, 0, $bytes.Length) } else { $context.Response.StatusCode = 404 }; $context.Response.Close() }"
    timeout /t 3 /nobreak >nul
    start http://localhost:8080/
    echo.
    echo [成功] 服务器已启动！
    echo 访问地址：http://localhost:8080/
    goto :end
)

:: 如果没有服务器，直接打开浏览器
echo [方案 3] 直接在浏览器中打开...
echo.
echo 注意：部分功能可能受限（如模板保存/加载），
echo 建议安装 Node.js 或 Python 以获得完整功能。
echo.
timeout /t 2 /nobreak >nul
start "" "%~dp0dist\index.html"
echo.
echo [成功] 已在浏览器中打开！
echo.
goto :end

:end
echo.
echo ================================================
echo          印章制作工具已启动！
echo.
echo  提示：
echo  - 可以关闭此窗口，不影响工具运行
echo  - 要停止服务器，请关闭服务器窗口
echo ================================================
echo.
echo 按任意键关闭此窗口...
pause >nul
