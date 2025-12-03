# 🚀 EMPIEZA AQUÍ - Configuración de Wiki

```
███████╗████████╗ █████╗ ██████╗ ████████╗    ██╗  ██╗███████╗██████╗ ███████╗
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝    ██║  ██║██╔════╝██╔══██╗██╔════╝
███████╗   ██║   ███████║██████╔╝   ██║       ███████║█████╗  ██████╔╝█████╗  
╚════██║   ██║   ██╔══██║██╔══██╗   ██║       ██╔══██║██╔══╝  ██╔══██╗██╔══╝  
███████║   ██║   ██║  ██║██║  ██║   ██║       ██║  ██║███████╗██║  ██║███████╗
╚══════╝   ╚══╝   ╚══╝  ╚══╝╚══╝    ╚══╝       ╚══╝  ╚══╝╚══════╝╚══╝  ╚══╝╚══════╝
```

## 👋 ¡Hola!

Estás a punto de configurar una **wiki profesional** para tu proyecto.

---

## ⚡ Opción Rápida (5 minutos)

¿Tienes prisa? Sigue estos 3 pasos:

### 1️⃣ Habilita la Wiki en GitHub

```
GitHub → Tu Repo → Settings → Features → ✅ Wikis
```

### 2️⃣ Configura el Script

Edita `publicar_wiki.sh` líneas 19-20:

```bash
REPO_USER="tu-usuario"
REPO_NAME="tu-repo"
```

Busca y reemplaza en todos los `.md`:
```
USUARIO/REPO  →  tu-usuario/tu-repo
```

### 3️⃣ Ejecuta el Script

```bash
cd wiki_setup
chmod +x publicar_wiki.sh
./publicar_wiki.sh
```

**✅ ¡Listo!** Tu wiki está en:  
`https://github.com/tu-usuario/tu-repo/wiki`

📖 **Detalles completos:** [INSTRUCCIONES_RAPIDAS.md](INSTRUCCIONES_RAPIDAS.md)

---

## 📚 Opción Completa (15 minutos)

¿Quieres entender todo? Lee la documentación:

1. 📖 **[README.md](README.md)** - Guía completa con todos los detalles
2. 📦 **[RESUMEN_ARCHIVOS.md](RESUMEN_ARCHIVOS.md)** - Qué hace cada archivo
3. 📋 **[INDEX.md](INDEX.md)** - Índice visual de todo el contenido

---

## 🗂️ Estructura de Archivos

```
wiki_setup/
│
├── 🚀 START_HERE.md              ← Estás aquí
│
├── 📖 Documentación
│   ├── INSTRUCCIONES_RAPIDAS.md  ← Lee esto primero
│   ├── README.md                 ← Guía completa
│   ├── RESUMEN_ARCHIVOS.md       ← Resumen de archivos
│   └── INDEX.md                  ← Índice visual
│
├── 🤖 Script
│   └── publicar_wiki.sh          ← Script automático
│
└── 📄 Contenido de la Wiki
    ├── Home.md                   ← Página principal
    ├── _Sidebar.md               ← Menú lateral
    ├── _Footer.md                ← Pie de página
    ├── FAQ.md                    ← Preguntas frecuentes
    └── Guia-Inicio-Rapido.md     ← Inicio rápido
```

---

## 🎯 ¿Qué Tipo de Usuario Eres?

### 🔰 Nuevo / Con Prisa
```
➡️ Lee: INSTRUCCIONES_RAPIDAS.md
⏱️  5 minutos
```

### 📚 Quiero Entender Todo
```
➡️ Lee: README.md
⏱️  15 minutos
```

### 🤔 Solo Quiero una Vista General
```
➡️ Lee: RESUMEN_ARCHIVOS.md
⏱️  3 minutos
```

### 🗺️ Necesito un Mapa Visual
```
➡️ Lee: INDEX.md
⏱️  2 minutos
```

---

## 📊 ¿Qué Obtendrás?

Una wiki completa con:

```
✅ 11 páginas de documentación
✅ 3 guías de usuario (Estudiante, Tutor, Admin)
✅ 3 documentos técnicos
✅ 60+ preguntas frecuentes
✅ Navegación organizada
✅ Menú lateral
✅ Búsqueda integrada
✅ Responsive (funciona en móvil)
```

**Total:** ~4,900 líneas | ~33,500 palabras

---

## ⚙️ Prerequisitos

Asegúrate de tener:

- [x] Cuenta de GitHub
- [x] Repositorio creado
- [x] Git instalado
- [x] Permisos de escritura
- [ ] **Wiki habilitada en GitHub** ← ¡Hazlo ahora!

---

## 🎬 Primer Paso

### Para Usuarios Rápidos

**➡️ [INSTRUCCIONES_RAPIDAS.md](INSTRUCCIONES_RAPIDAS.md)**

### Para Usuarios Detallistas

**➡️ [README.md](README.md)**

---

## 🆘 ¿Problemas?

| Si tienes... | Lee... |
|--------------|--------|
| 🔴 Error al ejecutar script | [README.md - Solución de Problemas](README.md#solución-de-problemas) |
| 🟠 No entiendo qué hace un archivo | [RESUMEN_ARCHIVOS.md](RESUMEN_ARCHIVOS.md) |
| 🟡 No sé cómo usar la wiki | [Guia-Inicio-Rapido.md](Guia-Inicio-Rapido.md) |
| 🟢 Quiero personalizar | [README.md - Personalización](README.md#mantenimiento) |

---

## 💡 Consejo Profesional

```
┌─────────────────────────────────────────┐
│                                         │
│  💡 Lee INSTRUCCIONES_RAPIDAS.md       │
│     y tendrás tu wiki en 5 minutos     │
│                                         │
│  📚 Luego explora los otros docs       │
│     cuando tengas más tiempo           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📈 Progreso

```
Tu progreso actual:

┌──────────────────────────────────────┐
│ [████░░░░░░░░░░░░░░░░░░░░] 20%     │
│                                      │
│ ✅ Archivos descargados              │
│ ⏳ Configuración pendiente           │
│ ⏳ Publicación pendiente             │
│ ⏳ Testing pendiente                 │
└──────────────────────────────────────┘
```

**Siguiente paso:** Leer instrucciones

---

## 🎉 ¡Adelante!

```
      📚
     /│\
    / │ \
   📖 │ 📖
  /   │   \
 📄  📄  📄

 ¡Tu wiki te espera!
```

**➡️ [EMPEZAR AHORA](INSTRUCCIONES_RAPIDAS.md)**

---

**⏱️ Tiempo estimado**: 5-15 minutos según tu experiencia  
**🎯 Dificultad**: Baja  
**💪 Nivel requerido**: Principiante  
**🆘 Soporte**: Documentación completa incluida

---

**🚀 ¡Vamos!**

[📖 INSTRUCCIONES_RAPIDAS.md](INSTRUCCIONES_RAPIDAS.md) | [📚 README.md](README.md) | [📋 INDEX.md](INDEX.md)

