# 📧 Guía Paso a Paso: Añadir Template de Email en Supabase

## 🎯 Objetivo

Añadir el template de email para reset de contraseña en la Edge Function `send-email` de Supabase.

---

## 📋 Paso 1: Acceder a la Edge Function

1. **Abre tu navegador** y ve a: https://supabase.com/dashboard
2. **Inicia sesión** con tu cuenta de Supabase
3. **Selecciona tu proyecto** (el que estás usando para la aplicación)
4. En el **menú lateral izquierdo**, busca y haz clic en **"Edge Functions"**
5. En la lista de Edge Functions, busca y haz clic en **"send-email"**

**Resultado esperado**: Deberías ver la página de detalles de la Edge Function `send-email`.

---

## 📋 Paso 2: Abrir el Editor de Código

1. En la página de `send-email`, verás varias **pestañas** en la parte superior:
   - Overview
   - Invocations
   - Logs
   - **Code** ← **Haz clic aquí**
   - Details

2. Haz clic en la pestaña **"Code"**

**Resultado esperado**: Deberías ver el código de la Edge Function en un editor.

---

## 📋 Paso 3: Localizar el Switch/Case Principal

En el código, busca una sección que se vea así:

```typescript
serve(async (req) => {
  try {
    const { type, data } = await req.json();

    switch (type) {
      case 'comment_notification':
        return await sendCommentNotification(data);
      
      case 'status_change':
        return await sendStatusChangeNotification(data);
      
      // ... más casos ...
      
      default:
        return new Response(
          JSON.stringify({ error: `Tipo de email desconocido: ${type}` }),
          { status: 400, headers: { 'Content-Type': 'application/json' } }
        );
    }
  } catch (error) {
    // ...
  }
});
```

**Ubicación**: Generalmente está al inicio o en la mitad del archivo.

---

## 📋 Paso 4: Añadir el Caso `password_reset`

1. **Localiza** el `switch (type)` o `if (type === ...)`
2. **Busca** el último `case` antes del `default:`
3. **Añade** este código justo antes del `default:`:

```typescript
case 'password_reset':
  return await sendPasswordResetEmail(data);
```

**Ejemplo de cómo debería verse**:

```typescript
switch (type) {
  case 'comment_notification':
    return await sendCommentNotification(data);
  
  case 'status_change':
    return await sendStatusChangeNotification(data);
  
  case 'welcome':
    return await sendWelcomeEmail(data);
  
  case 'password_reset':  // ← AÑADE ESTA LÍNEA
    return await sendPasswordResetEmail(data);  // ← AÑADE ESTA LÍNEA
  
  default:  // ← Esto ya existe
    return new Response(
      JSON.stringify({ error: `Tipo de email desconocido: ${type}` }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
}
```

---

## 📋 Paso 5: Añadir la Función `sendPasswordResetEmail`

1. **Desplázate** hacia el final del archivo
2. **Busca** donde terminan las otras funciones (como `sendCommentNotification`, `sendWelcomeEmail`, etc.)
3. **Añade** la función completa al final, justo antes del cierre del archivo

**Código completo a añadir**:

