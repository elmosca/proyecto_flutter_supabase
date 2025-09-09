# 🛠️ GUÍAS TÉCNICAS
# Sistema de Seguimiento de Proyectos TFG - Ciclo DAM

> **HERRAMIENTAS Y GUÍAS TÉCNICAS** - Documentación técnica y herramientas de desarrollo.

---

## 📋 **DOCUMENTOS DISPONIBLES**

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| **MCP Server** | Servidor MCP para integración con Supabase | ✅ Activo |

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

### **Para Desarrollo Local:**
1. Usar el servidor Supabase local en `http://192.168.1.9:54321`
2. Configurar el frontend para entorno `network`
3. Usar las credenciales de prueba configuradas

### **Para Testing:**
1. Usar usuarios de prueba predefinidos
2. Probar funcionalidades desde la aplicación
3. Usar el servidor MCP para diagnóstico

---

## 📚 **CONTENIDO DETALLADO**

### **🔧 MCP Server**
- **Integración con Supabase** para diagnóstico directo
- **Herramientas de debugging** integradas en Cursor
- **Consultas directas** a la base de datos
- **Gestión de usuarios** y autenticación
- **Monitoreo en tiempo real** del sistema

---

## 🔧 **HERRAMIENTAS CUBIERTAS**

### **MCP (Model Context Protocol)**
- **Servidor personalizado** para integración con Supabase
- **Herramientas de diagnóstico** integradas
- **Consultas SQL directas** a la base de datos
- **Gestión de autenticación** y usuarios
- **Monitoreo del sistema** en tiempo real

### **Configuración de Entornos**
- **Desarrollo local** (localhost)
- **Desarrollo en red** (192.168.1.9)
- **Configuración automática** por entorno
- **Credenciales de prueba** predefinidas

---

## 🎯 **CASOS DE USO**

### **Desarrollo Local**
- Desarrollo con servidor Supabase local
- Testing con usuarios de prueba
- Debugging con herramientas MCP
- Desarrollo colaborativo en red local

### **Testing y QA**
- Testing con usuarios predefinidos
- Verificación de funcionalidades
- Testing de autenticación
- Testing de navegación

### **Diagnóstico**
- Consultas directas a la base de datos
- Verificación de usuarios y roles
- Monitoreo de autenticación
- Debugging de problemas

---

## 📱 **CONFIGURACIÓN ACTUAL**

### **URLs de Acceso:**
- **Backend Supabase**: `http://192.168.1.9:54321`
- **Supabase Studio**: `http://192.168.1.9:54323`
- **Inbucket (Email)**: `http://192.168.1.9:54324`

### **Credenciales de Prueba:**
```json
{
  "student": "student.test@alumno.cifpcarlos3.es",
  "tutor": "tutor.test@cifpcarlos3.es", 
  "admin": "admin.test@cifpcarlos3.es",
  "passwords": {
    "student": "student123",
    "tutor": "tutor123", 
    "admin": "admin123"
  }
}
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS**

### **Problemas Comunes:**
- **"No GoRouter found"** - Verificar configuración de MaterialApp.router
- **"Connection refused"** - Verificar que Supabase esté corriendo
- **"Auth error"** - Usar credenciales de prueba correctas
- **"Navigation error"** - Verificar configuración del router

### **Debugging:**
- **MCP Server** para consultas directas
- **Logs de Supabase** para errores del backend
- **Logs de Flutter** para errores del frontend
- **Verificación de conectividad** con ping

---

## 🎯 **PRÓXIMOS PASOS**

1. **Usar usuarios de prueba** para testing
2. **Probar funcionalidades** de la aplicación
3. **Usar MCP Server** para diagnóstico
4. **Desarrollar nuevas funcionalidades**
5. **Mantener documentación** actualizada

---

**Fecha de actualización**: 9 de enero de 2025  
**Estado**: ✅ **ACTIVO** - Sistema funcionando con herramientas modernas
