import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  // Manejar CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const body = await req.json();
    const { action, user_email, new_password, user_data } = body;

    if (!action) {
      return new Response(
        JSON.stringify({ error: 'action es requerido (reset_password, create_user, delete_user o invite_user)' }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      );
    }

    // Crear cliente con service_role
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );

    if (action === 'reset_password') {
      // Lógica existente para resetear contraseña
      if (!user_email || !new_password) {
        return new Response(
          JSON.stringify({ error: 'user_email y new_password son requeridos para reset_password' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Obtener el usuario por email
      const { data: users, error: listError } = await supabaseAdmin.auth.admin.listUsers();
      
      if (listError) {
        throw listError;
      }

      const user = users.users.find(u => u.email === user_email);
      
      if (!user) {
        return new Response(
          JSON.stringify({ error: 'Usuario no encontrado' }),
          { 
            status: 404, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Actualizar la contraseña usando Admin API
      const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
        user.id,
        { password: new_password }
      );

      if (error) {
        throw error;
      }

      return new Response(
        JSON.stringify({ success: true, message: 'Contraseña actualizada exitosamente' }),
        { 
          status: 200, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          } 
        }
      );
    } else if (action === 'create_user') {
      // Nueva lógica para crear usuario sin verificación
      if (!user_data || !user_data.email || !user_data.password) {
        return new Response(
          JSON.stringify({ error: 'user_data con email y password son requeridos para create_user' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Verificar si el usuario ya existe antes de intentar crearlo
      const { data: existingUsers, error: listError } = await supabaseAdmin.auth.admin.listUsers();
      
      if (listError) {
        throw listError;
      }

      const existingUser = existingUsers.users.find(u => u.email === user_data.email);
      
      if (existingUser) {
        return new Response(
          JSON.stringify({ 
            error: 'A user with this email address has already been registered',
            error_code: 'email_already_registered',
            user_id: existingUser.id,
          }),
          { 
            status: 409, // Conflict - el recurso ya existe
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Crear usuario con email ya confirmado (sin verificación)
      const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
        email: user_data.email,
        password: user_data.password,
        email_confirm: true, // Esto marca el email como confirmado automáticamente
        user_metadata: {
          full_name: user_data.full_name || '',
          role: user_data.role || 'student',
        },
      });

      if (createError) {
        // Detectar si el error es porque el usuario ya existe
        const errorMessage = createError.message || createError.toString();
        if (errorMessage.includes('already been registered') || 
            errorMessage.includes('already registered') ||
            errorMessage.includes('email address has already')) {
          return new Response(
            JSON.stringify({ 
              error: 'A user with this email address has already been registered',
              error_code: 'email_already_registered',
            }),
            { 
              status: 409, // Conflict
              headers: { 
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              } 
            }
          );
        }
        throw createError;
      }

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Usuario creado exitosamente sin verificación de email',
          user_id: newUser.user.id,
        }),
        { 
          status: 200, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          } 
        }
      );
    } else if (action === 'delete_user') {
      // Eliminar usuario de Auth
      if (!user_email) {
        return new Response(
          JSON.stringify({ error: 'user_email es requerido para delete_user' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Obtener el usuario por email
      const { data: users, error: listError } = await supabaseAdmin.auth.admin.listUsers();
      
      if (listError) {
        throw listError;
      }

      const user = users.users.find(u => u.email === user_email);
      
      if (!user) {
        // Si el usuario no existe en Auth, retornar éxito (ya está eliminado)
        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'Usuario no encontrado en Auth (ya eliminado o no existía)',
          }),
          { 
            status: 200, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Eliminar el usuario de Auth
      const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(user.id);

      if (deleteError) {
        throw deleteError;
      }

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Usuario eliminado exitosamente de Auth',
        }),
        { 
          status: 200, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          } 
        }
      );
    } else if (action === 'bulk_delete_users_by_domain') {
      // Eliminar usuarios que NO pertenezcan al dominio autorizado
      // Dominios permitidos: jualas.es y fct.jualas.es
      const allowedDomains = ['@jualas.es', '@fct.jualas.es'];
      
      // Obtener todos los usuarios de Auth
      const { data: usersData, error: listError } = await supabaseAdmin.auth.admin.listUsers();
      
      if (listError) {
        throw listError;
      }

      const usersToDelete: Array<{ email: string; id: string; role?: string }> = [];
      const deletedUsers: Array<{ email: string; id: string }> = [];
      const errors: Array<{ email: string; error: string }> = [];

      // Filtrar usuarios que NO pertenecen a los dominios permitidos
      for (const user of usersData.users) {
        if (!user.email) continue;
        
        const email = user.email.toLowerCase();
        const belongsToAllowedDomain = allowedDomains.some(domain => email.endsWith(domain));
        
        if (!belongsToAllowedDomain) {
          usersToDelete.push({
            email: user.email,
            id: user.id,
            role: user.user_metadata?.role || 'unknown'
          });
        }
      }

      console.log(`🔍 Encontrados ${usersToDelete.length} usuarios a eliminar que no pertenecen a los dominios autorizados`);

      // Eliminar usuarios uno por uno
      for (const user of usersToDelete) {
        try {
          const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(user.id);
          
          if (deleteError) {
            errors.push({ email: user.email, error: deleteError.message });
            console.error(`❌ Error eliminando ${user.email}:`, deleteError.message);
          } else {
            deletedUsers.push({ email: user.email, id: user.id });
            console.log(`✅ Usuario eliminado de Auth: ${user.email}`);
          }
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          errors.push({ email: user.email, error: errorMessage });
          console.error(`❌ Error eliminando ${user.email}:`, errorMessage);
        }
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: `Eliminación masiva completada. ${deletedUsers.length} usuarios eliminados, ${errors.length} errores`,
          summary: {
            total_found: usersToDelete.length,
            deleted: deletedUsers.length,
            errors: errors.length,
            allowed_domains: allowedDomains
          },
          deleted_users: deletedUsers,
          errors: errors
        }),
        {
          status: 200,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          }
        }
      );
    } else if (action === 'invite_user') {
      // Invitar usuario con contraseña temporal visible
      if (!user_data || !user_data.email || !user_data.password) {
        return new Response(
          JSON.stringify({ error: 'user_data con email y password son requeridos para invite_user' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Verificar si el usuario ya existe
      const { data: existingUsers, error: listError } = await supabaseAdmin.auth.admin.listUsers();
      
      if (listError) {
        throw listError;
      }

      const existingUser = existingUsers.users.find(u => u.email === user_data.email);
      
      if (existingUser) {
        return new Response(
          JSON.stringify({ 
            error: 'A user with this email address has already been registered',
            error_code: 'email_already_registered',
            user_id: existingUser.id,
          }),
          { 
            status: 409,
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      // Invitar usuario con contraseña temporal
      // La contraseña se pasa en user_metadata para que esté disponible en la plantilla del email
      
      // Log para debug: ver qué datos estamos enviando
      console.log('📧 Invitando usuario con datos:', {
        email: user_data.email,
        full_name: user_data.full_name,
        password: user_data.password ? '***' : undefined,
        tutor_name: user_data.tutor_name,
        created_by: user_data.created_by,
        created_by_name: user_data.created_by_name,
      });
      
      const { data: invitedUser, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
        user_data.email,
        {
          data: {
            full_name: user_data.full_name || '',
            role: user_data.role || 'student',
            temporary_password: user_data.password, // Contraseña temporal visible en el email
            tutor_name: user_data.tutor_name || '',
            tutor_email: user_data.tutor_email || '',
            tutor_phone: user_data.tutor_phone || '',
            academic_year: user_data.academic_year || '',
            student_phone: user_data.student_phone || '',
            student_nre: user_data.student_nre || '',
            student_specialty: user_data.student_specialty || '',
            created_by: user_data.created_by || 'administrador',
            created_by_name: user_data.created_by_name || 'Sistema',
          },
          redirectTo: user_data.redirect_to || undefined,
        }
      );
      
      console.log('✅ Usuario invitado correctamente:', invitedUser?.user?.id);

      if (inviteError) {
        const errorMessage = inviteError.message || inviteError.toString();
        if (errorMessage.includes('already been registered') || 
            errorMessage.includes('already registered') ||
            errorMessage.includes('email address has already')) {
          return new Response(
            JSON.stringify({ 
              error: 'A user with this email address has already been registered',
              error_code: 'email_already_registered',
            }),
            { 
              status: 409,
              headers: { 
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              } 
            }
          );
        }
        throw inviteError;
      }

      // Ahora actualizamos la contraseña del usuario invitado
      // inviteUserByEmail crea el usuario pero no establece la contraseña
      // Necesitamos usar updateUserById para establecerla
      if (invitedUser && invitedUser.user) {
        const { error: passwordError } = await supabaseAdmin.auth.admin.updateUserById(
          invitedUser.user.id,
          { password: user_data.password }
        );

        if (passwordError) {
          console.error('Error al establecer contraseña:', passwordError);
          // No lanzamos error aquí porque el usuario ya fue invitado
          // El usuario podrá establecer su contraseña desde el enlace del email
        }
      }

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Usuario invitado exitosamente. Recibirá un email con su contraseña temporal.',
          user_id: invitedUser.user.id,
        }),
        { 
          status: 200, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          } 
        }
      );
    } else if (action === 'send_password_reset_email') {
      // Nueva acción: Enviar email de contraseña reseteada
      // Como generateLink() no envía emails automáticamente, lo enviamos manualmente
      
      if (!user_email || !new_password || !user_data) {
        return new Response(
          JSON.stringify({ error: 'user_email, new_password y user_data son requeridos para send_password_reset_email' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      console.log('📧 Enviando email de password reset para:', user_email);

      // Construir el HTML del email
      const emailHtml = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 0; }
    .email-container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; padding: 30px 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; font-weight: 600; }
    .content { padding: 30px 20px; }
    .greeting { font-size: 18px; margin-bottom: 20px; }
    .message { font-size: 16px; color: #666; margin-bottom: 25px; }
    .password-container { background-color: #f8f9fa; border: 2px solid #667eea; border-radius: 8px; padding: 20px; margin: 25px 0; text-align: center; }
    .password-label { font-size: 14px; color: #666; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 1px; }
    .password-value { font-size: 24px; font-weight: bold; color: #667eea; font-family: 'Courier New', monospace; letter-spacing: 2px; background-color: #fff; padding: 15px; border-radius: 6px; margin: 10px 0; }
    .info-box { background-color: #e7f3ff; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 4px; }
    .warning-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 25px 0; border-radius: 4px; }
    .warning-box ul { margin: 10px 0; padding-left: 20px; color: #856404; }
    .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 14px 28px; text-decoration: none; border-radius: 6px; font-weight: 600; margin: 20px 0; }
    .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #999; border-top: 1px solid #e9ecef; }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🔒 Contraseña Restablecida</h1>
    </div>
    <div class="content">
      <div class="greeting">Hola <strong>${user_data.student_name || user_email}</strong>,</div>
      <div class="message">Tu contraseña ha sido restablecida por <strong>${user_data.reset_by_name}</strong> (${user_data.reset_by}).</div>
      <div class="password-container">
        <div class="password-label">Tu Nueva Contraseña</div>
        <div class="password-value">${new_password}</div>
      </div>
      <div class="info-box">
        <strong>ℹ️ Cómo Iniciar Sesión:</strong>
        <p><strong>1. Correo:</strong> ${user_email}</p>
        <p><strong>2. Contraseña:</strong> Usa la contraseña mostrada arriba</p>
        <p><strong>3. Enlace:</strong> <a href="https://fct.jualas.es/login">https://fct.jualas.es/login</a></p>
      </div>
      <div class="warning-box">
        <strong>⚠️ Importante:</strong>
        <ul>
          <li>Guarda esta contraseña en un lugar seguro</li>
          <li>Puedes cambiarla después de iniciar sesión desde tu perfil</li>
          <li>Si no solicitaste este cambio, contacta a tu tutor</li>
        </ul>
      </div>
      <div style="text-align: center;">
        <a href="https://fct.jualas.es/login" class="button">Iniciar Sesión Ahora</a>
      </div>
    </div>
    <div class="footer">
      <p><strong>Sistema de Gestión de Proyectos TFG</strong></p>
      <p>CIFP Carlos III</p>
    </div>
  </div>
</body>
</html>`;

      // Enviar email usando Resend directamente
      // Como el SMTP de Supabase está configurado con Resend, usamos la API de Resend
      const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
      
      if (!RESEND_API_KEY) {
        console.error('❌ RESEND_API_KEY no configurada');
        return new Response(
          JSON.stringify({ error: 'RESEND_API_KEY no configurada en secrets' }),
          { 
            status: 500, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      try {
        // Enviar email usando Resend API directamente
        const resendResponse = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            from: 'Sistema TFG - CIFP Carlos III <noreply@fct.jualas.es>',
            to: [user_email],
            subject: '🔒 Tu contraseña ha sido restablecida - Sistema TFG',
            html: emailHtml
          })
        });

        if (!resendResponse.ok) {
          const errorText = await resendResponse.text();
          console.error('❌ Error de Resend:', errorText);
          return new Response(
            JSON.stringify({ error: `Error enviando email: ${errorText}` }),
            { 
              status: 500, 
              headers: { 
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              } 
            }
          );
        }

        const resendData = await resendResponse.json();
        console.log('✅ Email enviado exitosamente usando Resend:', resendData.id);

        return new Response(
          JSON.stringify({ 
            success: true,
            message: 'Email enviado correctamente',
            email_id: resendData.id
          }),
          { 
            status: 200, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      } catch (emailError) {
        console.error('❌ Excepción enviando email:', emailError);
        return new Response(
          JSON.stringify({ error: `Excepción enviando email: ${emailError.message}` }),
          { 
            status: 500, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }
    } else if (action === 'bulk_create_students') {
      // Creación masiva de estudiantes desde CSV
      // Permite crear múltiples usuarios sin los límites de rate limiting del cliente
      if (!body.students || !Array.isArray(body.students) || body.students.length === 0) {
        return new Response(
          JSON.stringify({ error: 'students array es requerido para bulk_create_students' }),
          { 
            status: 400, 
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            } 
          }
        );
      }

      const students = body.students;
      const tutorId = body.tutor_id || null;
      const results = [];
      const errors = [];

      // Obtener información del tutor si está disponible
      let tutorInfo = null;
      if (tutorId) {
        const { data: tutorData, error: tutorError } = await supabaseAdmin
          .from('users')
          .select('id, full_name, email, phone')
          .eq('id', tutorId)
          .eq('role', 'tutor')
          .single();
        
        if (!tutorError && tutorData) {
          tutorInfo = tutorData;
        }
      }

      // Función helper para enviar email de bienvenida usando Resend
      const sendWelcomeEmail = async (student: any, password: string) => {
        const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
        if (!RESEND_API_KEY) {
          console.warn('⚠️ RESEND_API_KEY no configurada, no se enviará email de bienvenida');
          return false;
        }

        const emailHtml = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 0; }
    .email-container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; padding: 30px 20px; text-align: center; }
    .header h1 { margin: 0; font-size: 24px; font-weight: 600; }
    .content { padding: 30px 20px; }
    .greeting { font-size: 18px; margin-bottom: 20px; }
    .message { font-size: 16px; color: #666; margin-bottom: 25px; }
    .password-container { background-color: #f8f9fa; border: 2px solid #667eea; border-radius: 8px; padding: 20px; margin: 25px 0; text-align: center; }
    .password-label { font-size: 14px; color: #666; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 1px; }
    .password-value { font-size: 24px; font-weight: bold; color: #667eea; font-family: 'Courier New', monospace; letter-spacing: 2px; background-color: #fff; padding: 15px; border-radius: 6px; margin: 10px 0; }
    .info-box { background-color: #e7f3ff; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 4px; }
    .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; padding: 14px 28px; text-decoration: none; border-radius: 6px; font-weight: 600; margin: 20px 0; }
    .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #999; border-top: 1px solid #e9ecef; }
  </style>
</head>
<body>
  <div class="email-container">
    <div class="header">
      <h1>🎓 Bienvenido al Sistema TFG</h1>
    </div>
    <div class="content">
      <div class="greeting">Hola <strong>${student.full_name}</strong>,</div>
      <div class="message">Has sido registrado en el Sistema de Gestión de Proyectos TFG del CIFP Carlos III.</div>
      ${tutorInfo ? `<div class="info-box"><strong>Tu tutor:</strong> ${tutorInfo.full_name}<br>Email: ${tutorInfo.email}${tutorInfo.phone ? `<br>Teléfono: ${tutorInfo.phone}` : ''}</div>` : ''}
      <div class="password-container">
        <div class="password-label">Tu Contraseña Temporal</div>
        <div class="password-value">${password}</div>
      </div>
      <div class="info-box">
        <strong>ℹ️ Cómo Iniciar Sesión:</strong>
        <p><strong>1. Correo:</strong> ${student.email}</p>
        <p><strong>2. Contraseña:</strong> Usa la contraseña mostrada arriba</p>
        <p><strong>3. Enlace:</strong> <a href="https://fct.jualas.es/login">https://fct.jualas.es/login</a></p>
      </div>
      <div style="text-align: center;">
        <a href="https://fct.jualas.es/login" class="button">Iniciar Sesión Ahora</a>
      </div>
    </div>
    <div class="footer">
      <p><strong>Sistema de Gestión de Proyectos TFG</strong></p>
      <p>CIFP Carlos III</p>
    </div>
  </div>
</body>
</html>`;

        try {
          const resendResponse = await fetch('https://api.resend.com/emails', {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${RESEND_API_KEY}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              from: 'Sistema TFG - CIFP Carlos III <noreply@fct.jualas.es>',
              to: [student.email],
              subject: '🎓 Bienvenido al Sistema TFG - CIFP Carlos III',
              html: emailHtml
            })
          });

          if (!resendResponse.ok) {
            const errorText = await resendResponse.text();
            console.error('❌ Error enviando email de bienvenida:', errorText);
            return false;
          }

          const resendData = await resendResponse.json();
          console.log('✅ Email de bienvenida enviado:', resendData.id);
          return true;
        } catch (emailError) {
          console.error('❌ Excepción enviando email de bienvenida:', emailError);
          return false;
        }
      };

      // Procesar cada estudiante con un pequeño delay para evitar sobrecarga
      for (let i = 0; i < students.length; i++) {
        const student = students[i];
        
        try {
          // Delay entre creaciones (1 segundo) - necesario para evitar rate limiting
          if (i > 0) {
            await new Promise(resolve => setTimeout(resolve, 1000));
          }

          // Validar datos requeridos
          if (!student.email || !student.password || !student.full_name) {
            errors.push({
              email: student.email || 'unknown',
              name: student.full_name || 'Unknown',
              error: 'Faltan datos requeridos (email, password, full_name)'
            });
            continue;
          }

          // Verificar si el usuario ya existe
          const { data: existingUsers, error: listError } = await supabaseAdmin.auth.admin.listUsers();
          
          if (listError) {
            errors.push({
              email: student.email,
              name: student.full_name,
              error: `Error verificando usuario: ${listError.message}`
            });
            continue;
          }

          const existingUser = existingUsers.users.find(u => u.email === student.email);
          
          if (existingUser) {
            errors.push({
              email: student.email,
              name: student.full_name,
              error: 'Email ya registrado en el sistema'
            });
            continue;
          }

          // Crear usuario en Auth usando createUser (NO envía email automáticamente)
          // Esto evita el límite de emails de Supabase Auth
          const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
            email: student.email,
            password: student.password,
            email_confirm: true, // Marcar email como confirmado
            user_metadata: {
              full_name: student.full_name || '',
              role: 'student',
              tutor_name: tutorInfo?.full_name || '',
              tutor_email: tutorInfo?.email || '',
              tutor_phone: tutorInfo?.phone || '',
              academic_year: student.academic_year || '',
              student_phone: student.phone || '',
              student_nre: student.nre || '',
              student_specialty: student.specialty || '',
              created_by: 'bulk_import',
              created_by_name: 'Importación CSV',
            },
          });

          if (createError) {
            errors.push({
              email: student.email,
              name: student.full_name,
              error: createError.message || 'Error al crear usuario en Auth'
            });
            continue;
          }

          // Crear registro en tabla users
          const { data: userRecord, error: insertError } = await supabaseAdmin
            .from('users')
            .insert({
              email: student.email,
              full_name: student.full_name,
              role: 'student',
              tutor_id: tutorId,
              phone: student.phone || null,
              nre: student.nre || null,
              specialty: student.specialty || null,
              biography: student.biography || null,
              academic_year: student.academic_year || null,
              status: 'active',
            })
            .select()
            .single();

          if (insertError) {
            // Si falla el insert pero el usuario se creó en Auth, intentar limpiar
            if (newUser && newUser.user) {
              await supabaseAdmin.auth.admin.deleteUser(newUser.user.id);
            }
            errors.push({
              email: student.email,
              name: student.full_name,
              error: `Error al crear registro en base de datos: ${insertError.message}`
            });
            continue;
          }

          // Enviar email de bienvenida usando Resend (sin límites de Supabase Auth)
          // Esto se hace después de crear el usuario para no bloquear la creación
          // Si falla el email, el usuario ya está creado y puede iniciar sesión
          const emailSent = await sendWelcomeEmail(student, student.password);
          if (!emailSent) {
            console.warn(`⚠️ No se pudo enviar email de bienvenida a ${student.email}, pero el usuario fue creado correctamente`);
          }

          results.push({
            email: student.email,
            name: student.full_name,
            password: student.password,
            user_id: userRecord.id,
            auth_id: newUser.user.id,
            status: 'success',
            email_sent: emailSent
          });

        } catch (error) {
          errors.push({
            email: student.email || 'unknown',
            name: student.full_name || 'Unknown',
            error: error.message || 'Error desconocido'
          });
        }
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: `Procesados ${students.length} estudiantes: ${results.length} exitosos, ${errors.length} con errores`,
          results: results,
          errors: errors,
          summary: {
            total: students.length,
            successful: results.length,
            failed: errors.length
          }
        }),
        { 
          status: 200, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
          } 
        }
      );
    } else {
      return new Response(
        JSON.stringify({ error: `Acción desconocida: ${action}. Acciones válidas: reset_password, create_user, delete_user, invite_user, send_password_reset_email, bulk_create_students` }),
        { 
          status: 400, 
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          } 
        }
      );
    }
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        } 
      }
    );
  }
});

