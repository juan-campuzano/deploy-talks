# Feature Specification: GenUI Chatbot Tab

**Feature Branch**: `005-genui-chatbot`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "ahora vamos a crear el otro tab que va a usar gemini con genui, hay que crear un catálogo de componentes para que gemini pueda usar en sus respuestas"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Gemini Responds with Rich UI Components (Priority: P1)

A user opens the "GenUI" tab and asks Gemini a question. Instead of receiving a plain text response, Gemini's reply is rendered as a rich UI surface — for example, a card with a title and description, a list of items, a code snippet block, or a stat widget. The chat feels like a living, dynamic interface rather than a text terminal.

**Why this priority**: This is the core differentiator of the GenUI tab vs the basic Gemini tab — if components don't render, the tab has no value.

**Independent Test**: Open the GenUI tab, type "dame un resumen de los planetas del sistema solar", and verify that Gemini's response renders as a structured UI component (e.g. a list or card) rather than raw markdown text.

**Acceptance Scenarios**:

1. **Given** the user is on the GenUI tab with an empty conversation, **When** they type a message and press send, **Then** their message appears as a user bubble on the right
2. **Given** the message was sent, **When** Gemini responds, **Then** the response renders as one or more GenUI components from the catalog (not raw text)
3. **Given** the response is being generated, **When** the user waits, **Then** a loading indicator is visible
4. **Given** an API error occurs, **When** the message fails, **Then** a user-friendly error message is shown

---

### User Story 2 - Component Catalog with Multiple Component Types (Priority: P1)

The GenUI catalog defines at least three distinct component types that Gemini can choose from when composing its answer. Each component type covers a different kind of structured information — prose summaries, item lists, highlighted key facts, and code snippets.

**Why this priority**: Without a multi-component catalog, Gemini has nothing interesting to pick from — all responses would look the same.

**Independent Test**: Ask Gemini "explícame qué es una API REST" and verify the response uses more than one component type (e.g. a prose card plus a code snippet block). Ask "dame 5 frutas" and verify a list component is used.

**Acceptance Scenarios**:

1. **Given** the catalog is loaded, **When** Gemini receives a question that calls for structured enumeration, **Then** it renders a list-type component
2. **Given** the catalog is loaded, **When** Gemini receives a question requiring prose explanation, **Then** it renders a card or text-block component
3. **Given** the catalog is loaded, **When** Gemini receives a question involving code or commands, **Then** it renders a code-block component
4. **Given** the catalog is loaded, **When** Gemini receives a question about a single key fact or metric, **Then** it renders a stat or highlight component

---

### User Story 3 - Multi-turn GenUI Conversation (Priority: P2)

A user can have a multi-turn conversation in the GenUI tab. Follow-up messages reference prior context (just like the basic Gemini tab) and Gemini continues choosing the most appropriate component for each response in the thread.

**Why this priority**: Single-shot Q&A is useful, but conversational depth is what makes this a demo-worthy chatbot.

**Independent Test**: Ask "dame los 3 países más grandes del mundo", then ask "¿y cuál tiene más población de esos tres?". Verify the second response is contextually aware of the first and renders an appropriate component.

**Acceptance Scenarios**:

1. **Given** a multi-message conversation, **When** the user sends a follow-up, **Then** Gemini's response reflects awareness of prior messages
2. **Given** the user switches to Chat Grupal and back, **When** they return to the GenUI tab, **Then** the full component history is still visible

---

### User Story 4 - Clear GenUI Conversation (Priority: P3)

A user can reset the GenUI conversation, clearing all rendered components and starting a fresh Gemini session.

**Why this priority**: Needed for demo resets between runs.

**Independent Test**: After a multi-turn conversation, tap the clear button, verify all components are removed, and verify a follow-up question has no memory of prior context.

**Acceptance Scenarios**:

1. **Given** an ongoing GenUI conversation, **When** the user taps the clear button, **Then** all rendered surfaces are removed and a new Gemini session starts
2. **Given** a cleared session, **When** the user references something said earlier, **Then** Gemini has no recollection of it

---

