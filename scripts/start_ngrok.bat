@echo off
title Sistema TFG - Inicio con Ngrok
color 0A

echo.
echo ========================================
echo    SISTEMA TFG - INICIO CON NGROK
echo ========================================
echo.

REM Verificar que Ngrok esté instalado
where ngrok >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Ngrok no está instalado o no está en el PATH
    echo Por favor instala Ngrok desde: https://ngrok.com/download
    pause
    exit /b 1
)

REM Verificar que Supabase esté instalado
where supabase >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Supabase CLI no está instalado
    echo Por favor instala Supabase CLI desde: https://supabase.com/docs/guides/cli
    pause
    exit /b 1
)

echo [1/5] Iniciando Supabase local...
start "Supabase Local" cmd /k "cd /d backend\supabase && echo Iniciando Supabase... && supabase start && echo. && echo Supabase iniciado correctamente. Presiona cualquier tecla para cerrar. && pause >nul"

echo [2/5] Esperando a que Supabase inicie (15 segundos)...
timeout /t 15 /nobreak >nul

echo [3/5] Iniciando túnel Ngrok para Supabase...
start "Ngrok Supabase" cmd /k "echo Iniciando túnel Ngrok para Supabase... && ngrok http 54321 --subdomain=tu-proyecto-tfg && echo. && echo Túnel Ngrok iniciado. Presiona cualquier tecla para cerrar. && pause >nul"

echo [4/5] Iniciando aplicación Flutter Web...
start "Flutter Web" cmd /k "cd /d frontend && echo Iniciando aplicación Flutter Web... && flutter run -d web-server --web-port 8080 --dart-define=ENVIRONMENT=ngrok && echo. && echo Aplicación web iniciada. Presiona cualquier tecla para cerrar. && pause >nul"

echo [5/5] Esperando a que la aplicación web inicie (10 segundos)...
timeout /t 10 /nobreak >nul

echo.
echo ========================================
echo    URLs DISPONIBLES:
echo ========================================
echo.
echo Backend (Supabase): https://tu-proyecto-tfg.ngrok.io
echo Aplicación Web:     http://localhost:8080
echo Dashboard Ngrok:    http://127.0.0.1:4040
echo.
echo ========================================
echo    INSTRUCCIONES:
echo ========================================
echo.
echo 1. Espera a que todos los servicios estén listos
echo 2. Abre el Dashboard Ngrok para ver las URLs exactas
echo 3. Para testing en móvil, usa la URL de ngrok
echo 4. Para desarrollo local, usa localhost:8080
echo.
echo Presiona cualquier tecla para abrir el Dashboard Ngrok...
pause >nul

echo Abriendo Dashboard Ngrok...
start http://127.0.0.1:4040

echo.
echo ========================================
echo    SERVICIOS INICIADOS CORRECTAMENTE
echo ========================================
echo.
echo Para detener todos los servicios:
echo 1. Cierra las ventanas de comandos abiertas
echo 2. O presiona Ctrl+C en cada ventana
echo.
echo Presiona cualquier tecla para salir...
pause >nul
