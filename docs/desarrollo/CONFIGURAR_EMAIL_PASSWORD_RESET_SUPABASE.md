# 📧 Configurar Email de Contraseña Reseteada en Supabase

## 🎯 Objetivo

Configurar el template de email "Magic Link" de Supabase para que envíe un email bonito cuando el tutor resetea la contraseña de un estudiante.

## 📋 Pasos

### 1. Acceder al Dashboard de Supabase

```
1. Ve a: https://supabase.com/dashboard
2. Selecciona tu proyecto
3. Ve a: Authentication → Email Templates
```

### 2. Seleccionar Template "Magic Link"

```
1. En el menú lateral, busca "Magic Link"
2. Haz clic en "Magic Link"
```

### 3. Configurar el Asunto (Subject)

En el campo **Subject**, pega:

```
🔒 Tu contraseña ha sido restablecida - Sistema TFG
```

### 4. Configurar el Cuerpo (Body)

En el campo **Body** (HTML), **REEMPLAZA TODO** el contenido existente con el contenido del archivo:

📄 `docs/desarrollo/plantilla_email_password_reset_magiclink.html`

**⚠️ IMPORTANTE:** 
- Copia **TODO** el contenido del archivo HTML
- Incluye desde `<!DOCTYPE html>` hasta `</html>`
- **NO** añadas ni quites nada

### 5. Guardar

```
1. Haz clic en "Save" al final de la página
2. Espera la confirmación "Template updated successfully"
```

## 🧪 Probar

### Paso 1: Resetear Contraseña

```
1. Inicia sesión como tutor
2. Ve a "Mis Estudiantes"
3. Selecciona un estudiante
4. Menú (⋮) → "Restablecer contraseña"
5. Ingresa nueva contraseña: "TestPass123!"
6. Confirma
```

### Paso 2: Verificar Logs

En la consola del navegador (F12), busca:

```
✅ Contraseña actualizada exitosamente en Supabase Auth
✅ Notificación interna enviada al estudiante
📧 Enviando email de reset usando Supabase Auth...
✅ Email de reset de contraseña enviado vía Supabase Auth
```

### Paso 3: Verificar Email

```
1. Ve a la bandeja de entrada del estudiante
2. Busca un email con asunto:
   "🔒 Tu contraseña ha sido restablecida - Sistema TFG"
3. Abre el email
4. Deberías ver:
   - Título bonito con degradado morado
   - Saludo con nombre del estudiante
   - Quién reseteo la contraseña (tutor/admin)
   - La nueva contraseña en una caja destacada
   - Instrucciones de login
   - Botón "Iniciar Sesión Ahora"
```

## 📊 Variables Disponibles en el Template

El template tiene acceso a estas variables:

### Variables Estándar de Supabase

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `{{ .Email }}` | Email del usuario | `alumno@example.com` |
| `{{ .SiteURL }}` | URL del sitio | `https://fct.jualas.es` |
| `{{ .ConfirmationURL }}` | URL de confirmación | (Link automático) |

### Variables Personalizadas (`.Data`)

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `{{ .Data.student_name }}` | Nombre del estudiante | `María López` |
| `{{ .Data.student_email }}` | Email del estudiante | `maria@example.com` |
| `{{ .Data.temporary_password }}` | Nueva contraseña | `TempPass123!` |
| `{{ .Data.reset_by }}` | Rol que reseteo | `Tutor` o `Administrador` |
| `{{ .Data.reset_by_name }}` | Nombre quien reseteo | `Juan Pérez` |
| `{{ .Data.password_reset }}` | Flag de reset | `true` |

## 🔧 Solución de Problemas

### Problema 1: Email No Llega

**Síntoma:**
```
📧 Enviando email de reset usando Supabase Auth...
⚠️ Timeout enviando email (ignorado)
```

**Solución:**
1. Verifica que la Edge Function `super-action` esté desplegada
2. Verifica los logs de la Edge Function en Supabase Dashboard
3. Verifica que el email template esté guardado correctamente

### Problema 2: Email Llega pero Sin Formato

**Síntoma:** Email llega pero se ve como texto plano o sin estilos.

**Solución:**
1. Verifica que copiaste **TODO** el HTML del template
2. Asegúrate de que NO haya espacios extra al inicio o final
3. Guarda de nuevo el template en Supabase

### Problema 3: Variables No Se Muestran

**Síntoma:** El email muestra `{{ .Data.student_name }}` literal en lugar del nombre.

**Solución:**
1. Verifica que la Edge Function esté pasando los datos correctamente
2. Revisa los logs de la Edge Function:
   ```
   📧 Enviando email de password reset para: alumno@example.com
   ✅ Link generado exitosamente
   ```
3. Verifica que la sintaxis de las variables sea correcta: `{{ .Data.variable_name }}`

### Problema 4: Error en Edge Function

**Síntoma:**
```
⚠️ Error en respuesta de email: {error: "..."}
```

**Solución:**
1. Ve a Supabase Dashboard → Edge Functions → super-action → Logs
2. Busca el error específico
3. Verifica que el código de la Edge Function esté actualizado

## 📝 Código de la Edge Function

La nueva acción `send_password_reset_email` está en:

📄 `docs/desarrollo/super-action_edge_function_completo.ts`

**Para desplegar:**

```bash
# Desde Supabase Dashboard
1. Ve a: Edge Functions → super-action
2. Copia el contenido de super-action_edge_function_completo.ts
3. Pega en el editor
4. Deploy
```

## ✅ Checklist Final

- [ ] Template "Magic Link" configurado en Supabase
- [ ] Asunto actualizado: "🔒 Tu contraseña ha sido restablecida - Sistema TFG"
- [ ] Body actualizado con el HTML completo
- [ ] Template guardado exitosamente
- [ ] Edge Function `super-action` desplegada con la nueva acción
- [ ] Aplicación Flutter reconstruida con `flutter build web`
- [ ] Probado el flujo completo (tutor resetea → email llega → estudiante puede iniciar sesión)

---

**Última actualización:** 2025-01-10  
**Estado:** ✅ Listo para configurar

