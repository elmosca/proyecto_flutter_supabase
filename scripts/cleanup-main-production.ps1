# Script para limpiar main y dejar solo archivos esenciales para producción
# Ejecutar directamente en la rama main después de hacer merge con develop

Write-Host "🧹 LIMPIEZA SELECTIVA DE MAIN (PRODUCCIÓN)" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Verificar que estamos en main
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "❌ Error: Este script debe ejecutarse en la rama 'main'. Estás en: $currentBranch" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Estás en la rama: $currentBranch" -ForegroundColor Green

# Eliminar subdirectorios de docs/desarrollo/ excepto 01-configuracion/
Write-Host "`n🗑️  Eliminando subdirectorios no esenciales de docs/desarrollo/..." -ForegroundColor Yellow
$desarrolloSubdirs = @("02-progreso", "03-guias-tecnicas", "04-despliegue", "05-historicos")
foreach ($subdir in $desarrolloSubdirs) {
    $path = "docs/desarrollo/$subdir"
    if (Test-Path $path) {
        Write-Host "   Eliminando: $path" -ForegroundColor Gray
        git rm -r --cached $path -f 2>$null
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Eliminar archivos sueltos en docs/desarrollo/ (mantener solo README.md y 01-configuracion/)
Write-Host "`n🗑️  Eliminando archivos sueltos de docs/desarrollo/..." -ForegroundColor Yellow
$desarrolloFiles = Get-ChildItem -Path "docs/desarrollo" -File -ErrorAction SilentlyContinue
foreach ($file in $desarrolloFiles) {
    if ($file.Name -ne "README.md") {
        $path = "docs/desarrollo/$($file.Name)"
        Write-Host "   Eliminando: $path" -ForegroundColor Gray
        git rm --cached $path -f 2>$null
        Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
    }
}

# Lista de archivos/directorios a ELIMINAR
$pathsToRemove = @(
    # Builds y artefactos
    "frontend/build",
    "frontend/dist",
    "frontend/web-build.zip",
    "build",
    
    # Documentación de desarrollo (ya manejado arriba, pero por si acaso)
    "docs/pruebas",
    
    # Scripts de desarrollo
    "scripts",
    "refactor_anteprojects.py",
    "refactor_files.py",
    "refactor_remaining_services.py",
    "refactor_tasks.py",
    
    # Archivos temporales
    "frontend/*.log",
    "frontend/*.iml",
    "frontend/untranslated_messages.txt",
    "frontend/flutter_*.log",
    
    # Node modules
    "node_modules",
    "frontend/node_modules",
    "mcp-resend/node_modules",
    "mcp-server/node_modules",
    
    # Archivos de IDE
    ".vscode",
    ".idea",
    "*.code-workspace",
    
    # Documentación de desarrollo
    "docs/Anteproyecto*.pdf",
    
    # Archivos de configuración local (mantener solo .example)
    "config/*.env"
)

Write-Host "`n🗑️  Eliminando archivos no esenciales..." -ForegroundColor Yellow

foreach ($path in $pathsToRemove) {
    $fullPath = Join-Path (Get-Location) $path
    if (Test-Path $fullPath) {
        Write-Host "   Eliminando: $path" -ForegroundColor Gray
        git rm -r --cached $path -f 2>$null
        Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Hacer commit de limpieza
Write-Host "`n📝 Haciendo commit de limpieza..." -ForegroundColor Yellow
git add -A
$hasChanges = git diff --cached --quiet
if (-not $hasChanges) {
    Write-Host "   ℹ️  No hay cambios para commitear" -ForegroundColor Gray
} else {
    git commit -m "chore: Limpiar archivos no esenciales para producción

- Eliminados builds y artefactos
- Eliminada documentación de desarrollo interno (excepto 01-configuracion/)
- Eliminados tests y scripts de desarrollo
- Mantenidos solo archivos esenciales para producción:
  * Código fuente completo (frontend/lib/)
  * Tests (frontend/test/) como documentación viva
  * Guías de setup (docs/desarrollo/01-configuracion/)
  * Base de datos (docs/base_datos/)
  * Wiki (wiki_setup/)
  * Guías de usuario y despliegue
  * README.md y LICENSE"
    Write-Host "   ✅ Commit de limpieza realizado" -ForegroundColor Green
}

# Mostrar resumen
Write-Host "`n📊 Resumen de archivos en main (producción):" -ForegroundColor Yellow
$fileCount = (git ls-files | Measure-Object).Count
Write-Host "   Total de archivos: $fileCount" -ForegroundColor Cyan

Write-Host "`n📁 Estructura principal:" -ForegroundColor Yellow
git ls-files | Where-Object { $_ -match "^frontend/lib/" } | Measure-Object | ForEach-Object {
    Write-Host "   frontend/lib/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^frontend/test/" } | Measure-Object | ForEach-Object {
    Write-Host "   frontend/test/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^wiki_setup/" } | Measure-Object | ForEach-Object {
    Write-Host "   wiki_setup/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^docs/base_datos/" } | Measure-Object | ForEach-Object {
    Write-Host "   docs/base_datos/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^docs/desarrollo/01-configuracion/" } | Measure-Object | ForEach-Object {
    Write-Host "   docs/desarrollo/01-configuracion/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^docs/guias_usuario/" } | Measure-Object | ForEach-Object {
    Write-Host "   docs/guias_usuario/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^docs/despliegue/" } | Measure-Object | ForEach-Object {
    Write-Host "   docs/despliegue/: $($_.Count) archivos" -ForegroundColor Cyan
}
git ls-files | Where-Object { $_ -match "^frontend/docker/" } | Measure-Object | ForEach-Object {
    Write-Host "   frontend/docker/: $($_.Count) archivos" -ForegroundColor Cyan
}
if (Test-Path "README.md") {
    Write-Host "   README.md: ✅ incluido" -ForegroundColor Green
}
if (Test-Path "LICENSE") {
    Write-Host "   LICENSE: ✅ incluido" -ForegroundColor Green
}

Write-Host "`n✅ Limpieza completada en main" -ForegroundColor Green
Write-Host "`n📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Revisar los cambios: git log --oneline -1" -ForegroundColor Cyan
Write-Host "   2. Si todo está bien, push a main: git push origin main" -ForegroundColor Cyan
Write-Host ""

