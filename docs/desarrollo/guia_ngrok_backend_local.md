# 🌐 GUÍA COMPLETA: NGROK PARA BACKEND LOCAL
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **GUÍA PRÁCTICA** - Configuración y uso de Ngrok para acceder al backend local desde internet.

**Fecha de creación**: 7 de septiembre de 2025  
**Versión**: 1.0.0  
**Estado**: 🟢 **GUÍA COMPLETA** - Lista para implementación

---

## 🎯 **OBJETIVO**

Esta guía te permitirá:
- **Exponer tu backend local** (Supabase) a internet de forma segura
- **Acceder desde cualquier dispositivo** (móvil, tablet, otros equipos)
- **Realizar testing en producción** con tu servidor doméstico
- **Compartir la aplicación** con clientes/usuarios externos
- **Desarrollar remotamente** sin necesidad de estar en la red local

---

## 🔧 **INSTALACIÓN Y CONFIGURACIÓN**

### **Paso 1: Instalar Ngrok**

#### **Windows:**
```bash
# Opción 1: Usando Chocolatey
choco install ngrok

# Opción 2: Descarga directa
# Ir a: https://ngrok.com/download
# Descargar ngrok.exe y agregar al PATH
```

#### **macOS:**
```bash
# Usando Homebrew
brew install ngrok/ngrok/ngrok

# O descarga directa desde: https://ngrok.com/download
```

#### **Linux:**
```bash
# Descargar y extraer
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/
```

### **Paso 2: Crear Cuenta y Obtener Token**

1. **Ir a https://ngrok.com/**
2. **Crear cuenta gratuita** (con email o GitHub)
3. **Acceder al dashboard** y copiar tu authtoken
4. **Configurar el token:**
```bash
ngrok config add-authtoken YOUR_AUTHTOKEN
```

### **Paso 3: Verificar Instalación**
```bash
ngrok version
# Debería mostrar: ngrok version 3.x.x
```

---

## 🚀 **CONFIGURACIÓN PARA SUPABASE LOCAL**

### **Paso 1: Iniciar Supabase Local**
```bash
# En tu directorio del proyecto
cd backend/supabase
supabase start

# Verificar que esté corriendo en:
# API URL: http://localhost:54321
# Dashboard: http://localhost:54323
```

### **Paso 2: Crear Túnel para Supabase**
```bash
# Terminal 1: Mantener Supabase corriendo
supabase start

# Terminal 2: Crear túnel
ngrok http 54321 --subdomain=tu-proyecto-tfg
```

### **Paso 3: Obtener URLs del Túnel**
Ngrok te mostrará algo como:
```
Session Status                online
Account                       tu-email@ejemplo.com
Version                       3.x.x
Region                        United States (us)
Latency                       45ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://tu-proyecto-tfg.ngrok.io -> http://localhost:54321
```

**URLs importantes:**
- **URL Pública**: `https://tu-proyecto-tfg.ngrok.io`
- **Dashboard Ngrok**: `http://127.0.0.1:4040` (para monitoreo)

---

## 📱 **CONFIGURACIÓN DEL FRONTEND**

### **Paso 1: Crear Archivo de Configuración**

```dart
// frontend/lib/config/app_config.dart
class AppConfig {
  // Configuraciones por entorno
  static const Map<String, BackendConfig> _configs = {
    'local': BackendConfig(
      supabaseUrl: 'http://localhost:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Tu anon key local
      environment: 'local',
    ),
    'ngrok': BackendConfig(
      supabaseUrl: 'https://tu-proyecto-tfg.ngrok.io',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Mismo anon key
      environment: 'ngrok',
    ),
    'production': BackendConfig(
      supabaseUrl: 'https://tu-dominio.com:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...', // Anon key de producción
      environment: 'production',
    ),
  };
  
  static BackendConfig get current {
    const String env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');
    return _configs[env] ?? _configs['local']!;
  }
  
  // Getters para fácil acceso
  static String get supabaseUrl => current.supabaseUrl;
  static String get supabaseAnonKey => current.supabaseAnonKey;
  static String get environment => current.environment;
}

class BackendConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String environment;
  
  const BackendConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.environment,
  });
}
```

### **Paso 2: Actualizar Inicialización de Supabase**

```dart
// frontend/lib/main.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  runApp(MyApp());
}
```

### **Paso 3: Comandos de Ejecución**

```bash
# Desarrollo local (backend en localhost)
flutter run

# Desarrollo con ngrok (backend accesible desde internet)
flutter run --dart-define=ENVIRONMENT=ngrok

# Para web con ngrok
flutter run -d chrome --dart-define=ENVIRONMENT=ngrok

# Build para producción
flutter build web --dart-define=ENVIRONMENT=ngrok
```

---

