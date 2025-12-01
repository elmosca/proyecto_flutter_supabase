# Script para configurar app_config_local.dart desde la plantilla
# Ejecutar cuando se clona el repositorio por primera vez

Write-Host "Configurando archivo de configuracion local..." -ForegroundColor Cyan
Write-Host ""

$templatePath = "frontend/lib/config/app_config_template.dart"
$localPath = "frontend/lib/config/app_config_local.dart"

if (Test-Path $localPath) {
    Write-Host "El archivo app_config_local.dart ya existe." -ForegroundColor Yellow
    Write-Host "Si quieres recrearlo desde la plantilla, eliminalo primero." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path $templatePath)) {
    Write-Host "Error: No se encuentra la plantilla $templatePath" -ForegroundColor Red
    exit 1
}

# Copiar plantilla a archivo local
Copy-Item $templatePath $localPath

Write-Host "Archivo app_config_local.dart creado desde la plantilla." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Yellow
Write-Host "1. Abre frontend/lib/config/app_config_local.dart" -ForegroundColor White
Write-Host "2. Obtén tus credenciales en: https://app.supabase.com/project/_/settings/api" -ForegroundColor White
Write-Host "3. Completa los valores TU_PROYECTO y TU_ANON_KEY_AQUI con tus credenciales reales" -ForegroundColor White
Write-Host ""

