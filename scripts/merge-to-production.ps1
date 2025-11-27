# Script para hacer merge selectivo a main (producción)
# Solo incluye archivos esenciales para producción

param(
    [switch]$DryRun = $false
)

Write-Host "🚀 MERGE SELECTIVO A MAIN (PRODUCCIÓN)" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Verificar que estamos en el directorio correcto
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: No se encontró el repositorio Git. Ejecuta desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# Verificar que estamos en develop
$currentBranch = git branch --show-current
if ($currentBranch -ne "develop") {
    Write-Host "⚠️  Advertencia: No estás en la rama 'develop'. Estás en: $currentBranch" -ForegroundColor Yellow
    $continue = Read-Host "¿Deseas continuar de todas formas? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        exit 0
    }
}

# Verificar que develop está actualizado
Write-Host "`n📋 Verificando estado de develop..." -ForegroundColor Yellow
git fetch origin
$localCommit = git rev-parse develop
$remoteCommit = git rev-parse origin/develop

if ($localCommit -ne $remoteCommit) {
    Write-Host "⚠️  Advertencia: La rama local 'develop' no está actualizada con 'origin/develop'" -ForegroundColor Yellow
    Write-Host "   Local:  $localCommit" -ForegroundColor Gray
    Write-Host "   Remote: $remoteCommit" -ForegroundColor Gray
    $pull = Read-Host "¿Deseas hacer pull de develop? (S/N)"
    if ($pull -eq "S" -or $pull -eq "s") {
        git pull origin develop
    }
}

# Crear rama temporal para producción
$prodBranch = "production-merge-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Host "`n📋 Creando rama temporal: $prodBranch" -ForegroundColor Yellow

if (-not $DryRun) {
    git checkout -b $prodBranch develop
} else {
    Write-Host "   [DRY RUN] Se crearía la rama: $prodBranch" -ForegroundColor Gray
}

# Lista de archivos/directorios a ELIMINAR (no esenciales para producción)
# NOTA: Se mantienen explícitamente:
# - wiki_setup/ (wiki del proyecto)
# - frontend/ (código fuente completo, incluyendo test/)
# - README.md (documentación principal)
# - LICENSE (licencia)
# - docs/base_datos/ (migraciones y modelo de datos)
# - docs/desarrollo/01-configuracion/ (guías esenciales de setup)
$pathsToRemove = @(
    # Builds y artefactos
    "frontend/build",
    "frontend/dist",
    "frontend/web-build.zip",
    "build",
    
    # Tests (MANTENER - son documentación viva)
    # "frontend/test",  # NO ELIMINAR - útil para desarrolladores
    "docs/pruebas",
    
    # Documentación de desarrollo interno (mantener solo 01-configuracion/)
    # "docs/desarrollo",  # NO ELIMINAR TODO - mantener 01-configuracion/
    
    # Scripts de desarrollo (mantener solo scripts de despliegue)
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
    "config/*.env",
    "!config/*.example"
)

Write-Host "`n🗑️  Eliminando archivos no esenciales..." -ForegroundColor Yellow

# Eliminar subdirectorios de docs/desarrollo/ excepto 01-configuracion/
$desarrolloSubdirs = @("02-progreso", "03-guias-tecnicas", "04-despliegue", "05-historicos")
foreach ($subdir in $desarrolloSubdirs) {
    $path = "docs/desarrollo/$subdir"
    $fullPath = Join-Path (Get-Location) $path
    if (Test-Path $fullPath) {
        if (-not $DryRun) {
            Write-Host "   Eliminando: $path" -ForegroundColor Gray
            git rm -r --cached $path -f 2>$null
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "   [DRY RUN] Se eliminaría: $path" -ForegroundColor Gray
        }
    }
}

# Eliminar archivos sueltos en docs/desarrollo/ (mantener solo README.md y 01-configuracion/)
$desarrolloFiles = Get-ChildItem -Path "docs/desarrollo" -File -ErrorAction SilentlyContinue
foreach ($file in $desarrolloFiles) {
    if ($file.Name -ne "README.md") {
        $path = "docs/desarrollo/$($file.Name)"
        if (-not $DryRun) {
            Write-Host "   Eliminando: $path" -ForegroundColor Gray
            git rm --cached $path -f 2>$null
            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "   [DRY RUN] Se eliminaría: $path" -ForegroundColor Gray
        }
    }
}

