# Tasks: Basic Gemini Chatbot Tab

**Input**: Design documents from `specs/004-basic-gemini-chatbot/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Organization**: Tasks are grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Which user story: US1 (tab shell), US2 (send/receive), US3 (multi-turn), US4 (clear)

---

## Phase 1: Setup

**Purpose**: Create the new feature folder skeleton so parallel work can begin immediately.

- [x] T001 Create feature directory structure: `app/lib/features/home/`, `app/lib/features/gemini_chat/`, `app/lib/features/gemini_chat/widgets/` (empty `.gitkeep` or placeholder files as needed)

---

## Phase 2: Foundational (Blocking Prerequisite)

**Purpose**: `GeminiMessage` and `GeminiRole` are required by all subsequent phases — controller, widgets, and page all import this model.

**⚠️ CRITICAL**: No user story implementation can begin until T002 is complete.

- [x] T002 Create `GeminiRole` enum (`user`, `model`) and `GeminiMessage` value class (fields: `role`, `text`, `timestamp`) in `app/lib/models/gemini_message.dart`

**Checkpoint**: Model file compiles — user story phases can now proceed.

---

## Phase 3: User Story 1 — Tab Navigation Shell (Priority: P1) 🎯 MVP start

**Goal**: Convert the single-screen `/chat` route into a two-tab layout. The group chat is tab 0; the Gemini chatbot (initially a placeholder) is tab 1.

**Independent Test**: Open the app, enter a name, verify two tabs ("Chat Grupal" / "Gemini") appear. Switching tabs works. Group chat is fully functional on tab 0.

### Implementation for User Story 1

- [x] T003 [US1] Create `HomePage` widget with `DefaultTabController(length: 2)`, `TabBar` with labels "Chat Grupal" and "Gemini", and `TabBarView` with `ChatPage()` as child 0 and an empty `Placeholder` widget as child 1 in `app/lib/features/home/home_page.dart`
- [x] T004 [US1] Update `app/lib/router.dart`: change the `/chat` route builder from `const ChatPage()` to `const HomePage()` — no other router changes needed

**Checkpoint**: US1 complete — two tabs render, group chat works, Gemini tab shows placeholder.

---

## Phase 4: User Story 2 — Send a Message and Receive a Reply (Priority: P1) 🎯 MVP core

**Goal**: The Gemini tab becomes a functional 1-on-1 chatbot. User types, sends, sees their message, waits for Gemini's reply with a loading indicator, and errors are surfaced.

**Independent Test**: Open Gemini tab, type "Hola, ¿cómo estás?", press send — message appears right-aligned, loading indicator appears, Gemini reply appears left-aligned within 10 s.

### Implementation for User Story 2

- [x] T005 [P] [US2] Create `GeminiChatController extends ChangeNotifier` in `app/lib/features/gemini_chat/gemini_chat_controller.dart`: constructor takes `displayName`, creates `GenerativeModel` (`FirebaseAI.vertexAI()`, model `gemini-2.5-flash`, `systemInstruction`), starts `ChatSession`; exposes `List<GeminiMessage> messages`, `bool isLoading`, `String? error`; implements `sendMessage(String text)` (appends user message → sets `isLoading = true` → awaits `_session.sendMessage(Content.text(text))` → appends model message → handles errors)
- [x] T006 [P] [US2] Create `GeminiMessageBubble` stateless widget in `app/lib/features/gemini_chat/widgets/gemini_message_bubble.dart`: takes a `GeminiMessage`; user-role messages align right with `AppColors.primary` bubble; model-role messages align left with `AppColors.surfaceEl` bubble; displays `message.text`
- [x] T007 [P] [US2] Create `GeminiInputBar` stateless widget in `app/lib/features/gemini_chat/widgets/gemini_input_bar.dart`: takes `TextEditingController`, `bool isLoading`, and `VoidCallback? onSend`; renders a `TextField` + send `IconButton`; button is disabled when `isLoading` is true or input is empty; matches existing `MessageInput` style using `AppColors`/`AppTheme`
- [x] T008 [US2] Create `GeminiChatPage` stateful widget in `app/lib/features/gemini_chat/gemini_chat_page.dart`: owns `GeminiChatController` lifecycle (`initState`/`dispose`); reads `UserNotifier` via `context.read` to get `displayName`; renders a `Scaffold` with a `ListView` of `GeminiMessageBubble` widgets, `GeminiInputBar` at bottom, `LinearProgressIndicator` when `isLoading`, and a `SnackBar` on non-null `error`; auto-scrolls to bottom on new messages using a `ScrollController`
- [x] T009 [US2] Replace the `Placeholder` child in `HomePage`'s `TabBarView` slot 1 with `GeminiChatPage()` in `app/lib/features/home/home_page.dart`

**Checkpoint**: US2 complete — full send/receive flow works end-to-end.

---

## Phase 5: User Story 3 — Multi-turn Conversation with Context (Priority: P2)

**Goal**: The conversation history survives tab switches within a session, and Gemini answers follow-up questions referencing prior turns.

**Independent Test**: Send "me llamo Carlos", switch to Chat Grupal, switch back to Gemini, send "¿Cómo me llamo?", verify Gemini replies with "Carlos".

### Implementation for User Story 3

- [x] T010 [US3] Add `AutomaticKeepAliveClientMixin` to `_GeminiChatPageState` in `app/lib/features/gemini_chat/gemini_chat_page.dart`: call `super.wantKeepAlive = true` in `build()` so Flutter does not dispose the page widget when the user switches tabs — this preserves `GeminiChatController` (and its `ChatSession` history) across tab switches

**Checkpoint**: US3 complete — conversation context persists across tab switches.

---

## Phase 6: User Story 4 — Clear Conversation (Priority: P3)

**Goal**: A clear button resets the conversation to a blank slate and starts a fresh Gemini session.

**Independent Test**: Send several messages, tap the clear button, verify the message list is empty; send "¿Qué dijimos antes?" and verify Gemini has no memory of the prior exchange.

### Implementation for User Story 4

- [x] T011 [US4] Implement `clearSession()` in `GeminiChatController` (`app/lib/features/gemini_chat/gemini_chat_controller.dart`): reset `messages` to `[]`, set `error = null`, `isLoading = false`, recreate `_session = _model.startChat()`, call `notifyListeners()`
- [x] T012 [US4] Add a clear `IconButton` (trash or refresh icon) to the `GeminiChatPage` `AppBar` or toolbar in `app/lib/features/gemini_chat/gemini_chat_page.dart`: calls `controller.clearSession()`; disabled when `messages` is empty

**Checkpoint**: US4 complete — clear button resets chat and Gemini loses prior context.

---

## Final Phase: Polish & Cross-cutting Concerns

**Purpose**: Visual consistency, empty states, and regression verification.

- [x] T013 [P] Style the `TabBar` in `app/lib/features/home/home_page.dart` to use `AppColors.primary` as the indicator color and `AppColors.textPrimary`/`AppColors.textSecondary` for selected/unselected label colors; match the `AppTheme` font (`Plus Jakarta Sans`)
- [x] T014 [P] Add an empty-state widget in `GeminiChatPage` (`app/lib/features/gemini_chat/gemini_chat_page.dart`): when `messages` is empty, show a centered text "Pregúntale algo a Gemini ✨" using `AppColors.textMuted` style
- [x] T015 Smoke-test the group chat tab for regressions: confirm presence join/leave, heartbeat timer, background gradient, and message send all work identically to before the `HomePage` wrapper was introduced

---

## Dependencies (Story Completion Order)

```
T001 (setup)
  └── T002 (GeminiMessage model) [BLOCKING]
        ├── T003 (HomePage shell)   [US1]
        │     └── T004 (router)     [US1] ──→ US1 DONE ✅
        │           └── T009 (wire GeminiChatPage into HomePage) [US2]
        │
        └── T005, T006, T007 [P] [US2] ──→ T008 (GeminiChatPage)
              └── T008 [US2] ──→ T009 ──→ US2 DONE ✅
                    └── T010 [US3] ──→ US3 DONE ✅
                          └── T011, T012 [US4] ──→ US4 DONE ✅
                                └── T013, T014, T015 (polish)
