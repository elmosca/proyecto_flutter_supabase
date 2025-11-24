# 📧 Resumen Rápido: Añadir Email de Bienvenida al Estudiante

## ✅ Cambios Realizados en Flutter

1. **`EmailNotificationService`**: Añadido método `sendStudentWelcomeEmail()` con todos los datos del formulario
2. **`UserManagementService.createStudent()`**: 
   - Modificado para aceptar NRE, especialidad y biografía
   - Modificado para enviar email automáticamente después de crear el estudiante con TODA la información
3. **`AddStudentForm`**: Modificado para pasar todos los datos del formulario (NRE, especialidad, biografía)

## 📋 Pasos en Supabase

### 1. Acceder a la Edge Function `send-email`

1. Ve a https://supabase.com/dashboard
2. Selecciona tu proyecto
3. En el menú lateral, haz clic en **"Edge Functions"**
4. Haz clic en **"send-email"**
5. Haz clic en la pestaña **"Code"**

### 2. Añadir la función `generateStudentWelcomeEmail`

Busca la función `generatePasswordResetEmail` (alrededor de la línea 236) y **después de ella**, añade esta función:

```typescript
/**
 * Genera email de bienvenida cuando se crea un nuevo estudiante
 */
function generateStudentWelcomeEmail(data) {
  const {
    studentEmail,
    studentName,
    password,
    academicYear,
    studentPhone,
    studentNre,
    studentSpecialty,
    tutorName,
    tutorEmail,
    tutorPhone,
    createdBy,
    createdByName,
  } = data;

  // Obtener la URL de la aplicación desde variables de entorno o usar un valor por defecto
  const APP_URL = Deno.env.get('APP_URL') || 'https://tu-app.supabase.co';

  // Template HTML del email
  const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bienvenido al Sistema TFG</title>
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
    .info-box {
      background-color: #e7f3ff;
      border-left: 4px solid #2196F3;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
      font-size: 14px;
      color: #0c5460;
    }
    .info-box strong {
      display: block;
      margin-bottom: 8px;
      color: #0c5460;
    }
    .info-box p {
      margin: 5px 0;
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
    .tutor-info {
      background-color: #f0f9ff;
      border-left: 4px solid #0ea5e9;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .tutor-info h3 {
      margin: 0 0 10px 0;
      color: #0c4a6e;
      font-size: 16px;
    }
    .tutor-info p {
      margin: 5px 0;
      color: #075985;
      font-size: 14px;
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
      transition: transform 0.2s;
    }
    .button:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 8px rgba(102, 126, 234, 0.4);
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
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🎓 ¡Bienvenido al Sistema TFG!</h1>
    </div>
    
    <div class="content">
      <div class="greeting">
        Hola <strong>${studentName}</strong>,
      </div>
      
      <div class="message">
        Has sido añadido al <strong>Sistema de Gestión de Proyectos TFG</strong> del CIFP Carlos III.
      </div>
      
      <div class="info-box">
        <strong>📋 Información de tu cuenta:</strong>
        <p><strong>Nombre completo:</strong> ${studentName}</p>
        <p><strong>Email:</strong> ${studentEmail}</p>
        ${studentNre ? `<p><strong>NRE:</strong> ${studentNre}</p>` : ''}
        ${studentPhone ? `<p><strong>Teléfono:</strong> ${studentPhone}</p>` : ''}
        ${academicYear ? `<p><strong>Año académico:</strong> ${academicYear}</p>` : ''}
        ${studentSpecialty ? `<p><strong>Especialidad:</strong> ${studentSpecialty}</p>` : ''}
        <p><strong>Creado por:</strong> ${createdByName} (${createdBy === 'administrador' ? 'Administrador' : 'Tutor'})</p>
      </div>
      
      ${tutorName ? `
      <div class="tutor-info">
        <h3>👨‍🏫 Tu Tutor Asignado</h3>
        <p><strong>Nombre:</strong> ${tutorName}</p>
        ${tutorEmail ? `<p><strong>Email:</strong> <a href="mailto:${tutorEmail}">${tutorEmail}</a></p>` : ''}
        ${tutorPhone ? `<p><strong>Teléfono:</strong> <a href="tel:${tutorPhone}">${tutorPhone}</a></p>` : ''}
        <p style="margin-top: 10px; font-size: 13px; color: #075985;">
          <strong>💬 Puedes contactar a tu tutor directamente por email o teléfono para cualquier consulta sobre tu proyecto TFG.</strong>
        </p>
      </div>
      ` : ''}
      
      <div class="password-container">
        <div class="password-label">Tu Contraseña de Acceso</div>
        <div class="password-value">${password}</div>
      </div>
      
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Guarda esta contraseña en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión desde tu perfil</li>
          <li>Por seguridad, no compartas esta contraseña con nadie</li>
          <li>Si tienes problemas para acceder, contacta a tu tutor o administrador</li>
        </ul>
      </div>
      
      <div class="button-container">
        <a href="${APP_URL}/login" class="button">Iniciar Sesión</a>
      </div>
      
      <div class="info-box">
        <strong>💡 Próximos pasos:</strong>
        <p>1. Inicia sesión con tu email y la contraseña proporcionada</p>
        <p>2. Completa tu perfil si es necesario</p>
        <p>3. Comienza a trabajar en tu proyecto TFG</p>
        ${tutorName ? `<p>4. Contacta a tu tutor ${tutorName} si tienes alguna pregunta</p>` : ''}
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

  // Template de texto plano (para clientes de email que no soportan HTML)
  const text = `
