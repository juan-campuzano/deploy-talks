# Tasks: Flutter Web Chat con Firebase y gen_ui

**Input**: Design documents from `specs/001-firebase-genui-chat/`
**Branch**: `001-firebase-genui-chat`
**Date**: 2026-05-08

---

## Phase 1: Setup (Infraestructura Compartida)

**Purpose**: Configuración del proyecto Flutter, Firebase y dependencias

- [X] T001 Agregar dependencias al `app/pubspec.yaml`: `genui ^0.9.0`, `json_schema_builder`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_vertexai`, `go_router`, `provider`
- [X] T002 Ejecutar `flutterfire configure` para generar `app/lib/firebase_options.dart` (web)
- [ ] T003 [P] Habilitar Anonymous Auth en Firebase Console
- [X] T004 [P] Crear colección `messages` en Firestore y aplicar reglas de seguridad desde `contracts/firestore-rules.md`
- [X] T005 [P] Crear índice compuesto Firestore `(roomId ASC, timestamp ASC)` vía `firestore.indexes.json`
- [X] T006 Inicializar Firebase en `app/lib/main.dart`: `WidgetsFlutterBinding.ensureInitialized()` + `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- [X] T007 Crear estructura de directorios: `app/lib/models/`, `app/lib/services/`, `app/lib/features/enter_name/`, `app/lib/features/chat/`, `app/lib/features/chat/widgets/`, `app/lib/features/chat/catalog/`

---

## Phase 2: Fundacional (Prerrequisitos Bloqueantes)

**Purpose**: Modelos, servicios y router — todo lo que las features necesitan antes de comenzar

⚠️ **CRÍTICO**: Ninguna tarea de feature puede comenzar hasta completar esta fase

- [X] T008 Crear `app/lib/models/chat_message.dart`: clase inmutable `ChatMessage` con campos `id`, `senderId`, `senderName`, `text`, `timestamp`, `roomId`; incluir `fromFirestore()` y `toMap()`
- [X] T009 [P] Crear `app/lib/models/app_user.dart`: clase inmutable `AppUser` con campos `uid`, `displayName`
- [X] T010 Crear `app/lib/services/chat_service.dart`: método `sendMessage(AppUser user, String text)` → escribe en Firestore; método `messagesStream(String roomId)` → `Stream<List<ChatMessage>>` via `snapshots()`
- [X] T011 [P] Crear `app/lib/services/genui_service.dart`: inicializa `SurfaceController` con catálogo, `A2uiTransportAdapter` (con `_onSendToLLM` usando `firebase_vertexai`), y `Conversation`; expone método `renderMessageAsBubble(ChatMessage msg, bool isOwn)` → devuelve `surfaceId`
- [X] T012 Crear `app/lib/features/chat/catalog/chat_catalog.dart`: define schema Dart con `json_schema_builder` y `CatalogItem` `ChatBubble` con campos `content`, `senderName`, `isOwn`; builder del widget alineado según `isOwn`
- [X] T013 Crear `app/lib/router.dart`: rutas `/enter-name`, `/chat`, `/` con guard `_nameGuard` basado en `ValueNotifier<AppUser?>`; wiring con `go_router`

**Checkpoint**: Fundación lista — las fases de feature pueden comenzar

---

## Phase 3: User Story 2 — Identificación por Nombre de Usuario (Priority: P2) 🎯 MVP

**Goal**: El usuario escribe su nombre y accede al chat. Sin este paso ningún otro flujo funciona.

**Independent Test**: Abrir la app → ver `EnterNamePage` → escribir nombre → confirmar → ser redirigido a `/chat` (aunque el chat esté vacío)

- [X] T014 Crear `app/lib/features/enter_name/user_notifier.dart`: `ValueNotifier<AppUser?>` global; métodos `setUser(String displayName)` (llama `signInAnonymously()` y construye `AppUser`) y `clearUser()` (llama `signOut()`)
- [X] T015 Crear `app/lib/features/enter_name/enter_name_page.dart`: `TextField` para nombre, botón "Entrar al chat", validación (`trim().isEmpty` → error inline), llamada a `userNotifier.setUser()`, manejo de error de conexión; `CircularProgressIndicator` durante `signInAnonymously()`
- [X] T016 Conectar `EnterNamePage` al router: ruta `/enter-name` → `EnterNamePage`; verificar que guard redirige a `/chat` si nombre ya está en sesión

---

## Phase 4: User Story 1 — Enviar y Recibir Mensajes (Priority: P1) 🎯 MVP

**Goal**: El usuario envía mensajes y todas las burbujas (propias y ajenas) se renderizan via `gen_ui`

**Independent Test**: Dos pestañas del navegador abiertas con nombres distintos → uno envía mensaje → ambas pestañas ven la burbuja `gen_ui` renderizada

