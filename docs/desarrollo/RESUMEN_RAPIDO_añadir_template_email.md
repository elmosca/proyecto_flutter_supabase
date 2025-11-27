# ⚡ RESUMEN RÁPIDO: Añadir Template de Email

## 🎯 En 3 Pasos Simples

### ✅ Paso 1: Ir a la Edge Function

```
Supabase Dashboard 
  → Edge Functions 
    → send-email 
      → Pestaña "Code"
```

### ✅ Paso 2: Añadir 2 Códigos

#### Código 1: En el switch (busca `switch (type)` o `if (type === ...)`)

```typescript
case 'password_reset':
  return await sendPasswordResetEmail(data);
```

**Dónde**: Justo antes del `default:` en el switch

---

#### Código 2: La función completa (al final del archivo)

**Copia TODO desde aquí** ↓

```typescript
async function sendPasswordResetEmail(data: any) {
  const { studentEmail, studentName, newPassword, resetBy, resetByName } = data;
  const APP_URL = Deno.env.get('APP_URL') || 'https://tu-app.supabase.co';

  const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; background: #f4f4f4; margin: 0; }
    .email-container { max-width: 600px; margin: 0 auto; background: #fff; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 30px 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; }
    .content { padding: 30px 20px; }
    .password-container { background: #f8f9fa; border: 2px dashed #667eea; border-radius: 8px; padding: 20px; margin: 25px 0; text-align: center; }
    .password-value { font-size: 24px; font-weight: bold; color: #667eea; font-family: monospace; }
    .warning-box { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 25px 0; border-radius: 4px; }
    .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 14px 28px; text-decoration: none; border-radius: 6px; font-weight: 600; }
    .footer { background: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #999; }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header"><h1>🔒 Contraseña Restablecida</h1></div>
    <div class="content">
      <p>Hola <strong>${studentName}</strong>,</p>
      <p>Tu contraseña ha sido restablecida por <strong>${resetByName}</strong> (${resetBy === 'administrador' ? 'Administrador' : 'Tutor'}).</p>
      <div class="password-container">
        <div style="font-size: 14px; color: #666; margin-bottom: 10px;">TU NUEVA CONTRASEÑA</div>
        <div class="password-value">${newPassword}</div>
      </div>
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Guarda esta contraseña en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión</li>
          <li>Si no solicitaste este cambio, contacta a tu tutor o administrador</li>
        </ul>
      </div>
      <div style="text-align: center; margin: 30px 0;">
        <a href="${APP_URL}/login" class="button">Iniciar Sesión</a>
      </div>
    </div>
    <div class="footer">
      <p><strong>Sistema de Gestión de Proyectos TFG</strong></p>
      <p>CIFP Carlos III</p>
      <p>Este es un email automático, por favor no respondas.</p>
    </div>
  </div>
</body>
</html>
  `;

  const text = `🔒 CONTRASEÑA RESTABLECIDA\n\nHola ${studentName},\n\nTu contraseña ha sido restablecida por ${resetByName} (${resetBy === 'administrador' ? 'Administrador' : 'Tutor'}).\n\nTU NUEVA CONTRASEÑA: ${newPassword}\n\n⚠️ IMPORTANTE:\n- Guarda esta contraseña en un lugar seguro\n- Puedes cambiarla después de iniciar sesión\n- Si no solicitaste este cambio, contacta a tu tutor o administrador\n\nInicia sesión en: ${APP_URL}/login\n\n---\nSistema de Gestión de Proyectos TFG - CIFP Carlos III`;

  const resendApiKey = Deno.env.get('RESEND_API_KEY');
  if (!resendApiKey) {
    throw new Error('RESEND_API_KEY no está configurada');
  }

  // Usar fetch directamente a la API de Resend (compatible con Edge Functions)
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${resendApiKey}`,
    },
    body: JSON.stringify({
      from: 'Sistema TFG <noreply@cifpcarlos3.es>',
      to: studentEmail,
      subject: '🔒 Tu contraseña ha sido restablecida - Sistema TFG',
      html: html,
      text: text,
    }),
  });

  // Leer el texto de la respuesta primero para manejar respuestas vacías o no-JSON
  const responseText = await response.text();
  
  // Verificar si la respuesta está vacía
  if (!responseText || responseText.trim().length === 0) {
    throw new Error(`Error enviando email: Respuesta vacía de Resend API (Status: ${response.status})`);
  }

  // Intentar parsear JSON
  let result;
  try {
    result = JSON.parse(responseText);
  } catch (parseError) {
    throw new Error(`Error parseando respuesta de Resend: ${parseError.message}. Respuesta recibida: ${responseText.substring(0, 200)}`);
  }

  // Verificar si hay errores en la respuesta
  if (!response.ok) {
    const errorMessage = result?.error?.message || result?.message || result?.error || `Error HTTP ${response.status}`;
    throw new Error(`Error enviando email: ${errorMessage}`);
  }

  if (result.error) {
    throw new Error(`Error enviando email: ${result.error.message || result.error || 'Error desconocido'}`);
  }

  return { success: true, messageId: result.id || 'unknown' };
}
```

**Hasta aquí** ↑

**Dónde**: Al final del archivo, después de todas las otras funciones

---

### ✅ Paso 3: Guardar

1. **Revisa** que no haya errores (el editor los marca en rojo)
2. **Haz clic** en **"Save"** o **"Deploy"**
3. **Espera** el mensaje de éxito

---

## ⚠️ IMPORTANTE: No se requiere importar Resend

Este código usa `fetch` directamente a la API de Resend, por lo que **NO necesitas importar el SDK de Resend**. Es compatible con Edge Functions de Supabase sin dependencias adicionales.

---

## 🎯 Ubicación Visual en el Código

```
Edge Function send-email
│
├─ Imports (al inicio)
│  └─ import { Resend } from '...';  ← Verificar que existe
│
├─ Función principal serve()
│  └─ switch (type) {
│      case 'comment_notification': ...
│      case 'status_change': ...
│      case 'password_reset': ...     ← AÑADIR AQUÍ (Paso 2 - Código 1)
│      default: ...
│    }
│
└─ Funciones auxiliares (al final)
   ├─ async function sendCommentNotification() { ... }
   ├─ async function sendStatusChangeNotification() { ... }
   └─ async function sendPasswordResetEmail() { ... }  ← AÑADIR AQUÍ (Paso 2 - Código 2)
```

---

## ✅ Checklist Rápido

- [ ] Fui a Edge Functions → send-email → Code
- [ ] Añadí `case 'password_reset':` en el switch
- [ ] Añadí la función `sendPasswordResetEmail` al final
- [ ] Verifiqué que Resend está importado
- [ ] Guardé los cambios
- [ ] Probé resetear una contraseña

---

## 🆘 Si Algo Sale Mal

1. **Revisa los logs**: Edge Functions → send-email → Logs
2. **Verifica la sintaxis**: El editor marca errores en rojo
3. **Comprueba Resend**: Settings → Edge Functions → Secrets → RESEND_API_KEY

---

## 📚 Guía Completa

Para más detalles, ver: `docs/desarrollo/guia_paso_a_paso_añadir_template_email_supabase.md`

