# Quickstart: Flutter Web Chat con Firebase y gen_ui

**Feature**: 001-firebase-genui-chat  
**Date**: 2026-05-08

Esta guía cubre la configuración del entorno desde cero hasta tener la app corriendo localmente.

---

## Prerrequisitos

| Herramienta | Versión mínima | Verificar |
|-------------|---------------|-----------|
| Flutter SDK | 3.41.8 (stable) | `flutter --version` |
| Dart SDK | 3.11.5 | `dart --version` |
| Node.js | 18+ | `node --version` (para Firebase CLI) |
| Firebase CLI | Latest | `firebase --version` |
| FlutterFire CLI | Latest | `flutterfire --version` |
| Cuenta Google Cloud | — | Con proyecto Firebase activo |

---

## Paso 1: Clonar y Preparar el Repositorio

```bash
git clone <repo-url>
cd deploy-talks
git checkout 001-firebase-genui-chat
cd app
```

---

## Paso 2: Crear y Configurar el Proyecto Firebase

### 2a. Crear proyecto en Firebase Console

1. Ir a [console.firebase.google.com](https://console.firebase.google.com).
2. Crear nuevo proyecto: `deploy-talks-chat` (o nombre de tu elección).
3. Habilitar **Google Analytics** (opcional).

### 2b. Habilitar Firebase Anonymous Authentication

1. En Firebase Console → **Authentication** → **Sign-in method**.
2. Habilitar **Anónimo** (Anonymous).
3. Email/contraseña, Google, etc. **no son necesarios** en v1.

### 2c. Crear base de datos Firestore

1. En Firebase Console → **Firestore Database** → **Create database**.
2. Seleccionar modo **Production** (las reglas se configuran en el siguiente paso).
3. Seleccionar región: `us-central1` (o la más cercana a tus usuarios).

### 2d. Aplicar reglas de Firestore

Crear archivo `firestore.rules` en la raíz del repo con el contenido de [contracts/firestore-rules.md](contracts/firestore-rules.md), luego:

```bash
# Desde la raíz del repo (deploy-talks/)
firebase deploy --only firestore:rules
```

### 2e. Crear índices Firestore

Crear archivo `firestore.indexes.json` en la raíz del repo con el contenido de [contracts/firestore-rules.md](contracts/firestore-rules.md) (sección de índices), luego:

```bash
firebase deploy --only firestore:indexes
```

### 2f. Habilitar Vertex AI en Firebase

1. En Firebase Console → **Vertex AI** → Habilitar la API.
2. Asegurarse de que Billing esté habilitado en el proyecto Google Cloud asociado.
3. El modelo a usar es `gemini-2.0-flash`.

---

## Paso 3: Configurar FlutterFire

```bash
# Desde app/
dart pub global activate flutterfire_cli

flutterfire configure \
  --project=<tu-firebase-project-id> \
  --platforms=web
```

Esto genera `app/lib/firebase_options.dart` con la configuración del proyecto. **No commitear este archivo con datos sensibles de producción si es un repo público** — usar variables de entorno o CI secrets.

---

## Paso 4: Instalar Dependencias

Agregar al `app/pubspec.yaml` bajo `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x
  firebase_vertexai: ^2.x.x

  # genui
  genui: ^0.9.0
  json_schema_builder: ^1.x.x

  # Routing
  go_router: ^14.x.x

  # State management
  provider: ^6.x.x
```

Luego:

```bash
cd app
flutter pub get
```

---

## Paso 5: Primer Run en Web

```bash
cd app
flutter run -d chrome --web-port 8080
```

La app debería:
1. Mostrar la pantalla **"¿Cómo te llamas?"** en `localhost:8080`.
2. Al ingresar un nombre y confirmar, acceder directamente al **Chat**.
3. Permitir enviar mensajes que aparecen en Firestore y como burbujas en la UI.
4. Las respuestas del asistente IA aparecen como superficies `gen_ui`.

---

## Paso 6: Build para Producción

```bash
cd app
flutter build web --release
```

Los archivos estáticos se generan en `app/build/web/`. Para desplegar en Firebase Hosting:

```bash
firebase deploy --only hosting
```

---

## Paso 7: Verificación

### Verificar mensajes en Firestore
- Firebase Console → Firestore Database → colección `messages`.
- Enviar un mensaje desde la app → debe aparecer en la consola en < 2 segundos.

### Verificar respuestas IA
- Enviar "Hola" desde el chat → el asistente debe responder con una burbuja `gen_ui`.
- La burbuja debe aparecer alineada a la izquierda con el nombre "Assistant".

### Verificar flujo de nombre
- Abrir `localhost:8080/chat` sin nombre en sesión → debe redirigir a `localhost:8080/enter-name`.
- Ingresar un nombre → debe redirigir a `/chat` y mostrar el nombre en los mensajes enviados.

---

## Troubleshooting

| Problema | Causa probable | Solución |
|----------|---------------|---------|
| `PERMISSION_DENIED` en Firestore | Reglas no aplicadas | Ejecutar `firebase deploy --only firestore:rules` |
| `Missing index` en Firestore | Índice compuesto no creado | Crear índice en Firebase Console o via `firebase deploy --only firestore:indexes` |
| Error `firebase_vertexai not initialized` | `Firebase.initializeApp()` no ejecutado antes de usar VertexAI | Verificar orden de inicialización en `main.dart` |
| `flutter run` falla en web | Flutter web no habilitado | `flutter config --enable-web && flutter devices` |
| LLM no responde con `ChatBubble` | System prompt no configurado | Verificar que `genui_service.dart` incluye el system prompt del catálogo |
