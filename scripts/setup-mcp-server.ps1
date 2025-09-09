# Script para configurar el servidor MCP de Supabase
Write-Host "🚀 Configurando servidor MCP de Supabase..." -ForegroundColor Cyan

# Verificar si Node.js está instalado
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js encontrado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js no está instalado. Por favor, instala Node.js desde https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Navegar al directorio del servidor MCP
Set-Location "mcp-server"

# Instalar dependencias
Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
npm install

# Compilar TypeScript
Write-Host "🔨 Compilando TypeScript..." -ForegroundColor Yellow
npm run build

# Crear archivo .env
Write-Host "⚙️ Creando archivo de configuración..." -ForegroundColor Yellow
Copy-Item "env.example" ".env"

Write-Host "✅ Servidor MCP configurado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Configura el archivo mcp-config.json en Cursor" -ForegroundColor White
Write-Host "2. Reinicia Cursor para cargar el servidor MCP" -ForegroundColor White
Write-Host "3. Usa las herramientas de Supabase desde Cursor" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Para iniciar el servidor manualmente:" -ForegroundColor Cyan
Write-Host "   cd mcp-server && npm start" -ForegroundColor White

# Volver al directorio raíz
Set-Location ".."
