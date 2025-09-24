# Script de configuración automática para el servidor MCP de Resend
# Ejecutar como administrador en PowerShell

param(
    [Parameter(Mandatory=$true)]
    [string]$ResendApiKey,
    
    [Parameter(Mandatory=$false)]
    [string]$SenderEmail = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ReplyToEmail = ""
)

Write-Host "🚀 Configurando servidor MCP de Resend..." -ForegroundColor Green

# Verificar que estamos en el directorio correcto
$projectRoot = "C:\dev\proyecto_flutter_supabase"
if (-not (Test-Path $projectRoot)) {
    Write-Error "❌ Directorio del proyecto no encontrado: $projectRoot"
    exit 1
}

Set-Location $projectRoot

# Verificar que el servidor MCP existe
$mcpPath = "$projectRoot\mcp-resend"
if (-not (Test-Path $mcpPath)) {
    Write-Error "❌ Servidor MCP de Resend no encontrado en: $mcpPath"
    Write-Host "💡 Ejecuta primero: git clone https://github.com/resend/mcp-send-email.git mcp-resend"
    exit 1
}

# Verificar que está compilado
$buildPath = "$mcpPath\build\index.js"
if (-not (Test-Path $buildPath)) {
    Write-Host "🔨 Compilando servidor MCP..." -ForegroundColor Yellow
    Set-Location $mcpPath
    npm install
    npm run build
    Set-Location $projectRoot
}

# Configurar archivo mcp.json
$mcpConfigPath = "$env:USERPROFILE\.cursor\mcp.json"
Write-Host "📝 Configurando archivo MCP: $mcpConfigPath" -ForegroundColor Blue

# Leer configuración actual
if (Test-Path $mcpConfigPath) {
    $config = Get-Content $mcpConfigPath | ConvertFrom-Json
} else {
    $config = @{
        mcpServers = @{}
    }
}

# Configurar servidor Resend
$resendConfig = @{
    command = "node"
    args = @("$buildPath")
    env = @{
        RESEND_API_KEY = $ResendApiKey
    }
}

# Añadir configuración opcional
if ($SenderEmail) {
    $resendConfig.env.SENDER_EMAIL_ADDRESS = $SenderEmail
}

if ($ReplyToEmail) {
    $resendConfig.env.REPLY_TO_EMAIL_ADDRESS = $ReplyToEmail
}

# Actualizar configuración
$config.mcpServers.resend = $resendConfig

# Guardar configuración
$config | ConvertTo-Json -Depth 10 | Set-Content $mcpConfigPath -Encoding UTF8

Write-Host "✅ Configuración completada!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de configuración:" -ForegroundColor Cyan
Write-Host "   • API Key: $($ResendApiKey.Substring(0, 10))..." -ForegroundColor Gray
if ($SenderEmail) {
    Write-Host "   • Sender Email: $SenderEmail" -ForegroundColor Gray
}
if ($ReplyToEmail) {
    Write-Host "   • Reply-To Email: $ReplyToEmail" -ForegroundColor Gray
}
Write-Host "   • Servidor MCP: $buildPath" -ForegroundColor Gray
Write-Host ""
Write-Host "🔄 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Reinicia Cursor completamente" -ForegroundColor White
Write-Host "   2. Verifica que el servidor MCP esté activo" -ForegroundColor White
Write-Host "   3. Prueba enviando un email desde Cursor" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Para probar la configuración:" -ForegroundColor Cyan
Write-Host "   cd $mcpPath" -ForegroundColor Gray
Write-Host "   node test_mcp.js" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentación: docs/mcp-server/README_RESEND.md" -ForegroundColor Blue
