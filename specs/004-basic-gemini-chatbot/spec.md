# Feature Specification: Basic Gemini Chatbot Tab

**Feature Branch**: `004-basic-gemini-chatbot`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "ahora necesito crear otros dos tabs, este chat grupal va a ser un tab, va a haber otro tab donde hay un chatbot con gemini usando el vertexAI, y el otro tab también un chatbot solo que ese chatbot va a tener genui, por ahora solo empecemos con el chatbot básico"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Navigate Between Group Chat and Gemini Chatbot (Priority: P1)

A user who has already entered their name arrives at the main chat screen. Instead of a single group chat, they now see a tabbed interface. They can tap a tab labeled "Chat Grupal" to see the existing group chat, and tap another tab labeled "Gemini" to open the new AI chatbot.

**Why this priority**: The tab navigation shell is the structural foundation — all other stories depend on it.

**Independent Test**: Open the app, enter a name, and verify two tabs appear. Switching between tabs shows the group chat and an empty Gemini chatbot screen respectively.

**Acceptance Scenarios**:

1. **Given** a logged-in user on the main screen, **When** the page loads, **Then** two tabs are visible: "Chat Grupal" and "Gemini"
2. **Given** the user is on the Gemini tab, **When** they tap "Chat Grupal", **Then** they see the existing group chat without losing any state
3. **Given** the user is on the Chat Grupal tab, **When** they tap "Gemini", **Then** they see the Gemini chatbot interface

---

### User Story 2 - Send a Message to Gemini and Receive a Reply (Priority: P1)

A user opens the Gemini tab, types a question or message in the input field, and submits it. They see their message appear in the conversation, followed shortly by a response from Gemini. The exchange feels like a 1-on-1 chat.

**Why this priority**: This is the core value of the entire feature — without it, the tab has no purpose.

**Independent Test**: Open the Gemini tab, type "Hola, ¿cómo estás?", send it, and receive a coherent text response displayed in the chat.

**Acceptance Scenarios**:

1. **Given** the user is on the Gemini tab with an empty conversation, **When** they type a message and press send, **Then** their message appears on the right side of the chat
2. **Given** the message was sent, **When** Gemini processes it, **Then** a response appears on the left side of the chat within 10 seconds
3. **Given** a response is being generated, **When** the user waits, **Then** a loading indicator is visible so the user knows a response is coming
4. **Given** a network or API error occurs, **When** the message fails to send, **Then** a user-friendly error message is shown and the user can retry

---

### User Story 3 - Multi-turn Conversation with Context (Priority: P2)

A user sends multiple messages in sequence. Each subsequent message can reference the previous exchange. Gemini maintains conversational context within the session — e.g., if the user says "my name is Ana", a follow-up like "what's my name?" returns "Ana".

**Why this priority**: Contextual memory is what makes the chatbot feel intelligent vs a simple one-shot query tool.

**Independent Test**: Send "me llamo Carlos", then send "¿Cómo me llamo?", and verify Gemini responds with "Carlos" or references the name.

**Acceptance Scenarios**:

1. **Given** a user has sent multiple messages, **When** they send a follow-up referencing prior context, **Then** Gemini's response demonstrates awareness of the conversation history
2. **Given** the user navigates away to the group chat tab and back, **When** they return to the Gemini tab, **Then** the conversation history is still visible for the current session

---

### User Story 4 - Clear Conversation (Priority: P3)

A user wants to start a fresh conversation with Gemini. They tap a "Clear" or reset button, and the chat history is wiped, beginning a brand new session.

**Why this priority**: Nice-to-have for demo sessions; the demo context benefits from resetting between runs.

**Independent Test**: After sending a few messages, tap the clear button and verify the chat is empty and Gemini no longer references prior context.

**Acceptance Scenarios**:

1. **Given** an ongoing conversation, **When** the user taps the clear button, **Then** all messages are removed from the UI and a new Gemini session starts
2. **Given** a cleared session, **When** the user asks about something from the prior conversation, **Then** Gemini has no memory of it

---

### Edge Cases

- What happens when the user sends an empty message? → Send button is disabled or input validation prevents submission.
- What happens when Gemini returns an empty response? → Show a fallback message like "No se recibió respuesta, intenta de nuevo."
- What happens if the user sends a very long message? → The input field scrolls; no hard limit enforced but reasonable UX truncation at display.
- What happens when the device loses connectivity mid-response? → Show a connectivity error; allow the user to retry when back online.
- What if the user switches tabs while a response is loading? → The loading state is preserved; the response appears when the user returns to the Gemini tab.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app's main screen (post-login) MUST display a tab bar with at minimum two tabs: "Chat Grupal" and "Gemini"
- **FR-002**: The "Chat Grupal" tab MUST display the existing group chat functionality without regression
- **FR-003**: The "Gemini" tab MUST display a chat-style interface where the user can type and submit messages
- **FR-004**: The system MUST send the user's message to Gemini via the VertexAI backend (using the already-installed `firebase_ai` package)
- **FR-005**: Gemini's response MUST be displayed in the chat as a distinct message on the left side of the conversation
- **FR-006**: The system MUST maintain full conversation history within the same session, sending all prior turns as context with each new message
- **FR-007**: The system MUST show a loading indicator while waiting for Gemini's response
- **FR-008**: The system MUST display a user-friendly error message if the Gemini API call fails
- **FR-009**: The conversation history MUST persist for the duration of the session (in-memory; no Firestore persistence required)
- **FR-010**: The user MUST be able to clear the current conversation and start fresh
- **FR-011**: The send button MUST be disabled when the text input is empty or while a response is pending

### Key Entities

- **GeminiMessage**: Represents a single turn in the conversation — has a role (`user` or `model`), text content, and timestamp
- **GeminiChatSession**: The in-memory collection of `GeminiMessage` items for the current session, along with the active Gemini multi-turn chat object

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can switch between the group chat and Gemini chatbot without any visible delay or loss of state in either tab
- **SC-002**: A user message sent to Gemini receives a visible response within 10 seconds under normal network conditions
- **SC-003**: The loading indicator appears within 200ms of the user pressing send
- **SC-004**: The existing group chat (Chat Grupal tab) retains 100% of its current functionality with no regressions
- **SC-005**: Error states are communicated to the user within 1 second of a failed API call
- **SC-006**: The conversation context is maintained for at least 20 turns within a single session without degradation

## Assumptions

- **A-001**: The `firebase_ai` package already configured in the project connects to VertexAI backend; no additional Firebase configuration is required
- **A-002**: Conversation history is in-memory only — it does not need to survive app restarts or tab switches beyond the current Flutter widget tree lifecycle
- **A-003**: The Gemini model used is the project default (e.g., `gemini-2.0-flash`); no model selection UI is needed
- **A-004**: The user's display name (from the existing `UserNotifier`) MAY be included in a system prompt to personalize the chatbot, but this is optional
- **A-005**: No rate limiting or quota management UI is required for this demo context
- **A-006**: The tab structure wraps the existing `ChatPage` widget as-is; no modification to the group chat internals is needed for P1 delivery
- **A-007**: The app's existing theme and design system (colors, typography) will be reused for the Gemini chatbot UI
