#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_header() {
    echo -e "${PURPLE}[HEADER]${NC} $1"
}

# Función para limpiar procesos al salir
cleanup() {
    print_warning "Deteniendo todos los servicios..."
    
    # Matar procesos en background
    if [ ! -z "$SUPABASE_PID" ]; then
        kill $SUPABASE_PID 2>/dev/null
        print_status "Supabase detenido"
    fi
    if [ ! -z "$NGROK_SUPABASE_PID" ]; then
        kill $NGROK_SUPABASE_PID 2>/dev/null
        print_status "Ngrok Supabase detenido"
    fi
    if [ ! -z "$WEB_PID" ]; then
        kill $WEB_PID 2>/dev/null
        print_status "Servidor web detenido"
    fi
    if [ ! -z "$NGROK_WEB_PID" ]; then
        kill $NGROK_WEB_PID 2>/dev/null
        print_status "Ngrok Web detenido"
    fi
    
    print_success "Todos los servicios detenidos correctamente"
    exit 0
}

# Configurar trap para limpiar procesos
trap cleanup SIGINT SIGTERM

echo ""
echo "========================================"
echo "    SISTEMA TFG - INICIO EN SERVIDOR"
echo "========================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "README.md" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    print_error "No se encontró el proyecto. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# Verificar dependencias
print_header "Verificando dependencias..."

if ! command -v git &> /dev/null; then
    print_error "Git no está instalado"
    exit 1
fi

if ! command -v supabase &> /dev/null; then
    print_error "Supabase CLI no está instalado"
    exit 1
fi

if ! command -v ngrok &> /dev/null; then
    print_error "Ngrok no está instalado"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    print_error "Python3 no está instalado"
    exit 1
fi

print_success "Todas las dependencias están instaladas"

# Actualizar repositorio
print_header "Actualizando repositorio..."
print_status "Obteniendo últimos cambios del repositorio..."

git fetch origin
if [ $? -ne 0 ]; then
    print_error "Error al obtener cambios del repositorio"
    exit 1
fi

git pull origin develop
if [ $? -ne 0 ]; then
    print_error "Error al actualizar el repositorio"
    exit 1
fi

print_success "Repositorio actualizado correctamente"

# Verificar que los archivos nuevos estén presentes
if [ ! -f "frontend/lib/config/app_config.dart" ]; then
    print_error "Archivo de configuración no encontrado. Verifica la actualización."
    exit 1
fi

if [ ! -f "docs/desarrollo/guia_ngrok_backend_local.md" ]; then
    print_error "Documentación de Ngrok no encontrada. Verifica la actualización."
    exit 1
fi

print_success "Archivos nuevos verificados"

# Iniciar Supabase
print_header "Iniciando Supabase..."
print_status "Deteniendo Supabase si está corriendo..."
supabase stop >/dev/null 2>&1

print_status "Iniciando Supabase..."
cd backend/supabase
supabase start &
SUPABASE_PID=$!

print_status "Esperando a que Supabase inicie (20 segundos)..."
sleep 20

# Verificar que Supabase esté funcionando
if ! supabase status >/dev/null 2>&1; then
    print_error "Supabase no pudo iniciarse correctamente"
    exit 1
fi

print_success "Supabase iniciado correctamente"

# Obtener información de Supabase
SUPABASE_URL=$(supabase status | grep "API URL" | awk '{print $3}')
SUPABASE_ANON_KEY=$(supabase status | grep "anon key" | awk '{print $3}')

print_status "Supabase URL: $SUPABASE_URL"
print_status "Supabase Anon Key: ${SUPABASE_ANON_KEY:0:20}..."

# Iniciar túnel ngrok para Supabase
print_header "Iniciando túnel Ngrok para Supabase..."
cd ../..
ngrok http 54321 --subdomain=tu-proyecto-tfg &
NGROK_SUPABASE_PID=$!

print_status "Esperando a que Ngrok inicie (5 segundos)..."
sleep 5

# Construir aplicación web
print_header "Construyendo aplicación web..."
cd frontend

print_status "Obteniendo dependencias de Flutter..."
flutter pub get
if [ $? -ne 0 ]; then
    print_error "Error al obtener dependencias de Flutter"
    exit 1
fi

print_status "Construyendo aplicación web para producción..."
flutter build web --dart-define=ENVIRONMENT=ngrok --release
if [ $? -ne 0 ]; then
    print_error "Error al construir la aplicación web"
    exit 1
fi

print_success "Aplicación web construida correctamente"

# Iniciar servidor web
print_header "Iniciando servidor web..."
cd build/web
python3 -m http.server 8080 &
WEB_PID=$!

print_status "Esperando a que el servidor web inicie (3 segundos)..."
sleep 3

# Verificar que el servidor web esté funcionando
if ! curl -s http://localhost:8080 >/dev/null; then
    print_error "Servidor web no pudo iniciarse correctamente"
    exit 1
fi

print_success "Servidor web iniciado correctamente"

# Iniciar túnel ngrok para aplicación web
print_header "Iniciando túnel Ngrok para aplicación web..."
cd ../../..
ngrok http 8080 --subdomain=tu-proyecto-tfg-web &
NGROK_WEB_PID=$!

print_status "Esperando a que Ngrok Web inicie (5 segundos)..."
sleep 5

echo ""
echo "========================================"
echo "    SISTEMA INICIADO CORRECTAMENTE"
echo "========================================"
echo ""
print_success "Backend (Supabase): https://tu-proyecto-tfg.ngrok.io"
print_success "Aplicación Web:     https://tu-proyecto-tfg-web.ngrok.io"
print_success "Dashboard Ngrok:    http://127.0.0.1:4040"
echo ""
echo "========================================"
echo "    INFORMACIÓN DEL SISTEMA"
echo "========================================"
echo ""
print_status "Supabase URL Local: $SUPABASE_URL"
print_status "Servidor Web Local: http://localhost:8080"
print_status "Entorno: ngrok (acceso externo)"
echo ""
echo "========================================"
echo "    CREDENCIALES DE PRUEBA"
echo "========================================"
echo ""
print_status "Email: carlos.lopez@alumno.cifpcarlos3.es"
print_status "Password: password123"
print_status "Rol: student"
echo ""
echo "========================================"
echo "    INSTRUCCIONES"
echo "========================================"
echo ""
print_status "1. Abre el Dashboard Ngrok para ver las URLs exactas"
print_status "2. Prueba la aplicación desde un dispositivo móvil"
print_status "3. Usa las credenciales de prueba para hacer login"
print_status "4. Presiona Ctrl+C para detener todos los servicios"
echo ""

# Abrir dashboard de ngrok en el navegador
if command -v xdg-open &> /dev/null; then
    xdg-open http://127.0.0.1:4040
elif command -v open &> /dev/null; then
    open http://127.0.0.1:4040
fi

print_success "Sistema TFG iniciado correctamente en el servidor"
echo ""

# Mantener el script corriendo
wait
