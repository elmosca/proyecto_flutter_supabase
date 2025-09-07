# 🔧 CONFIGURACIÓN DE EJEMPLO: NGROK
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **CONFIGURACIÓN PRÁCTICA** - Ejemplo de configuración para tu proyecto específico.

**Fecha de creación**: 7 de septiembre de 2025  
**Versión**: 1.0.0  
**Estado**: 🟢 **CONFIGURACIÓN DE EJEMPLO** - Lista para personalizar

---

## 🎯 **PASOS PARA CONFIGURAR EN TU PROYECTO**

### **Paso 1: Personalizar URLs de Ngrok**

Edita el archivo `frontend/lib/config/app_config.dart`:

```dart
// Cambiar estas URLs por las tuyas
'ngrok': BackendConfig(
  supabaseUrl: 'https://TU-PROYECTO-TFG.ngrok.io',  // ← Cambiar aquí
  supabaseAnonKey: 'tu-anon-key-aqui',              // ← Cambiar aquí
  environment: 'ngrok',
  debugMode: true,
),
```

### **Paso 2: Personalizar Scripts**

Edita el archivo `scripts/start_ngrok.bat` (Windows):

```batch
REM Cambiar el subdomain por el tuyo
ngrok http 54321 --subdomain=TU-PROYECTO-TFG
```

Edita el archivo `scripts/start_ngrok.sh` (Linux/macOS):

```bash
# Cambiar el subdomain por el tuyo
ngrok http 54321 --subdomain=TU-PROYECTO-TFG
```

### **Paso 3: Obtener tu Anon Key de Supabase**

```bash
# En el directorio backend/supabase
supabase start

# El anon key aparecerá en la salida, cópialo
```

### **Paso 4: Configurar Ngrok**

```bash
# Crear cuenta en https://ngrok.com/
# Obtener tu authtoken del dashboard
ngrok config add-authtoken TU_AUTHTOKEN_AQUI
```

---

## 📋 **CHECKLIST DE CONFIGURACIÓN**

### **Configuración Inicial:**
- [ ] Crear cuenta en ngrok.com
- [ ] Obtener authtoken
- [ ] Configurar ngrok con el token
- [ ] Obtener anon key de Supabase local
- [ ] Personalizar URLs en app_config.dart
- [ ] Personalizar subdomains en scripts

### **Testing:**
- [ ] Ejecutar script de inicio
- [ ] Verificar que Supabase inicie correctamente
- [ ] Verificar que ngrok cree el túnel
- [ ] Probar acceso desde navegador
- [ ] Probar acceso desde dispositivo móvil

### **Verificación:**
- [ ] Backend accesible desde internet
- [ ] Aplicación web funcionando
- [ ] Dashboard ngrok mostrando tráfico
- [ ] Logs de Supabase sin errores

---

## 🚀 **COMANDOS DE EJECUCIÓN**

### **Windows:**
```cmd
# Ejecutar script automatizado
scripts\start_ngrok.bat

# O manualmente:
cd backend\supabase
supabase start

# En otra terminal:
ngrok http 54321 --subdomain=TU-PROYECTO-TFG

# En otra terminal:
cd frontend
flutter run -d web-server --web-port 8080 --dart-define=ENVIRONMENT=ngrok
```

### **Linux/macOS:**
```bash
# Ejecutar script automatizado
./scripts/start_ngrok.sh

# O manualmente:
cd backend/supabase
supabase start &

ngrok http 54321 --subdomain=TU-PROYECTO-TFG &

cd ../../frontend
flutter run -d web-server --web-port 8080 --dart-define=ENVIRONMENT=ngrok &
```

---

## 📱 **TESTING EN DISPOSITIVOS**

### **URLs para Testing:**
- **Backend**: `https://TU-PROYECTO-TFG.ngrok.io`
- **Aplicación Web**: `http://localhost:8080` (solo local)
- **Dashboard Ngrok**: `http://127.0.0.1:4040`

### **Desde Dispositivo Móvil:**
1. Conectar a internet (WiFi o datos)
2. Abrir navegador
3. Ir a: `https://TU-PROYECTO-TFG.ngrok.io`
4. Probar funcionalidades

---

## 🔧 **CONFIGURACIÓN AVANZADA**

### **Para Múltiples Túneles:**

```bash
# Terminal 1: Supabase
ngrok http 54321 --subdomain=tu-proyecto-tfg

# Terminal 2: Aplicación Web
ngrok http 8080 --subdomain=tu-proyecto-tfg-web

# Terminal 3: APIs REST (si las tienes)
ngrok http 3000 --subdomain=tu-proyecto-tfg-api
```

### **Con Autenticación Básica:**

```bash
# Túnel con usuario/contraseña
ngrok http 54321 --subdomain=tu-proyecto-tfg --basic-auth="usuario:contraseña"
```

### **Con IP Whitelist:**

```bash
# Solo permitir IPs específicas
ngrok http 54321 --subdomain=tu-proyecto-tfg --allow-cidr="192.168.1.0/24"
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS COMUNES**

### **"subdomain already taken"**
```bash
# Usar subdomain diferente
ngrok http 54321 --subdomain=tu-proyecto-tfg-unique
```

### **"tunnel not found"**
```bash
# Verificar que Supabase esté corriendo
supabase status

# Reiniciar si es necesario
supabase stop
supabase start
```

### **"connection refused"**
```bash
# Verificar puerto
netstat -an | findstr :54321

# Verificar firewall
```

### **"SSL certificate error"**
- Asegúrate de usar `https://` en las URLs
- Ngrok maneja SSL automáticamente

---

## 📊 **MONITOREO**

### **Dashboard Ngrok:**
- URL: `http://127.0.0.1:4040`
- Ver tráfico en tiempo real
- Revisar requests y responses
- Debugging de errores

### **Logs de Supabase:**
```bash
# Ver logs
supabase logs

# Logs específicos
supabase logs --service api
supabase logs --service db
```

---

## 💡 **MEJORES PRÁCTICAS**

### **Seguridad:**
- ✅ No compartir URLs con datos sensibles
- ✅ Usar autenticación básica para demos
- ✅ Limitar tiempo de exposición
- ✅ Monitorear tráfico

### **Desarrollo:**
- ✅ Mantener Supabase local como principal
- ✅ Usar ngrok solo para testing externo
- ✅ Documentar URLs para el equipo
- ✅ Cerrar túneles cuando no se usen

### **Rendimiento:**
- ✅ Usar subdomains fijos
- ✅ Monitorear latencia
- ✅ Optimizar para conexiones lentas

---

## 🎯 **PRÓXIMOS PASOS**

1. **Personalizar configuración** con tus URLs
2. **Probar acceso** desde dispositivos móviles
3. **Configurar monitoreo** y seguridad
4. **Documentar URLs** para el equipo
5. **Automatizar proceso** de inicio

---

**Fecha de actualización**: 7 de septiembre de 2025  
**Responsable**: Equipo de Desarrollo  
**Estado**: 🟢 **CONFIGURACIÓN DE EJEMPLO** - Lista para personalizar  
**Confianza**: Alta - Configuración probada y documentada
