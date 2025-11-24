Param(
    [string]$OutputDir = "./backups",
    [ValidateSet("custom","directory","tar","plain")]
    [string]$Format = "custom",
    [switch]$NoOwner
)

# Requisitos:
# - Tener instaladas las utilidades de PostgreSQL (pg_dump en PATH)
# - Definir la variable de entorno SUPABASE_DB_URL con la cadena de conexión
#   Ejemplo: postgres://usuario:password@host:5432/postgres?sslmode=require

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $env:SUPABASE_DB_URL) {
    Write-Error "La variable de entorno SUPABASE_DB_URL no está definida. Configúrala antes de ejecutar este script."
}

# Asegurar sslmode=require si no viene incluido
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

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$fileBase = Join-Path $OutputDir "supabase_$timestamp"

switch ($Format) {
    "custom" { $outFile = "$fileBase.dump" }
    "directory" { $outFile = "$fileBase.dir" }
    "tar" { $outFile = "$fileBase.tar" }
    "plain" { $outFile = "$fileBase.sql" }
    default { $outFile = "$fileBase.dump" }
}

$argsList = @("--dbname=$dbUrl", "--format=$Format")
if ($NoOwner) { $argsList += "--no-owner" }

if ($Format -eq "directory") {
    # En formato directory, el destino es un directorio
    $argsList += "--file=$outFile"
} else {
    $argsList += "--file=$outFile"
}

Write-Host "Iniciando backup a: $outFile" -ForegroundColor Cyan
pg_dump @argsList
Write-Host "Backup completado: $outFile" -ForegroundColor Green


