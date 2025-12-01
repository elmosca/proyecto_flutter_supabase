# Script para preparar el código antes de hacer push a GitHub
# Reemplaza las credenciales reales de Supabase con placeholders

Write-Host "🔒 PREPARANDO CÓDIGO PARA GITHUB" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host ""

$appConfigPath = "frontend/lib/config/app_config.dart"

if (-not (Test-Path $appConfigPath)) {
    Write-Host "❌ Error: No se encuentra $appConfigPath" -ForegroundColor Red
    exit 1
}

Write-Host "📝 Reemplazando credenciales de Supabase..." -ForegroundColor Cyan

# Leer el archivo
$content = Get-Content $appConfigPath -Raw

# Reemplazar URL de Supabase
$content = $content -replace 'https://zkririyknhlwoxhsoqih\.supabase\.co', 'https://TU_PROYECTO.supabase.co'

# Reemplazar Anon Key (JWT completo)
$anonKeyPattern = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0\.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg'
$content = $content -replace $anonKeyPattern, 'TU_ANON_KEY_AQUI'

# Reemplazar Project ID en URLs
$content = $content -replace 'zkririyknhlwoxhsoqih', 'TU_PROYECTO_ID'

# Reemplazar credenciales de prueba
$content = $content -replace 'laura\.sanchez@jualas\.es', 'estudiante@tu-dominio.es'
$content = $content -replace 'jualas@jualas\.es', 'tutor@tu-dominio.es'
$content = $content -replace 'admin@jualas\.es', 'admin@tu-dominio.es'
$content = $content -replace 'EzmvfdQmijMa', 'password123'

# Escribir el archivo modificado
Set-Content -Path $appConfigPath -Value $content -NoNewline

Write-Host "✅ Credenciales reemplazadas con placeholders" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Yellow
Write-Host "   - Las credenciales reales han sido reemplazadas por placeholders" -ForegroundColor Yellow
Write-Host "   - El archivo está listo para commit y push a GitHub" -ForegroundColor Yellow
Write-Host "   - Para restaurar las credenciales reales localmente, ejecuta:" -ForegroundColor Yellow
Write-Host "     git checkout frontend/lib/config/app_config.dart" -ForegroundColor White
Write-Host ""

