# 🚀 OPCIONES DE DESPLIEGUE BACKEND - TFG

## 📋 **RESUMEN EJECUTIVO**

Este documento describe las **tres opciones principales** para desplegar el backend del sistema TFG:

1. **Supabase Local** - Para desarrollo y testing
2. **Supabase Cloud** - Alternativa a Firebase para producción
3. **Servidor Independiente** - Para control total y producción interna

---

## 🎯 **OPCIÓN 1: SUPABASE LOCAL**

### **Descripción**
Backend ejecutándose en tu máquina local o servidor de red doméstica usando Supabase CLI y Docker.

### **Ventajas**
- ✅ **Control total** sobre la infraestructura
- ✅ **Sin costos** de hosting
- ✅ **Sin límites** de uso o almacenamiento
- ✅ **Desarrollo rápido** sin dependencias externas
- ✅ **Privacidad total** de datos
- ✅ **Configuración personalizada** completa

### **Desventajas**
- ❌ **Mantenimiento manual** requerido
- ❌ **Depende de tu infraestructura** (electricidad, internet)
- ❌ **Configuración compleja** inicial
- ❌ **Sin backups automáticos** (debes configurarlos)
- ❌ **Escalabilidad limitada** a tu hardware

### **Configuración**

#### **Requisitos**
```bash
# Instalar Supabase CLI
curl -fsSL https://cli.supabase.com/install | sh

# Instalar Docker
sudo apt-get install docker.io docker-compose

# Verificar instalación
supabase --version
docker --version
```

#### **Configuración Inicial**
```bash
# Navegar al directorio del backend
cd backend/supabase

# Inicializar proyecto (si no existe)
supabase init

# Crear archivo de configuración
cp .env.example .env

# Editar variables de entorno
nano .env
```

#### **Variables de Entorno**
```bash
# .env
POSTGRES_PASSWORD=postgres
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
DASHBOARD_USERNAME=supabase
DASHBOARD_PASSWORD=this_password_is_insecure_and_should_be_updated
API_EXTERNAL_URL=http://localhost:54321
```

#### **Iniciar Servicios**
```bash
# Iniciar todos los servicios
supabase start

# Verificar estado
supabase status

# Ver logs
supabase logs
```

#### **Aplicar Migraciones**
```bash
# Aplicar todas las migraciones
supabase db reset

# O aplicar migraciones incrementales
supabase migration up
```

### **URLs de Acceso**
```bash
# API REST
http://localhost:54321

# Dashboard de Supabase
http://localhost:54323

# Base de datos PostgreSQL
postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Storage
http://localhost:54324
```

### **Comandos Útiles**
```bash
# Detener servicios
supabase stop

# Reiniciar servicios
supabase restart

# Ver logs en tiempo real
supabase logs --follow

# Resetear base de datos
supabase db reset

# Crear nueva migración
supabase migration new nombre_migracion
```

---

## ☁️ **OPCIÓN 2: SUPABASE CLOUD**

### **Descripción**
Backend alojado en los servidores de Supabase (AWS) como alternativa a Firebase de Google.

### **Ventajas**
- ✅ **Sin mantenimiento** de infraestructura
- ✅ **Escalabilidad automática** según demanda
- ✅ **Backups automáticos** diarios
- ✅ **Alta disponibilidad** (99.9%+ uptime)
- ✅ **Configuración simple** y rápida
- ✅ **Plan gratuito** generoso
- ✅ **Integración nativa** con otros servicios AWS

### **Desventajas**
- ❌ **Dependencia externa** de Supabase
- ❌ **Costos** en planes pagados
- ❌ **Límites** de uso en plan gratuito
- ❌ **Control limitado** sobre la infraestructura
- ❌ **Datos en servidores externos**

### **Configuración**