```typescript
/**
 * Envía email de notificación cuando se resetea una contraseña de estudiante
 */
async function sendPasswordResetEmail(data: any) {
  const { studentEmail, studentName, newPassword, resetBy, resetByName } = data;

  // Obtener la URL de la aplicación desde variables de entorno o usar un valor por defecto
  const APP_URL = Deno.env.get('APP_URL') || 'https://tu-app.supabase.co';

  // Template HTML del email
  const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contraseña Restablecida</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333333;
      background-color: #f4f4f4;
      margin: 0;
      padding: 0;
    }
    .email-container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
    }
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #ffffff;
      padding: 30px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
      font-weight: 600;
    }
    .content {
      padding: 30px 20px;
      background-color: #ffffff;
    }
    .greeting {
      font-size: 18px;
      margin-bottom: 20px;
      color: #333333;
    }
    .message {
      font-size: 16px;
      color: #666666;
      margin-bottom: 25px;
    }
    .password-container {
      background-color: #f8f9fa;
      border: 2px dashed #667eea;
      border-radius: 8px;
      padding: 20px;
      margin: 25px 0;
      text-align: center;
    }
    .password-label {
      font-size: 14px;
      color: #666666;
      margin-bottom: 10px;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    .password-value {
      font-size: 24px;
      font-weight: bold;
      color: #667eea;
      font-family: 'Courier New', monospace;
      letter-spacing: 2px;
      word-break: break-all;
    }
    .warning-box {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 25px 0;
      border-radius: 4px;
    }
    .warning-box strong {
      color: #856404;
      display: block;
      margin-bottom: 10px;
    }
    .warning-box ul {
      margin: 10px 0;
      padding-left: 20px;
      color: #856404;
    }
    .warning-box li {
      margin-bottom: 8px;
    }
    .button-container {
      text-align: center;
      margin: 30px 0;
    }
    .button {
      display: inline-block;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #ffffff;
      padding: 14px 28px;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      font-size: 16px;
      box-shadow: 0 4px 6px rgba(102, 126, 234, 0.3);
    }
    .footer {
      background-color: #f8f9fa;
      padding: 20px;
      text-align: center;
      font-size: 12px;
      color: #999999;
      border-top: 1px solid #e9ecef;
    }
    .footer p {
      margin: 5px 0;
    }
    .info-box {
      background-color: #e7f3ff;
      border-left: 4px solid #2196F3;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
      font-size: 14px;
      color: #0c5460;
    }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🔒 Contraseña Restablecida</h1>
    </div>
    
    <div class="content">
      <div class="greeting">
        Hola <strong>${studentName}</strong>,
      </div>
      
      <div class="message">
        Tu contraseña ha sido restablecida por <strong>${resetByName}</strong> (${resetBy === 'administrador' ? 'Administrador' : 'Tutor'}).
      </div>
      
      <div class="password-container">
        <div class="password-label">Tu Nueva Contraseña</div>
        <div class="password-value">${newPassword}</div>
      </div>
      
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Guarda esta contraseña en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión desde tu perfil</li>
          <li>Si no solicitaste este cambio, contacta inmediatamente a tu tutor o administrador</li>
          <li>Por seguridad, no compartas esta contraseña con nadie</li>
        </ul>
      </div>
      
      <div class="info-box">
        <strong>💡 Consejo:</strong> Después de iniciar sesión, te recomendamos cambiar esta contraseña por una que solo tú conozcas.
      </div>
      
      <div class="button-container">
        <a href="${APP_URL}/login" class="button">Iniciar Sesión</a>
      </div>
    </div>
    
    <div class="footer">
      <p><strong>Sistema de Gestión de Proyectos TFG</strong></p>
      <p>CIFP Carlos III</p>
      <p>Este es un email automático, por favor no respondas.</p>
      <p style="margin-top: 10px; font-size: 11px;">
        Si tienes problemas para acceder, contacta a tu tutor o administrador.
      </p>
    </div>
  </div>
</body>
</html>
  `;

  // Template de texto plano
  const text = `
🔒 CONTRASEÑA RESTABLECIDA

Hola ${studentName},

Tu contraseña ha sido restablecida por ${resetByName} (${resetBy === 'administrador' ? 'Administrador' : 'Tutor'}).

TU NUEVA CONTRASEÑA:
${newPassword}

⚠️ IMPORTANTE:
- Guarda esta contraseña en un lugar seguro
- Puedes cambiarla después de iniciar sesión desde tu perfil
- Si no solicitaste este cambio, contacta inmediatamente a tu tutor o administrador
- Por seguridad, no compartas esta contraseña con nadie

💡 CONSEJO:
Después de iniciar sesión, te recomendamos cambiar esta contraseña por una que solo tú conozcas.

Inicia sesión en: ${APP_URL}/login

---
Sistema de Gestión de Proyectos TFG
CIFP Carlos III

Este es un email automático, por favor no respondas.
Si tienes problemas para acceder, contacta a tu tutor o administrador.
  `;

  // Enviar el email usando Resend API
  const resendApiKey = Deno.env.get('RESEND_API_KEY');
  if (!resendApiKey) {
    throw new Error('RESEND_API_KEY no está configurada');
  }

  // Usar fetch directamente a la API de Resend (más compatible con Edge Functions)
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

  return {
    success: true,
    messageId: result.id || 'unknown',
  };
}
```

**⚠️ IMPORTANTE**: 
- Copia TODO el código desde `async function sendPasswordResetEmail` hasta el cierre `}`
- Asegúrate de que esté al mismo nivel de indentación que las otras funciones
- No olvides el punto y coma `;` al final si es necesario según el estilo del código

---

## 📋 Paso 6: Verificar que no se requiere importar Resend

**✅ IMPORTANTE**: Este código usa `fetch` directamente a la API de Resend, por lo que **NO necesitas importar el SDK de Resend**. 

El código es compatible con Edge Functions de Supabase sin dependencias adicionales. Solo necesitas tener configurada la variable de entorno `RESEND_API_KEY` en Supabase.

---

## 📋 Paso 7: Personalizar (Opcional pero Recomendado)

### Cambiar el Email del Remitente

1. **Busca** esta línea en la función que acabas de añadir:
   ```typescript
   from: 'Sistema TFG <noreply@cifpcarlos3.es>',
   ```

2. **Cámbiala** por tu dominio verificado en Resend:
   ```typescript
   from: 'Sistema TFG <noreply@tu-dominio.com>',
   ```

   **⚠️ IMPORTANTE**: El dominio debe estar verificado en Resend. Si no lo está, los emails no se enviarán.

### Cambiar la URL de la Aplicación

1. **Opción A**: Cambiar el valor por defecto en el código:
   ```typescript
   const APP_URL = Deno.env.get('APP_URL') || 'https://tu-dominio-real.com';
   ```

2. **Opción B**: Configurar variable de entorno en Supabase:
   - Ve a **Settings** → **Edge Functions** → **Secrets**
   - Haz clic en **"Add new secret"**
   - **Nombre**: `APP_URL`
   - **Valor**: `https://tu-dominio-real.com`
   - Haz clic en **"Add secret"**

