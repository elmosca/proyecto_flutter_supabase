# Script para preparar merge selectivo a main (producción)
# Este script identifica y lista los archivos esenciales para producción

Write-Host "🔍 PREPARANDO MERGE SELECTIVO A MAIN (PRODUCCIÓN)" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Archivos y directorios ESENCIALES para producción
$essentialPaths = @(
    # Aplicación Flutter - Código fuente
    "frontend/lib/",
    "frontend/pubspec.yaml",
    "frontend/pubspec.lock",
    "frontend/l10n.yaml",
    "frontend/analysis_options.yaml",
    "frontend/dartdoc_options.yaml",
    
    # Assets necesarios
    "frontend/assets/",
    
    # Configuración de plataformas
    "frontend/web/",
    "frontend/windows/",
    "frontend/android/",
    
    # Docker y despliegue
    "frontend/docker/",
    "frontend/scripts/build-windows-release.ps1",
    "frontend/scripts/README.md",
    
    # Documentación esencial
    "docs/guias_usuario/",
    "docs/despliegue/",
    "docs/arquitectura/login.md",
    "docs/arquitectura/registro_usuarios_por_roles.md",
    "docs/base_datos/migraciones/",
    "docs/base_datos/modelo_datos.md",
    
    # Ejemplos para usuarios
    "ejemplos_csv/",
    
    # Edge Functions de Supabase
    "supabase/functions/",
    
    # Archivos de configuración raíz
    "README.md",
    "LICENSE",
    ".gitignore",
    
    # Configuración (solo ejemplos)
    "config/*.example"
)

# Archivos y directorios a EXCLUIR de producción
$excludePaths = @(
    # Builds y artefactos
    "frontend/build/",
    "frontend/dist/",
    "frontend/web-build.zip",
    "build/",
    
    # Tests
    "frontend/test/",
    "docs/pruebas/",
    
    # Documentación de desarrollo interno
    "docs/desarrollo/",
    
    # Scripts de desarrollo
    "scripts/",
    "refactor_*.py",
    
    # Wiki (opcional, comentar si se quiere incluir)
    # "wiki_setup/",
    
    # Archivos temporales
    "*.log",
    "frontend/*.log",
    "frontend/*.iml",
    "frontend/untranslated_messages.txt",
    
    # Node modules y dependencias
    "node_modules/",
    "frontend/node_modules/",
    "mcp-resend/node_modules/",
    "mcp-server/node_modules/",
    
    # Archivos de IDE
    ".vscode/",
    ".idea/",
    "*.code-workspace",
    
    # Archivos de sistema
    ".DS_Store",
    "Thumbs.db",
    
    # Configuración local
    "config/*.env",
    "!config/*.example",
    
    # Documentación de desarrollo
    "docs/Anteproyecto*.pdf"
)

Write-Host "`n📋 Archivos ESENCIALES para producción:" -ForegroundColor Yellow
foreach ($path in $essentialPaths) {
    Write-Host "   ✅ $path" -ForegroundColor Cyan
}

Write-Host "`n❌ Archivos a EXCLUIR de producción:" -ForegroundColor Yellow
foreach ($path in $excludePaths) {
    Write-Host "   🚫 $path" -ForegroundColor Gray
}

Write-Host "`n📝 Estrategia de merge:" -ForegroundColor Yellow
Write-Host "   1. Crear rama temporal desde develop" -ForegroundColor Cyan
Write-Host "   2. Eliminar archivos no esenciales" -ForegroundColor Cyan
Write-Host "   3. Hacer commit limpio" -ForegroundColor Cyan
Write-Host "   4. Merge a main" -ForegroundColor Cyan
Write-Host ""

# Preguntar si continuar
$response = Read-Host "¿Deseas continuar con el merge selectivo? (S/N)"
if ($response -ne "S" -and $response -ne "s") {
    Write-Host "Operación cancelada" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n🚀 Iniciando proceso de merge selectivo..." -ForegroundColor Green

