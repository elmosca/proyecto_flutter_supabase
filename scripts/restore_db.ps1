Param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,
    [switch]$Clean,
    [switch]$NoOwner
)

# Requisitos:
# - Tener instaladas las utilidades de PostgreSQL (pg_restore/psql en PATH)
# - Definir la variable de entorno SUPABASE_DB_URL con la cadena de conexión
#   Ejemplo: postgres://usuario:password@host:5432/postgres?sslmode=require

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $env:SUPABASE_DB_URL) {
    Write-Error "La variable de entorno SUPABASE_DB_URL no está definida. Configúrala antes de ejecutar este script."
}

if (-not (Test-Path $InputPath)) {
    Write-Error "No se encontró el archivo de entrada: $InputPath"
}

function Ensure-SslModeRequire([string]$dbUrl) {
    if ($dbUrl -match "\\?") {
        if ($dbUrl -notmatch "sslmode=") { return "$dbUrl&sslmode=require" }
        return $dbUrl
    } else {
        if ($dbUrl -notmatch "sslmode=") { return "$dbUrl?sslmode=require" }
        return $dbUrl
    }
}

$dbUrl = Ensure-SslModeRequire $env:SUPABASE_DB_URL

$ext = [System.IO.Path]::GetExtension($InputPath).ToLowerInvariant()

if ($ext -eq ".sql") {
    Write-Host "Restaurando desde SQL plano via psql..." -ForegroundColor Cyan
    psql "$dbUrl" -f "$InputPath"
} else {
    Write-Host "Restaurando via pg_restore..." -ForegroundColor Cyan
    $argsList = @("--dbname=$dbUrl")
    if ($Clean) { $argsList += "--clean"; $argsList += "--if-exists" }
    if ($NoOwner) { $argsList += "--no-owner" }
    $argsList += "$InputPath"
    pg_restore @argsList
}

Write-Host "Restauración completada." -ForegroundColor Green


