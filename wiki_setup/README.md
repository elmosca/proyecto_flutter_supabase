# 📚 Configuración de GitHub Wiki - Guía Paso a Paso

Esta carpeta contiene todos los archivos necesarios para configurar y publicar la wiki de documentación del proyecto.

---

## 📋 Tabla de Contenidos

1. [Prerequisitos](#prerequisitos)
2. [Configuración Inicial](#configuración-inicial)
3. [Publicación Automática](#publicación-automática)
4. [Publicación Manual](#publicación-manual)
5. [Mantenimiento](#mantenimiento)
6. [Solución de Problemas](#solución-de-problemas)

---

## ✅ Prerequisitos

Antes de empezar, asegúrate de tener:

- [ ] Cuenta de GitHub
- [ ] Repositorio del proyecto creado
- [ ] Git instalado en tu computadora
- [ ] Permisos de escritura en el repositorio
- [ ] Wiki habilitada en el repositorio (ver abajo)

### Habilitar la Wiki en GitHub

1. Ve a tu repositorio en GitHub
2. Haz clic en **Settings** (⚙️)
3. Scroll hasta la sección **"Features"**
4. Marca la casilla **"Wikis"** ✅
5. Guarda los cambios

![Habilitar Wiki](https://docs.github.com/assets/cb-47699/mw-1440/images/help/repository/repo-settings-features.webp)

---

## 🚀 Configuración Inicial

### Paso 1: Edita el Script de Publicación

Abre el archivo `publicar_wiki.sh` y reemplaza estos valores:

```bash
# Líneas 19-20
REPO_USER="TU_USUARIO_GITHUB"      # ← Cambia por tu usuario
REPO_NAME="TU_REPOSITORIO"         # ← Cambia por tu repo
```

**Ejemplo:**
```bash
REPO_USER="juanperez"
REPO_NAME="proyecto_flutter_supabase"
```

---

### Paso 2: Da Permisos de Ejecución al Script

#### En Linux/Mac:
```bash
chmod +x publicar_wiki.sh
```

#### En Windows:
Usa Git Bash o PowerShell para ejecutar el script.

---

### Paso 3: Actualiza los Enlaces en los Archivos

Busca y reemplaza en todos los archivos `.md`:

```
USUARIO/REPO
```

Por tu información real, ejemplo:
```
juanperez/proyecto_flutter_supabase
```

**Archivos a actualizar:**
- `Home.md`
- `_Sidebar.md`
- `_Footer.md`
- `FAQ.md`
- `Guia-Inicio-Rapido.md`

**Buscar y reemplazar en VSCode:**
1. Presiona `Ctrl+Shift+H` (Windows/Linux) o `Cmd+Shift+H` (Mac)
2. Buscar: `USUARIO/REPO`
3. Reemplazar con: `tu-usuario/tu-repo`
4. Haz clic en "Reemplazar todo"

---

## 🤖 Publicación Automática (Recomendado)

### Opción A: Usando el Script Bash

```bash
# 1. Ve a la carpeta wiki_setup
cd wiki_setup

# 2. Ejecuta el script
./publicar_wiki.sh
```

El script hará todo automáticamente:
- ✅ Verificará prerequisitos
- ✅ Clonará/actualizará la wiki
- ✅ Copiará todos los archivos
- ✅ Hará commit y push a GitHub

**Salida esperada:**
```
================================================
  📚 Publicador de Wiki de GitHub
  Sistema de Seguimiento de Proyectos TFCGS
================================================

➤ Verificando prerequisitos...
✔ Prerequisitos verificados

➤ Clonando o actualizando wiki...
✔ Wiki lista para actualizar

➤ Copiando archivos de estructura...
✔ ✓ Home.md copiado
✔ ✓ _Sidebar.md copiado
✔ ✓ _Footer.md copiado
...

➤ Publicando cambios a GitHub...
✔ ¡Cambios publicados exitosamente!

================================================
  ✅ Wiki Actualizada Exitosamente
================================================
```

---

### Opción B: GitHub Action (Automatización Total)

Si quieres que la wiki se actualice automáticamente con cada push, usa GitHub Actions.

**Archivo:** `.github/workflows/update-wiki.yml`

```yaml
name: Actualizar Wiki

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'
      - 'wiki_setup/**'

jobs:
  update-wiki:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout código
        uses: actions/checkout@v3
        
      - name: Configurar Git
        run: |
          git config --global user.name 'GitHub Action'
          git config --global user.email 'action@github.com'
      
      - name: Publicar a Wiki
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          cd wiki_setup
          chmod +x publicar_wiki.sh
          ./publicar_wiki.sh
```

---

## 📝 Publicación Manual

Si prefieres hacerlo manualmente:

### 1. Clona la Wiki

```bash
# Reemplaza con tu info
git clone https://github.com/USUARIO/REPO.wiki.git wiki_temp
cd wiki_temp
```

### 2. Copia los Archivos

```bash
# Desde la carpeta wiki_temp

# Estructura de la wiki
cp ../wiki_setup/Home.md Home.md
cp ../wiki_setup/_Sidebar.md _Sidebar.md
cp ../wiki_setup/_Footer.md _Footer.md
cp ../wiki_setup/FAQ.md FAQ.md
cp ../wiki_setup/Guia-Inicio-Rapido.md Guia-Inicio-Rapido.md

# Guías de usuario
cp ../docs/guias_usuario/guia_estudiante.md Guia-Estudiantes.md
cp ../docs/guias_usuario/guia_tutor.md Guia-Tutores.md
cp ../docs/guias_usuario/guia_administrador.md Guia-Administradores.md

# Documentación técnica
cp ../docs/arquitectura/login.md Arquitectura-Autenticacion.md
cp ../docs/arquitectura/registro_usuarios_por_roles.md Registro-Usuarios.md
cp ../docs/despliegue/guia_despliegue_vps_debian.md Guia-Despliegue.md
```

### 3. Publica los Cambios

```bash
git add .
git commit -m "📚 Actualizar documentación"
git push origin master
```

---

## 🔄 Mantenimiento

### Actualizar la Wiki

Cada vez que hagas cambios en la documentación:

```bash
cd wiki_setup
./publicar_wiki.sh
```

O si tienes GitHub Action configurado, simplemente haz push:

```bash
git add docs/
git commit -m "Actualizar documentación"
git push
```

La wiki se actualizará automáticamente.

---

### Agregar Nuevas Páginas

1. **Crea el archivo** en `wiki_setup/` o en `docs/`

2. **Actualiza `_Sidebar.md`** para agregar el enlace:
```markdown
- [Nueva Página](Nueva-Pagina)
```

3. **Actualiza `publicar_wiki.sh`** si es necesario:
```bash
# En la función copy_technical_docs() o create_new_function()
if [ -f "${DOCS_DIR}/ruta/al/archivo.md" ]; then
    cp "${DOCS_DIR}/ruta/al/archivo.md" Nueva-Pagina.md
    print_success "✓ Nueva Página copiada"
fi
```

4. **Publica:**
```bash
./publicar_wiki.sh
```

---

## 🔧 Solución de Problemas

### Error: "Permission denied"

**Problema:** No tienes permisos para escribir en el repositorio.

**Solución:**
1. Verifica que eres colaborador del repositorio
2. Configura SSH keys: https://docs.github.com/es/authentication/connecting-to-github-with-ssh

---

### Error: "Wiki not enabled"

**Problema:** La wiki no está habilitada en el repositorio.

**Solución:**
1. Ve a Settings → Features
2. Marca "Wikis" ✅
3. Intenta de nuevo

---

### Error: "fatal: repository not found"

**Problema:** La URL del repositorio es incorrecta.

**Solución:**
1. Verifica `REPO_USER` y `REPO_NAME` en el script
2. Asegúrate de que el repositorio existe
3. Verifica que tienes acceso

---

### Los cambios no aparecen

**Problema:** Publicaste pero no ves los cambios.

**Solución:**
1. Espera 1-2 minutos (propagación)
2. Refresca la página (Ctrl+F5)
3. Verifica que el push fue exitoso:
```bash
cd wiki_temp
git log
```

---

### Conflictos de Git

**Problema:** Alguien más editó la wiki.

**Solución:**
```bash
cd wiki_temp
git pull origin master
# Resuelve conflictos
git add .
git commit -m "Resolver conflictos"
git push origin master
```

---

## 📊 Estructura de Archivos

```
wiki_setup/
├── README.md                    # ← Este archivo
├── publicar_wiki.sh             # Script de publicación automática
├── Home.md                      # Página principal de la wiki
├── _Sidebar.md                  # Menú lateral
├── _Footer.md                   # Pie de página
├── FAQ.md                       # Preguntas frecuentes
├── Guia-Inicio-Rapido.md        # Inicio rápido para nuevos usuarios
└── wiki_temp/                   # ← Creado automáticamente (git ignore)
```

---

## 🎯 Checklist de Configuración

Marca cada paso cuando lo completes:

- [ ] Wiki habilitada en GitHub
- [ ] Script `publicar_wiki.sh` configurado con tu repo
- [ ] Enlaces actualizados (USUARIO/REPO → tu info)
- [ ] Permisos de ejecución dados al script
- [ ] Primera publicación ejecutada exitosamente
- [ ] Wiki verificada en GitHub
- [ ] Enlaces probados desde la aplicación Flutter

---

## 📞 Soporte

¿Problemas? Consulta:

1. [Documentación oficial de GitHub Wiki](https://docs.github.com/es/communities/documenting-your-project-with-wikis)
2. [FAQ de este proyecto](FAQ.md)
3. Abre un issue en el repositorio

---

## 📝 Notas Adicionales

### Archivos Especiales de la Wiki

- **`Home.md`**: Página principal (obligatorio)
- **`_Sidebar.md`**: Menú lateral (opcional pero recomendado)
- **`_Footer.md`**: Pie de página (opcional)

### Sintaxis de Enlaces

En la wiki de GitHub:
```markdown
[Texto del enlace](Nombre-De-La-Pagina)
```

No incluyas `.md` en los enlaces.

### Imágenes

Para agregar imágenes a la wiki:

1. **Opción 1:** Súbelas al repositorio en `docs/images/`
2. **Opción 2:** Usa enlaces externos (GitHub, Imgur, etc.)

```markdown
![Alt text](https://github.com/user/repo/raw/main/docs/images/imagen.png)
```

---

## 🎉 ¡Listo!

Tu wiki ahora está configurada y lista para usar. Los usuarios podrán acceder a toda la documentación desde:

**`https://github.com/TU_USUARIO/TU_REPO/wiki`**

---

**📅 Última actualización**: Diciembre 2025  
**✍️ Autor**: Juan Antonio Francés Pérez  
**📧 Contacto**: jualas@jualas.es  
**📦 Versión**: 1.0

