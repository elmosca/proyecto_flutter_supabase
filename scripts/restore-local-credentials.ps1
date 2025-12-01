# Script para restaurar las credenciales reales de Supabase después de hacer push
# Úsalo después de hacer push a GitHub para que la app funcione localmente

Write-Host "🔓 RESTAURANDO CREDENCIALES LOCALES" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

$appConfigPath = "frontend/lib/config/app_config.dart"

if (-not (Test-Path $appConfigPath)) {
    Write-Host "❌ Error: No se encuentra $appConfigPath" -ForegroundColor Red
    exit 1
}

Write-Host "📝 Restaurando credenciales de Supabase..." -ForegroundColor Cyan

# Leer el archivo
$content = Get-Content $appConfigPath -Raw

# Restaurar URL de Supabase
$content = $content -replace 'https://TU_PROYECTO\.supabase\.co', 'https://zkririyknhlwoxhsoqih.supabase.co'

# Restaurar Anon Key
$content = $content -replace 'TU_ANON_KEY_AQUI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcmlyaXlrbmhsd294aHNvcWloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDkxNjUsImV4cCI6MjA3MTk4NTE2NX0.N9egQFLIqsYdbpjOeSELNiHy5G5RWqa0JY5luZWNBJg'

# Restaurar Project ID en URLs
$content = $content -replace 'TU_PROYECTO_ID', 'zkririyknhlwoxhsoqih'

# Restaurar credenciales de prueba
$content = $content -replace 'estudiante@tu-dominio\.es', 'laura.sanchez@jualas.es'
$content = $content -replace 'tutor@tu-dominio\.es', 'jualas@jualas.es'
$content = $content -replace 'admin@tu-dominio\.es', 'admin@jualas.es'
$content = $content -replace "'password123',\s*// Contraseña temporal de Laura Sánchez", "'EzmvfdQmijMa', // Contraseña temporal de Laura Sánchez"

# Escribir el archivo modificado
Set-Content -Path $appConfigPath -Value $content -NoNewline

Write-Host "✅ Credenciales restauradas" -ForegroundColor Green
Write-Host ""
Write-Host "La aplicacion ahora funcionara localmente con las credenciales reales" -ForegroundColor Cyan
Write-Host ""

