# Script para reemplazar credenciales reales con placeholders antes de push a GitHub
# Ejecutar antes de hacer commit/push si has modificado app_config_local.dart con credenciales reales

Write-Host "Preparando credenciales para GitHub..." -ForegroundColor Yellow
Write-Host ""

$configPath = "frontend/lib/config/app_config_local.dart"

if (-not (Test-Path $configPath)) {
    Write-Host "No se encuentra $configPath" -ForegroundColor Red
    exit 1
}

$content = Get-Content $configPath -Raw

# Verificar si ya tiene placeholders
if ($content -match "TU_PROYECTO|TU_ANON_KEY_AQUI") {
    Write-Host "El archivo ya tiene placeholders. No es necesario reemplazar." -ForegroundColor Green
    exit 0
}

# Reemplazar credenciales reales con placeholders
Write-Host "Reemplazando credenciales reales con placeholders..." -ForegroundColor Cyan

# Reemplazar URL
$content = $content -replace 'https://zkririyknhlwoxhsoqih\.supabase\.co', 'https://TU_PROYECTO.supabase.co'

# Reemplazar Anon Key (JWT completo)
$anonKeyPattern = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0\.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg'
$content = $content -replace $anonKeyPattern, 'TU_ANON_KEY_AQUI'

# Reemplazar Project ID
$content = $content -replace 'zkririyknhlwoxhsoqih', 'TU_PROYECTO_ID'

Set-Content -Path $configPath -Value $content -NoNewline

Write-Host "Credenciales reemplazadas con placeholders." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE: Despues del push, restaura tus credenciales reales localmente." -ForegroundColor Yellow
Write-Host ""

