# Tasks: Username en Burbujas de Chat

**Input**: Design documents from `specs/002-username-chat-bubbles/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Puede ejecutarse en paralelo (archivos distintos, sin dependencias de tareas incompletas)
- **[Story]**: Historia de usuario a la que pertenece la tarea ([US1], [US2], [US3])
- Se incluyen rutas exactas de archivos en cada tarea

---

## Phase 1: Setup

**Purpose**: No hay infraestructura nueva que crear. El proyecto ya está inicializado con Flutter, Firebase y genui. Esta fase verifica el entorno.

- [X] T001 Verificar que la rama `002-username-chat-bubbles` está activa (`git branch --show-current`)

---

## Phase 2: Foundational (Prerequisitos Bloqueantes)

**Purpose**: Confirmar que el modelo de datos y el pipeline de renderizado ya soportan la feature antes de modificar la UI.

**⚠️ CRÍTICO**: Las historias de usuario dependen de que estas premisas sean correctas.

- [X] T002 Confirmar que `ChatMessage.senderName` está presente en documentos Firestore existentes inspeccionando la colección `messages` en Firebase Console (o ejecutando la app y verificando logs de `chat_service.dart`)
- [X] T003 Confirmar que `GenuiService.renderMessageAsBubble` ya pasa `senderName` al `ChatBubble` en `app/lib/services/genui_service.dart`

**Checkpoint**: Fundación confirmada — la UI puede recibir el nombre; solo falta mostrarlo siempre.

---

## Phase 3: User Story 1 — Ver el nombre del remitente en cada burbuja (Priority: P1) 🎯 MVP

**Goal**: El nombre del usuario aparece encima de **todas** las burbujas (propias y ajenas), permitiendo identificar al remitente de cualquier mensaje.

**Independent Test**: Abrir dos pestañas en el navegador con nombres distintos ("Ana" y "Luis"), enviar un mensaje desde cada pestaña, y verificar que en ambas pestañas todas las burbujas muestran el nombre del remitente.

### Implementation for User Story 1

- [X] T004 [US1] Eliminar la condición `if (!isOwn)` que oculta el nombre en burbujas propias en `app/lib/features/chat/catalog/chat_catalog.dart`
- [X] T005 [US1] Ajustar el `Padding` del widget `Text(senderName)` para que use `EdgeInsets.only(right: 4, bottom: 2)` cuando `isOwn == true` y `EdgeInsets.only(left: 4, bottom: 2)` cuando `isOwn == false` en `app/lib/features/chat/catalog/chat_catalog.dart`
- [X] T006 [US1] Actualizar `kChatBubbleSystemPromptFragment` para indicar que `senderName` debe mostrarse en **todos** los mensajes (no solo cuando `isOwn` es false) en `app/lib/features/chat/catalog/chat_catalog.dart`

**Checkpoint**: US1 completa — todas las burbujas muestran el nombre del remitente.

---

## Phase 4: User Story 2 — Distinguir visualmente mensajes propios de recibidos (Priority: P2)

**Goal**: Los mensajes propios se muestran a la derecha (azul) y los ajenos a la izquierda (gris), con el nombre del remitente correctamente alineado en cada caso.

**Independent Test**: Desde la pestaña A (usuario "Ana"): las burbujas propias están a la derecha en azul con "Ana" alineado a la derecha; las de "Luis" están a la izquierda en gris con "Luis" alineado a la izquierda. La pestaña B debe ser el espejo exacto.

### Implementation for User Story 2

*Nota: El comportamiento de alineación y color de burbujas ya existe. Esta historia se verifica visualmente tras los cambios de US1.*

- [ ] T007 [US2] Verificar manualmente (dos pestañas del navegador) que la alineación y el color de las burbujas son correctos después de los cambios de T004–T006: burbuja propia a la derecha en azul, burbuja ajena a la izquierda en gris

**Checkpoint**: US2 completa — diferenciación visual confirmada sin cambios adicionales de código.

---

## Phase 5: User Story 3 — Mensajes en tiempo real con identidad del remitente (Priority: P3)

**Goal**: Los mensajes que llegan en tiempo real desde otra pestaña incluyen inmediatamente el nombre del remitente, sin recargar la página.

**Independent Test**: Con dos pestañas abiertas, enviar un mensaje desde la pestaña B y verificar que en la pestaña A aparece la burbuja con el nombre correcto en menos de 2 segundos.

### Implementation for User Story 3

*Nota: El streaming en tiempo real ya funciona a través de `ChatController._onMessages`. Esta historia se verifica tras los cambios de US1.*

- [ ] T008 [US3] Verificar manualmente en tiempo real (pestaña A abierta, enviar mensaje desde pestaña B) que la burbuja nueva en pestaña A muestra el nombre del remitente correctamente

**Checkpoint**: US3 completa — tiempo real con identidad verificado.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validación de edge cases y revisión final.

- [X] T009 [P] Verificar edge case: nombre vacío — confirmar que `EnterNamePage` sigue bloqueando el envío si el campo está vacío (validador existente en `app/lib/features/enter_name/enter_name_page.dart`)
- [X] T010 [P] Verificar edge case: nombre largo (> 30 caracteres) — confirmar que el widget `Text(senderName)` no rompe el layout de la burbuja (overflow/elipsis)
- [X] T011 Ejecutar checklist de verificación de `quickstart.md` completo (5 ítems)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Sin dependencias — puede empezar inmediatamente
- **Phase 2 (Foundational)**: Depende de Phase 1 — bloquea las historias de usuario
- **Phase 3 (US1)**: Depende de Phase 2 — contiene el único cambio de código real
- **Phase 4 (US2)**: Depende de Phase 3 (T004–T006 deben estar completas)
- **Phase 5 (US3)**: Depende de Phase 3 (T004–T006 deben estar completas)
- **Phase 6 (Polish)**: Depende de Phase 3, 4 y 5

### User Story Dependencies

- **US1 (P1)**: Sin dependencias de otras historias — es el MVP
- **US2 (P2)**: Depende de US1 (los cambios de US1 implementan el comportamiento de US2 también)
- **US3 (P3)**: Depende de US1 (los cambios de US1 ya habilitan el tiempo real)

### Within Phase 3 (único código a cambiar)

- T004 → T005 → T006 deben ejecutarse en secuencia (todos en el mismo archivo)
- T007, T008 son verificaciones independientes y paralelas tras T004–T006

### Parallel Opportunities

- T002 y T003 pueden verificarse en paralelo (Phase 2)
- T009 y T010 pueden ejecutarse en paralelo (Phase 6)
- T007 y T008 son verificaciones independientes y pueden hacerse simultáneamente

---

## Parallel Example: Phase 6 (Polish)

```text
T009 ──── verificar nombre vacío ────────────────────── ✓
T010 ──── verificar nombre largo ────────────────────── ✓
                                                         └── T011 run quickstart checklist
```

---

## Implementation Strategy

### MVP Scope (entregar valor inmediato)

Implementar **solo US1** (T001–T006): un cambio quirúrgico de 3 líneas en `chat_catalog.dart` que desbloquea las tres historias de usuario simultáneamente.

### Incremental Delivery

1. **Iteración 1** (MVP): T001 → T002 → T003 → T004 → T005 → T006
2. **Iteración 2** (verificación): T007 → T008
3. **Iteración 3** (polish): T009, T010 en paralelo → T011

### Scope Note

Las historias US2 y US3 **no requieren código adicional** más allá del cambio de US1. Son inherentemente satisfechas por la misma modificación en `chat_catalog.dart`, por lo que sus tareas de implementación son únicamente verificaciones manuales.
