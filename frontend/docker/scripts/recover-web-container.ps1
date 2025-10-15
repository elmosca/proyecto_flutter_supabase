# Script de recuperación del contenedor web Flutter
# Puerto: 8082
# Autor: Sistema FCT
# Fecha: $(Get-Date)

Write-Host "🚀 INICIANDO RECUPERACIÓN DEL CONTENEDOR WEB FLUTTER" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: No se encontró pubspec.yaml. Ejecuta este script desde el directorio frontend/" -ForegroundColor Red
    exit 1
}

Write-Host "📋 PASO 1: Limpiando contenedores y volúmenes existentes" -ForegroundColor Yellow
# Detener y eliminar contenedores existentes
docker-compose -f docker/docker-compose.yml down --volumes --remove-orphans
docker system prune -f

Write-Host "📋 PASO 2: Verificando dependencias Flutter" -ForegroundColor Yellow
# Verificar Flutter
flutter doctor
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Flutter no está instalado o configurado correctamente" -ForegroundColor Red
    exit 1
}

Write-Host "📋 PASO 3: Instalando dependencias" -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: No se pudieron instalar las dependencias" -ForegroundColor Red
    exit 1
}

Write-Host "📋 PASO 4: Construyendo aplicación Flutter Web" -ForegroundColor Yellow
# Limpiar build anterior
if (Test-Path "build/web") {
    Remove-Item -Recurse -Force "build/web"
}

# Construir aplicación web
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: No se pudo construir la aplicación web" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Aplicación web construida exitosamente" -ForegroundColor Green

Write-Host "📋 PASO 5: Verificando archivos de build" -ForegroundColor Yellow
if (-not (Test-Path "build/web/index.html")) {
    Write-Host "❌ Error: No se encontró index.html en build/web/" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Archivos de build verificados" -ForegroundColor Green

Write-Host "📋 PASO 6: Construyendo imagen Docker" -ForegroundColor Yellow
# Construir imagen Docker
docker-compose -f docker/docker-compose.yml build --no-cache
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: No se pudo construir la imagen Docker" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Imagen Docker construida exitosamente" -ForegroundColor Green

Write-Host "📋 PASO 7: Iniciando contenedor web" -ForegroundColor Yellow
# Iniciar contenedor
docker-compose -f docker/docker-compose.yml up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: No se pudo iniciar el contenedor" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Contenedor iniciado exitosamente" -ForegroundColor Green

Write-Host "📋 PASO 8: Verificando estado del contenedor" -ForegroundColor Yellow
# Esperar un momento para que el contenedor se inicie
Start-Sleep -Seconds 5

# Verificar estado
docker-compose -f docker/docker-compose.yml ps

Write-Host "📋 PASO 9: Verificando conectividad" -ForegroundColor Yellow
# Verificar que el puerto 8082 esté disponible
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082" -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Aplicación web accesible en http://localhost:8082" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Aplicación web responde pero con código: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error: No se puede acceder a la aplicación web en http://localhost:8082" -ForegroundColor Red
    Write-Host "Verifica que el contenedor esté ejecutándose con: docker-compose -f docker/docker-compose.yml ps" -ForegroundColor Yellow
}

Write-Host "🎉 RECUPERACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host "🌐 Aplicación web disponible en: http://localhost:8082" -ForegroundColor Cyan
Write-Host "📊 Estado del contenedor:" -ForegroundColor Cyan
docker-compose -f docker/docker-compose.yml ps

Write-Host "🔧 Comandos útiles:" -ForegroundColor Cyan
Write-Host "  - Ver logs: docker-compose -f docker/docker-compose.yml logs -f" -ForegroundColor White
Write-Host "  - Detener: docker-compose -f docker/docker-compose.yml down" -ForegroundColor White
Write-Host "  - Reiniciar: docker-compose -f docker/docker-compose.yml restart" -ForegroundColor White
