# Guía: Configurar RESEND_FROM_EMAIL en Supabase

## 📍 Ubicación en Supabase Dashboard

### Paso 1: Acceder a Edge Functions

1. **Abre** tu navegador y ve a [supabase.com](https://supabase.com)
2. **Inicia sesión** en tu cuenta
3. **Selecciona** tu proyecto (en este caso, el proyecto con el ID `zkririyknhlwoxhsoqih`)

### Paso 2: Navegar a Edge Functions

1. En el menú lateral izquierdo del Dashboard, busca la sección **"Edge Functions"**
2. **Haz clic** en **"Edge Functions"**

### Paso 3: Acceder a Secrets

1. En la página de **Edge Functions**, busca la pestaña o sección **"Secrets"** (generalmente está en la parte superior junto a otras pestañas como "Functions", "Logs", etc.)
2. **Haz clic** en la pestaña **"Secrets"**
3. Verás la página de **"Edge Function Secrets"** con dos secciones:
   - **Sección superior**: "ADD OR REPLACE SECRETS" (para añadir nuevos secretos)
   - **Sección inferior**: Lista de secretos existentes (tabla con NAME, DIGEST, UPDATED AT)

### Paso 4: Añadir la Variable de Entorno

En la página de **Edge Function Secrets** verás dos secciones:

**Sección Superior: "ADD OR REPLACE SECRETS"**

1. En el campo **"Name"**, escribe: `RESEND_FROM_EMAIL`
2. En el campo **"Value"**, escribe: `Sistema TFG <noreply@tudominio.com>` (reemplaza `tudominio.com` con tu dominio verificado en Resend)
   - **Nota**: Puedes usar el icono del ojo 👁️ para mostrar/ocultar el valor mientras lo escribes
3. **Haz clic** en el botón verde **"Save"** (en la esquina inferior derecha de la sección)

**Lista de Secretos Existentes:**

En la sección inferior verás una tabla con todos los secretos configurados, incluyendo:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_DB_URL`
- `RESEND_API_KEY` (ya configurado)

Después de guardar, `RESEND_FROM_EMAIL` aparecerá en esta lista.

### Paso 5: Verificar la Configuración

1. Deberías ver `RESEND_FROM_EMAIL` en la lista de variables de entorno
2. **Importante**: La variable se aplicará automáticamente a todas las Edge Functions
3. No necesitas reiniciar nada, la Edge Function usará la nueva variable en la próxima ejecución

## 📝 Ejemplo de Configuración

Si tu dominio verificado en Resend es `cifpcarlosiii.es`, la configuración sería:

```
Nombre: RESEND_FROM_EMAIL
Valor: Sistema TFG <noreply@cifpcarlosiii.es>
```

O si prefieres usar un subdominio:

```
Nombre: RESEND_FROM_EMAIL
Valor: Sistema TFG <sistema@mail.cifpcarlosiii.es>
```

## 🔍 Ubicación Visual en el Dashboard

La ruta completa es:

```
Supabase Dashboard
  └── Tu Proyecto
      └── Edge Functions (menú lateral)
          └── Secrets (pestaña o sección)
              └── Sección "ADD OR REPLACE SECRETS"
                  ├── Campo "Name": RESEND_FROM_EMAIL
                  ├── Campo "Value": Sistema TFG <noreply@tudominio.com>
                  └── Botón "Save" (verde)
```

## 📸 Interfaz que Verás

La página de **Edge Function Secrets** tiene:

1. **Sección Superior**: "ADD OR REPLACE SECRETS"
   - Campo "Name" (ejemplo: `e.g. CLIENT_KEY`)
   - Campo "Value" (con iconos de ojo y generar)
   - Botón "Add another" (para añadir múltiples secretos)
   - Botón "Save" (verde, esquina inferior derecha)

2. **Sección Inferior**: Lista de secretos existentes
   - Barra de búsqueda: "Search for a secret"
   - Tabla con columnas: NAME, DIGEST (SHA256), UPDATED AT
   - Secretos existentes como `RESEND_API_KEY`, `SUPABASE_URL`, etc.

## ⚠️ Notas Importantes

1. **Formato**: La dirección debe seguir el formato `Nombre <email@dominio.com>`
2. **Dominio verificado**: Solo puedes usar direcciones de email del dominio que hayas verificado en Resend
3. **Aplicación automática**: La variable se aplica a todas las Edge Functions automáticamente
4. **Sin reinicio**: No necesitas reiniciar la Edge Function, se actualizará automáticamente

## 🐛 Si No Encuentras la Opción

Si no ves la opción de "Secrets" o "Settings" en Edge Functions:

1. **Verifica** que tienes permisos de administrador en el proyecto
2. **Busca** en la documentación de Supabase: [supabase.com/docs/guides/functions/secrets](https://supabase.com/docs/guides/functions/secrets)
3. **Alternativa**: Puedes usar la CLI de Supabase:
   ```bash
   supabase secrets set RESEND_FROM_EMAIL="Sistema TFG <noreply@tudominio.com>"
   ```

## ✅ Verificación

Después de configurar la variable:

1. **Actualiza** la Edge Function `send-email` con el código actualizado (si aún no lo has hecho)
2. **Crea** un nuevo estudiante desde la aplicación
3. **Revisa** los logs de la Edge Function en Supabase Dashboard
4. Deberías ver en los logs: `🔍 Debug - RESEND_FROM_EMAIL: Sistema TFG <noreply@tudominio.com>`

