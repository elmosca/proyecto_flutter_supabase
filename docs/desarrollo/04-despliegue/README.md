# 🚀 DESPLIEGUE Y PRODUCCIÓN
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **DESPLIEGUE Y PRODUCCIÓN** - Guías para desplegar y mantener el sistema en producción.

---

## 📋 **DOCUMENTOS DISPONIBLES**

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| **[guia_actualizacion_servidor.md](./guia_actualizacion_servidor.md)** | Guía para actualizar servidor y levantar aplicación web | ✅ Completa |

---

## 🎯 **OBJETIVO**

Este directorio contiene documentación para:
- **Actualización de servidores**
- **Despliegue en producción**
- **Configuración de entornos**
- **Monitoreo y mantenimiento**
- **Scripts de automatización**

---

## 🚀 **INICIO RÁPIDO**

### **Para Actualizar Servidor:**
1. Leer **[guia_actualizacion_servidor.md](./guia_actualizacion_servidor.md)**
2. Ejecutar scripts automatizados
3. Verificar funcionamiento

### **Para Despliegue Completo:**
1. Actualizar repositorio en servidor
2. Levantar backend (Supabase)
3. Configurar Ngrok
4. Levantar aplicación web
5. Probar desde dispositivos externos

---

## 📚 **CONTENIDO DETALLADO**

### **🖥️ guia_actualizacion_servidor.md**
- **Prerequisitos** en el servidor
- **Actualización del repositorio** con git pull
- **Levantamiento del backend** (Supabase)
- **Configuración de Ngrok** para acceso externo
- **Levantamiento de la aplicación web**
- **Scripts de automatización** para Windows y Linux/macOS
- **Verificación y testing**
- **Monitoreo y debugging**
- **Solución de problemas**

---

## 🔧 **SCRIPTS AUTOMATIZADOS**

### **Scripts Disponibles:**
- **`scripts/start_server_system.sh`** - Linux/macOS
- **`scripts/start_server_system.bat`** - Windows

### **Funcionalidades de los Scripts:**
- ✅ **Verificación de dependencias** (Git, Supabase, Ngrok, Flutter, Python)
- ✅ **Actualización automática** del repositorio
- ✅ **Verificación de archivos** nuevos
- ✅ **Inicio de Supabase** local
- ✅ **Creación de túnel Ngrok** para backend
- ✅ **Construcción de aplicación web** con Flutter
- ✅ **Inicio de servidor web** con Python
- ✅ **Creación de túnel Ngrok** para aplicación web
- ✅ **Mostrar URLs** y credenciales
- ✅ **Abrir dashboard** de Ngrok automáticamente

---

## 🌐 **URLS DE ACCESO**

### **URLs Resultantes:**
- **Backend (Supabase)**: `https://tu-proyecto-tfg.ngrok.io`
- **Aplicación Web**: `https://tu-proyecto-tfg-web.ngrok.io`
- **Dashboard Ngrok**: `http://127.0.0.1:4040`

### **URLs Locales:**
- **Supabase Local**: `http://localhost:54321`
- **Servidor Web Local**: `http://localhost:8080`

---

## 📱 **TESTING EN PRODUCCIÓN**

### **Credenciales de Prueba:**
```json
{
  "email": "carlos.lopez@alumno.cifpcarlos3.es",
  "password": "password123",
  "role": "student"
}
```

### **Testing desde Dispositivos:**
1. **Conectar a internet** (WiFi o datos móviles)
2. **Abrir navegador** en el dispositivo
3. **Ir a la URL de ngrok**: `https://tu-proyecto-tfg-web.ngrok.io`
4. **Probar funcionalidades**:
   - Login con credenciales de prueba
   - Navegación entre pantallas
   - Formularios de anteproyectos
   - Sistema de comentarios
   - Sistema de archivos

---

## 🔧 **CONFIGURACIÓN AVANZADA**

### **Variables de Entorno:**
```bash
# Crear archivo .env
SUPABASE_URL=https://tu-proyecto-tfg.ngrok.io
SUPABASE_ANON_KEY=tu-anon-key-aqui
ENVIRONMENT=ngrok
```

### **Configuración de Seguridad:**
- **Autenticación básica** en Ngrok
- **IP Whitelist** para acceso restringido
- **Headers personalizados** de seguridad
- **Monitoreo de tráfico** en dashboard

---

## 📊 **MONITOREO Y DEBUGGING**

### **Dashboard de Ngrok:**
- **URL**: `http://127.0.0.1:4040`
- **Funciones**: Ver tráfico, requests, responses, errores
- **Monitoreo en tiempo real**

### **Logs del Sistema:**
```bash
# Logs de Supabase
supabase logs --follow

# Logs específicos
supabase logs --service api
supabase logs --service db

# Logs del servidor web
# Aparecen en la terminal donde ejecutaste el servidor
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problemas Comunes:**

#### **"git pull" falla**
```bash
# Verificar conexión
ping github.com

# Verificar credenciales
git config --list

# Forzar actualización
git fetch origin
git reset --hard origin/develop
```

#### **Supabase no inicia**
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

#### **Ngrok no funciona**
```bash
# Verificar authtoken
ngrok config check

# Verificar que el puerto esté abierto
netstat -tlnp | grep :54321

# Reiniciar ngrok
pkill ngrok
ngrok http 54321 --subdomain=tu-proyecto-tfg
```

#### **Aplicación web no carga**
```bash
# Verificar que el build se haya completado
ls -la frontend/build/web

# Verificar que el servidor esté corriendo
netstat -tlnp | grep :8080

# Verificar logs del servidor
```

---

## 📋 **CHECKLIST DE DESPLIEGUE**

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
**Estado**: ✅ **COMPLETO** - Guías de despliegue completas y probadas
