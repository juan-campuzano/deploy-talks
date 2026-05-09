---
description: "Task list for Admin Panel feature"
---

# Tasks: Admin Panel

**Input**: Design documents from `specs/003-admin-panel/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Organization**: Tasks agrupadas por user story para implementación y prueba independiente.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede ejecutarse en paralelo (archivos distintos, sin dependencias de tasks incompletas)
- **[Story]**: User story a la que pertenece la tarea
- Paths relativos a `app/`

---

## Phase 1: Setup (Infraestructura compartida)

**Purpose**: Crear la estructura de archivos y actualizar configuración base antes de implementar cualquier user story

- [x] T001 Crear estructura de directorios: `lib/features/admin/widgets/`, `test/admin/`
- [x] T002 Actualizar `firestore.rules` añadiendo regla de lectura/escritura para la colección `settings`

**Checkpoint**: Estructura lista — implementación de user stories puede comenzar

---

## Phase 2: Fundacional (Prerequisitos bloqueantes)

**Purpose**: Modelos, servicio y notifier que TODAS las user stories necesitan. Debe completarse antes de cualquier UI de admin.

**⚠️ CRÍTICO**: Ninguna user story puede comenzar hasta que esta fase esté completa.

- [x] T003 [P] Crear modelo `ChatBackground` con `fromFirestore` y `toMap` en `lib/models/chat_background.dart`
- [x] T004 [P] Crear modelo `PresenceRecord` con `fromFirestore` en `lib/models/presence_record.dart`
- [x] T005 Crear `AdminSessionNotifier` (ValueNotifier<bool>) con métodos `authenticate(String password)` y `logout()` usando `String.fromEnvironment('ADMIN_PASSWORD')` en `lib/features/admin/admin_session_notifier.dart`
- [x] T006 Crear `AdminService` con `clearChat()`, `generateBackground(String prompt)` y `backgroundStream()` en `lib/services/admin_service.dart` (depende de T003)
- [x] T007 Extender `PresenceService` añadiendo `connectedUsersStream()` que retorna `Stream<List<PresenceRecord>>` en `lib/services/presence_service.dart` (depende de T004)
- [x] T008 Registrar `AdminSessionNotifier` y `AdminService` como Providers en `lib/main.dart` (depende de T005, T006)
- [x] T009 Añadir ruta `/admin` en `lib/router.dart` usando `Listenable.merge` para el `refreshListenable`, con redirect que muestra `AdminLoginPage` o `AdminDashboardPage` según estado del notifier (depende de T005, T008)

**Checkpoint**: Modelos, servicios y routing listos — todas las user stories pueden implementarse en paralelo

---

## Phase 3: User Story 1 — Acceso al Panel de Administrador (Priority: P1) 🎯 MVP

**Goal**: El administrador puede navegar a `/admin`, ingresar la contraseña correcta y acceder al panel. Los accesos incorrectos son rechazados.

**Independent Test**: Correr `flutter run -d chrome --dart-define=ADMIN_PASSWORD=test123`, navegar a `/#/admin`, ingresar `test123` → panel visible; ingresar cualquier otra cosa → error.

### Implementation

- [x] T010 [US1] Crear `AdminLoginPage` con campo de contraseña, botón de acceso y mensaje de error en `lib/features/admin/admin_login_page.dart` (depende de T005, T009)
- [x] T011 [US1] Crear `AdminDashboardPage` como scaffold vacío (placeholder) con botón de logout en `lib/features/admin/admin_dashboard_page.dart` (depende de T005, T009)

**Checkpoint**: US1 completamente funcional — login/logout del admin opera correctamente

---

## Phase 4: User Story 2 — Limpiar el Historial del Chat (Priority: P2)

**Goal**: El administrador puede eliminar todos los mensajes del chat con confirmación previa; el cambio se propaga en tiempo real a todos los usuarios.

**Independent Test**: Enviar varios mensajes al chat, abrir el panel admin, ejecutar "Limpiar Chat", confirmar → chat vacío para todos los clientes conectados.

### Implementation

- [x] T012 [US2] Crear widget `ClearChatCard` con botón de acción, diálogo de confirmación y manejo de estados (limpiando / éxito / error) en `lib/features/admin/widgets/clear_chat_card.dart` (depende de T006)
- [x] T013 [US2] Integrar `ClearChatCard` en `AdminDashboardPage` en `lib/features/admin/admin_dashboard_page.dart` (depende de T011, T012)

