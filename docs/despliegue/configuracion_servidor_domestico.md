# 🏠 CONFIGURACIÓN BACKEND EN SERVIDOR DOMÉSTICO - TFG

## 📋 **RESUMEN EJECUTIVO**

Esta guía te ayudará a configurar el backend del sistema TFG en tu **servidor de red doméstica**, aprovechando que ya tienes el backend listo en un servidor de tu red.

---

## 🎯 **SITUACIÓN ACTUAL**

### **Lo que ya tienes:**
- ✅ Backend Supabase funcionando en servidor de red doméstica
- ✅ Base de datos PostgreSQL configurada
- ✅ APIs REST funcionales
- ✅ Sistema de autenticación operativo

### **Lo que necesitas configurar:**
- 🔧 Acceso desde Internet (opcional)
- 🔧 Configuración de dominio personalizado
- 🔧 Certificados SSL/HTTPS
- 🔧 Backups automáticos
- 🔧 Monitoreo del servidor

---

## 🛠️ **CONFIGURACIÓN PASO A PASO**

### **Paso 1: Verificar Configuración Actual**

#### **Verificar que el backend funciona**
```bash
# Conectar al servidor
ssh usuario@tu-servidor-domestico

# Verificar que Supabase está ejecutándose
cd /ruta/a/tu/proyecto/backend/supabase
supabase status

# Verificar puertos abiertos
sudo netstat -tlnp | grep :54321
```

#### **Verificar conectividad desde la red local**
```bash
# Desde cualquier dispositivo en tu red local
curl -X GET 'http://IP-DEL-SERVIDOR:54321/rest/v1/anteprojects' \
  -H "apikey: TU_ANON_KEY"

# Deberías recibir una respuesta JSON con los anteproyectos
```

### **Paso 2: Configurar Acceso desde Internet (Opcional)**

#### **Opción A: Port Forwarding (Recomendado para pruebas)**
```bash
# En tu router, configurar port forwarding:
# Puerto externo: 54321 → Puerto interno: 54321
# IP destino: IP-DE-TU-SERVIDOR

# Verificar que funciona desde Internet
curl -X GET 'http://TU-IP-PUBLICA:54321/rest/v1/anteprojects' \
  -H "apikey: TU_ANON_KEY"
```

#### **Opción B: VPN (Recomendado para producción)**
```bash
# Configurar OpenVPN o WireGuard en tu servidor
# Esto permite acceso seguro sin exponer puertos

# Instalar OpenVPN
sudo apt install openvpn

# Configurar certificados y configuración
# (Ver documentación oficial de OpenVPN)
```

#### **Opción C: Cloudflare Tunnel (Más seguro)**
```bash
# Instalar cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# Autenticarse con Cloudflare
cloudflared tunnel login

# Crear túnel
cloudflared tunnel create tfg-backend

# Configurar túnel
nano ~/.cloudflared/config.yml
```

```yaml
# ~/.cloudflared/config.yml
tunnel: TU_TUNNEL_ID
credentials-file: /home/usuario/.cloudflared/TU_TUNNEL_ID.json

ingress:
  - hostname: tfg-backend.tu-dominio.com
    service: http://localhost:54321
  - service: http_status:404
```

```bash
# Ejecutar túnel
cloudflared tunnel run tfg-backend

# Configurar como servicio
sudo cloudflared service install
```

### **Paso 3: Configurar Dominio Personalizado**

#### **Comprar dominio (si no tienes uno)**
- Recomendado: Namecheap, GoDaddy, o Google Domains
- Costo: ~$10-15/año

#### **Configurar DNS**
```bash
# Si usas port forwarding:
# Añadir registro A en tu proveedor DNS:
# Nombre: tfg-backend
# Valor: TU-IP-PUBLICA

# Si usas Cloudflare Tunnel:
# Añadir registro CNAME:
# Nombre: tfg-backend
# Valor: TU_TUNNEL_ID.cfargotunnel.com
```

### **Paso 4: Configurar SSL/HTTPS**

#### **Con Let's Encrypt (Gratuito)**
```bash
# Instalar Certbot
sudo apt install certbot

# Obtener certificado
sudo certbot certonly --standalone -d tfg-backend.tu-dominio.com

# Configurar renovación automática
sudo crontab -e
# Añadir: 0 12 * * * /usr/bin/certbot renew --quiet
```

#### **Configurar Nginx como Reverse Proxy**
```bash
# Instalar Nginx
sudo apt install nginx

# Configurar sitio
sudo nano /etc/nginx/sites-available/tfg-backend
```

