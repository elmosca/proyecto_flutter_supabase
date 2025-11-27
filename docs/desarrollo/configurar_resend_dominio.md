# Configurar Resend para Enviar Emails a Cualquier Destinatario

## Problema Actual

Resend solo permite enviar emails de prueba a tu propia dirección de email cuando usas `onboarding@resend.dev`. Para enviar emails a otros destinatarios (como estudiantes), necesitas verificar un dominio.

## Solución: Verificar un Dominio en Resend

### Paso 1: Verificar tu Dominio en Resend

1. Ve a [resend.com/domains](https://resend.com/domains)
2. Haz clic en "Add Domain"
3. Ingresa tu dominio (ej: `cifpcarlosiii.es` o un subdominio como `mail.cifpcarlosiii.es`)
4. Resend te proporcionará registros DNS que debes añadir a tu proveedor de DNS:
   - **TXT record** para verificación
   - **DKIM records** para autenticación
   - **SPF record** (opcional pero recomendado)
5. Una vez verificados los registros DNS, Resend verificará el dominio (puede tardar unos minutos)

### Paso 2: Configurar la Variable de Entorno en Supabase

**📖 Para una guía detallada paso a paso, consulta:** [`docs/desarrollo/guia_configurar_resend_from_email_supabase.md`](./guia_configurar_resend_from_email_supabase.md)

**Resumen rápido:**

1. Ve a tu proyecto en Supabase Dashboard
2. En el menú lateral, haz clic en **Edge Functions**
3. Busca y haz clic en **Settings** o **Secrets** (puede estar en la parte superior o en un menú de tres puntos)
4. Haz clic en **"Add new secret"** o **"Add environment variable"**
5. Añade:
   - **Nombre**: `RESEND_FROM_EMAIL`
   - **Valor**: `Sistema TFG <noreply@tudominio.com>` (reemplaza `tudominio.com` con tu dominio verificado)
6. Guarda los cambios

### Paso 3: Actualizar la Edge Function

La Edge Function `send-email` ya está configurada para usar la variable de entorno `RESEND_FROM_EMAIL`. Si no está configurada, usará `onboarding@resend.dev` por defecto (solo para pruebas).

### Ejemplo de Configuración

Si tu dominio verificado es `cifpcarlosiii.es`, la variable de entorno sería:

```
RESEND_FROM_EMAIL=Sistema TFG <noreply@cifpcarlosiii.es>
```

O si prefieres usar un subdominio:

```
RESEND_FROM_EMAIL=Sistema TFG <sistema@mail.cifpcarlosiii.es>
```

## Alternativa Temporal (Solo para Desarrollo)

Si no tienes un dominio verificado aún, puedes:

1. **Usar tu propia dirección de email para pruebas**: Temporalmente, cambia la dirección `to` en la Edge Function para enviar a `jualas@gmail.com` y verificar que el contenido del email es correcto.

2. **Usar un servicio de email alternativo**: Considera usar SendGrid, Mailgun, o AWS SES si necesitas enviar emails inmediatamente sin verificar un dominio.

## Verificación

Después de configurar el dominio y la variable de entorno:

1. Reinicia la Edge Function (o espera a que se actualice automáticamente)
2. Intenta crear un nuevo estudiante
3. Verifica que el email se envía correctamente
4. Revisa los logs de la Edge Function en Supabase Dashboard para confirmar que usa la dirección correcta

## Notas Importantes

- **Dominio verificado**: Solo puedes usar direcciones de email del dominio que hayas verificado en Resend
- **Formato**: La dirección `from` debe seguir el formato `Nombre <email@dominio.com>`
- **DNS**: Los cambios de DNS pueden tardar hasta 48 horas en propagarse, aunque normalmente es más rápido
- **Límites**: Resend tiene límites en el plan gratuito (100 emails/día), verifica tu plan actual