- [X] T017 Crear `app/lib/features/chat/chat_controller.dart`: `ChangeNotifier` que suscribe a `chatService.messagesStream('public')`; mantiene `Map<String, String> messageIdToSurfaceId`; por cada `ChatMessage` nuevo llama a `genuiService.renderMessageAsBubble()` y guarda el `surfaceId`; expone `List<String> orderedSurfaceIds`
- [X] T018 Crear `app/lib/features/chat/widgets/genui_bubble.dart`: widget `GenuiBubble` que recibe `surfaceId` y renderiza `Surface(host: conversation.host, surfaceId: surfaceId)`
- [X] T019 Crear `app/lib/features/chat/widgets/message_input.dart`: `TextField` controlado + botón "Enviar"; validación `trim().isEmpty`; al enviar llama a `chatService.sendMessage()` y limpia el campo
- [X] T020 Crear `app/lib/features/chat/widgets/chat_list.dart`: `ListView.builder` que itera sobre `chatController.orderedSurfaceIds` y construye `GenuiBubble` por cada uno; auto-scroll al fondo cuando `orderedSurfaceIds` cambia
- [X] T021 Crear `app/lib/features/chat/chat_page.dart`: `Scaffold` con `AppBar` (título + botón "Salir"), cuerpo `ChatList`, y `MessageInput` en la parte inferior; provee `ChatController` via `ChangeNotifierProvider`; botón "Salir" llama `userNotifier.clearUser()`
- [X] T022 Conectar `ChatPage` al router: ruta `/chat` → `ChatPage`; verificar que guard redirige a `/enter-name` si no hay nombre

---

## Phase 5: User Story 3 — Historial de Mensajes (Priority: P3)

**Goal**: Al entrar al chat, los mensajes anteriores se cargan desde Firestore y se renderizan como burbujas `gen_ui`

**Independent Test**: Enviar 3 mensajes → recargar la página → los 3 mensajes se renderizan nuevamente como superficies `gen_ui` en el orden correcto

- [X] T023 Actualizar `chat_controller.dart`: al inicializar, procesar el snapshot inicial de Firestore (mensajes existentes) antes de empezar a escuchar nuevos; añadir estado `isLoadingHistory` para mostrar `CircularProgressIndicator` mientras se crean las superficies `gen_ui` iniciales
- [X] T024 Actualizar `chat_list.dart`: mostrar estado vacío ("Sé el primero en enviar un mensaje") cuando `orderedSurfaceIds` está vacío y `isLoadingHistory` es `false`
- [X] T025 Implementar paginación simple en `chatService.messagesStream()`: añadir `.limit(500)` a la query de Firestore (SC-003)

---

## Phase 6: User Story 4 — Distinción Visual Propio/Ajeno (Priority: P3)

**Goal**: Las burbujas propias aparecen a la derecha y las ajenas a la izquierda, con diferenciación visual generada por el LLM

**Independent Test**: Enviar mensaje desde cuenta A y cuenta B → en ambas pantallas, los mensajes propios están a la derecha y los ajenos a la izquierda

- [X] T026 Actualizar `chat_controller.dart`: al llamar `genuiService.renderMessageAsBubble()`, calcular `isOwn = message.senderId == userNotifier.value?.uid` y pasarlo al servicio
- [X] T027 Actualizar `genui_service.dart`: incluir `isOwn` en el prompt enviado al LLM; verificar que el system prompt del `A2uiTransportAdapter` contiene las instrucciones de alineación del contrato `genui-catalog.md`
- [X] T028 Actualizar `chat_catalog.dart`: asegurar que el widget builder de `ChatBubble` lee el campo `isOwn` reactivamente y aplica `CrossAxisAlignment.end` (propio) o `CrossAxisAlignment.start` (ajeno) en el `Row` contenedor

---

## Phase 7: Pulido y Verificación Final

**Purpose**: Edge cases, UX final y verificación multiplataforma

- [X] T029 Manejar edge case: mensaje vacío — `MessageInput` debe estar deshabilitado si `trim().isEmpty` (doble protección además de `chatService`)
- [X] T030 Manejar edge case: pérdida de conexión — `chatService.sendMessage()` debe capturar excepciones Firestore y mostrar `SnackBar` de error en `ChatPage`
- [ ] T031 [P] Verificar funcionamiento en Chrome, Firefox, Safari y Edge (`flutter build web --release`)
- [ ] T032 [P] Verificar reglas Firestore: intentar escribir un mensaje con `senderId` diferente al UID → debe ser rechazado por las reglas
- [ ] T033 Verificar auto-scroll: enviar mensajes hasta superar el viewport → el `chat_list.dart` debe hacer scroll al último mensaje automáticamente