```nginx
# /etc/nginx/sites-available/tfg-backend
server {
    listen 80;
    server_name tfg-backend.tu-dominio.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name tfg-backend.tu-dominio.com;

    ssl_certificate /etc/letsencrypt/live/tfg-backend.tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tfg-backend.tu-dominio.com/privkey.pem;

    location / {
        proxy_pass http://localhost:54321;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/tfg-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### **Paso 5: Configurar Backups Automáticos**

#### **Script de Backup**
```bash
# Crear script de backup
sudo nano /opt/scripts/backup-tfg.sh
```

```bash
#!/bin/bash
# /opt/scripts/backup-tfg.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups/tfg"
DB_NAME="postgres"
DB_USER="postgres"
DB_HOST="localhost"

# Crear directorio de backups
mkdir -p $BACKUP_DIR

# Backup de base de datos
pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Backup de archivos de configuración
tar -czf $BACKUP_DIR/config_backup_$DATE.tar.gz \
  /ruta/a/tu/proyecto/backend/supabase/.env \
  /ruta/a/tu/proyecto/backend/supabase/migrations/ \
  /ruta/a/tu/proyecto/backend/supabase/functions/

# Comprimir backup de BD
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Eliminar backups antiguos (mantener últimos 7 días)
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "config_backup_*.tar.gz" -mtime +7 -delete

# Enviar notificación (opcional)
echo "Backup TFG completado: $DATE" | mail -s "Backup TFG" tu-email@dominio.com

echo "Backup completado: $DATE"
```

```bash
# Hacer ejecutable
sudo chmod +x /opt/scripts/backup-tfg.sh

# Configurar backup diario
sudo crontab -e
# Añadir: 0 2 * * * /opt/scripts/backup-tfg.sh >> /var/log/backup-tfg.log 2>&1
```

#### **Backup a la Nube (Opcional)**
```bash
# Instalar rclone para sincronización con la nube
curl https://rclone.org/install.sh | sudo bash

# Configurar Google Drive, Dropbox, etc.
rclone config

# Añadir al script de backup
rclone copy $BACKUP_DIR remote:backups/tfg/
```

### **Paso 6: Configurar Monitoreo**

#### **Monitoreo Básico del Sistema**
```bash
# Instalar herramientas de monitoreo
sudo apt install htop iotop nethogs

# Configurar alertas de espacio en disco
sudo nano /opt/scripts/disk-alert.sh
```

```bash
#!/bin/bash
# /opt/scripts/disk-alert.sh

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $DISK_USAGE -gt 80 ]; then
    echo "ALERTA: Espacio en disco al $DISK_USAGE%" | \
    mail -s "Alerta Disco - Servidor TFG" tu-email@dominio.com
fi
```

```bash
# Configurar verificación cada hora
sudo crontab -e
# Añadir: 0 * * * * /opt/scripts/disk-alert.sh
```

#### **Monitoreo de Servicios**
```bash
# Crear script de verificación de servicios
sudo nano /opt/scripts/check-services.sh
```

```bash
#!/bin/bash
# /opt/scripts/check-services.sh

# Verificar Supabase
if ! curl -s http://localhost:54321/health > /dev/null; then
    echo "ERROR: Supabase no responde" | \
    mail -s "Error Servicio - TFG Backend" tu-email@dominio.com
fi

# Verificar PostgreSQL
if ! pg_isready -h localhost > /dev/null; then
    echo "ERROR: PostgreSQL no responde" | \
    mail -s "Error Servicio - TFG Database" tu-email@dominio.com
fi

# Verificar Nginx
if ! systemctl is-active --quiet nginx; then
    echo "ERROR: Nginx no está ejecutándose" | \
    mail -s "Error Servicio - TFG Nginx" tu-email@dominio.com
fi
```

```bash
# Configurar verificación cada 5 minutos
sudo crontab -e
# Añadir: */5 * * * * /opt/scripts/check-services.sh
```

### **Paso 7: Configurar Firewall**

#### **Configuración de UFW**
```bash
# Habilitar firewall
sudo ufw enable

# Permitir SSH
sudo ufw allow ssh

# Permitir HTTP y HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Permitir puerto de Supabase (solo si usas port forwarding)
sudo ufw allow 54321

