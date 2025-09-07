#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para limpiar procesos al salir
cleanup() {
    print_warning "Deteniendo todos los servicios..."
    
    # Matar procesos en background
    if [ ! -z "$SUPABASE_PID" ]; then
        kill $SUPABASE_PID 2>/dev/null
    fi
    if [ ! -z "$NGROK_SUPABASE_PID" ]; then
        kill $NGROK_SUPABASE_PID 2>/dev/null
    fi
    if [ ! -z "$WEB_PID" ]; then
        kill $WEB_PID 2>/dev/null
    fi
    if [ ! -z "$NGROK_WEB_PID" ]; then
        kill $NGROK_WEB_PID 2>/dev/null
    fi
    
    print_success "Servicios detenidos correctamente"
    exit 0
}

# Configurar trap para limpiar procesos
trap cleanup SIGINT SIGTERM

echo ""
echo "========================================"
echo "    SISTEMA TFG - INICIO CON NGROK"
echo "========================================"
echo ""

# Verificar que Ngrok esté instalado
if ! command -v ngrok &> /dev/null; then
    print_error "Ngrok no está instalado"
    echo "Por favor instala Ngrok desde: https://ngrok.com/download"
    exit 1
fi

# Verificar que Supabase esté instalado
if ! command -v supabase &> /dev/null; then
    print_error "Supabase CLI no está instalado"
    echo "Por favor instala Supabase CLI desde: https://supabase.com/docs/guides/cli"
    exit 1
fi

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado"
    echo "Por favor instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

print_status "Iniciando Supabase local..."
cd backend/supabase
supabase start &
SUPABASE_PID=$!

print_status "Esperando a que Supabase inicie (15 segundos)..."
sleep 15

print_status "Iniciando túnel Ngrok para Supabase..."
ngrok http 54321 --subdomain=tu-proyecto-tfg &
NGROK_SUPABASE_PID=$!

print_status "Iniciando aplicación Flutter Web..."
cd ../../frontend
flutter run -d web-server --web-port 8080 --dart-define=ENVIRONMENT=ngrok &
WEB_PID=$!

print_status "Esperando a que la aplicación web inicie (10 segundos)..."
sleep 10

print_status "Iniciando túnel Ngrok para aplicación web..."
ngrok http 8080 --subdomain=tu-proyecto-tfg-web &
NGROK_WEB_PID=$!

echo ""
echo "========================================"
echo "    URLs DISPONIBLES:"
echo "========================================"
echo ""
echo "Backend (Supabase): https://tu-proyecto-tfg.ngrok.io"
echo "Aplicación Web:     http://localhost:8080"
echo "Dashboard Ngrok:    http://127.0.0.1:4040"
echo ""
echo "========================================"
echo "    INSTRUCCIONES:"
echo "========================================"
echo ""
echo "1. Espera a que todos los servicios estén listos"
echo "2. Abre el Dashboard Ngrok para ver las URLs exactas"
echo "3. Para testing en móvil, usa la URL de ngrok"
echo "4. Para desarrollo local, usa localhost:8080"
echo ""

# Abrir dashboard de ngrok en el navegador
if command -v xdg-open &> /dev/null; then
    xdg-open http://127.0.0.1:4040
elif command -v open &> /dev/null; then
    open http://127.0.0.1:4040
fi

print_success "Servicios iniciados correctamente"
echo ""
echo "========================================"
echo "    SERVICIOS EN EJECUCIÓN"
echo "========================================"
echo ""
echo "Para detener todos los servicios, presiona Ctrl+C"
echo ""

# Mantener el script corriendo
wait
