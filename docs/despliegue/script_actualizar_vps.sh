#!/bin/bash
# Script para actualizar la aplicación Flutter Web en el VPS
# Asegura que el contenido se actualice correctamente

set -e  # Salir si hay algún error

echo "🚀 ACTUALIZANDO APLICACIÓN FLUTTER WEB EN VPS"
echo "=============================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "docker/docker-compose.yml" ]; then
    echo "❌ Error: Ejecuta este script desde /opt/tfg-frontend/"
    exit 1
fi

echo ""
echo "📋 PASO 1: Deteniendo contenedor actual"
docker compose -f docker/docker-compose.yml stop || true
docker compose -f docker/docker-compose.yml down || true

echo ""
echo "📋 PASO 2: Verificando que existe web-build.zip"
if [ ! -f "web-build.zip" ]; then
    echo "❌ Error: No se encontró web-build.zip en el directorio actual"
    echo "   Asegúrate de haber subido el archivo desde tu máquina local"
    exit 1
fi

echo "✅ Archivo web-build.zip encontrado"
ls -lh web-build.zip

echo ""
echo "📋 PASO 3: Limpiando build anterior completamente"
# Eliminar completamente el directorio build/web si existe
if [ -d "build/web" ]; then
    echo "   Eliminando build/web anterior..."
    rm -rf build/web
fi

# Crear directorio limpio
mkdir -p build/web

echo ""
echo "📋 PASO 4: Descomprimiendo nuevo build"
unzip -o web-build.zip -d build/web/

# Verificar que se descomprimió correctamente
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Error: No se encontró index.html después de descomprimir"
    echo "   Verifica que el archivo web-build.zip esté correcto"
    exit 1
fi

echo "✅ Archivos descomprimidos correctamente"
echo "   Archivos en build/web/:"
ls -lh build/web/ | head -10

echo ""
echo "📋 PASO 5: Verificando archivos críticos"
CRITICAL_FILES=("index.html" "main.dart.js" "flutter.js")
for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "build/web/$file" ]; then
        echo "   ✅ $file encontrado"
        # Mostrar fecha de modificación
        ls -lh "build/web/$file" | awk '{print "      Última modificación: " $6 " " $7 " " $8}'
    else
        echo "   ⚠️  $file no encontrado (puede ser normal si no es necesario)"
    fi
done

echo ""
echo "📋 PASO 6: Limpiando caché de Docker"
# Limpiar imágenes antiguas
docker image prune -f || true

echo ""
echo "📋 PASO 7: Reconstruyendo contenedor (sin caché)"
docker compose -f docker/docker-compose.yml build --no-cache

echo ""
echo "📋 PASO 8: Iniciando contenedor"
docker compose -f docker/docker-compose.yml up -d

echo ""
echo "📋 PASO 9: Esperando a que el contenedor esté listo"
sleep 5

echo ""
echo "📋 PASO 10: Verificando estado del contenedor"
if docker ps | grep -q tfg-frontend-web; then
    echo "✅ Contenedor está ejecutándose"
    docker ps | grep tfg-frontend-web
else
    echo "❌ Error: El contenedor no está ejecutándose"
    echo "   Revisa los logs con: docker compose -f docker/docker-compose.yml logs"
    exit 1
fi

echo ""
echo "📋 PASO 11: Verificando que la aplicación responde"
if curl -f -s http://localhost:8082 > /dev/null; then
    echo "✅ Aplicación responde correctamente en http://localhost:8082"
else
    echo "⚠️  Advertencia: La aplicación no responde en http://localhost:8082"
    echo "   Revisa los logs con: docker compose -f docker/docker-compose.yml logs"
fi

echo ""
echo "📋 PASO 12: Limpiando archivo zip"
rm -f web-build.zip
echo "✅ Archivo web-build.zip eliminado"

echo ""
echo "✅ ACTUALIZACIÓN COMPLETADA"
echo "============================"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Verifica que la aplicación funciona: curl http://localhost:8082"
echo "   2. Si usas un proxy reverso (Nginx, Traefik), reinícialo"
echo "   3. Limpia la caché del navegador (Ctrl+Shift+R o Ctrl+F5)"
echo "   4. Verifica los logs si hay problemas: docker compose -f docker/docker-compose.yml logs -f"
echo ""
echo "🔍 Para ver los logs en tiempo real:"
echo "   docker compose -f docker/docker-compose.yml logs -f frontend-web"
echo ""

