@echo off
title Sistema TFG - Inicio en Servidor
color 0A

echo.
echo ========================================
echo    SISTEMA TFG - INICIO EN SERVIDOR
echo ========================================
echo.

REM Verificar que estamos en el directorio correcto
if not exist "README.md" (
    echo ERROR: No se encontró el proyecto. Asegúrate de estar en el directorio raíz del proyecto.
    pause
    exit /b 1
)

if not exist "backend" (
    echo ERROR: Directorio backend no encontrado.
    pause
    exit /b 1
)

if not exist "frontend" (
    echo ERROR: Directorio frontend no encontrado.
    pause
    exit /b 1
)

echo [1/8] Verificando dependencias...

REM Verificar Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Git no está instalado
    pause
    exit /b 1
)

REM Verificar Supabase
where supabase >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Supabase CLI no está instalado
    pause
    exit /b 1
)

REM Verificar Ngrok
where ngrok >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Ngrok no está instalado
    pause
    exit /b 1
)

REM Verificar Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter no está instalado
    pause
    exit /b 1
)

REM Verificar Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Python no está instalado
    pause
    exit /b 1
)

echo [2/8] Dependencias verificadas correctamente

echo [3/8] Actualizando repositorio...
echo Obteniendo últimos cambios del repositorio...

git fetch origin
if %errorlevel% neq 0 (
    echo ERROR: Error al obtener cambios del repositorio
    pause
    exit /b 1
)

git pull origin develop
if %errorlevel% neq 0 (
    echo ERROR: Error al actualizar el repositorio
    pause
    exit /b 1
)

echo Repositorio actualizado correctamente

REM Verificar archivos nuevos
if not exist "frontend\lib\config\app_config.dart" (
    echo ERROR: Archivo de configuración no encontrado. Verifica la actualización.
    pause
    exit /b 1
)

if not exist "docs\desarrollo\guia_ngrok_backend_local.md" (
    echo ERROR: Documentación de Ngrok no encontrada. Verifica la actualización.
    pause
    exit /b 1
)

echo [4/8] Archivos nuevos verificados

echo [5/8] Iniciando Supabase...
echo Deteniendo Supabase si está corriendo...
cd backend\supabase
supabase stop >nul 2>nul

echo Iniciando Supabase...
start "Supabase Server" cmd /k "echo Iniciando Supabase... && supabase start && echo. && echo Supabase iniciado correctamente. Presiona cualquier tecla para cerrar. && pause >nul"

echo Esperando a que Supabase inicie (20 segundos)...
timeout /t 20 /nobreak >nul

REM Verificar que Supabase esté funcionando
supabase status >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Supabase no pudo iniciarse correctamente
    pause
    exit /b 1
)

echo Supabase iniciado correctamente

echo [6/8] Iniciando túnel Ngrok para Supabase...
cd ..\..
start "Ngrok Supabase" cmd /k "echo Iniciando túnel Ngrok para Supabase... && ngrok http 54321 --subdomain=tu-proyecto-tfg && echo. && echo Túnel Ngrok iniciado. Presiona cualquier tecla para cerrar. && pause >nul"

echo Esperando a que Ngrok inicie (5 segundos)...
timeout /t 5 /nobreak >nul

echo [7/8] Construyendo aplicación web...
cd frontend

echo Obteniendo dependencias de Flutter...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Error al obtener dependencias de Flutter
    pause
    exit /b 1
)

echo Construyendo aplicación web para producción...
flutter build web --dart-define=ENVIRONMENT=ngrok --release
if %errorlevel% neq 0 (
    echo ERROR: Error al construir la aplicación web
    pause
    exit /b 1
)

echo Aplicación web construida correctamente

echo [8/8] Iniciando servidor web...
cd build\web
start "Web Server" cmd /k "echo Iniciando servidor web... && python -m http.server 8080 && echo. && echo Servidor web iniciado. Presiona cualquier tecla para cerrar. && pause >nul"

echo Esperando a que el servidor web inicie (3 segundos)...
timeout /t 3 /nobreak >nul

echo Iniciando túnel Ngrok para aplicación web...
cd ..\..\..
start "Ngrok Web" cmd /k "echo Iniciando túnel Ngrok para aplicación web... && ngrok http 8080 --subdomain=tu-proyecto-tfg-web && echo. && echo Túnel Ngrok Web iniciado. Presiona cualquier tecla para cerrar. && pause >nul"

echo Esperando a que Ngrok Web inicie (5 segundos)...
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo    SISTEMA INICIADO CORRECTAMENTE
echo ========================================
echo.
echo Backend (Supabase): https://tu-proyecto-tfg.ngrok.io
echo Aplicación Web:     https://tu-proyecto-tfg-web.ngrok.io
echo Dashboard Ngrok:    http://127.0.0.1:4040
echo.
echo ========================================
echo    INFORMACIÓN DEL SISTEMA
echo ========================================
echo.
echo Supabase URL Local: http://localhost:54321
echo Servidor Web Local: http://localhost:8080
echo Entorno: ngrok (acceso externo)
echo.
echo ========================================
echo    CREDENCIALES DE PRUEBA
echo ========================================
echo.
echo Email: carlos.lopez@alumno.cifpcarlos3.es
echo Password: password123
echo Rol: student
echo.
echo ========================================
echo    INSTRUCCIONES
echo ========================================
echo.
echo 1. Abre el Dashboard Ngrok para ver las URLs exactas
echo 2. Prueba la aplicación desde un dispositivo móvil
echo 3. Usa las credenciales de prueba para hacer login
echo 4. Cierra las ventanas de comandos para detener servicios
echo.

echo Abriendo Dashboard Ngrok...
start http://127.0.0.1:4040

echo.
echo ========================================
echo    SISTEMA TFG INICIADO EN SERVIDOR
echo ========================================
echo.
echo Presiona cualquier tecla para salir...
pause >nul