# Verificar estado
sudo ufw status
```

### **Paso 8: Configurar el Frontend**

#### **Actualizar Variables de Entorno**
```dart
// En tu proyecto Flutter, actualizar lib/config/supabase_config.dart
class SupabaseConfig {
  // Para acceso local en la red
  static const String url = 'http://IP-DEL-SERVIDOR:54321';
  
  // Para acceso desde Internet
  // static const String url = 'https://tfg-backend.tu-dominio.com';
  
  static const String anonKey = 'TU_ANON_KEY';
}
```

#### **Configuración Condicional por Entorno**
```dart
// lib/config/environment.dart
enum Environment { local, domestic, production }

class EnvironmentConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');
    switch (env) {
      case 'domestic':
        return Environment.domestic;
      case 'production':
        return Environment.production;
      default:
        return Environment.local;
    }
  }

  static String get supabaseUrl {
    switch (environment) {
      case Environment.domestic:
        return 'http://IP-DEL-SERVIDOR:54321';
      case Environment.production:
        return 'https://tfg-backend.tu-dominio.com';
      default:
        return 'http://localhost:54321';
    }
  }
}
```

---

## 🔧 **MANTENIMIENTO RUTINARIO**

### **Tareas Diarias**
```bash
# Verificar logs de servicios
sudo journalctl -u supabase -f
sudo journalctl -u nginx -f
sudo journalctl -u postgresql -f

# Verificar espacio en disco
df -h

# Verificar uso de memoria
free -h
```

### **Tareas Semanales**
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade

# Verificar backups
ls -la /opt/backups/tfg/

# Verificar certificados SSL
sudo certbot certificates
```

### **Tareas Mensuales**
```bash
# Revisar logs antiguos
sudo journalctl --vacuum-time=30d

# Verificar rendimiento
sudo htop

# Revisar configuración de seguridad
sudo ufw status
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problema: No se puede acceder desde Internet**
```bash
# Verificar port forwarding en router
# Verificar firewall del servidor
sudo ufw status

# Verificar que el servicio está ejecutándose
sudo systemctl status supabase
```

### **Problema: Certificado SSL expirado**
```bash
# Renovar certificado manualmente
sudo certbot renew

# Verificar renovación automática
sudo crontab -l | grep certbot
```

### **Problema: Base de datos no responde**
```bash
# Verificar estado de PostgreSQL
sudo systemctl status postgresql

# Verificar logs
sudo journalctl -u postgresql -f

# Reiniciar servicio
sudo systemctl restart postgresql
```

### **Problema: Backup falla**
```bash
# Verificar espacio en disco
df -h

# Verificar permisos
ls -la /opt/backups/

# Ejecutar backup manualmente
sudo /opt/scripts/backup-tfg.sh
```

---

## 📊 **MÉTRICAS DE RENDIMIENTO**

### **Monitoreo de Recursos**
```bash
# CPU y memoria
htop

# Disco
iotop

# Red
nethogs

# Procesos específicos
ps aux | grep supabase
ps aux | grep postgres
```

### **Logs Importantes**
```bash
# Logs de Supabase
sudo journalctl -u supabase -f

# Logs de Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Logs de PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-*.log
```

---

## 🔒 **SEGURIDAD**

### **Recomendaciones de Seguridad**
1. **Cambiar contraseñas por defecto**
2. **Usar SSH con claves en lugar de contraseñas**
3. **Mantener el sistema actualizado**
4. **Configurar firewall correctamente**
5. **Usar HTTPS siempre que sea posible**
6. **Hacer backups regulares**
7. **Monitorear logs de seguridad**

### **Configuración SSH Segura**
```bash
# Editar configuración SSH
sudo nano /etc/ssh/sshd_config

# Deshabilitar login con contraseña
PasswordAuthentication no

# Cambiar puerto SSH (opcional)
Port 2222

# Reiniciar SSH
sudo systemctl restart ssh
```

---

## 📚 **RECURSOS ADICIONALES**

### **Documentación Oficial**
- [Supabase Self-Hosting](https://supabase.com/docs/guides/self-hosting)
- [PostgreSQL Administration](https://www.postgresql.org/docs/current/admin.html)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

### **Herramientas Útiles**
- [htop](https://htop.dev/) - Monitor de procesos
- [rclone](https://rclone.org/) - Sincronización con la nube
- [certbot](https://certbot.eff.org/) - Certificados SSL automáticos
- [fail2ban](https://www.fail2ban.org/) - Protección contra ataques

---

**Fecha de actualización**: 17 de agosto de 2024  
**Versión**: 1.0.0  
**Responsable**: Equipo Backend  
**Estado**: ✅ Completado
