# Desarrollo con Supabase Cloud (Guía Genérica)

> Esta guía describe el uso de Supabase Cloud en el proyecto, sin exponer datos reales. Sustituye cualquier valor sensible por variables de entorno y secretos gestionados fuera del repositorio.

---

## Configuración de entorno (Frontend)

Define las variables mediante `--dart-define` o un gestor de configuración seguro.

```bash
# Ejemplo (no real):
flutter run \
  --dart-define=SUPABASE_URL=https://<TU-PROYECTO>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<TU_ANON_KEY>
```

Recomendaciones:
- No commitear claves en el repositorio.
- Separar entornos (desarrollo, staging, producción) con variables por entorno.

---

## Conexión desde scripts y herramientas

Para tareas de administración (backups, restauración, psql), usa la URL de base de datos gestionada por Supabase Cloud con SSL.

```bash
# Formato genérico (no real):
export SUPABASE_DB_URL="postgres://<usuario>:<password>@<host>:<puerto>/<db>?sslmode=require"
```

Obtén estos valores solo desde el panel de Supabase Cloud (Project Settings → Database). No los guardes en el repositorio.

---

## Backups y Restauración (Cloud, genérico)

- Planes gratuitos pueden no incluir backups automáticos; usa `pg_dump`/`pg_restore`.
- Scripts de ejemplo (ajusta variables de entorno y rutas):

```powershell
# Backup (genérico)
powershell -ExecutionPolicy Bypass -File .\scripts\backup_db.ps1 -OutputDir .\backups -Format custom -NoOwner

# Restauración (genérico)
powershell -ExecutionPolicy Bypass -File .\scripts\restore_db.ps1 -InputPath .\backups\supabase_YYYYMMDD_HHMMSS.dump -Clean -NoOwner
```

Buenas prácticas:
- Usa `sslmode=require` siempre.
- Almacena dumps fuera del repo y cifra si contienen datos sensibles.

---

## Autenticación y Seguridad

Checklist recomendado (genérico):
- Activar y revisar RLS en todas las tablas de datos de usuario.
- Definir Policies específicas por rol (admin, tutor, student).
- Minimizar la superficie de `anon` y usar `service_role` solo en servidores seguros.
- Rotar claves periódicamente y usar secretos gestionados (CI/CD / vault).

---

## Storage (Archivos)

- Crear buckets y permisos desde el panel (Storage → Buckets).
- Acceso desde frontend mediante el SDK de Supabase con la URL del proyecto.
- No utilizar access/secret keys S3 desde el cliente; usar endpoints gestionados por Supabase.

---

## Edge Functions (Opcional)

- Desarrollar y desplegar funciones con la CLI de Supabase o CI/CD.
- Gestionar secretos de funciones desde el panel (sin commitearlos).
- Exponer solo endpoints necesarios y validar autenticación/roles en cada función.

---

## Notificaciones y Email (Genérico)

- Integrar un proveedor (p. ej., Resend, SES, SendGrid) con claves como secretos.
- Para pruebas, usar entornos sandbox del proveedor o cuentas de prueba, sin exponer claves.

---

## Observabilidad

- Revisar logs en Supabase (Auth, DB, Storage, Functions) desde el panel.
- Configurar alertas (si el plan lo permite) y métricas básicas en tu CI/CD.

---

## Referencias

- Panel de Supabase Cloud: `https://app.supabase.com` (inicia sesión y selecciona tu proyecto)
- Documentación: `https://supabase.com/docs`

---

## Notas

- Este documento evita direcciones IP, puertos locales y credenciales reales.
- Si necesitas la configuración local histórica, consúltala en una rama de backup fuera del flujo principal (no recomendada para el proyecto actual).
