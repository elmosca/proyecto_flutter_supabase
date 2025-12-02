# Script para eliminar Service Role Key de Supabase del historial de Git
# Uso: .\scripts\eliminar-service-role-key-historial.ps1

param(
    [string]$ServiceRoleKey = "",
    [switch]$DryRun = $false
)

Write-Host "🔐 Script para eliminar Service Role Key del historial de Git" -ForegroundColor Yellow
Write-Host ""

# Verificar que estamos en un repositorio Git
if (-not (Test-Path .git)) {
    Write-Host "❌ Error: No estás en un repositorio Git" -ForegroundColor Red
    exit 1
}

# Verificar que no hay cambios sin commitear
$status = git status --porcelain
if ($status) {
    Write-Host "⚠️  ADVERTENCIA: Tienes cambios sin commitear:" -ForegroundColor Yellow
    Write-Host $status -ForegroundColor Gray
    Write-Host ""
    $response = Read-Host "¿Deseas continuar de todos modos? (s/N)"
    if ($response -ne "s" -and $response -ne "S") {
        Write-Host "❌ Operación cancelada" -ForegroundColor Red
        exit 1
    }
}

# Si no se proporciona la clave, intentar encontrarla
if ([string]::IsNullOrEmpty($ServiceRoleKey)) {
    Write-Host "🔍 Buscando Service Role Key en el historial..." -ForegroundColor Cyan
    
    # Buscar JWT tokens que puedan ser Service Role Keys
    # Las Service Role Keys tienen "role":"service_role" en el payload
    $commits = git log --all --full-history --source --pretty=format:"%H" -- "*config*" "*env*" "*credential*" "*app_config*"
    
    Write-Host "📋 Revisando commits recientes..." -ForegroundColor Cyan
    $found = $false
    
    foreach ($commit in ($commits | Select-Object -First 20)) {
        $content = git show $commit 2>$null
        if ($content -match 'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+') {
            # Decodificar el payload del JWT para verificar si es service_role
            $matches | ForEach-Object {
                $jwt = $_.Value
                $parts = $jwt -split '\.'
                if ($parts.Length -eq 3) {
                    try {
                        # Decodificar base64 del payload (segunda parte)
                        $payload = $parts[1]
                        # Añadir padding si es necesario
                        while ($payload.Length % 4 -ne 0) {
                            $payload += "="
                        }
                        $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payload))
                        if ($decoded -match '"role"\s*:\s*"service_role"') {
                            Write-Host "⚠️  Service Role Key encontrada en commit: $commit" -ForegroundColor Red
                            Write-Host "   JWT: $($jwt.Substring(0, 50))..." -ForegroundColor Yellow
                            $ServiceRoleKey = $jwt
                            $found = $true
                        }
                    } catch {
                        # Ignorar errores de decodificación
                    }
                }
            }
        }
    }
    
    if (-not $found) {
        Write-Host "⚠️  No se encontró automáticamente la Service Role Key" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Por favor, proporciona la Service Role Key que quieres eliminar:" -ForegroundColor Cyan
        Write-Host "(Puedes obtenerla del mensaje de GitGuardian o del historial de Git)" -ForegroundColor Gray
        $ServiceRoleKey = Read-Host "Service Role Key (o presiona Enter para buscar manualmente)"
    }
}

if ([string]::IsNullOrEmpty($ServiceRoleKey)) {
    Write-Host ""
    Write-Host "📝 Instrucciones para encontrar la Service Role Key:" -ForegroundColor Cyan
    Write-Host "1. Revisa el email de GitGuardian - debería incluir la clave expuesta" -ForegroundColor White
    Write-Host "2. O busca en commits recientes:" -ForegroundColor White
    Write-Host "   git log -S 'service_role' --all --source --pretty=format:'%H %s'" -ForegroundColor Gray
    Write-Host "3. Luego revisa el contenido:" -ForegroundColor White
    Write-Host "   git show <commit-hash>" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Una vez que tengas la clave, ejecuta este script de nuevo con:" -ForegroundColor Yellow
    Write-Host "  .\scripts\eliminar-service-role-key-historial.ps1 -ServiceRoleKey 'TU_CLAVE_AQUI'" -ForegroundColor Green
    exit 1
}

Write-Host ""
Write-Host "✅ Service Role Key proporcionada" -ForegroundColor Green
Write-Host "   Clave: $($ServiceRoleKey.Substring(0, [Math]::Min(50, $ServiceRoleKey.Length)))..." -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 MODO DRY-RUN: Solo se mostrará qué se haría, sin modificar nada" -ForegroundColor Cyan
    Write-Host ""
}

