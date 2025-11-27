# Prueba Manual de Envío de Correos desde la Aplicación

## Objetivo

Validar que la aplicación puede enviar correos electrónicos reales utilizando la Edge Function `send-email` y Resend.

## Requisitos Previos

- Edge Function `send-email` desplegada con el código actualizado (`docs/desarrollo/codigo_completo_edge_function_send_email_actualizado.ts`)
- Secretos configurados en Supabase:
  - `RESEND_API_KEY`
  - `RESEND_FROM_EMAIL` (ej. `Sistema TFG <noreply@fct.jualas.es>`)
- Dominio verificado en Resend (`fct.jualas.es` u otro dominio propio)
- Cuenta de Resend en modo Producción (no modo "sandbox")

## Ejecución del Test Manual

1. Sitúate en la carpeta del frontend:
   ```bash
   cd frontend
   ```

2. Ejecuta el script pasando el destinatario de prueba:
   ```bash
   dart run bin/send_email_smoke.dart tu_correo@dominio.com
   ```

   Si no pasas un destinatario, usará `jualas@gmail.com`.

3. El script enviará un email de bienvenida utilizando `EmailNotificationService.sendStudentWelcomeEmail` con `failSilently: false`.  
   Cualquier error en la Edge Function hará que el comando termine con error y mostrará el mensaje devuelto por Supabase o Resend.

## Resultado Esperado

- El comando termina con `All tests passed!`
- El destinatario recibe un email con el asunto `🎓 ¡Bienvenido al Sistema TFG - CIFP Carlos III!`
- En los logs de Supabase (`Edge Functions > send-email > Logs`) aparece `✅ Email sent successfully`

## Limpieza

Los correos enviados son reales. El test utiliza una contraseña generada con marca temporal (`Test-XXXXXXXX`), por lo que no afecta a usuarios existentes.

## Notas

- Puedes repetir el test cambiando el correo de destino para validar diferentes destinatarios.
- Si deseas probar otras plantillas (`password_reset`, `status_change`, etc.) puedes adaptar el test manual siguiendo el mismo patrón.

