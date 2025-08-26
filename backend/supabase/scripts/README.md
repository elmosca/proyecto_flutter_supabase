# 📜 Scripts - Backend Supabase

Este directorio contiene scripts de utilidad para el mantenimiento y verificación del sistema.

## 📁 Archivos

### `verify_tables.sql`
Script de verificación de tablas y estructura de la base de datos.
- Verifica la existencia de todas las tablas
- Cuenta registros en tablas principales
- Valida la estructura del esquema
- Útil para verificar migraciones

## 🚀 Uso

```bash
# Verificar estructura de la base de datos
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/verify_tables.sql
```

## 📝 Notas

- Este script es útil para verificar que las migraciones se aplicaron correctamente
- Proporciona información sobre el estado de la base de datos
- Es útil para debugging y mantenimiento
- Se puede ejecutar después de aplicar migraciones
