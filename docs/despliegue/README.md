# 📚 Documentación de Despliegue

## 🎯 **ÍNDICE DE GUÍAS**

### **Guías Principales:**
- **[Guía de Despliegue en VPS Debian](guia_despliegue_vps_debian.md)** - Guía completa para desplegar en VPS Debian
- **[Configuración de Cloudflare](CLOUDFLARE_SETUP.md)** - Configuración de DNS y túneles

### **Guías Específicas:**
- **[Desarrollo Local](desarrollo-local.md)** - Configuración para desarrollo local (OBSOLETO)
- **[Guías Técnicas](../desarrollo/03-guias-tecnicas/)** - Guías técnicas específicas

---

## 🚀 **DESPLIEGUE RÁPIDO**

### **Para VPS Debian:**
```bash
# 1. Seguir la guía completa
cat guia_despliegue_vps_debian.md

# 2. O ejecutar comandos principales
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose snapd
sudo snap install flutter --classic
# ... (ver guía completa)
```

### **Para Desarrollo Local:**
```bash
# Ver guía de desarrollo local (OBSOLETO)
cat desarrollo-local.md
```

---

## 📋 **REQUISITOS DEL SISTEMA**

### **VPS Mínimo:**
- **OS**: Debian 11+ (Bullseye/Bookworm)
- **RAM**: 1GB mínimo
- **CPU**: 1 core mínimo
- **Disco**: 2GB espacio libre (Flutter via Snap)
- **Red**: IP pública con puerto 8082 abierto

### **VPS Recomendado:**
- **OS**: Debian 12 (Bookworm)
- **RAM**: 2GB+
- **CPU**: 2 cores+
- **Disco**: 5GB+ SSD
- **Red**: IP pública con dominio configurado

---

## 🔧 **TECNOLOGÍAS UTILIZADAS**

### **Frontend:**
- **Flutter Web** - Framework de desarrollo
- **Supabase Flutter** - Cliente de Supabase
- **BLoC** - Gestión de estado
- **GoRouter** - Navegación

### **Backend:**
- **Supabase Cloud** - Backend-as-a-Service (externo)
- **PostgreSQL** - Base de datos (gestionada por Supabase)
- **Row Level Security (RLS)** - Seguridad (configurada en Supabase)

### **Infraestructura:**
- **Docker** - Contenedorización
- **Nginx** - Servidor web
- **Docker Compose** - Orquestación

---

## 📊 **ARQUITECTURA DE DESPLIEGUE**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cliente Web   │────│   VPS Debian    │────│  Supabase Cloud │
│                 │    │                 │    │   (Externo)     │
│ - Navegador     │    │ - Docker        │    │                 │
│ - Flutter Web   │    │ - Nginx         │    │ - PostgreSQL    │
│                 │    │ - Flutter App   │    │ - Auth          │
│                 │    │                 │    │ - Storage       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS COMUNES**

### **Problema: Puerto 8082 no accesible**
```bash
# Verificar firewall
sudo ufw status
sudo ufw allow 8082

# Verificar que el contenedor está ejecutándose
docker ps | grep tfg-frontend-web
```

### **Problema: Aplicación no carga**
```bash
# Verificar que el build existe
ls -la /opt/tfg-frontend/build/web/

# Reconstruir aplicación
cd /opt/tfg-frontend
flutter build web --release
docker compose -f docker/docker-compose.yml restart
```

### **Problema: Docker no inicia**
```bash
# Verificar estado de Docker
sudo systemctl status docker
sudo systemctl restart docker
```

---

## 📞 **SOPORTE**

### **Recursos Oficiales:**
- **Flutter**: https://docs.flutter.dev/
- **Docker**: https://docs.docker.com/
- **Supabase**: https://supabase.com/docs
- **Nginx**: https://nginx.org/en/docs/

### **Logs Importantes:**
- **Docker**: `docker compose -f docker/docker-compose.yml logs`
- **Nginx**: `docker exec -it tfg-frontend-web cat /var/log/nginx/error.log`
- **Sistema**: `sudo journalctl -f`

---

## 📝 **NOTAS DE VERSIÓN**

### **Versión Actual:**
- **Flutter**: 3.24.5
- **Docker**: Latest
- **Supabase**: 2.10.0
- **Nginx**: Alpine

### **Última Actualización:**
- **Fecha**: Enero 2025
- **Cambios**: Migración a Supabase Cloud
- **Estado**: Estable

---

**¡Despliegue exitoso! 🚀**