### Edge Cases

- What if Gemini returns a component type not in the catalog? → GenUI's `SurfaceController` handles unknown types gracefully; the surface renders empty rather than crashing.
- What if the user sends an empty message? → Send button is disabled when input is empty.
- What if a component has missing required fields? → Each catalog component defines sensible defaults for optional fields; required fields are enforced by the schema.
- What if the user switches tabs while a response is loading? → The loading state persists; the component renders when the user returns (via `AutomaticKeepAliveClientMixin`).
- What if Gemini decides to mix components in a single response? → The catalog supports a `ResponseCard` container component that wraps multiple child components in a single surface.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST display a "GenUI" tab alongside "Chat Grupal" and "Gemini" in the tab bar (extending `HomePage` from 3 tabs)
- **FR-002**: The GenUI tab MUST use the `genui` package's `SurfaceView` to render Gemini's responses as UI components
- **FR-003**: The GenUI catalog MUST define at minimum the following component types: `TextCard` (prose response), `ItemList` (enumerated items), `CodeBlock` (code/commands), `StatHighlight` (single key metric or fact)
- **FR-004**: Gemini MUST receive a system prompt that describes the available catalog components and instructs it to use them to structure its answers
- **FR-005**: Each user message MUST appear as a plain styled text bubble (not a GenUI surface) on the right side of the conversation
- **FR-006**: Gemini's responses MUST be rendered as GenUI surfaces using `SurfaceView` on the left side of the conversation
- **FR-007**: The system MUST maintain full multi-turn conversation history within the session (in-memory; no Firestore persistence)
- **FR-008**: The system MUST show a loading indicator while awaiting a Gemini response
- **FR-009**: The system MUST display a user-friendly error message if the Gemini API call fails
- **FR-010**: The user MUST be able to clear the GenUI conversation and start a fresh session
- **FR-011**: The conversation history (surfaces + user messages) MUST persist across tab switches within the same session

### Key Entities

- **GenuiCatalog** (`005`): The new catalog containing `TextCard`, `ItemList`, `CodeBlock`, `StatHighlight` components — separate from the existing `chat_catalog` used by the group chat
- **GenuiConversationEntry**: A sealed/tagged union representing either a user text message or a Gemini GenUI surface (identified by surfaceId)
- **GenuiChatController**: The in-memory session state — holds the conversation entries list, `isLoading`, `error`, the `GenerativeModel`, `ChatSession`, and the `SurfaceController`

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The tab bar shows three tabs ("Chat Grupal", "Gemini", "GenUI") without layout overflow on any target screen size
- **SC-002**: At least 4 distinct catalog component types render correctly when triggered by appropriate user questions
- **SC-003**: Gemini's first response renders a GenUI component (not raw text) in 100% of successful API calls, as verified during demo sessions
- **SC-004**: Component surfaces appear within 10 seconds of sending a message under normal network conditions
- **SC-005**: The existing "Chat Grupal" and "Gemini" tabs retain 100% of their current functionality after the tab bar is extended to 3 tabs
- **SC-006**: Conversation context is maintained for at least 10 follow-up turns within a single session

## Assumptions

- **A-001**: The `genui` package (`^0.9.0`) and `json_schema_builder` (`^0.1.3`) are already installed — no new dependencies needed
- **A-002**: The new GenUI catalog is a separate Dart file and separate `Catalog` instance from the existing `chat_catalog` — they do not share components
- **A-003**: The new catalog's `SurfaceController` is owned by `GenuiChatController` (page-local, not the global `GenuiService` provider used by the group chat)
- **A-004**: Gemini is instructed via `systemInstruction` and `systemPromptFragments` from the catalog to always respond with GenUI surfaces; plain-text fallback is acceptable but not the goal
- **A-005**: The existing `GenuiService` in the provider tree is untouched — the GenUI chatbot creates its own isolated controller/transport/catalog stack
- **A-006**: Component visual design uses the existing `AppColors` / `AppTheme` tokens for consistency with the rest of the app
- **A-007**: No Firestore persistence — conversation is in-memory only, reset on app restart
