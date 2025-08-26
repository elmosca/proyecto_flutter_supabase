# 🔧 Fixes - Backend Supabase

Este directorio contiene scripts de corrección para problemas identificados durante el desarrollo.

## 📁 Archivos

### `fix_rls_functions.sql`
Corrección de variables ambiguas en funciones RLS.
- Corrige `is_project_student()` con variable ambigua
- Corrige `is_anteproject_author()` con variable ambigua
- Resuelve conflictos de nombres de parámetros

### `fix_auth_functions.sql`
Corrección de funciones de autenticación.
- Corrige `simulate_login()` con variables ambiguas
- Actualiza parámetros para evitar conflictos
- Mejora la claridad del código

### `fix_simulate_login.sql`
Corrección específica de la función de login.
- Recrea la función `simulate_login()` con parámetros correctos
- Resuelve problemas de variables ambiguas
- Optimiza la función para pruebas

## 🚀 Uso

```bash
# Aplicar correcciones RLS
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f fixes/fix_rls_functions.sql

# Aplicar correcciones de autenticación
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f fixes/fix_auth_functions.sql

# Corregir función de login
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f fixes/fix_simulate_login.sql
```

## 📝 Notas

- Estos scripts corrigen problemas identificados durante el desarrollo
- Se aplican después de las migraciones principales
- Son útiles para debugging y mantenimiento
- Documentan problemas y soluciones encontradas
