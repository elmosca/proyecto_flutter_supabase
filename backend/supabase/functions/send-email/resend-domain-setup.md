# 🌐 CONFIGURACIÓN DE DOMINIO EN RESEND

## 🚨 **PROBLEMA ACTUAL**

Resend está en modo de prueba y solo permite enviar emails a `jualas@gmail.com`. Para enviar emails a otros destinatarios, necesitas verificar un dominio.

## 🔧 **SOLUCIÓN: VERIFICAR DOMINIO EN RESEND**

### **Paso 1: Acceder a Resend**
1. Ve a [resend.com/domains](https://resend.com/domains)
2. Inicia sesión con tu cuenta de Resend
3. Haz clic en **"Add Domain"**

### **Paso 2: Agregar Dominio**
1. **Dominio sugerido**: `jualas.es`
2. **Subdominio alternativo**: `mail.jualas.es` o `noreply.jualas.es`
3. Haz clic en **"Add Domain"**

### **Paso 3: Configurar DNS**
Resend te proporcionará registros DNS que debes agregar a tu proveedor de dominio:

#### **Registros DNS Necesarios:**
```
Tipo: TXT
Nombre: @
Valor: [valor proporcionado por Resend]

Tipo: CNAME
Nombre: resend._domainkey
Valor: [valor proporcionado por Resend]
```

### **Paso 4: Verificar Dominio**
1. Agrega los registros DNS en tu proveedor de dominio
2. Espera 24-48 horas para la propagación
3. Haz clic en **"Verify Domain"** en Resend

### **Paso 5: Actualizar Edge Function**
Una vez verificado el dominio, actualiza la Edge Function:

```typescript
// Cambiar de:
from: 'Sistema TFG <onboarding@resend.dev>'

// A:
from: 'Sistema TFG <noreply@jualas.es>'
```

## 🧪 **MODO DE PRUEBA ACTUAL**

### **Configuración Temporal:**
- ✅ **Todos los emails** se envían a `jualas@gmail.com`
- ✅ **Asunto modificado** para mostrar destinatario original
- ✅ **Contenido modificado** para mostrar información de prueba
- ✅ **Sistema funcional** para testing

### **Ejemplo de Email de Prueba:**
```
Asunto: [TEST - Para: 3850437@alu.murciaeduca.es] 📝 Nuevo comentario en "Mi Anteproyecto"

Contenido:
🧪 EMAIL DE PRUEBA
Destinatario original: 3850437@alu.murciaeduca.es
Enviado a: jualas@gmail.com (modo de prueba)

[Resto del contenido del email...]
```

## 📋 **CHECKLIST DE CONFIGURACIÓN**

### **Para Verificar Dominio:**
- [ ] Acceder a resend.com/domains
- [ ] Agregar dominio `jualas.es`
- [ ] Configurar registros DNS
- [ ] Esperar verificación (24-48h)
- [ ] Actualizar Edge Function
- [ ] Probar envío a todos los destinatarios

### **Para Modo de Prueba:**
- [x] Configurar envío a `jualas@gmail.com`
- [x] Modificar asunto para mostrar destinatario
- [x] Modificar contenido para mostrar información de prueba
- [x] Probar sistema completo

## 🚀 **PRÓXIMOS PASOS**

1. **Inmediato**: El sistema funciona en modo de prueba
2. **Corto plazo**: Verificar dominio en Resend
3. **Mediano plazo**: Actualizar Edge Function con dominio verificado
4. **Largo plazo**: Configurar dominio personalizado para producción

## 💡 **ALTERNATIVAS**

### **Si no puedes verificar dominio:**
1. **Usar subdominio**: `mail.jualas.es`
2. **Usar servicio alternativo**: SendGrid, Mailgun
3. **Mantener modo de prueba**: Para desarrollo/testing

### **Para Producción:**
- Configurar dominio profesional
- Implementar tracking de emails
- Configurar templates personalizados
- Implementar gestión de bounces
