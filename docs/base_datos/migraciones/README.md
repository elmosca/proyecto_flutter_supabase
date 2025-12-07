# Migraciones de Base de Datos

Este directorio contiene los scripts SQL de migración de la base de datos del Sistema TFG.

## Instalación

Para instalar el esquema completo de la base de datos, ejecuta el archivo **`schema_completo.sql`** en el **SQL Editor de Supabase Cloud**.

Este archivo contiene el estado final consolidado de todas las migraciones y puede ejecutarse de forma idempotente.

## Estructura

```
migraciones/
├── schema_completo.sql          # Archivo principal - Estado final consolidado
├── README.md                    # Este archivo
├── historico/                   # Migraciones originales (referencia)
│   ├── 202*.sql                # Migraciones históricas
│   └── rollbacks/              # Scripts de rollback
└── utilidades/                 # Scripts auxiliares
    └── verificar_estado_rls.sql
```

## Contenido

- **`schema_completo.sql`**: Archivo único que contiene todo el esquema consolidado (recomendado para instalación inicial)
- **`historico/`**: Migraciones originales organizadas cronológicamente (para referencia y desarrollo)
- **`historico/rollbacks/`**: Scripts de rollback para revertir cambios específicos
- **`utilidades/`**: Scripts de verificación y utilidades auxiliares

---

**Nota**: Para información completa sobre el modelo de datos, entidades, relaciones y seguridad, consulta [`docs/02_BASE_DE_DATOS.md`](../../02_BASE_DE_DATOS.md).