#### **Crear Proyecto en Supabase Cloud**
1. Ir a [supabase.com](https://supabase.com)
2. Crear cuenta o iniciar sesión
3. Crear nuevo proyecto
4. Seleccionar región (recomendado: Europa)
5. Configurar contraseña de base de datos

#### **Vincular Proyecto Local con Cloud**
```bash
# Obtener Project Reference ID
# (disponible en Settings > General del proyecto)

# Vincular proyecto local con cloud
supabase link --project-ref YOUR_PROJECT_REF

# Verificar conexión
supabase status
```

#### **Subir Migraciones a Cloud**
```bash
# Subir esquema de base de datos
supabase db push

# Subir Edge Functions
supabase functions deploy

# Subir datos de ejemplo (opcional)
supabase db reset --linked
```

#### **Variables de Entorno para Cloud**
```bash
# Obtener desde Settings > API del proyecto
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### **Planes y Límites**

#### **Plan Gratuito**
- **Base de datos**: 500MB
- **Bandwidth**: 2GB/mes
- **Auth users**: 50,000
- **Edge Functions**: 500,000 invocations/mes
- **Storage**: 1GB
- **Realtime**: 2 concurrent connections

#### **Plan Pro ($25/mes)**
- **Base de datos**: 8GB
- **Bandwidth**: 250GB/mes
- **Auth users**: 100,000
- **Edge Functions**: 2M invocations/mes
- **Storage**: 100GB
- **Realtime**: 100 concurrent connections

### **Migración de Local a Cloud**
```bash
# 1. Vincular proyecto
supabase link --project-ref YOUR_PROJECT_REF

# 2. Subir migraciones
supabase db push

# 3. Desplegar funciones
supabase functions deploy

# 4. Actualizar variables en frontend
# Cambiar SUPABASE_URL y claves en el frontend

# 5. Probar conexión
curl -X GET 'https://your-project.supabase.co/rest/v1/anteprojects' \
  -H "apikey: YOUR_ANON_KEY"
```

---

## 🖥️ **OPCIÓN 3: SERVIDOR INDEPENDIENTE**

### **Descripción**
Backend ejecutándose en tu propio servidor (físico o VPS) con PostgreSQL y Supabase instalado.

### **Ventajas**
- ✅ **Control total** sobre infraestructura y datos
- ✅ **Sin dependencias** de servicios externos
- ✅ **Costos mínimos** (solo electricidad/internet)
- ✅ **Privacidad máxima** de datos
- ✅ **Configuración personalizada** completa
- ✅ **Sin límites** de uso o almacenamiento

### **Desventajas**
- ❌ **Mantenimiento manual** requerido
- ❌ **Configuración compleja** inicial
- ❌ **Responsabilidad** de seguridad y backups
- ❌ **Depende de tu infraestructura**
- ❌ **Escalabilidad limitada** a tu hardware

### **Configuración**

#### **Requisitos del Servidor**
```bash
# Sistema operativo recomendado: Ubuntu 20.04+ o CentOS 8+
# RAM mínima: 4GB (recomendado: 8GB+)
# Almacenamiento: 20GB+ (SSD recomendado)
# CPU: 2 cores+ (recomendado: 4 cores+)
# Conexión: Internet estable con IP pública
```

#### **Instalación de PostgreSQL**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# CentOS/RHEL
sudo yum install postgresql postgresql-server
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### **Configuración de PostgreSQL**
```bash
# Acceder como usuario postgres
sudo -u postgres psql

# Crear base de datos para Supabase
CREATE DATABASE supabase;

# Crear usuario para Supabase
CREATE USER supabase WITH PASSWORD 'your-secure-password';

# Otorgar permisos
GRANT ALL PRIVILEGES ON DATABASE supabase TO supabase;

# Salir
\q
```

#### **Instalación de Supabase en Servidor**
```bash
# Instalar Docker en el servidor
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Supabase CLI
curl -fsSL https://cli.supabase.com/install | sh

# Crear directorio para el proyecto
mkdir -p /opt/supabase-tfg
cd /opt/supabase-tfg

# Inicializar proyecto
supabase init

# Configurar variables de entorno
nano .env
```

#### **Configuración de Variables de Entorno**
```bash
# .env para servidor independiente
POSTGRES_PASSWORD=your-secure-password
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=your-secure-dashboard-password
API_EXTERNAL_URL=https://your-server.com:54321

# Configuración de red
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=supabase
POSTGRES_USER=supabase
```

#### **Configuración de Red y Firewall**
```bash
# Abrir puertos necesarios
sudo ufw allow 54321  # API REST
sudo ufw allow 54323  # Dashboard
sudo ufw allow 54322  # PostgreSQL (solo si es necesario)
sudo ufw allow 54324  # Storage

# Configurar reverse proxy (opcional)
# Usar Nginx para HTTPS y dominio personalizado
```

#### **Configuración de SSL/HTTPS**
```bash
# Instalar Certbot para Let's Encrypt
sudo apt install certbot python3-certbot-nginx

# Obtener certificado SSL
sudo certbot --nginx -d your-domain.com

# Configurar renovación automática
sudo crontab -e
# Añadir: 0 12 * * * /usr/bin/certbot renew --quiet
```

### **Backups y Mantenimiento**

#### **Backup Automático de Base de Datos**
```bash
#!/bin/bash
# /opt/scripts/backup-db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
DB_NAME="supabase"

# Crear directorio de backups
mkdir -p $BACKUP_DIR

# Realizar backup
pg_dump -h localhost -U supabase $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Comprimir backup
gzip $BACKUP_DIR/backup_$DATE.sql

# Eliminar backups antiguos (mantener últimos 7 días)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completado: backup_$DATE.sql.gz"
```

#### **Cron Job para Backups**
```bash
# Configurar backup diario
sudo crontab -e

# Añadir línea para backup diario a las 2:00 AM
0 2 * * * /opt/scripts/backup-db.sh >> /var/log/backup.log 2>&1
```

#### **Monitoreo del Servidor**
```bash
# Instalar herramientas de monitoreo
sudo apt install htop iotop nethogs

# Configurar alertas de espacio en disco
# Configurar monitoreo de servicios
# Configurar logs de aplicación
```

### **Migración de Local a Servidor Independiente**
```bash
# 1. Exportar datos del entorno local
supabase db dump --local

# 2. Transferir archivo de backup al servidor
scp supabase_dump.sql user@your-server:/tmp/

# 3. Importar datos en el servidor
psql -h localhost -U supabase -d supabase -f /tmp/supabase_dump.sql

# 4. Aplicar migraciones en el servidor
supabase db reset

# 5. Actualizar variables de entorno en frontend
# Cambiar SUPABASE_URL a tu servidor
```

---

## 📊 **COMPARACIÓN DETALLADA**

| Aspecto | Local | Cloud | Servidor Independiente |
|---------|-------|-------|----------------------|
| **Costo Mensual** | $0 | $0-$25+ | $5-$50 (VPS) |
| **Configuración** | Media | Fácil | Compleja |
| **Mantenimiento** | Manual | Automático | Manual |
| **Escalabilidad** | Limitada | Automática | Manual |
| **Backups** | Manual | Automático | Manual |
| **Uptime** | 95-99% | 99.9%+ | 95-99% |
| **Control** | Total | Limitado | Total |
| **Privacidad** | Máxima | Media | Máxima |
| **Velocidad** | Muy alta | Alta | Alta |
| **Seguridad** | Tu responsabilidad | Gestionada | Tu responsabilidad |

---

## 🎯 **RECOMENDACIONES POR CASO DE USO**

### **Desarrollo y Testing**
- **Recomendado**: Supabase Local
- **Razón**: Control total, sin costos, desarrollo rápido
- **Configuración**: 30 minutos

### **MVP y Prototipos**
- **Recomendado**: Supabase Cloud (Plan Gratuito)
- **Razón**: Configuración rápida, sin mantenimiento
- **Configuración**: 15 minutos

### **Producción Interna/Corporativa**
- **Recomendado**: Servidor Independiente
- **Razón**: Control de datos, sin dependencias externas
- **Configuración**: 2-4 horas

### **Aplicaciones Públicas/Startups**
- **Recomendado**: Supabase Cloud (Plan Pro)
- **Razón**: Escalabilidad, mantenimiento automático
- **Configuración**: 30 minutos

### **Aplicaciones Críticas/Enterprise**
- **Recomendado**: Servidor Independiente + Backup Cloud
- **Razón**: Control total + redundancia
- **Configuración**: 4-8 horas

---

## 🔄 **MIGRACIÓN ENTRE OPCIONES**

### **Flujo de Migración Recomendado**

1. **Desarrollo**: Comenzar con Supabase Local
2. **Testing**: Usar Supabase Local o Cloud (gratuito)
3. **MVP**: Migrar a Supabase Cloud
4. **Producción**: Evaluar entre Cloud y Servidor Independiente

### **Comandos de Migración**

#### **Local → Cloud**
```bash
# Vincular proyecto
supabase link --project-ref YOUR_PROJECT_REF

# Subir migraciones
supabase db push

# Desplegar funciones
supabase functions deploy

# Actualizar frontend
# Cambiar SUPABASE_URL y claves
```

#### **Local → Servidor Independiente**
```bash
# Exportar datos
supabase db dump --local

# Transferir al servidor
scp supabase_dump.sql user@server:/tmp/

# Importar en servidor
psql -h localhost -U supabase -d supabase -f /tmp/supabase_dump.sql

# Aplicar migraciones
supabase db reset

# Actualizar frontend
# Cambiar SUPABASE_URL a tu servidor
```

#### **Cloud → Servidor Independiente**
```bash
# Exportar desde cloud
supabase db dump --linked

# Transferir al servidor
scp supabase_dump.sql user@server:/tmp/

# Importar en servidor
psql -h localhost -U supabase -d supabase -f /tmp/supabase_dump.sql

# Aplicar migraciones
supabase db reset

# Actualizar frontend
# Cambiar SUPABASE_URL a tu servidor
```

---

## 🛠️ **CONFIGURACIÓN DEL FRONTEND**

### **Variables de Entorno por Opción**

#### **Supabase Local**
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'http://localhost:54321';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

#### **Supabase Cloud**
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';
}
```

#### **Servidor Independiente**
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://your-server.com:54321';
  static const String anonKey = 'your-anon-key';
}
```

### **Configuración Condicional**
```dart
// lib/config/environment.dart
enum Environment { local, cloud, server }

class EnvironmentConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');
    switch (env) {
      case 'cloud':
        return Environment.cloud;
      case 'server':
        return Environment.server;
      default:
        return Environment.local;
    }
  }

  static String get supabaseUrl {
    switch (environment) {
      case Environment.cloud:
        return 'https://your-project.supabase.co';
      case Environment.server:
        return 'https://your-server.com:54321';
      default:
        return 'http://localhost:54321';
    }
  }
}
```

---

## 📚 **RECURSOS ADICIONALES**

### **Documentación Oficial**
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Supabase Cloud](https://supabase.com/docs/guides/getting-started)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [Docker](https://docs.docker.com/)

### **Guías de Configuración**
- [Configuración SSL con Let's Encrypt](https://letsencrypt.org/getting-started/)
- [Configuración de Nginx como Reverse Proxy](https://nginx.org/en/docs/)
- [Backup y Restore de PostgreSQL](https://www.postgresql.org/docs/current/backup.html)

### **Herramientas de Monitoreo**
- [Prometheus](https://prometheus.io/) - Monitoreo de métricas
- [Grafana](https://grafana.com/) - Visualización de datos
- [Logrotate](https://linux.die.net/man/8/logrotate) - Rotación de logs

---

**Fecha de actualización**: 17 de agosto de 2024  
**Versión**: 1.0.0  
**Responsable**: Equipo Backend  
**Estado**: ✅ Completado
