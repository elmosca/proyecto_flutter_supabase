# 🖥️ GUÍA DE ACTUALIZACIÓN DEL SERVIDOR
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **GUÍA PRÁCTICA** - Actualizar el servidor con los últimos cambios y levantar la aplicación web.

**Fecha de creación**: 7 de septiembre de 2025  
**Versión**: 1.0.0  
**Estado**: 🟢 **GUÍA COMPLETA** - Lista para implementación

---

## 🎯 **OBJETIVO**

Esta guía te permitirá:
- **Actualizar el servidor** con los últimos cambios del repositorio
- **Levantar la aplicación web** en el mismo servidor del backend
- **Configurar Ngrok** para acceso externo
- **Realizar pruebas** desde dispositivos externos
- **Monitorear** el funcionamiento del sistema

---

## 📋 **PREREQUISITOS EN EL SERVIDOR**

### **Software Necesario:**
- ✅ **Git** instalado
- ✅ **Docker** y **Docker Compose** instalados
- ✅ **Supabase CLI** instalado
- ✅ **Node.js** (v16+) instalado
- ✅ **Ngrok** instalado
- ✅ **Python 3** (para servir archivos estáticos)

### **Verificar Instalaciones:**
```bash
# Verificar que todo esté instalado
git --version
docker --version
docker-compose --version
supabase --version
node --version
npm --version
ngrok version
python3 --version
```

---

## 🔄 **PASO 1: ACTUALIZAR REPOSITORIO EN EL SERVIDOR**

### **Conectar al Servidor:**
```bash
# Conectar por SSH
ssh usuario@ip-del-servidor

# O si usas Windows con WSL
wsl
ssh usuario@ip-del-servidor
```

### **Actualizar Código:**
```bash
# Ir al directorio del proyecto
cd /ruta/al/proyecto_flutter_supabase

# Verificar estado actual
git status
git branch

# Cambiar a la rama develop (si no estás en ella)
git checkout develop

# Actualizar con los últimos cambios
git pull origin develop

# Verificar que se hayan descargado los cambios
git log --oneline -3
```

### **Verificar Archivos Nuevos:**
```bash
# Verificar que se hayan descargado los nuevos archivos
ls -la docs/desarrollo/guia_ngrok_backend_local.md
ls -la frontend/lib/config/app_config.dart
ls -la scripts/start_ngrok.sh
ls -la scripts/start_ngrok.bat
```

---

## 🚀 **PASO 2: LEVANTAR BACKEND (SUPABASE)**

### **Iniciar Supabase:**
```bash
# Ir al directorio del backend
cd backend/supabase

# Verificar estado
supabase status

# Si está corriendo, detenerlo
supabase stop

# Iniciar Supabase
supabase start

# Verificar que esté funcionando
supabase status
```

### **Verificar URLs del Backend:**
```bash
# Las URLs deberían ser algo como:
# API URL: http://localhost:54321
# Dashboard: http://localhost:54323
# DB URL: postgresql://postgres:postgres@localhost:54322/postgres
```

---

## 🌐 **PASO 3: CONFIGURAR NGROK**

### **Configurar Ngrok (si no está configurado):**
```bash
# Configurar authtoken (si no lo has hecho)
ngrok config add-authtoken TU_AUTHTOKEN

# Verificar configuración
ngrok config check
```

### **Crear Túnel para Supabase:**
```bash
# En una nueva terminal o en background
ngrok http 54321 --subdomain=tu-proyecto-tfg

# Anotar la URL que te da ngrok
# Ejemplo: https://tu-proyecto-tfg.ngrok.io
```

---

## 📱 **PASO 4: LEVANTAR APLICACIÓN WEB**

### **Opción 1: Usando Flutter (Recomendado)**

```bash
# Ir al directorio del frontend
cd frontend

# Instalar dependencias
flutter pub get

# Hacer build de la aplicación web
flutter build web --dart-define=ENVIRONMENT=ngrok

# Servir la aplicación web
cd build/web
python3 -m http.server 8080

# O usando Node.js si prefieres
# npx serve -s build/web -l 8080
```

### **Opción 2: Usando Script Automatizado**

```bash
# Hacer ejecutable el script (Linux/macOS)
chmod +x scripts/start_ngrok.sh

# Ejecutar script automatizado
./scripts/start_ngrok.sh
```

### **Verificar Aplicación Web:**
```bash
# La aplicación debería estar disponible en:
# http://localhost:8080
```

---

## 🔗 **PASO 5: CONFIGURAR TÚNEL PARA APLICACIÓN WEB**

### **Crear Segundo Túnel:**
```bash
# En otra terminal
ngrok http 8080 --subdomain=tu-proyecto-tfg-web

# Anotar la URL
# Ejemplo: https://tu-proyecto-tfg-web.ngrok.io
```

---

## ✅ **PASO 6: VERIFICAR CONFIGURACIÓN**

### **URLs Disponibles:**
- **Backend (Supabase)**: `https://tu-proyecto-tfg.ngrok.io`
- **Aplicación Web**: `https://tu-proyecto-tfg-web.ngrok.io`
- **Dashboard Ngrok**: `http://127.0.0.1:4040`

### **Verificar Funcionamiento:**
```bash
# Probar backend
curl https://tu-proyecto-tfg.ngrok.io/health

# Probar aplicación web
curl https://tu-proyecto-tfg-web.ngrok.io
```