🎓 ¡BIENVENIDO AL SISTEMA TFG!

Hola ${studentName},

Has sido añadido al Sistema de Gestión de Proyectos TFG del CIFP Carlos III.

📋 INFORMACIÓN DE TU CUENTA:
Nombre completo: ${studentName}
Email: ${studentEmail}
${studentNre ? `NRE: ${studentNre}\n` : ''}${studentPhone ? `Teléfono: ${studentPhone}\n` : ''}${academicYear ? `Año académico: ${academicYear}\n` : ''}${studentSpecialty ? `Especialidad: ${studentSpecialty}\n` : ''}Creado por: ${createdByName} (${createdBy === 'administrador' ? 'Administrador' : 'Tutor'})

${tutorName ? `
👨‍🏫 TU TUTOR ASIGNADO:
Nombre: ${tutorName}
${tutorEmail ? `Email: ${tutorEmail}\n` : ''}${tutorPhone ? `Teléfono: ${tutorPhone}\n` : ''}
💬 Puedes contactar a tu tutor directamente por email o teléfono para cualquier consulta sobre tu proyecto TFG.

` : ''}

TU CONTRASEÑA DE ACCESO:
${password}

⚠️ IMPORTANTE:
- Guarda esta contraseña en un lugar seguro
- Puedes cambiarla después de iniciar sesión desde tu perfil
- Por seguridad, no compartas esta contraseña con nadie
- Si tienes problemas para acceder, contacta a tu tutor o administrador

💡 PRÓXIMOS PASOS:
1. Inicia sesión con tu email y la contraseña proporcionada
2. Completa tu perfil si es necesario
3. Comienza a trabajar en tu proyecto TFG
${tutorName ? `4. Contacta a tu tutor ${tutorName} si tienes alguna pregunta\n` : ''}

Inicia sesión en: ${APP_URL}/login

---
Sistema de Gestión de Proyectos TFG
CIFP Carlos III

Este es un email automático, por favor no respondas.
Si tienes problemas para acceder, contacta a tu tutor o administrador.
  `;

  return {
    to: studentEmail,
    subject: '🎓 ¡Bienvenido al Sistema TFG - CIFP Carlos III!',
    html,
    text,
  };
}
```

### 3. Añadir el caso `student_welcome` en el switch

Busca el `switch(type)` (alrededor de la línea 771) y añade este caso **antes del `default`**:

```typescript
switch(type) {
  case 'comment_notification':
    emailData = generateCommentNotificationEmail(data);
    break;
  case 'status_change':
    emailData = generateStatusChangeEmail(data);
    break;
  case 'password_reset':
    emailData = generatePasswordResetEmail(data);
    break;
  case 'student_welcome':  // ← AÑADE ESTE CASO
    emailData = generateStudentWelcomeEmail(data);
    break;
  default:
    throw new Error(`Unknown email type: ${type}`);
}
```

### 4. Guardar y Desplegar

1. Haz clic en **"Deploy"** o **"Save"** (según tu versión de Supabase)
2. Espera a que se despliegue la función

## ✅ Verificación

1. Crea un nuevo estudiante desde la aplicación (como tutor o admin)
2. Verifica que el estudiante recibe el email de bienvenida con:
   - **Información completa de su cuenta:**
     - Nombre completo
     - Email
     - NRE (si está configurado)
     - Teléfono (si está configurado)
     - Año académico (si está configurado)
     - Especialidad (si está configurada)
     - Información de quién lo creó
   - **Información del tutor asignado:**
     - Nombre del tutor
     - Email del tutor (con enlace mailto)
     - Teléfono del tutor (con enlace tel)
     - Mensaje de que puede contactar directamente
   - **Contraseña de acceso** destacada

## ⚠️ Nota Importante

El estudiante recibirá **DOS emails**:
1. **Email de verificación de Supabase Auth** (automático) - Este es el que viste antes
2. **Email personalizado de bienvenida** (nuestro) - Este incluye TODA la información del formulario y del tutor

Ambos emails son normales y esperados. El email personalizado se envía después de crear el estudiante exitosamente.

## 📝 Notas

- El código completo está en: `docs/desarrollo/codigo_completo_edge_function_send_email_actualizado.ts`
- El email se envía automáticamente después de crear el estudiante
- Si el email falla, no interrumpe la creación del estudiante (es no crítico)
- El email incluye toda la información relevante: contraseña, tutor, año académico, etc.