```

## Parallel Execution Opportunities

**US2 parallel group** (after T002 is done): T005, T006, T007 touch completely different files and can run simultaneously:
- Agent A → `gemini_chat_controller.dart` (T005)
- Agent B → `gemini_message_bubble.dart` (T006)
- Agent C → `gemini_input_bar.dart` (T007)

**Polish parallel group**: T013 (tab styling) and T014 (empty state) are in independent code locations.

## Implementation Strategy

**MVP scope**: Phase 1 + Phase 2 + Phase 3 + Phase 4 (T001–T009) — delivers a fully working two-tab app with real Gemini chat.

**Incremental delivery**:
1. T001–T004: Tab shell visible, group chat unchanged ✅
2. T005–T009: Full Gemini send/receive working ✅
3. T010: Tab-switch state persistence ✅
4. T011–T012: Clear button ✅
5. T013–T015: Polish and smoke test ✅

## Summary

| Metric | Count |
|--------|-------|
| Total tasks | 15 |
| Phase 1 (Setup) | 1 |
| Phase 2 (Foundation) | 1 |
| US1 tasks | 2 |
| US2 tasks | 5 |
| US3 tasks | 1 |
| US4 tasks | 2 |
| Polish tasks | 3 |
| Parallelizable [P] tasks | 5 |
