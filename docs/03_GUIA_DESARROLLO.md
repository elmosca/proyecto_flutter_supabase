# 3. GUÍA DE DESARROLLO Y CONFIGURACIÓN

Este documento consolida las guías de configuración del entorno, los comandos esenciales y las convenciones de desarrollo para facilitar la continuación del proyecto.

## 3.1. Configuración del Entorno (Frontend)

El proyecto utiliza **Flutter** y **Supabase**.

### Prerrequisitos

*   **Flutter SDK** (versión 3.0+).
*   **Git**.
*   **Supabase Cloud Project** (con las migraciones SQL aplicadas).

### Pasos de Inicio Rápido

1.  **Clonar el Repositorio:**
    ```bash
    git clone https://github.com/elmosca/proyecto_flutter_supabase.git
    cd proyecto_flutter_supabase/frontend
    ```

2.  **Instalar Dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Configurar Variables de Entorno:**
    El proyecto requiere la URL y la clave anónima de tu proyecto Supabase. Estas se inyectan en tiempo de ejecución (o a través de un archivo `.env` si se usa un paquete de gestión de entorno).

    **Ejemplo de ejecución con `dart-define`:**
    ```bash
    flutter run -d chrome \
      --dart-define=SUPABASE_URL=https://<TU-PROYECTO>.supabase.co \
      --dart-define=SUPABASE_ANON_KEY=<TU_ANON_KEY>
    ```

4.  **Generar Código (Modelos):**
    Si se modifican los modelos de datos (`@JsonSerializable`), es necesario regenerar el código:
    ```bash
    flutter packages pub run build_runner build
    ```

5.  **Ejecutar la Aplicación:**
    ```bash
    flutter run -d chrome  # Para desarrollo web rápido
    flutter run -d android # Para desarrollo móvil
    ```

## 3.2. Comandos Esenciales

| Tarea | Comando |
| :--- | :--- |
| **Instalar Dependencias** | `flutter pub get` |
| **Generar Código** | `flutter packages pub run build_runner build` |
| **Análisis de Código** | `flutter analyze` |
| **Formatear Código** | `flutter format .` |
| **Ejecutar Tests** | `flutter test` |
| **Build Web (Producción)** | `flutter build web --release` |

## 3.3. Convenciones de Desarrollo

*   **Gestión de Estado:** Se utiliza el patrón **BLoC** para separar la lógica de negocio de la interfaz de usuario.
*   **Estructura de Carpetas:**
    *   `lib/blocs/`: Lógica de negocio y gestión de estado.
    *   `lib/services/`: Acceso a datos (Supabase) y lógica de negocio pura.
    *   `lib/models/`: Estructuras de datos y serialización JSON.
    *   `lib/screens/`: Vistas principales.
*   **Seguridad:** Nunca incluir claves sensibles directamente en el código fuente. Utilizar `dart-define` o gestores de secretos.

## 3.4. Documentación Adicional

*   **Migraciones de Base de Datos:** Ejecuta `docs/base_datos/migraciones/schema_completo.sql` para instalar el esquema completo. Las migraciones históricas están en `historico/` para referencia.
*   **Edge Functions:** Las Edge Functions de Supabase se documentan en el código fuente y en el dashboard de Supabase.

---
*Este documento consolida la información de `docs/desarrollo/01-configuracion/guia_inicio_frontend.md` y otros archivos de desarrollo.*