---

## 📱 **PASO 7: TESTING EN DISPOSITIVOS**

### **Desde Dispositivo Móvil:**
1. **Conectar a internet** (WiFi o datos móviles)
2. **Abrir navegador**
3. **Ir a**: `https://tu-proyecto-tfg-web.ngrok.io`
4. **Probar funcionalidades**:
   - Login con credenciales de prueba
   - Navegación entre pantallas
   - Formularios de anteproyectos
   - Sistema de comentarios
   - Sistema de archivos

### **Credenciales de Prueba:**
```json
{
  "email": "carlos.lopez@alumno.cifpcarlos3.es",
  "password": "password123",
  "role": "student"
}
```

---

## 🔧 **CONFIGURACIÓN AVANZADA**

### **Configurar Variables de Entorno:**

```bash
# Crear archivo de configuración
nano .env

# Contenido del archivo:
SUPABASE_URL=https://tu-proyecto-tfg.ngrok.io
SUPABASE_ANON_KEY=tu-anon-key-aqui
ENVIRONMENT=ngrok
```

### **Script de Inicio Automático:**

```bash
# Crear script de inicio
nano start_system.sh

# Contenido del script:
#!/bin/bash
echo "Iniciando Sistema TFG..."

# Iniciar Supabase
cd backend/supabase
supabase start &
SUPABASE_PID=$!

# Esperar a que Supabase inicie
sleep 15

# Iniciar túnel ngrok para Supabase
ngrok http 54321 --subdomain=tu-proyecto-tfg &
NGROK_SUPABASE_PID=$!

# Iniciar aplicación web
cd ../../frontend
flutter build web --dart-define=ENVIRONMENT=ngrok
cd build/web
python3 -m http.server 8080 &
WEB_PID=$!

# Iniciar túnel ngrok para aplicación web
ngrok http 8080 --subdomain=tu-proyecto-tfg-web &
NGROK_WEB_PID=$!

echo "Sistema iniciado correctamente"
echo "Backend: https://tu-proyecto-tfg.ngrok.io"
echo "Web App: https://tu-proyecto-tfg-web.ngrok.io"

# Mantener corriendo
wait
```

```bash
# Hacer ejecutable
chmod +x start_system.sh

# Ejecutar
./start_system.sh
```

---

## 📊 **MONITOREO Y DEBUGGING**

### **Dashboard de Ngrok:**
- **URL**: `http://127.0.0.1:4040`
- **Funciones**: Ver tráfico, requests, responses, errores

### **Logs de Supabase:**
```bash
# Ver logs en tiempo real
supabase logs --follow

# Logs específicos
supabase logs --service api
supabase logs --service db
```

### **Logs de la Aplicación Web:**
```bash
# Si usas Python
# Los logs aparecen en la terminal donde ejecutaste python3 -m http.server

# Si usas Node.js
# Los logs aparecen en la terminal donde ejecutaste npx serve
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problema: "git pull" falla**
```bash
# Verificar conexión
ping github.com

# Verificar credenciales
git config --list

# Forzar actualización
git fetch origin
git reset --hard origin/develop
```

### **Problema: Supabase no inicia**
```bash
# Verificar Docker
docker ps

# Reiniciar Docker
sudo systemctl restart docker

# Limpiar y reiniciar Supabase
supabase stop
supabase db reset
supabase start
```

### **Problema: Ngrok no funciona**
```bash
# Verificar authtoken
ngrok config check

# Verificar que el puerto esté abierto
netstat -tlnp | grep :54321

# Reiniciar ngrok
pkill ngrok
ngrok http 54321 --subdomain=tu-proyecto-tfg
```

### **Problema: Aplicación web no carga**
```bash
# Verificar que el build se haya completado
ls -la frontend/build/web

# Verificar que el servidor esté corriendo
netstat -tlnp | grep :8080

# Verificar logs del servidor
# Revisar la terminal donde ejecutaste el servidor
```

---

## 📋 **CHECKLIST DE VERIFICACIÓN**

### **Antes de Empezar:**
- [ ] Servidor conectado a internet
- [ ] Software necesario instalado
- [ ] Acceso SSH al servidor
- [ ] Cuenta de Ngrok configurada

### **Actualización:**
- [ ] Repositorio actualizado con `git pull`
- [ ] Archivos nuevos descargados
- [ ] Backend (Supabase) funcionando
- [ ] Túnel ngrok para backend creado

### **Aplicación Web:**
- [ ] Build de Flutter completado
- [ ] Servidor web funcionando
- [ ] Túnel ngrok para web creado
- [ ] URLs accesibles desde internet

### **Testing:**
- [ ] Backend accesible desde externo
- [ ] Aplicación web accesible desde externo
- [ ] Login funcionando
- [ ] Funcionalidades principales probadas

---

## 🎯 **PRÓXIMOS PASOS**

1. **Actualizar servidor** con los cambios
2. **Levantar backend** y aplicación web
3. **Configurar Ngrok** para acceso externo
4. **Probar desde dispositivos** móviles
5. **Monitorear funcionamiento** y logs

---

**Fecha de actualización**: 7 de septiembre de 2025  
**Responsable**: Equipo de Desarrollo  
**Estado**: 🟢 **GUÍA COMPLETA** - Lista para implementación  
**Confianza**: Alta - Guía práctica y probada
