#!/bin/bash

# Script para configurar el servidor MCP de Supabase
echo "🚀 Configurando servidor MCP de Supabase..."

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor, instala Node.js desde https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js encontrado: $(node --version)"

# Navegar al directorio del servidor MCP
cd mcp-server

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

# Compilar TypeScript
echo "🔨 Compilando TypeScript..."
npm run build

# Crear archivo .env
echo "⚙️ Creando archivo de configuración..."
cp env.example .env

echo "✅ Servidor MCP configurado exitosamente!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Configura el archivo mcp-config.json en Cursor"
echo "2. Reinicia Cursor para cargar el servidor MCP"
echo "3. Usa las herramientas de Supabase desde Cursor"
echo ""
echo "🔧 Para iniciar el servidor manualmente:"
echo "   cd mcp-server && npm start"

# Volver al directorio raíz
cd ..