foreach ($path in $pathsToRemove) {
    if ($path.StartsWith("!")) {
        # Patrón de exclusión, saltar
        continue
    }
    
    $fullPath = Join-Path (Get-Location) $path
    if (Test-Path $fullPath) {
        if (-not $DryRun) {
            Write-Host "   Eliminando: $path" -ForegroundColor Gray
            git rm -r --cached $path -f 2>$null
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "   [DRY RUN] Se eliminaría: $path" -ForegroundColor Gray
        }
    }
}

# Añadir .gitignore actualizado si es necesario
Write-Host "`n📋 Verificando .gitignore..." -ForegroundColor Yellow
if (-not $DryRun) {
    # Asegurar que builds están en .gitignore
    $gitignoreContent = Get-Content .gitignore -Raw
    if ($gitignoreContent -notmatch "frontend/dist/") {
        Add-Content .gitignore "`n# Builds de producción`nfrontend/dist/`nfrontend/web-build.zip`n"
        Write-Host "   ✅ .gitignore actualizado" -ForegroundColor Green
    }
}

# Hacer commit de limpieza
if (-not $DryRun) {
    Write-Host "`n📝 Haciendo commit de limpieza..." -ForegroundColor Yellow
    git add -A
    $hasChanges = git diff --cached --quiet
    if (-not $hasChanges) {
        git commit -m "chore: Limpiar archivos no esenciales para producción

- Eliminados builds y artefactos
- Eliminada documentación de desarrollo interno
- Eliminados tests y scripts de desarrollo
- Mantenidos solo archivos esenciales para producción"
        Write-Host "   ✅ Commit de limpieza realizado" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  No hay cambios para commitear" -ForegroundColor Gray
    }
} else {
    Write-Host "`n[DRY RUN] Se haría commit de limpieza" -ForegroundColor Gray
}

# Mostrar resumen
Write-Host "`n📊 Resumen de archivos en la rama de producción:" -ForegroundColor Yellow
if (-not $DryRun) {
    $fileCount = (git ls-files | Measure-Object).Count
    Write-Host "   Total de archivos: $fileCount" -ForegroundColor Cyan
    
    Write-Host "`n📁 Estructura principal:" -ForegroundColor Yellow
    git ls-files | Where-Object { $_ -match "^frontend/lib/" } | Measure-Object | ForEach-Object {
        Write-Host "   frontend/lib/: $($_.Count) archivos" -ForegroundColor Cyan
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
    git ls-files | Where-Object { $_ -match "^frontend/test/" } | Measure-Object | ForEach-Object {
        Write-Host "   frontend/test/: $($_.Count) archivos" -ForegroundColor Cyan
    }
    if (Test-Path "README.md") {
        Write-Host "   README.md: ✅ incluido" -ForegroundColor Green
    }
    if (Test-Path "LICENSE") {
        Write-Host "   LICENSE: ✅ incluido" -ForegroundColor Green
    }
}

Write-Host "`n✅ Rama de producción preparada: $prodBranch" -ForegroundColor Green
Write-Host "`n📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Revisar los cambios: git diff develop..$prodBranch" -ForegroundColor Cyan
Write-Host "   2. Si todo está bien, hacer merge a main:" -ForegroundColor Cyan
Write-Host "      git checkout main" -ForegroundColor Gray
Write-Host "      git merge $prodBranch --no-ff -m 'chore: Merge a producción - versión limpia'" -ForegroundColor Gray
Write-Host "   3. Push a main: git push origin main" -ForegroundColor Cyan
Write-Host "   4. Eliminar rama temporal: git branch -d $prodBranch" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "⚠️  Este fue un DRY RUN. No se hicieron cambios reales." -ForegroundColor Yellow
    Write-Host "   Ejecuta sin -DryRun para aplicar los cambios." -ForegroundColor Yellow
}

