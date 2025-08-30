# 🚀 DOCUMENTACIÓN DE DESPLIEGUE - TFG

## 📋 **RESUMEN EJECUTIVO**

Esta sección contiene toda la documentación relacionada con el **despliegue del backend** del sistema TFG, incluyendo las diferentes opciones disponibles y configuraciones específicas.

---

## 📚 **DOCUMENTACIÓN DISPONIBLE**

### **📖 Guías Principales**

#### **🚀 [Opciones de Despliegue](opciones_backend.md)**
Guía completa que describe las **tres opciones principales** para desplegar el backend:

1. **Supabase Local** - Para desarrollo y testing
2. **Supabase Cloud** - Alternativa a Firebase para producción
3. **Servidor Independiente** - Para control total y producción interna

**Incluye:**
- ✅ Comparación detallada de opciones
- ✅ Configuración paso a paso
- ✅ Migración entre entornos
- ✅ Recomendaciones por caso de uso
- ✅ Configuración del frontend

#### **🏠 [Configuración Servidor Doméstico](configuracion_servidor_domestico.md)**
Guía específica para configurar el backend en tu **servidor de red doméstica**, aprovechando que ya tienes el backend listo.

**Incluye:**
- ✅ Configuración paso a paso
- ✅ Acceso desde Internet (port forwarding, VPN, Cloudflare Tunnel)
- ✅ Configuración de dominio y SSL
- ✅ Backups automáticos
- ✅ Monitoreo del servidor
- ✅ Mantenimiento rutinario
- ✅ Solución de problemas

---

## 🎯 **RECOMENDACIONES POR CASO DE USO**

### **🛠️ Desarrollo y Testing**
- **Recomendado**: Supabase Local
- **Documentación**: [Opciones de Despliegue](opciones_backend.md#opción-1-supabase-local)
- **Tiempo de configuración**: 30 minutos

### **🏠 Producción en Red Doméstica**
- **Recomendado**: Servidor Independiente
- **Documentación**: [Configuración Servidor Doméstico](configuracion_servidor_domestico.md)
- **Tiempo de configuración**: 2-4 horas

### **☁️ Producción Pública/Startup**
- **Recomendado**: Supabase Cloud
- **Documentación**: [Opciones de Despliegue](opciones_backend.md#opción-2-supabase-cloud)
- **Tiempo de configuración**: 30 minutos

### **🏢 Aplicaciones Enterprise**
- **Recomendado**: Servidor Independiente + Backup Cloud
- **Documentación**: [Opciones de Despliegue](opciones_backend.md#opción-3-servidor-independiente)
- **Tiempo de configuración**: 4-8 horas

---

## 📊 **COMPARACIÓN RÁPIDA**

| Aspecto | Local | Cloud | Servidor Independiente |
|---------|-------|-------|----------------------|
| **Costo** | Gratis | $0-$25+/mes | $5-$50/mes (VPS) |
| **Configuración** | Media | Fácil | Compleja |
| **Mantenimiento** | Manual | Automático | Manual |
| **Control** | Total | Limitado | Total |
| **Privacidad** | Máxima | Media | Máxima |

---

## 🔄 **FLUJO DE MIGRACIÓN RECOMENDADO**

1. **Desarrollo**: Comenzar con Supabase Local
2. **Testing**: Usar Supabase Local o Cloud (gratuito)
3. **MVP**: Migrar a Supabase Cloud
4. **Producción**: Evaluar entre Cloud y Servidor Independiente

**Ver comandos de migración en**: [Opciones de Despliegue](opciones_backend.md#migración-entre-opciones)

---

## 🛠️ **CONFIGURACIÓN DEL FRONTEND**

### **Variables de Entorno por Opción**

#### **Supabase Local**
```dart
static const String url = 'http://localhost:54321';
```

#### **Supabase Cloud**
```dart
static const String url = 'https://your-project.supabase.co';
```

#### **Servidor Independiente**
```dart
static const String url = 'https://your-server.com:54321';
```

**Ver configuración completa en**: [Opciones de Despliegue](opciones_backend.md#configuración-del-frontend)

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problemas Comunes**

#### **No se puede acceder desde Internet**
- **Solución**: Verificar port forwarding y firewall
- **Documentación**: [Configuración Servidor Doméstico](configuracion_servidor_domestico.md#problema-no-se-puede-acceder-desde-internet)

#### **Certificado SSL expirado**
- **Solución**: Renovar certificado con Let's Encrypt
- **Documentación**: [Configuración Servidor Doméstico](configuracion_servidor_domestico.md#problema-certificado-ssl-expirado)

#### **Base de datos no responde**
- **Solución**: Verificar estado de PostgreSQL
- **Documentación**: [Configuración Servidor Doméstico](configuracion_servidor_domestico.md#problema-base-de-datos-no-responde)

---

## 📚 **RECURSOS ADICIONALES**

### **Documentación Oficial**
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Supabase Cloud](https://supabase.com/docs/guides/getting-started)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [Docker](https://docs.docker.com/)

### **Herramientas Útiles**
- [Let's Encrypt](https://letsencrypt.org/docs/) - Certificados SSL gratuitos
- [Nginx](https://nginx.org/en/docs/) - Servidor web y reverse proxy
- [rclone](https://rclone.org/) - Sincronización con la nube
- [htop](https://htop.dev/) - Monitor de procesos

---

## 📞 **SOPORTE**

### **Para Problemas Técnicos**
1. Revisar la documentación específica de cada opción
2. Consultar la sección de solución de problemas
3. Verificar logs del sistema
4. Revisar documentación oficial de las herramientas

### **Para Consultas Específicas**
- **Supabase Local**: [Opciones de Despliegue](opciones_backend.md#opción-1-supabase-local)
- **Supabase Cloud**: [Opciones de Despliegue](opciones_backend.md#opción-2-supabase-cloud)
- **Servidor Doméstico**: [Configuración Servidor Doméstico](configuracion_servidor_domestico.md)

---

**Fecha de actualización**: 17 de agosto de 2024  
**Versión**: 1.0.0  
**Responsable**: Equipo Backend  
**Estado**: ✅ Completado