---

## 📋 Paso 8: Guardar los Cambios

1. **Revisa** que no haya errores de sintaxis (el editor debería mostrarlos en rojo)
2. **Haz clic** en el botón **"Save"** o **"Deploy"** (generalmente está en la parte superior derecha)
3. **Espera** a que se despliegue (verás un mensaje de éxito)

**Resultado esperado**: Deberías ver un mensaje como "Function deployed successfully" o "Changes saved".

---

## 📋 Paso 9: Verificar que Funciona

### Opción A: Probar desde la Aplicación

1. **Abre** tu aplicación Flutter
2. **Inicia sesión** como tutor o administrador
3. **Ve** a la lista de estudiantes
4. **Resetea** la contraseña de un estudiante
5. **Verifica** que el estudiante recibe el email

### Opción B: Verificar en los Logs

1. En Supabase Dashboard, ve a **Edge Functions** → **send-email** → **Logs**
2. **Intenta** resetear una contraseña desde la aplicación
3. **Revisa** los logs para ver si hay errores

---

## ❌ Solución de Problemas

### Error: "Resend is not defined"

**Causa**: Este error no debería aparecer porque el código usa `fetch` directamente, no el SDK de Resend.

**Solución**: Si ves este error, verifica que copiaste el código correcto. El código corregido usa `fetch` en lugar de `new Resend()`.

### Error: "RESEND_API_KEY no está configurada"

**Causa**: Falta configurar la API key de Resend

**Solución**:
1. Ve a **Settings** → **Edge Functions** → **Secrets**
2. Verifica que existe `RESEND_API_KEY`
3. Si no existe, añádela con tu API key de Resend

### Error: "Domain not verified"

**Causa**: El dominio del remitente no está verificado en Resend

**Solución**:
1. Ve a https://resend.com/domains
2. Verifica tu dominio
3. O cambia el email del remitente a un dominio verificado

### El email no llega

**Verificaciones**:
1. Revisa los logs de la Edge Function
2. Verifica que `RESEND_API_KEY` está correcta
3. Verifica que el dominio del remitente está verificado
4. Revisa la carpeta de spam del destinatario

---

## 📝 Checklist Final

Antes de considerar que está completo, verifica:

- [ ] Añadí el caso `'password_reset'` en el switch
- [ ] Añadí la función `sendPasswordResetEmail` completa
- [ ] Verifiqué que Resend está importado
- [ ] Personalicé el email del remitente (si es necesario)
- [ ] Personalicé la URL de la aplicación (si es necesario)
- [ ] Guardé los cambios
- [ ] Probé resetear una contraseña
- [ ] Verifiqué que el email llega correctamente

---

## 🎯 Resumen Visual de los Pasos

```
1. Supabase Dashboard
   ↓
2. Edge Functions → send-email
   ↓
3. Pestaña "Code"
   ↓
4. Añadir caso en switch: case 'password_reset'
   ↓
5. Añadir función sendPasswordResetEmail al final
   ↓
6. Verificar import de Resend
   ↓
7. Personalizar (opcional)
   ↓
8. Guardar/Desplegar
   ↓
9. Probar
```

---

## 💡 Consejos

- **Guarda una copia** del código original antes de hacer cambios (por si acaso)
- **Revisa los logs** si algo no funciona
- **Prueba con un email real** antes de usarlo en producción
- **Verifica el dominio** en Resend antes de cambiar el remitente

---

## 📞 ¿Necesitas Ayuda?

Si tienes problemas:

1. **Revisa los logs** de la Edge Function
2. **Verifica** que copiaste todo el código correctamente
3. **Comprueba** que no hay errores de sintaxis (el editor los marca en rojo)
4. **Consulta** la documentación de Resend: https://resend.com/docs