# Verificar si git-filter-repo está instalado
$hasFilterRepo = $false
try {
    $null = git filter-repo --version 2>&1
    $hasFilterRepo = $true
    Write-Host "✅ git-filter-repo está instalado" -ForegroundColor Green
} catch {
    Write-Host "⚠️  git-filter-repo no está instalado" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Cyan
    Write-Host "1. Instalar git-filter-repo (recomendado):" -ForegroundColor White
    Write-Host "   pip install git-filter-repo" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Usar BFG Repo-Cleaner:" -ForegroundColor White
    Write-Host "   Descargar: https://rtyley.github.io/bfg-repo-cleaner/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Usar método manual con git filter-branch (más lento)" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "¿Deseas continuar con el método manual? (s/N)"
    if ($response -ne "s" -and $response -ne "S") {
        Write-Host "❌ Operación cancelada. Por favor, instala git-filter-repo primero." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "⚠️  ADVERTENCIA IMPORTANTE:" -ForegroundColor Red
Write-Host "Este script reescribirá el historial de Git." -ForegroundColor Yellow
Write-Host "Esto significa que:" -ForegroundColor Yellow
Write-Host "  - Todos los commits serán modificados" -ForegroundColor White
Write-Host "  - Necesitarás hacer force push a GitHub" -ForegroundColor White
Write-Host "  - Cualquiera que haya clonado el repo necesitará re-clonarlo" -ForegroundColor White
Write-Host "  - Los colaboradores necesitarán actualizar sus repos locales" -ForegroundColor White
Write-Host ""
Write-Host "✅ VENTAJAS:" -ForegroundColor Green
Write-Host "  - La Service Role Key será eliminada completamente del historial" -ForegroundColor White
Write-Host "  - GitGuardian dejará de detectar el secreto" -ForegroundColor White
Write-Host "  - Tu clave actual seguirá funcionando (no necesitas rotarla)" -ForegroundColor White
Write-Host ""

$response = Read-Host "¿Estás seguro de que deseas continuar? (escribe 'SI' para confirmar)"
if ($response -ne "SI") {
    Write-Host "❌ Operación cancelada" -ForegroundColor Red
    exit 1
}

# Crear backup del repositorio
Write-Host ""
Write-Host "💾 Creando backup del repositorio..." -ForegroundColor Cyan
$backupDir = "backup-repo-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git clone --mirror . $backupDir 2>&1 | Out-Null
if (Test-Path $backupDir) {
    Write-Host "✅ Backup creado en: $backupDir" -ForegroundColor Green
} else {
    Write-Host "⚠️  No se pudo crear el backup, pero continuamos..." -ForegroundColor Yellow
}

# Crear archivo con el texto a reemplazar
$replaceFile = "replace-text.txt"
"$ServiceRoleKey==>REMOVIDO_POR_SEGURIDAD" | Out-File -FilePath $replaceFile -Encoding UTF8

if ($hasFilterRepo) {
    Write-Host ""
    Write-Host "🔧 Usando git-filter-repo para eliminar la clave..." -ForegroundColor Cyan
    
    if (-not $DryRun) {
        # Usar git-filter-repo para reemplazar el texto
        git filter-repo --replace-text $replaceFile --force 2>&1 | Tee-Object -Variable output
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Service Role Key eliminada del historial local" -ForegroundColor Green
            Write-Host ""
            Write-Host "📤 Próximos pasos:" -ForegroundColor Cyan
            Write-Host "1. Verifica que todo está correcto:" -ForegroundColor White
            Write-Host "   git log --all" -ForegroundColor Gray
            Write-Host ""
            Write-Host "2. Actualiza el repositorio remoto (FORCE PUSH):" -ForegroundColor White
            Write-Host "   git push origin --force --all" -ForegroundColor Yellow
            Write-Host "   git push origin --force --tags" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "3. Notifica a los colaboradores que necesitan re-clonar el repo" -ForegroundColor White
            Write-Host ""
            Write-Host "4. Verifica en GitGuardian que la alerta desaparece (puede tardar unas horas)" -ForegroundColor White
        } else {
            Write-Host "❌ Error al ejecutar git-filter-repo" -ForegroundColor Red
            Write-Host $output -ForegroundColor Red
        }
    } else {
        Write-Host "🔍 DRY-RUN: Se ejecutaría:" -ForegroundColor Cyan
        Write-Host "   git filter-repo --replace-text $replaceFile --force" -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "🔧 Usando método manual con git filter-branch..." -ForegroundColor Cyan
    Write-Host "⚠️  Este método es más lento pero no requiere herramientas adicionales" -ForegroundColor Yellow
    
    if (-not $DryRun) {
        # Método manual usando git filter-branch
        $env:GIT_FILTER_BRANCH_SQUELCH_WARNING = "1"
        
        git filter-branch --force --index-filter `
            "git rm --cached --ignore-unmatch -r . && git reset --hard" `
            --prune-empty --tag-name-filter cat -- --all 2>&1 | Tee-Object -Variable output
        
        # Luego reemplazar el texto en todos los archivos
        git filter-branch --force --tree-filter `
            "if [ -f '$replaceFile' ]; then find . -type f -exec sed -i 's|$ServiceRoleKey|REMOVIDO_POR_SEGURIDAD|g' {} \; ; fi" `
            --prune-empty --tag-name-filter cat -- --all 2>&1 | Tee-Object -Variable output2
        
        Write-Host ""
        Write-Host "✅ Proceso completado" -ForegroundColor Green
        Write-Host ""
        Write-Host "📤 Próximos pasos:" -ForegroundColor Cyan
        Write-Host "1. Limpiar referencias:" -ForegroundColor White
        Write-Host "   git reflog expire --expire=now --all" -ForegroundColor Gray
        Write-Host "   git gc --prune=now --aggressive" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Actualizar remoto:" -ForegroundColor White
        Write-Host "   git push origin --force --all" -ForegroundColor Yellow
        Write-Host "   git push origin --force --tags" -ForegroundColor Yellow
    } else {
        Write-Host "🔍 DRY-RUN: Se ejecutarían los comandos de filter-branch" -ForegroundColor Cyan
    }
}

# Limpiar archivo temporal
if (Test-Path $replaceFile) {
    Remove-Item $replaceFile -Force
}

Write-Host ""
Write-Host "✅ Script completado" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Nota: El archivo app_config_local.dart debe estar en .gitignore" -ForegroundColor Cyan
Write-Host "   Verifica que está incluido:" -ForegroundColor White
Write-Host "   git check-ignore frontend/lib/config/app_config_local.dart" -ForegroundColor Gray

