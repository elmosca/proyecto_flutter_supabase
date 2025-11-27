# ⚡ Instrucciones Rápidas - Configurar Wiki en 5 Minutos

Esta es la guía más rápida para tener tu wiki funcionando.

---

## 🎯 Paso 1: Habilitar Wiki en GitHub (1 minuto)

```
1. Ve a tu repositorio en GitHub
2. Clic en "Settings" (⚙️)
3. Scroll hasta "Features"
4. Marca ✅ "Wikis"
5. Guarda
```

---

## ⚙️ Paso 2: Configurar Script (2 minutos)

### 2.1 Edita `publicar_wiki.sh`

Busca las líneas 19-20 y reemplaza:

```bash
REPO_USER="TU_USUARIO_GITHUB"    # ← PON TU USUARIO AQUÍ
REPO_NAME="TU_REPOSITORIO"       # ← PON TU REPO AQUÍ
```

**Ejemplo real:**
```bash
REPO_USER="juanperez"
REPO_NAME="proyecto_flutter_supabase"
```

---

### 2.2 Actualiza Enlaces

**Busca y reemplaza en TODOS los archivos `.md`:**

```
Buscar:     USUARIO/REPO
Reemplazar: tu-usuario/tu-repo
```

**Archivos a actualizar:**
- ✅ `Home.md`
- ✅ `_Sidebar.md`
- ✅ `_Footer.md`
- ✅ `FAQ.md`
- ✅ `Guia-Inicio-Rapido.md`

**En VSCode:**
1. `Ctrl+Shift+H` (Windows) o `Cmd+Shift+H` (Mac)
2. Buscar: `USUARIO/REPO`
3. Reemplazar: `tuusuario/turepo`
4. Clic en "Reemplazar Todo en Archivos"

---

## 🚀 Paso 3: Publicar (2 minutos)

### En Linux/Mac:

```bash
cd wiki_setup
chmod +x publicar_wiki.sh
./publicar_wiki.sh
```

### En Windows (Git Bash):

```bash
cd wiki_setup
bash publicar_wiki.sh
```

### En Windows (PowerShell):

```powershell
cd wiki_setup
bash publicar_wiki.sh
```

---

## ✅ Verificación

Si todo salió bien, verás:

```
================================================
  ✅ Wiki Actualizada Exitosamente
================================================

📚 Tu wiki está disponible en:
https://github.com/TUUSUARIO/TUREPO/wiki
```

---

## 🌐 Accede a Tu Wiki

Abre en tu navegador:

```
https://github.com/TUUSUARIO/TUREPO/wiki
```

**Deberías ver:**
- 🏠 Página principal con enlaces por rol
- 📚 Menú lateral con navegación
- 📖 Todas las guías disponibles

---

## 🔧 Si Algo Falla

### Error: "Permission denied"
```bash
chmod +x publicar_wiki.sh
```

### Error: "Repository not found"
→ Revisa que `REPO_USER` y `REPO_NAME` sean correctos

### Error: "Wiki not enabled"
→ Ve a Settings → Features → Marca "Wikis"

### Otros problemas
→ Lee `README.md` completo en esta carpeta

---

## 📋 Checklist Rápido

Marca lo que hayas hecho:

- [ ] Wiki habilitada en GitHub
- [ ] `publicar_wiki.sh` editado con mi info
- [ ] Enlaces USUARIO/REPO reemplazados
- [ ] Script ejecutado exitosamente
- [ ] Wiki verificada en navegador
- [ ] ✅ **¡LISTO!**

---

## 🎉 ¡Éxito!

Tu wiki está configurada. Ahora:

1. **Comparte el enlace** con tu equipo
2. **Actualiza cuando necesites**:
   ```bash
   cd wiki_setup
   ./publicar_wiki.sh
   ```

---

**⏱️ Tiempo total**: ~5 minutos  
**🆘 Ayuda**: Ver `README.md` completo

