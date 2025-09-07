# 🛠️ GUÍAS TÉCNICAS
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **HERRAMIENTAS Y GUÍAS TÉCNICAS** - Documentación técnica y herramientas de desarrollo.

---

## 📋 **DOCUMENTOS DISPONIBLES**

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| **[guia_ngrok_backend_local.md](./guia_ngrok_backend_local.md)** | Guía completa para acceso externo al backend con Ngrok | ✅ Completa |
| **[configuracion_ngrok_ejemplo.md](./configuracion_ngrok_ejemplo.md)** | Configuración de ejemplo para Ngrok | ✅ Completa |

---

## 🎯 **OBJETIVO**

Este directorio contiene guías técnicas para:
- **Herramientas de desarrollo**
- **Configuraciones técnicas**
- **Guías de uso de herramientas**
- **Ejemplos prácticos**
- **Soluciones técnicas**

---

## 🚀 **INICIO RÁPIDO**

### **Para Acceso Externo al Backend:**
1. Leer **[guia_ngrok_backend_local.md](./guia_ngrok_backend_local.md)** - Guía completa
2. Seguir **[configuracion_ngrok_ejemplo.md](./configuracion_ngrok_ejemplo.md)** - Configuración paso a paso

### **Para Testing en Dispositivos Móviles:**
1. Configurar Ngrok siguiendo las guías
2. Usar URLs públicas para testing
3. Probar desde cualquier dispositivo

---

## 📚 **CONTENIDO DETALLADO**

### **🌐 guia_ngrok_backend_local.md**
- **Instalación y configuración** de Ngrok
- **Configuración para Supabase** local
- **Configuración del frontend** para múltiples entornos
- **Scripts de automatización** para Windows y Linux/macOS
- **Configuración de seguridad** y mejores prácticas
- **Monitoreo y debugging**
- **Solución de problemas** comunes
- **Testing en dispositivos** móviles

### **⚙️ configuracion_ngrok_ejemplo.md**
- **Configuración de ejemplo** personalizable
- **Pasos específicos** para tu proyecto
- **Checklist de configuración**
- **Comandos de ejecución**
- **Testing y verificación**
- **Configuración avanzada**
- **Solución de problemas**

---

## 🔧 **HERRAMIENTAS CUBIERTAS**

### **Ngrok**
- **Túnel seguro** desde servidor local a internet
- **HTTPS automático** incluido
- **URLs públicas** accesibles desde cualquier dispositivo
- **Dashboard de monitoreo** en tiempo real
- **Configuración de seguridad** avanzada

### **Configuración de Entornos**
- **Desarrollo local** (localhost)
- **Desarrollo remoto** (ngrok)
- **Producción** (servidor propio)
- **Configuración automática** por entorno

---

## 🎯 **CASOS DE USO**

### **Desarrollo Remoto**
- Acceso al backend desde cualquier lugar
- Testing en dispositivos móviles reales
- Demostraciones a clientes/usuarios
- Desarrollo colaborativo

### **Testing y QA**
- Testing en múltiples dispositivos
- Testing de conectividad
- Testing de rendimiento
- Testing de funcionalidades completas

### **Demostraciones**
- Presentaciones a clientes
- Demostraciones en vivo
- Acceso temporal para usuarios
- Prototipado rápido

---

## 📱 **TESTING EN DISPOSITIVOS**

### **URLs de Acceso:**
- **Backend**: `https://tu-proyecto-tfg.ngrok.io`
- **Aplicación Web**: `https://tu-proyecto-tfg-web.ngrok.io`
- **Dashboard Ngrok**: `http://127.0.0.1:4040`

### **Credenciales de Prueba:**
```json
{
  "email": "carlos.lopez@alumno.cifpcarlos3.es",
  "password": "password123",
  "role": "student"
}
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problemas Comunes:**
- **"subdomain already taken"** - Usar subdomain diferente
- **"tunnel not found"** - Verificar que Supabase esté corriendo
- **"connection refused"** - Verificar puerto y firewall
- **"SSL certificate error"** - Asegurar uso de https://

### **Debugging:**
- **Dashboard Ngrok** para ver tráfico
- **Logs de Supabase** para errores del backend
- **Logs del servidor web** para errores de la aplicación
- **Verificación de conectividad** con curl

---

## 🎯 **PRÓXIMOS PASOS**

1. **Configurar Ngrok** siguiendo las guías
2. **Probar acceso** desde dispositivos móviles
3. **Configurar monitoreo** y seguridad
4. **Documentar URLs** para el equipo
5. **Automatizar proceso** de inicio

---

**Fecha de actualización**: 7 de septiembre de 2025  
**Estado**: ✅ **COMPLETO** - Guías técnicas completas y probadas