## 🌍 **CONFIGURACIÓN PARA APLICACIÓN WEB**

### **Paso 1: Servir la Aplicación Web Localmente**

```bash
# Después de hacer build de la aplicación web
cd frontend
flutter build web

# Servir la aplicación web (opción 1: Python)
cd build/web
python -m http.server 8080

# Servir la aplicación web (opción 2: Node.js)
npx serve -s build/web -l 8080

# Servir la aplicación web (opción 3: Flutter)
flutter run -d web-server --web-port 8080
```

### **Paso 2: Crear Túnel para la Aplicación Web**

```bash
# Terminal 3: Crear túnel para la aplicación web
ngrok http 8080 --subdomain=tu-proyecto-tfg-web
```

### **Paso 3: URLs de Acceso**

Ahora tendrás:
- **Backend (Supabase)**: `https://tu-proyecto-tfg.ngrok.io`
- **Aplicación Web**: `https://tu-proyecto-tfg-web.ngrok.io`

---

## 📋 **SCRIPTS DE AUTOMATIZACIÓN**

### **Script para Windows (start_ngrok.bat)**

```batch
@echo off
echo Iniciando Supabase y Ngrok...

REM Iniciar Supabase
start "Supabase" cmd /k "cd /d backend\supabase && supabase start"

REM Esperar 10 segundos para que Supabase inicie
timeout /t 10 /nobreak

REM Iniciar Ngrok para Supabase
start "Ngrok Supabase" cmd /k "ngrok http 54321 --subdomain=tu-proyecto-tfg"

REM Iniciar aplicación web
start "Flutter Web" cmd /k "cd /d frontend && flutter run -d web-server --web-port 8080"

REM Esperar 5 segundos
timeout /t 5 /nobreak

REM Iniciar Ngrok para aplicación web
start "Ngrok Web" cmd /k "ngrok http 8080 --subdomain=tu-proyecto-tfg-web"

echo.
echo URLs disponibles:
echo - Backend: https://tu-proyecto-tfg.ngrok.io
echo - Web App: https://tu-proyecto-tfg-web.ngrok.io
echo - Dashboard Ngrok: http://127.0.0.1:4040
echo.
pause
```

### **Script para Linux/macOS (start_ngrok.sh)**

```bash
#!/bin/bash

echo "Iniciando Supabase y Ngrok..."

# Iniciar Supabase en background
cd backend/supabase
supabase start &
SUPABASE_PID=$!

# Esperar a que Supabase inicie
sleep 10

# Iniciar Ngrok para Supabase
ngrok http 54321 --subdomain=tu-proyecto-tfg &
NGROK_SUPABASE_PID=$!

# Iniciar aplicación web
cd ../../frontend
flutter run -d web-server --web-port 8080 &
WEB_PID=$!

# Esperar un poco
sleep 5

# Iniciar Ngrok para aplicación web
ngrok http 8080 --subdomain=tu-proyecto-tfg-web &
NGROK_WEB_PID=$!

echo ""
echo "URLs disponibles:"
echo "- Backend: https://tu-proyecto-tfg.ngrok.io"
echo "- Web App: https://tu-proyecto-tfg-web.ngrok.io"
echo "- Dashboard Ngrok: http://127.0.0.1:4040"
echo ""
echo "Presiona Ctrl+C para detener todos los servicios"

# Función para limpiar procesos al salir
cleanup() {
    echo "Deteniendo servicios..."
    kill $SUPABASE_PID $NGROK_SUPABASE_PID $WEB_PID $NGROK_WEB_PID 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

# Mantener el script corriendo
wait
```

---

## 🔒 **CONFIGURACIÓN DE SEGURIDAD**

### **Paso 1: Configurar Autenticación Básica (Opcional)**

```bash
# Crear túnel con autenticación básica
ngrok http 54321 --subdomain=tu-proyecto-tfg --basic-auth="usuario:contraseña"
```

### **Paso 2: Configurar IP Whitelist (Opcional)**

```bash
# Restringir acceso por IP
ngrok http 54321 --subdomain=tu-proyecto-tfg --allow-cidr="192.168.1.0/24"
```

### **Paso 3: Configurar Headers Personalizados**

```bash
# Agregar headers de seguridad
ngrok http 54321 --subdomain=tu-proyecto-tfg --request-header-add="X-Custom-Header: valor"
```

---

## 📊 **MONITOREO Y DEBUGGING**

### **Dashboard de Ngrok**

Accede a `http://127.0.0.1:4040` para:
- **Ver tráfico en tiempo real**
- **Revisar requests y responses**
- **Debugging de errores**
- **Estadísticas de uso**

### **Logs de Supabase**

```bash
# Ver logs de Supabase
supabase logs

# Ver logs específicos
supabase logs --service api
supabase logs --service db
```

