# 🧪 Tests - Backend Supabase

Este directorio contiene los scripts de prueba para verificar el funcionamiento del sistema.

## 📁 Archivos

### `test_rls_functions.sql`
Script de prueba para verificar las funciones RLS (Row Level Security).
- Prueba funciones sin JWT
- Prueba funciones con diferentes roles (admin, tutor, student)
- Verifica permisos específicos

### `test_complete_system.sql`
Script de prueba completa del sistema de autenticación y RLS.
- Pruebas de autenticación
- Pruebas de JWT claims
- Pruebas de políticas RLS
- Verificación final del sistema

## 🚀 Uso

```bash
# Ejecutar pruebas RLS
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f tests/test_rls_functions.sql

# Ejecutar pruebas completas del sistema
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f tests/test_complete_system.sql
```

## 📝 Notas

- Estos tests verifican el funcionamiento de las políticas RLS
- Simulan diferentes roles de usuario
- Validan el sistema de autenticación
- Son útiles para debugging y verificación
