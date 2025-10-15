#!/bin/bash
# Script de recuperación del contenedor web Flutter
# Puerto: 8082
# Autor: Sistema FCT
# Fecha: $(date)

echo "🚀 INICIANDO RECUPERACIÓN DEL CONTENEDOR WEB FLUTTER"
echo "================================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: No se encontró pubspec.yaml. Ejecuta este script desde el directorio frontend/"
    exit 1
fi

echo "📋 PASO 1: Limpiando contenedores y volúmenes existentes"
# Detener y eliminar contenedores existentes
docker-compose -f docker/docker-compose.yml down --volumes --remove-orphans
docker system prune -f

echo "📋 PASO 2: Verificando dependencias Flutter"
# Verificar Flutter
flutter doctor
if [ $? -ne 0 ]; then
    echo "❌ Error: Flutter no está instalado o configurado correctamente"
    exit 1
fi

echo "📋 PASO 3: Instalando dependencias"
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudieron instalar las dependencias"
    exit 1
fi

echo "📋 PASO 4: Construyendo aplicación Flutter Web"
# Limpiar build anterior
if [ -d "build/web" ]; then
    rm -rf build/web
fi

# Construir aplicación web
flutter build web --release
if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudo construir la aplicación web"
    exit 1
fi

echo "✅ Aplicación web construida exitosamente"

echo "📋 PASO 5: Verificando archivos de build"
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Error: No se encontró index.html en build/web/"
    exit 1
fi

echo "✅ Archivos de build verificados"

echo "📋 PASO 6: Construyendo imagen Docker"
# Construir imagen Docker
docker-compose -f docker/docker-compose.yml build --no-cache
if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudo construir la imagen Docker"
    exit 1
fi

echo "✅ Imagen Docker construida exitosamente"

echo "📋 PASO 7: Iniciando contenedor web"
# Iniciar contenedor
docker-compose -f docker/docker-compose.yml up -d
if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudo iniciar el contenedor"
    exit 1
fi

echo "✅ Contenedor iniciado exitosamente"

echo "📋 PASO 8: Verificando estado del contenedor"
# Esperar un momento para que el contenedor se inicie
sleep 5

# Verificar estado
docker-compose -f docker/docker-compose.yml ps

echo "📋 PASO 9: Verificando conectividad"
# Verificar que el puerto 8082 esté disponible
if curl -f http://localhost:8082 > /dev/null 2>&1; then
    echo "✅ Aplicación web accesible en http://localhost:8082"
else
    echo "❌ Error: No se puede acceder a la aplicación web en http://localhost:8082"
    echo "Verifica que el contenedor esté ejecutándose con: docker-compose -f docker/docker-compose.yml ps"
fi

echo "🎉 RECUPERACIÓN COMPLETADA"
echo "================================================="
echo "🌐 Aplicación web disponible en: http://localhost:8082"
echo "📊 Estado del contenedor:"
docker-compose -f docker/docker-compose.yml ps

echo "🔧 Comandos útiles:"
echo "  - Ver logs: docker-compose -f docker/docker-compose.yml logs -f"
echo "  - Detener: docker-compose -f docker/docker-compose.yml down"
echo "  - Reiniciar: docker-compose -f docker/docker-compose.yml restart"