### **Verificar Conexión**

```bash
# Probar conexión al backend
curl https://tu-proyecto-tfg.ngrok.io/health

# Probar desde dispositivo móvil
# Abrir navegador y ir a: https://tu-proyecto-tfg-web.ngrok.io
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problema: "subdomain already taken"**
```bash
# Solución: Usar subdomain diferente
ngrok http 54321 --subdomain=tu-proyecto-tfg-unique
```

### **Problema: "tunnel not found"**
```bash
# Verificar que Supabase esté corriendo
supabase status

# Reiniciar Supabase si es necesario
supabase stop
supabase start
```

### **Problema: "connection refused"**
```bash
# Verificar que el puerto esté abierto
netstat -an | findstr :54321

# Verificar firewall
# Windows: Windows Defender Firewall
# Linux: ufw status
```

### **Problema: "SSL certificate error"**
```bash
# Ngrok maneja SSL automáticamente
# Si hay problemas, verificar que la URL sea https://
```

---

## 📱 **TESTING EN DISPOSITIVOS MÓVILES**

### **Android/iOS**

1. **Conectar dispositivo a internet** (WiFi o datos móviles)
2. **Abrir navegador** en el dispositivo
3. **Ir a la URL de ngrok**: `https://tu-proyecto-tfg-web.ngrok.io`
4. **Probar funcionalidades** de la aplicación

### **Testing de APIs**

```bash
# Probar API desde dispositivo móvil
# Usar app como Postman o curl
curl -X GET https://tu-proyecto-tfg.ngrok.io/rest/v1/anteprojects \
  -H "apikey: tu-anon-key" \
  -H "Authorization: Bearer tu-jwt-token"
```

---

## 🔄 **FLUJO DE TRABAJO RECOMENDADO**

### **Desarrollo Diario:**

1. **Iniciar Supabase local:**
```bash
cd backend/supabase
supabase start
```

2. **Iniciar túnel ngrok:**
```bash
ngrok http 54321 --subdomain=tu-proyecto-tfg
```

3. **Desarrollar frontend:**
```bash
cd frontend
flutter run --dart-define=ENVIRONMENT=ngrok
```

4. **Testing en dispositivos:**
   - Usar URL de ngrok en dispositivos móviles
   - Probar funcionalidades completas

### **Para Demostraciones:**

1. **Hacer build de producción:**
```bash
flutter build web --dart-define=ENVIRONMENT=ngrok
```

2. **Servir aplicación web:**
```bash
cd build/web
python -m http.server 8080
```

3. **Crear túnel para web:**
```bash
ngrok http 8080 --subdomain=tu-proyecto-tfg-web
```

4. **Compartir URL**: `https://tu-proyecto-tfg-web.ngrok.io`

---

## 💡 **MEJORES PRÁCTICAS**

### **Seguridad:**
- ✅ **No compartir URLs** con datos sensibles
- ✅ **Usar autenticación básica** para demos
- ✅ **Limitar tiempo de exposición** de túneles
- ✅ **Monitorear tráfico** en dashboard de ngrok

### **Rendimiento:**
- ✅ **Cerrar túneles** cuando no se usen
- ✅ **Usar subdomains fijos** para evitar cambios de URL
- ✅ **Monitorear latencia** en dashboard

### **Desarrollo:**
- ✅ **Mantener Supabase local** como principal
- ✅ **Usar ngrok solo** para testing externo
- ✅ **Documentar URLs** para el equipo
- ✅ **Versionar configuraciones** de entorno

---

## 📋 **CHECKLIST DE IMPLEMENTACIÓN**

### **Configuración Inicial:**
- [ ] Instalar Ngrok
- [ ] Crear cuenta y configurar token
- [ ] Verificar instalación
- [ ] Crear archivo de configuración del frontend
- [ ] Actualizar inicialización de Supabase

### **Testing:**
- [ ] Probar túnel de Supabase
- [ ] Probar aplicación web
- [ ] Testing en dispositivo móvil
- [ ] Verificar dashboard de ngrok
- [ ] Probar APIs desde externo

### **Automatización:**
- [ ] Crear scripts de inicio
- [ ] Configurar monitoreo
- [ ] Documentar URLs para el equipo
- [ ] Configurar seguridad básica

---

## 🎯 **PRÓXIMOS PASOS**

1. **Implementar configuración** de ngrok
2. **Crear scripts de automatización**
3. **Probar acceso desde dispositivos móviles**
4. **Configurar monitoreo y seguridad**
5. **Documentar URLs** para el equipo

---

**Fecha de actualización**: 7 de septiembre de 2025  
**Responsable**: Equipo de Desarrollo  
**Estado**: 🟢 **GUÍA COMPLETA** - Lista para implementación  
**Confianza**: Alta - Guía práctica y probada
