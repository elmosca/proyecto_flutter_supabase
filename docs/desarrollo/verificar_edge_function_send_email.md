# Verificar y Actualizar Edge Function send-email

## 🔍 Problema Detectado

Los logs muestran que la Edge Function `send-email` está devolviendo **error 500**. Esto significa que hay un problema en el código de la función.

## ✅ Pasos para Solucionar

### Paso 1: Verificar que la Edge Function está Actualizada

1. Ve a **Supabase Dashboard** → **Edge Functions** → **send-email**
2. **Haz clic** en la función `send-email`
3. **Revisa** el código actual

### Paso 2: Actualizar el Código Completo

1. **Abre** el archivo: `docs/desarrollo/codigo_completo_edge_function_send_email_actualizado.ts`
2. **Copia TODO el contenido** del archivo
3. En Supabase Dashboard, **reemplaza TODO el código** de la Edge Function `send-email`
4. **Guarda** y **despliega** la función

### Paso 3: Verificar Variables de Entorno

Asegúrate de que estas variables estén configuradas en **Secrets**:

- ✅ `RESEND_API_KEY` (ya debería estar configurada)
- ✅ `RESEND_FROM_EMAIL` (añádela si no está)

### Paso 4: Verificar los Logs

1. Después de actualizar, **crea un nuevo estudiante** desde la aplicación
2. Ve a **Edge Functions** → **send-email** → **Logs**
3. **Revisa** los logs para ver si hay errores específicos

## 🐛 Errores Comunes

### Error: "RESEND_API_KEY is required"
- **Solución**: Verifica que `RESEND_API_KEY` esté configurada en Secrets

### Error: "Failed to send email: You can only send testing emails..."
- **Solución**: Verifica un dominio en Resend y configura `RESEND_FROM_EMAIL` con una dirección de ese dominio

### Error: "SyntaxError" o errores de TypeScript
- **Solución**: Asegúrate de copiar TODO el código del archivo `.ts`, sin omitir ninguna línea

## 📋 Checklist

- [ ] Edge Function `send-email` actualizada con el código completo
- [ ] Variable `RESEND_API_KEY` configurada en Secrets
- [ ] Variable `RESEND_FROM_EMAIL` configurada en Secrets (o usando el valor por defecto)
- [ ] Código guardado y desplegado
- [ ] Logs revisados después de crear un estudiante

