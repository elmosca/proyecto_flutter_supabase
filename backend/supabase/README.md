# 🗄️ Backend Supabase - Sistema TFG

## 📋 Estado Actual

### ✅ **Completado:**
- **Modelo de datos completo**: 19 tablas principales con todas las relaciones
- **Migraciones aplicadas**: 5 migraciones con esquema, triggers, datos iniciales, RLS y Auth
- **Sistema de seguridad**: 54 políticas RLS implementadas
- **Autenticación**: JWT con roles configurado
- **Funcionalidades avanzadas**: Sistema de notificaciones, auditoría, validaciones
- **Datos de ejemplo**: Usuarios, anteproyectos, proyectos y tareas de demostración

### 🔄 **Pendiente:**
- **API REST**: Endpoints para el frontend
- **Frontend**: Interfaz de usuario con Flutter

## 🏗️ Estructura del Proyecto

```
backend/supabase/
├── migrations/          # Migraciones de la base de datos
│   ├── 20240815000001_create_initial_schema.sql    # Esquema base
│   ├── 20240815000002_create_triggers_and_functions.sql  # Triggers y funciones
│   ├── 20240815000003_seed_initial_data.sql       # Datos iniciales
│   ├── 20240815000004_configure_rls_fixed.sql     # Configuración RLS
│   └── 20240815000005_configure_auth.sql          # Configuración Auth
├── tests/              # Scripts de prueba
│   ├── test_rls_functions.sql                     # Pruebas RLS
│   └── test_complete_system.sql                   # Pruebas completas
├── fixes/              # Scripts de corrección
│   ├── fix_rls_functions.sql                      # Correcciones RLS
│   ├── fix_auth_functions.sql                     # Correcciones Auth
│   └── fix_simulate_login.sql                     # Corrección login
├── scripts/            # Scripts de utilidad
│   └── verify_tables.sql                          # Verificación de tablas
├── config/             # Configuración de Supabase
├── functions/          # Supabase Edge Functions (APIs REST)
│   ├── approval-api/        # API de aprobación de anteproyectos
│   ├── anteprojects-api/    # API CRUD de anteproyectos
│   └── README.md           # Documentación de las APIs
├── seed/               # Datos iniciales
├── supabase/           # Configuración de Supabase CLI
├── README.md           # Este archivo
├── rls_setup_guide.md  # Guía de configuración RLS
└── verificacion_migraciones.md # Documentación de verificación
```

## 🚀 Comandos Útiles

### Iniciar Supabase Local
```bash
cd backend/supabase
supabase start
```

### Verificar Estado
```bash
supabase status
```

### Resetear Base de Datos
```bash
supabase db reset
```

### Aplicar Migraciones
```bash
supabase migration up
```

### Verificar Tablas
```bash
# Ejecutar script de verificación
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/verify_tables.sql
```

## 🚀 APIs REST (Edge Functions)

### Funciones implementadas:

1. **approval-api**: Gestión de aprobación de anteproyectos
   - Aprobar anteproyectos
   - Rechazar anteproyectos
   - Solicitar cambios

2. **anteprojects-api**: CRUD completo de anteproyectos
   - Listar anteproyectos por rol
   - Crear nuevos anteproyectos
   - Actualizar anteproyectos
   - Enviar para revisión

### Probar las APIs:
```bash
# Ejecutar script de pruebas completas
./tests/test_api_endpoints.sh

# O probar endpoints individuales
curl -X GET 'http://localhost:54321/functions/v1/anteprojects-api/' \
  -H "Authorization: Bearer $JWT_TOKEN"
```

📖 **Ver documentación completa**: `functions/README.md`

### Ejecutar Pruebas
```bash
# Pruebas RLS
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f tests/test_rls_functions.sql

# Pruebas completas del sistema
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f tests/test_complete_system.sql
```

### Aplicar Correcciones
```bash
# Correcciones RLS
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f fixes/fix_rls_functions.sql

# Correcciones de autenticación
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f fixes/fix_auth_functions.sql
```

## 📊 Modelo de Datos

