# 🔧 Configuración de Cloudflare para fct.jualas.es

Esta guía te ayudará a configurar el subdominio `fct.jualas.es` en Cloudflare para poder enviar correos electrónicos a través de Resend.

## 📋 Prerrequisitos

- Cuenta de Cloudflare con acceso al dominio `jualas.es`
- Token de API de Cloudflare con permisos de DNS
- Cuenta de Resend configurada

## 🚀 Paso 1: Obtener Token de API de Cloudflare

1. **Accede a tu cuenta de Cloudflare**:
   - Ve a [https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)

2. **Crear un token personalizado**:
   - Haz clic en "Create Token"
   - Selecciona "Custom token"
   - Configura los permisos:
     - **Zone**: `Zone:Read`
     - **DNS**: `DNS:Edit`
   - **Zone Resources**: `Include - Specific zone - jualas.es`
   - **Client IP Address Filtering**: (opcional)
   - **TTL**: `1 hour` (para pruebas)

3. **Copiar el token**:
   - Guarda el token en un lugar seguro
   - ⚠️ **No lo compartas ni lo commitees al repositorio**

## 🔧 Paso 2: Configurar Variables de Entorno

1. **Copiar archivo de ejemplo**:
   ```bash
   cp config/cloudflare.env.example .env.cloudflare
   ```

2. **Editar el archivo**:
   ```bash
   # Editar .env.cloudflare
   CLOUDFLARE_API_TOKEN=tu_token_real_aqui
   CLOUDFLARE_ZONE_ID=tu_zone_id_aqui  # Opcional
   ```

3. **Obtener Zone ID** (opcional):
   - Ve a [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
   - Selecciona `jualas.es`
   - En la sección "Overview", copia el "Zone ID"

## 📝 Paso 3: Configurar Registros DNS

### Opción A: Usar el Script Automático

```bash
# Cargar variables de entorno
source .env.cloudflare

# Ejecutar configuración automática
node scripts/cloudflare-dns.js setup
```

### Opción B: Configuración Manual

1. **Acceder al panel de Cloudflare**:
   - Ve a [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
   - Selecciona `jualas.es`
   - Ve a la pestaña "DNS"

2. **Añadir registros DNS** (los valores exactos los proporcionará Resend):

   **Registro TXT para verificación**:
   - Tipo: `TXT`
   - Nombre: `_resend.fct`
   - Contenido: `[valor_proporcionado_por_resend]`
   - TTL: `Auto`
   - Proxy: `Desactivado` (nube gris)

   **Registro CNAME para servicio**:
   - Tipo: `CNAME`
   - Nombre: `resend.fct`
   - Contenido: `resend.com`
   - TTL: `Auto`
   - Proxy: `Desactivado`

   **Registros CNAME para DKIM**:
   - Tipo: `CNAME`
   - Nombre: `dkim1._domainkey.fct`
   - Contenido: `dkim1.resend.com`
   - TTL: `Auto`
   - Proxy: `Desactivado`

   - Tipo: `CNAME`
   - Nombre: `dkim2._domainkey.fct`
   - Contenido: `dkim2.resend.com`
   - TTL: `Auto`
   - Proxy: `Desactivado`

## ✅ Paso 4: Verificar en Resend

1. **Acceder a Resend**:
   - Ve a [https://resend.com/domains](https://resend.com/domains)

2. **Añadir dominio**:
   - Haz clic en "Add Domain"
   - Introduce: `fct.jualas.es`

3. **Obtener registros DNS**:
   - Resend te proporcionará los registros exactos
   - Actualiza los registros en Cloudflare con estos valores

4. **Verificar dominio**:
   - Haz clic en "Verify DNS Records"
   - Espera la confirmación (puede tardar hasta 24 horas)

## 🧪 Paso 5: Probar Configuración

```bash
# Listar registros DNS actuales
node scripts/cloudflare-dns.js list

# Verificar configuración
node scripts/cloudflare-dns.js verify
```

## 📧 Paso 6: Enviar Correo de Prueba

Una vez verificado el dominio, podrás enviar correos desde `noreply@fct.jualas.es` a cualquier destinatario.

## 🔍 Comandos Útiles

```bash
# Configurar registros DNS
node scripts/cloudflare-dns.js setup

# Listar todos los registros
node scripts/cloudflare-dns.js list

# Verificar configuración
node scripts/cloudflare-dns.js verify
```

## 🚨 Solución de Problemas

### Error: "Zone not found"
- Verifica que el token tenga permisos para `jualas.es`
- Asegúrate de que el dominio esté en tu cuenta de Cloudflare

### Error: "API Error: Invalid token"
- Verifica que el token sea correcto
- Asegúrate de que el token no haya expirado

### Los registros no se propagan
- Los cambios DNS pueden tardar hasta 24 horas
- Usa herramientas como [WhatsMyDNS](https://www.whatsmydns.net/) para verificar

### Resend no verifica el dominio
- Asegúrate de que todos los registros estén correctos
- Verifica que el proxy esté desactivado (nube gris)
- Espera hasta 24 horas para la propagación completa

## 📚 Enlaces Útiles

- [Documentación de Cloudflare API](https://developers.cloudflare.com/api/)
- [Documentación de Resend](https://resend.com/docs)
- [Configuración DNS de Resend](https://resend.com/docs/domains/introduction)

## 🔒 Seguridad

- ⚠️ **Nunca commitees el archivo `.env.cloudflare`**
- 🔐 Mantén tu token de API seguro
- 🕐 Usa tokens con TTL corto para desarrollo
- 🔄 Rota los tokens regularmente
