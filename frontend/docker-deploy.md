# 🐳 Guía de Despliegue Docker - Aplicación Flutter Web

## 📋 Descripción

Esta guía explica cómo desplegar la aplicación Flutter Web usando Docker para que otros desarrolladores puedan acceder y testear la aplicación a través de un navegador web.

**📁 Todos los archivos Docker están organizados en el directorio `docker/` para mantener el proyecto limpio.**

## 🚀 Despliegue Rápido

### **Opción 1: Script Automatizado (Recomendado)**

```powershell
# Windows PowerShell
.\docker\scripts\docker-deploy.ps1 production

# Linux/Mac Bash
./docker/scripts/docker-deploy.sh production
```

### **Opción 2: Comandos Docker Compose**

```bash
# Ir al directorio docker
cd docker

# Modo producción
docker-compose up -d frontend-web

# Modo desarrollo
docker-compose --profile dev up -d frontend-dev
```

## 🌐 Acceso a la Aplicación

### **Modo Producción**
- **URL**: http://localhost:8080
- **Puerto**: 8080
- **Optimizado**: Sí (build release)

### **Modo Desarrollo**
- **URL**: http://localhost:3000
- **Puerto**: 3000
- **Hot Reload**: Sí (desarrollo activo)

## 📁 Estructura Organizada

```
proyecto_flutter_supabase/
├── lib/                    # Código Flutter
├── test/                   # Tests
├── web/                    # Archivos web de Flutter
├── docker/                 # 🐳 Configuración Docker
│   ├── web/               # Dockerfiles para la aplicación
│   ├── nginx/             # Configuración de Nginx
│   ├── scripts/           # Scripts de despliegue
│   ├── docker-compose.yml # Configuración principal
│   └── README.md          # Documentación Docker
├── pubspec.yaml           # Dependencias Flutter
└── README.md              # Documentación principal
```

## 🔧 Comandos Útiles

### **Scripts de Despliegue**

```powershell
# Windows PowerShell
.\docker\scripts\docker-deploy.ps1 help
.\docker\scripts\docker-deploy.ps1 status
.\docker\scripts\docker-deploy.ps1 logs
.\docker\scripts\docker-deploy.ps1 stop
.\docker\scripts\docker-deploy.ps1 cleanup
```

```bash
# Linux/Mac Bash
./docker/scripts/docker-deploy.sh help
./docker/scripts/docker-deploy.sh status
./docker/scripts/docker-deploy.sh logs
./docker/scripts/docker-deploy.sh stop
./docker/scripts/docker-deploy.sh cleanup
```

### **Docker Compose Directo**

```bash
# Desde el directorio docker/
cd docker

# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Detener
docker-compose down

# Limpiar
docker-compose down --volumes --remove-orphans
```

## 🌍 Acceso desde Otros Dispositivos

### **Configuración de Red**

Para que otros desarrolladores accedan desde sus dispositivos:

1. **Obtener IP del servidor**:
   ```powershell
   # Windows
   ipconfig
   
   # Linux/Mac
   ifconfig
   ```

2. **Acceder desde otros dispositivos**:
   ```
   http://[IP_DEL_SERVIDOR]:8080
   ```

3. **Configurar firewall** (si es necesario):
   ```powershell
   # Windows PowerShell (como administrador)
   New-NetFirewallRule -DisplayName "Flutter Web" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
   
   # Linux
   sudo ufw allow 8080
   ```

## 🔒 Configuración de Seguridad

### **Variables de Entorno**

Crear archivo `.env` en el directorio raíz del proyecto:

```env
# Configuración de Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Configuración de la aplicación
NODE_ENV=production
FLUTTER_WEB_DEBUG=false
```

## 📊 Monitoreo y Logs

### **Logs de Aplicación**

```bash
# Ver logs de todos los servicios
cd docker
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f frontend-web

# Ver logs de Nginx
docker-compose exec frontend-web tail -f /var/log/nginx/access.log
```

## 🚨 Solución de Problemas

### **Problemas Comunes**

1. **Puerto ya en uso**:
   ```yaml
   # Cambiar puerto en docker/docker-compose.yml
   ports:
     - "8081:80"  # Cambiar 8080 por 8081
   ```

2. **Error de permisos** (Linux/Mac):
   ```bash
   # Hacer ejecutable el script
   chmod +x docker/scripts/docker-deploy.sh
   ```

3. **Error de build**:
   ```bash
   # Limpiar y reconstruir
   cd docker
   docker-compose down --volumes
   docker-compose build --no-cache
   ```

## 🔄 Actualizaciones

### **Actualizar Aplicación**

```bash
# 1. Detener aplicación
cd docker
docker-compose down

# 2. Actualizar código
cd ..
git pull origin main

# 3. Reconstruir y ejecutar
cd docker
docker-compose build --no-cache
docker-compose up -d
```

## 📚 Recursos Adicionales

- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **Flutter Web**: https://docs.flutter.dev/platform-integration/web
- **Nginx**: https://nginx.org/en/docs/

## 🎯 Checklist de Despliegue

- [ ] Docker instalado y funcionando
- [ ] Docker Compose instalado
- [ ] Scripts de despliegue ejecutables
- [ ] Variables de entorno configuradas
- [ ] Puertos disponibles (8080, 3000)
- [ ] Firewall configurado (si es necesario)
- [ ] Aplicación accesible desde navegador
- [ ] Logs funcionando correctamente
- [ ] Health checks pasando
- [ ] Otros desarrolladores pueden acceder

---

**¡La aplicación está lista para ser compartida con tu equipo! 🚀**

**📁 Para más detalles, consulta la documentación completa en `docker/README.md`**
