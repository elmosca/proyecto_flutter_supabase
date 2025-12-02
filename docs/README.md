# 📚 Documentación del Sistema TFG

## 🎯 Propósito

Este directorio contiene toda la documentación esencial para entender, configurar y desarrollar el Sistema de Seguimiento de Proyectos TFG.

---

## 📖 Guías Principales

La documentación está organizada en 4 guías principales que cubren todos los aspectos del proyecto:

| Guía | Descripción | Contenido |
| :--- | :--- | :--- |
| **[01_ARQUITECTURA.md](01_ARQUITECTURA.md)** | Arquitectura y especificación funcional | Roles, entidades, flujo de trabajo, stack tecnológico |
| **[02_BASE_DE_DATOS.md](02_BASE_DE_DATOS.md)** | Modelo de datos y migraciones | Esquema de base de datos, RLS, migraciones SQL |
| **[03_GUIA_DESARROLLO.md](03_GUIA_DESARROLLO.md)** | Configuración y desarrollo | Setup del entorno, comandos esenciales, convenciones |
| **[04_ESTRUCTURA_CODIGO.md](04_ESTRUCTURA_CODIGO.md)** | Estructura del código | Organización del frontend, BLoCs, Services, Models |

---

## 🗄️ Migraciones de Base de Datos

Todas las migraciones SQL se encuentran en el directorio `base_datos/migraciones/`:

- **40+ archivos SQL** con el esquema completo de la base de datos
- **Scripts de rollback** para revertir cambios si es necesario
- **Índice de migraciones** en `base_datos/migraciones/INDICE_MIGRACIONES.md`

**Importante**: Las migraciones deben ejecutarse en orden cronológico en el SQL Editor de Supabase Cloud.

---

## 🚀 Inicio Rápido para Nuevos Desarrolladores

1. **Leer** `01_ARQUITECTURA.md` para entender el sistema
2. **Configurar** el entorno siguiendo `03_GUIA_DESARROLLO.md`
3. **Aplicar** las migraciones desde `base_datos/migraciones/`
4. **Explorar** la estructura del código en `04_ESTRUCTURA_CODIGO.md`
5. **Consultar** `02_BASE_DE_DATOS.md` cuando trabajes con la base de datos

---

## 📋 Estructura del Directorio

```
docs/
├── README.md                    # Este archivo - Índice principal
├── 01_ARQUITECTURA.md          # Arquitectura y especificación funcional
├── 02_BASE_DE_DATOS.md         # Modelo de datos y migraciones
├── 03_GUIA_DESARROLLO.md       # Configuración y desarrollo
├── 04_ESTRUCTURA_CODIGO.md     # Estructura del código
└── base_datos/
    └── migraciones/             # Todas las migraciones SQL
        ├── *.sql               # Archivos de migración
        ├── INDICE_MIGRACIONES.md
        └── README_RLS_MIGRATIONS.md
```

---

## 🎯 Recomendaciones de Lectura por Rol

### Para Desarrolladores Backend:
1. `02_BASE_DE_DATOS.md` - Modelo de datos y migraciones
2. `01_ARQUITECTURA.md` - Especificaciones funcionales

### Para Desarrolladores Frontend:
1. `03_GUIA_DESARROLLO.md` - Configuración del entorno
2. `04_ESTRUCTURA_CODIGO.md` - Estructura del código
3. `01_ARQUITECTURA.md` - Entender el dominio

### Para Arquitectos:
1. `01_ARQUITECTURA.md` - Arquitectura completa
2. `02_BASE_DE_DATOS.md` - Modelo de datos
3. `04_ESTRUCTURA_CODIGO.md` - Organización del código

---

## ✅ Estado de la Documentación

- ✅ **4 guías principales** completas y actualizadas
- ✅ **40+ migraciones SQL** documentadas y listas para usar
- ✅ **Estructura limpia** y fácil de navegar
- ✅ **Lista para wiki** y nuevos desarrolladores

---

**Última actualización**: Diciembre 2025  
**Versión**: 2.0 (Documentación consolidada)
