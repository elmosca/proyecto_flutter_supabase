# 🚀 RECUPERACIÓN DEL CONTENEDOR WEB FLUTTER

## 📋 **PROBLEMA IDENTIFICADO**
El contenedor web que mapeaba la aplicación Flutter en el puerto 8082 se ha roto y no tenemos el docker-compose para volver a levantarlo.

## ✅ **SOLUCIÓN IMPLEMENTADA**

### **1. CONFIGURACIÓN DOCKER COMPLETA**
- ✅ **Dockerfile optimizado** para Flutter Web
- ✅ **Docker Compose** configurado para puerto 8082
- ✅ **Nginx optimizado** para Flutter Web + Supabase
- ✅ **Scripts de recuperación** automáticos

### **2. ARCHIVOS CREADOS/ACTUALIZADOS**
```
frontend/docker/
├── docker-compose.yml          # ✅ Actualizado para puerto 8082
├── nginx/nginx.conf            # ✅ Optimizado para Flutter Web
├── web/Dockerfile              # ✅ Optimizado
├── scripts/
│   ├── recover-web-container.ps1  # ✅ Script PowerShell
│   └── recover-web-container.sh   # ✅ Script Bash
└── README_RECOVERY.md          # ✅ Este archivo
```

## 🚀 **INSTRUCCIONES DE RECUPERACIÓN**

### **OPCIÓN 1: Script Automático (RECOMENDADO)**

#### **Windows (PowerShell):**
```powershell
cd frontend
.\docker\scripts\recover-web-container.ps1
```

#### **Linux/macOS (Bash):**
```bash
cd frontend
chmod +x docker/scripts/recover-web-container.sh
./docker/scripts/recover-web-container.sh
```

### **OPCIÓN 2: Comandos Manuales**

#### **Paso 1: Limpiar entorno**
```bash
cd frontend
docker-compose -f docker/docker-compose.yml down --volumes --remove-orphans
docker system prune -f
```

#### **Paso 2: Construir aplicación Flutter**
```bash
flutter pub get
flutter build web --release --web-renderer html
```

#### **Paso 3: Construir y ejecutar contenedor**
```bash
docker-compose -f docker/docker-compose.yml build --no-cache
docker-compose -f docker/docker-compose.yml up -d
```

#### **Paso 4: Verificar funcionamiento**
```bash
# Verificar estado
docker-compose -f docker/docker-compose.yml ps

# Ver logs
docker-compose -f docker/docker-compose.yml logs -f

# Probar conectividad
curl http://localhost:8082
```

## 🌐 **ACCESO A LA APLICACIÓN**

Una vez ejecutado el script de recuperación:

- **URL**: http://localhost:8082
- **Health Check**: http://localhost:8082/health
- **Estado**: Verificar con `docker-compose -f docker/docker-compose.yml ps`

## 🔧 **COMANDOS ÚTILES**

### **Gestión del Contenedor**
```bash
# Ver estado
docker-compose -f docker/docker-compose.yml ps

# Ver logs
docker-compose -f docker/docker-compose.yml logs -f

# Detener
docker-compose -f docker/docker-compose.yml down

# Reiniciar
docker-compose -f docker/docker-compose.yml restart

# Reconstruir
docker-compose -f docker/docker-compose.yml build --no-cache
```

### **Debugging**
```bash
# Entrar al contenedor
docker exec -it tfg-frontend-web sh

# Ver logs de nginx
docker exec -it tfg-frontend-web cat /var/log/nginx/access.log
docker exec -it tfg-frontend-web cat /var/log/nginx/error.log

# Verificar archivos
docker exec -it tfg-frontend-web ls -la /usr/share/nginx/html
```

## 📊 **CONFIGURACIÓN TÉCNICA**

### **Puerto y Red**
- **Puerto externo**: 8082
- **Puerto interno**: 80
- **Red**: tfg-network
- **Contenedor**: tfg-frontend-web

### **Volúmenes**
- `../build/web:/usr/share/nginx/html:ro` - Archivos de la aplicación
- `nginx-logs:/var/log/nginx` - Logs de nginx

### **Health Check**
- **Endpoint**: http://localhost:80
- **Intervalo**: 30s
- **Timeout**: 10s
- **Retries**: 3

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Error: Puerto 8082 en uso**
```bash
# Verificar qué usa el puerto
netstat -ano | findstr :8082
# o
lsof -i :8082

# Detener proceso o cambiar puerto en docker-compose.yml
```

### **Error: No se puede construir Flutter**
```bash
# Limpiar cache de Flutter
flutter clean
flutter pub get
flutter build web --release --web-renderer html
```

### **Error: Contenedor no inicia**
```bash
# Ver logs detallados
docker-compose -f docker/docker-compose.yml logs

# Verificar configuración
docker-compose -f docker/docker-compose.yml config
```

### **Error: Archivos no encontrados**
```bash
# Verificar que existe build/web
ls -la build/web/

# Si no existe, reconstruir
flutter build web --release --web-renderer html
```

## 📈 **OPTIMIZACIONES IMPLEMENTADAS**

### **Nginx**
- ✅ Compresión gzip optimizada
- ✅ Cache headers para archivos estáticos
- ✅ Configuración específica para Flutter Web
- ✅ Headers de seguridad
- ✅ Health check endpoint

### **Docker**
- ✅ Multi-stage build optimizado
- ✅ Imagen Alpine ligera
- ✅ Volúmenes persistentes para logs
- ✅ Health checks automáticos
- ✅ Restart policy

### **Flutter Web**
- ✅ Renderer HTML optimizado
- ✅ Build de producción
- ✅ Assets optimizados
- ✅ Service worker configurado

## 🎯 **VERIFICACIÓN FINAL**

Después de ejecutar el script, verifica:

1. ✅ **Contenedor ejecutándose**: `docker ps | grep tfg-frontend-web`
2. ✅ **Puerto accesible**: `curl http://localhost:8082`
3. ✅ **Health check**: `curl http://localhost:8082/health`
4. ✅ **Logs sin errores**: `docker-compose -f docker/docker-compose.yml logs`

## 📞 **SOPORTE**

Si encuentras problemas:

1. **Revisar logs**: `docker-compose -f docker/docker-compose.yml logs -f`
2. **Verificar configuración**: `docker-compose -f docker/docker-compose.yml config`
3. **Reconstruir desde cero**: Ejecutar el script de recuperación nuevamente
4. **Verificar Flutter**: `flutter doctor` y `flutter build web --release`

---

**¡El contenedor web debería estar funcionando en http://localhost:8082! 🚀**