### Tablas Principales:
1. **users** - Usuarios del sistema (admin, tutor, student)
2. **dam_objectives** - Objetivos del ciclo DAM
3. **anteprojects** - Anteproyectos de TFG
4. **projects** - Proyectos finales aprobados
5. **milestones** - Hitos del proyecto
6. **tasks** - Tareas del proyecto
7. **comments** - Comentarios en tareas
8. **files** - Archivos adjuntos
9. **notifications** - Sistema de notificaciones
10. **activity_log** - Registro de auditoría

### Relaciones Clave:
- Un anteproyecto genera un solo proyecto (1:1)
- Un proyecto puede tener múltiples estudiantes
- Las tareas se pueden generar automáticamente o manualmente
- Sistema de archivos polimórfico (tareas, comentarios, anteproyectos)

## 🔧 Funcionalidades Implementadas

### Triggers Automáticos:
- Actualización de `updated_at` en todas las tablas
- Validación de URLs de GitHub
- Validación de NRE solo para estudiantes
- Actualización de `last_activity_at` en proyectos
- Generación automática de versiones de archivos
- Sistema de notificaciones automáticas

### Funciones de Utilidad:
- `get_project_stats()` - Estadísticas de proyecto
- `get_tasks_by_status()` - Tareas agrupadas por estado (Kanban)
- `get_entity_files()` - Archivos de una entidad
- `create_notification()` - Crear notificaciones
- `log_activity()` - Registrar actividad

## 👥 Usuarios de Ejemplo

### Administrador:
- **Email**: admin@cifpcarlos3.es
- **Password**: admin123

### Tutores:
- **María García**: maria.garcia@cifpcarlos3.es (password: tutor123)
- **Carlos Rodríguez**: carlos.rodriguez@cifpcarlos3.es (password: tutor123)
- **Ana Martínez**: ana.martinez@cifpcarlos3.es (password: tutor123)

### Estudiantes:
- **Sofía Jiménez**: sofia.jimenez@alumno.cifpcarlos3.es (password: student123)
- **David Sánchez**: david.sanchez@alumno.cifpcarlos3.es (password: student123)
- **Juan Pérez**: juan.perez@alumno.cifpcarlos3.es (password: student123)

## 📈 Datos de Ejemplo

### Proyecto Activo:
- **Título**: "Desarrollo de una aplicación móvil para gestión de tareas académicas"
- **Estado**: En desarrollo
- **Estudiantes**: Sofía Jiménez (líder) y David Sánchez
- **Tutor**: María García
- **Tareas**: 13 tareas distribuidas en 4 milestones
- **Progreso**: 23% completado

### Anteproyectos:
- 1 anteproyecto aprobado (generó el proyecto activo)
- 1 anteproyecto en borrador

## 🔐 Seguridad

### Validaciones Implementadas:
- Solo estudiantes pueden tener NRE
- URLs de GitHub deben tener formato válido
- Relaciones 1:1 entre anteproyectos y proyectos
- Restricciones de integridad referencial

### Pendiente:
- Políticas RLS (Row Level Security)
- Autenticación con Supabase Auth
- Validación de permisos por rol

## 📝 Próximos Pasos

1. **Verificar migraciones**: Asegurar que todas las tablas se crearon correctamente
2. **Configurar RLS**: Implementar políticas de seguridad
3. **Crear API REST**: Endpoints para el frontend
4. **Integrar autenticación**: Conectar con Supabase Auth
5. **Configurar storage**: Para archivos y documentos
6. **Implementar real-time**: Para notificaciones en tiempo real

## 🐛 Solución de Problemas

### Error: "Address already in use"
```bash
# Detener todos los contenedores
supabase stop

# Reiniciar
supabase start
```

### Error: "Cannot find project ref"
```bash
# Para desarrollo local, usar:
supabase db reset
supabase migration up
```

### Verificar si las tablas existen:
```bash
# Usar el script de verificación
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f verify_tables.sql
```

## 📚 Documentación Adicional

- [Documentación oficial de Supabase](https://supabase.com/docs)
- [Guía de migraciones](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [Políticas RLS](https://supabase.com/docs/guides/auth/row-level-security)
- [API REST](https://supabase.com/docs/guides/api)
