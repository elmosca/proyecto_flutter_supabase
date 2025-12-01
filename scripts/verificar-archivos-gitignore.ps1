# Script para verificar archivos que deberían estar en .gitignore pero están rastreados
# Ejecutar desde la raíz del proyecto

Write-Host "VERIFICANDO ARCHIVOS QUE DEBERIAN ESTAR EN .GITIGNORE" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

$problemas = @()

# Verificar archivos de build
Write-Host "Verificando archivos de build..." -ForegroundColor Yellow
$buildFiles = git ls-files | Where-Object { 
    $_ -match "dist/" -or 
    $_ -match "build/" -or 
    $_ -match "\.zip$" -or
    $_ -match "\.dll$" -or
    $_ -match "\.exe$" -or
    $_ -match "\.so$" -or
    $_ -match "\.bin$"
}

if ($buildFiles) {
    Write-Host "❌ Archivos de build encontrados:" -ForegroundColor Red
    $buildFiles | ForEach-Object { 
        Write-Host "   - $_" -ForegroundColor Red
        $problemas += $_
    }
} else {
    Write-Host "✅ No se encontraron archivos de build rastreados" -ForegroundColor Green
}

Write-Host ""

# Verificar scripts temporales
Write-Host "Verificando scripts temporales..." -ForegroundColor Yellow
$tempScripts = git ls-files | Where-Object { 
    $_ -match "refactor_.*\.py$"
}

if ($tempScripts) {
    Write-Host "❌ Scripts temporales encontrados:" -ForegroundColor Red
    $tempScripts | ForEach-Object { 
        Write-Host "   - $_" -ForegroundColor Red
        $problemas += $_
    }
} else {
    Write-Host "✅ No se encontraron scripts temporales" -ForegroundColor Green
}

Write-Host ""

# Verificar migraciones alternativas
Write-Host "Verificando migraciones alternativas..." -ForegroundColor Yellow
$altMigrations = git ls-files | Where-Object { 
    $_ -match "ALTERNATIVA|PUBLIC" -and $_ -match "\.sql$"
}

if ($altMigrations) {
    Write-Host "⚠️  Migraciones alternativas encontradas (considerar eliminar):" -ForegroundColor Yellow
    $altMigrations | ForEach-Object { 
        Write-Host "   - $_" -ForegroundColor Yellow
        $problemas += $_
    }
} else {
    Write-Host "✅ No se encontraron migraciones alternativas" -ForegroundColor Green
}

Write-Host ""

# Verificar archivos duplicados
Write-Host "Verificando archivos duplicados..." -ForegroundColor Yellow
$duplicados = @()
if ((Test-Path "estudiantes_ejemplo.csv") -and (Test-Path "ejemplos_csv/estudiantes_ejemplo.csv")) {
    $duplicados += "estudiantes_ejemplo.csv (existe en raíz y en ejemplos_csv/)"
}

if ($duplicados) {
    Write-Host "⚠️  Archivos duplicados encontrados:" -ForegroundColor Yellow
    $duplicados | ForEach-Object { 
        Write-Host "   - $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ No se encontraron archivos duplicados" -ForegroundColor Green
}

Write-Host ""

# Verificar node_modules
Write-Host "Verificando node_modules..." -ForegroundColor Yellow
$nodeModules = git ls-files | Where-Object { 
    $_ -match "node_modules/"
}

if ($nodeModules) {
    Write-Host "❌ node_modules encontrados:" -ForegroundColor Red
    $nodeModules | Select-Object -First 5 | ForEach-Object { 
        Write-Host "   - $_" -ForegroundColor Red
        $problemas += $_
    }
    if ($nodeModules.Count -gt 5) {
        Write-Host "   ... y $($nodeModules.Count - 5) más" -ForegroundColor Red
    }
} else {
    Write-Host "✅ No se encontraron node_modules rastreados" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "RESUMEN" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

if ($problemas.Count -eq 0) {
    Write-Host "Excelente! No se encontraron problemas." -ForegroundColor Green
    Write-Host "Todos los archivos rastreados son apropiados para el repositorio." -ForegroundColor Green
} else {
    Write-Host "Se encontraron $($problemas.Count) archivos problematicos" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "RECOMENDACIONES:" -ForegroundColor Cyan
    Write-Host "   1. Revisar el archivo docs/ANALISIS_LIMPIEZA_REPOSITORIO.md" -ForegroundColor Cyan
    Write-Host "   2. Actualizar .gitignore si es necesario" -ForegroundColor Cyan
    Write-Host "   3. Eliminar archivos de build del repositorio:" -ForegroundColor Cyan
    Write-Host "      git rm --cached frontend/dist/*" -ForegroundColor White
    Write-Host "      git rm --cached frontend/web-build.zip" -ForegroundColor White
    Write-Host "   4. Hacer commit de los cambios" -ForegroundColor Cyan
}

Write-Host ""

