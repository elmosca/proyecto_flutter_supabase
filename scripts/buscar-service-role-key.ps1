# Script para buscar Service Role Key de Supabase en el historial de Git
# Uso: .\scripts\buscar-service-role-key.ps1

Write-Host "🔍 Buscando Service Role Key de Supabase en el historial de Git..." -ForegroundColor Yellow
Write-Host ""

# Buscar commits que puedan contener service role keys
Write-Host "📋 Buscando en commits recientes..." -ForegroundColor Cyan
git log --all --full-history --source --pretty=format:"%H|%ai|%s" -- "*config*" "*env*" "*credential*" | 
    Select-Object -First 50 | 
    ForEach-Object {
        $parts = $_ -split '\|'
        if ($parts.Length -ge 3) {
            Write-Host "Commit: $($parts[0])" -ForegroundColor Gray
            Write-Host "  Fecha: $($parts[1])" -ForegroundColor Gray
            Write-Host "  Mensaje: $($parts[2])" -ForegroundColor Gray
            Write-Host ""
        }
    }

Write-Host ""
Write-Host "🔍 Buscando JWT tokens que puedan ser Service Role Keys..." -ForegroundColor Cyan
Write-Host ""

# Buscar JWT tokens en archivos de configuración
$files = @(
    "frontend/lib/config/*.dart",
    "config/*.env*",
    "*.env*",
    "supabase/functions/**/*.ts"
)

foreach ($pattern in $files) {
    $found = git grep -n "eyJ" -- $pattern 2>$null
    if ($found) {
        Write-Host "⚠️  Posibles JWT encontrados en: $pattern" -ForegroundColor Red
        $found | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

Write-Host ""
Write-Host "📝 Instrucciones:" -ForegroundColor Green
Write-Host "1. Si encuentras una Service Role Key, RÓTALA INMEDIATAMENTE en Supabase Dashboard" -ForegroundColor White
Write-Host "2. Revisa la guía: docs/SEGURIDAD_ROTAR_SERVICE_ROLE_KEY.md" -ForegroundColor White
Write-Host "3. Para ver el contenido de un commit específico:" -ForegroundColor White
Write-Host "   git show <commit-hash>:<ruta-archivo>" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Búsqueda completada" -ForegroundColor Green

