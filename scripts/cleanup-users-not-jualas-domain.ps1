# =====================================================
# Script: Limpieza de usuarios fuera del dominio jualas.es
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM
# =====================================================
# 
# Este script elimina usuarios que NO pertenecen al dominio
# jualas.es (incluyendo fct.jualas.es) de:
# 1. auth.users (usando Edge Function)
# 2. tabla users (usando SQL)
# 
# ⚠️ ADVERTENCIA: Este script es DESTRUCTIVO
# =====================================================

param(
    [switch]$DryRun = $false,
    [string]$SupabaseUrl = "",
    [string]$SupabaseAnonKey = "",
    [string]$SupabaseServiceRoleKey = ""
)

Write-Host "🧹 Limpieza de usuarios fuera del dominio jualas.es" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar parámetros
if (-not $SupabaseUrl) {
    $SupabaseUrl = Read-Host "Introduce la URL de Supabase (ej: https://xxxxx.supabase.co)"
}

if (-not $SupabaseAnonKey) {
    $SupabaseAnonKey = Read-Host "Introduce la Anon Key de Supabase"
}

if (-not $SupabaseServiceRoleKey) {
    $SupabaseServiceRoleKey = Read-Host "Introduce la Service Role Key de Supabase (para Edge Function)"
}

if ($DryRun) {
    Write-Host "⚠️  MODO DRY RUN - No se eliminarán usuarios, solo se mostrará información" -ForegroundColor Yellow
    Write-Host ""
}

# Dominios permitidos
$allowedDomains = @("@jualas.es", "@fct.jualas.es")
Write-Host "📋 Dominios permitidos:" -ForegroundColor Yellow
foreach ($domain in $allowedDomains) {
    Write-Host "   ✅ $domain" -ForegroundColor Green
}
Write-Host ""

# Paso 1: Eliminar de auth.users usando Edge Function
Write-Host "🔐 Paso 1: Eliminando usuarios de auth.users..." -ForegroundColor Yellow
Write-Host ""

try {
    $headers = @{
        "Authorization" = "Bearer $SupabaseServiceRoleKey"
        "Content-Type" = "application/json"
        "apikey" = $SupabaseAnonKey
    }

    $body = @{
        action = "bulk_delete_users_by_domain"
    } | ConvertTo-Json

    if (-not $DryRun) {
        $response = Invoke-RestMethod -Uri "$SupabaseUrl/functions/v1/super-action" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop

        Write-Host "✅ Respuesta de Edge Function:" -ForegroundColor Green
        Write-Host "   Total encontrados: $($response.summary.total_found)" -ForegroundColor White
        Write-Host "   Eliminados: $($response.summary.deleted)" -ForegroundColor Green
        Write-Host "   Errores: $($response.summary.errors)" -ForegroundColor $(if ($response.summary.errors -gt 0) { "Red" } else { "Green" })
        Write-Host ""

        if ($response.deleted_users.Count -gt 0) {
            Write-Host "📋 Usuarios eliminados de auth.users:" -ForegroundColor Yellow
            foreach ($user in $response.deleted_users) {
                Write-Host "   ✅ $($user.email)" -ForegroundColor Green
            }
            Write-Host ""
        }

        if ($response.errors.Count -gt 0) {
            Write-Host "❌ Errores al eliminar:" -ForegroundColor Red
            foreach ($error in $response.errors) {
                Write-Host "   ❌ $($error.email): $($error.error)" -ForegroundColor Red
            }
            Write-Host ""
        }
    } else {
        Write-Host "⚠️  DRY RUN: Se llamaría a la Edge Function para eliminar usuarios de auth.users" -ForegroundColor Yellow
        Write-Host ""
    }
} catch {
    Write-Host "❌ Error al eliminar usuarios de auth.users:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Paso 2: Eliminar de la tabla users usando SQL
Write-Host "🗄️  Paso 2: Eliminando usuarios de la tabla users..." -ForegroundColor Yellow
Write-Host ""

# Nota: Para ejecutar SQL directamente, necesitarías usar psql o la API de Supabase
# Por ahora, mostramos el SQL que se debe ejecutar
Write-Host "📝 SQL a ejecutar en Supabase SQL Editor:" -ForegroundColor Yellow
Write-Host ""
Write-Host "-- Eliminar usuarios fuera del dominio jualas.es" -ForegroundColor Cyan
Write-Host "DELETE FROM public.users" -ForegroundColor Cyan
Write-Host "WHERE email NOT LIKE '%@jualas.es'" -ForegroundColor Cyan
Write-Host "  AND email NOT LIKE '%@fct.jualas.es';" -ForegroundColor Cyan
Write-Host ""

if (-not $DryRun) {
    Write-Host "⚠️  IMPORTANTE: Ejecuta el SQL anterior en el SQL Editor de Supabase" -ForegroundColor Yellow
    Write-Host "   O ejecuta la migración: 20250112000002_cleanup_users_not_jualas_domain.sql" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "⚠️  DRY RUN: Se ejecutaría el SQL para eliminar usuarios de la tabla users" -ForegroundColor Yellow
    Write-Host ""
}

# Resumen final
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "✅ Limpieza completada" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Verifica que los usuarios se eliminaron correctamente" -ForegroundColor White
Write-Host "   2. Ejecuta el SQL en Supabase SQL Editor para limpiar la tabla users" -ForegroundColor White
Write-Host "   3. Verifica que no quedan usuarios huérfanos" -ForegroundColor White
Write-Host ""