**Checkpoint**: US2 funcional — el admin puede limpiar el chat desde el panel

---

## Phase 5: User Story 3 — Ver Personas Conectadas (Priority: P2)

**Goal**: El administrador ve en tiempo real la lista de usuarios conectados con sus nombres y el conteo total.

**Independent Test**: Abrir 3 pestañas con nombres distintos, abrir el panel admin en otra pestaña → lista muestra los 3 nombres; cerrar una pestaña → lista se actualiza.

### Implementation

- [x] T014 [US3] Crear widget `ConnectedUsersCard` que escucha `PresenceService.connectedUsersStream()` y muestra lista de nombres + conteo total en `lib/features/admin/widgets/connected_users_card.dart` (depende de T007)
- [x] T015 [US3] Integrar `ConnectedUsersCard` en `AdminDashboardPage` en `lib/features/admin/admin_dashboard_page.dart` (depende de T013, T014)

**Checkpoint**: US3 funcional — el admin ve usuarios conectados en tiempo real

---

## Phase 6: User Story 4 — Cambiar el Background del Chat con IA (Priority: P3)

**Goal**: El administrador escribe un prompt, Gemini genera un gradiente de colores, y el fondo del chat cambia para todos los usuarios en tiempo real.

**Independent Test**: Escribir "fondo oceánico" en el panel → indicador de carga → fondo de gradiente azul aplicado en la pantalla de chat abierta en otra pestaña.

### Implementation

- [x] T016 [US4] Crear widget `BackgroundPromptCard` con campo de texto para el prompt, botón de generar, estado de carga y manejo de error en `lib/features/admin/widgets/background_prompt_card.dart` (depende de T006)
- [x] T017 [US4] Modificar `ChatPage` para escuchar `AdminService.backgroundStream()` y aplicar el `LinearGradient` resultante como `decoration` del `Container` del body en `lib/features/chat/chat_page.dart` (depende de T006, T003)
- [x] T018 [US4] Integrar `BackgroundPromptCard` en `AdminDashboardPage` en `lib/features/admin/admin_dashboard_page.dart` (depende de T015, T016)

**Checkpoint**: US4 funcional — prompt → IA → background en tiempo real para todos

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: UX final, estados de carga consistentes y validaciones de edge cases

- [x] T019 [P] Manejar el edge case de `ADMIN_PASSWORD` vacío en `AdminLoginPage`: deshabilitar el botón de login y mostrar mensaje informativo
- [x] T020 [P] Aplicar background por defecto (`null` → sin decoración) cuando `settings/chat_background` no existe, asegurando que `ChatPage` no lanza errores con stream vacío
- [x] T021 Revisar y pulir el layout responsivo de `AdminDashboardPage` para que las tres cards funcionen bien en pantallas pequeñas y grandes

---

## Dependencies (orden de completación de user stories)

```
Phase 1 (Setup)
    └── Phase 2 (Foundational)
            ├── Phase 3 (US1 - Login) → MVP demostrable
            ├── Phase 4 (US2 - Clear Chat)  ← depende de Phase 3 para tener el dashboard
            ├── Phase 5 (US3 - Presencia)   ← depende de Phase 4 para el dashboard
            └── Phase 6 (US4 - Background)  ← depende de Phase 5 para el dashboard
                    └── Phase 7 (Polish)
```

**MVP**: Phases 1–3 (T001–T011) → Panel con login funcional

---

## Parallel Execution

### Dentro de Phase 2 (una vez T003 y T004 terminan):
- T005 (AdminSessionNotifier) puede ejecutarse en paralelo con T006 (AdminService) y T007 (PresenceService)

### Dentro de Phase 7:
- T019 y T020 son independientes entre sí y pueden ejecutarse en paralelo

### Phases 4, 5, 6 son secuenciales entre sí:
Comparten `AdminDashboardPage` — cada phase añade una card al dashboard sobre la anterior.

---

## Implementation Strategy

**MVP recomendado** (Phases 1–3, tasks T001–T011):
- Infraestructura de routing + autenticación admin
- Panel funcional con login/logout
- Entrega de valor inmediata: el admin puede acceder al panel de forma segura

**Incremento 1** (Phase 4, T012–T013):
- Limpiar chat con confirmación

**Incremento 2** (Phase 5, T014–T015):
- Lista de usuarios conectados en tiempo real

**Incremento 3** (Phase 6–7, T016–T021):
- Background generado por IA + polish final
