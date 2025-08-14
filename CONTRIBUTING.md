# Guía de Contribución

Esta guía define el flujo de trabajo de ramas, convenciones y buenas prácticas para colaborar en este monorepo (Flutter + Supabase).

## Estrategia de ramas (GitFlow adaptado)

- `main`: rama estable de producción. Solo se fusiona desde `release/*` y `hotfix/*`. Etiquetada con versiones `vX.Y.Z`.
- `develop`: rama de integración. Base para trabajo diario y pruebas de conjunto.
- `feature/<slug>`: ramas de funcionalidad. Se crean desde `develop` y se fusionan a `develop` mediante Pull Request (PR).
- `release/<X.Y.Z>`: ramas de estabilización para preparar una versión. Se crean desde `develop` y se fusionan a `main` (con etiqueta `vX.Y.Z`) y de vuelta a `develop`.
- `hotfix/<X.Y.Z+hotfix>`: correcciones urgentes en producción. Se crean desde `main` y se fusionan a `main` (tag), y de vuelta a `develop`.

### Convenciones de nombres
- Usar kebab-case y descriptores claros: `feature/kanban-drag-drop`, `hotfix/1.0.1-crash-inicio`, `release/1.1.0`.
- Commits con Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.

### Flujo recomendado
1. Actualiza referencias: `git fetch --all --prune`.
2. Crea una rama de feature desde `develop`:
   - `git checkout develop && git pull --ff-only`
   - `git checkout -b feature/<slug>`
3. Commits pequeños, con pruebas y documentación cuando aplique.
4. Abre PR hacia `develop` y solicita revisión.
5. Integra vía `git merge --no-ff` o rebase según la política del repo.
6. Tras aprobar, mergea y elimina la rama de feature.

### Lanzamientos
- Crea `release/<X.Y.Z>` desde `develop`.
- Solo correcciones y ajustes de versión/changelog.
- Fusiona en `main`, etiqueta `vX.Y.Z`, despliega.
- Fusiona cambios de `release` de vuelta a `develop`.

### Hotfixes
- Crea `hotfix/<X.Y.Z+hotfix>` desde `main`.
- Corrige, etiqueta en `main` y fusiona a `develop`.

## Reglas de PR
- Al menos 1 revisor.
- CI verde (build, lint, pruebas si aplican).
- Checklist:
  - Migraciones en `backend/supabase/migrations` cuando cambie el esquema.
  - RLS habilitado y políticas mínimas necesarias.
  - Sin secretos en el código; `.env` locales.
  - Documentación actualizada (README/Docs) si aplica.

## Versionado
- SemVer: `MAJOR.MINOR.PATCH`.
- Etiquetas en `main`: `vX.Y.Z`.

