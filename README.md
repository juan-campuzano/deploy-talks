# Deploy Talks — Flutter + Firebase + Gemini GenUI

Una aplicación Flutter construida en vivo durante una presentación, donde cada feature se implementó paso a paso usando **GitHub Copilot** como asistente de desarrollo. El objetivo fue mostrar cómo AI-assisted coding acelera el ciclo de especificación → implementación → entrega.

---

## ¿Qué es esta app?

Es un chat grupal en tiempo real con Firebase, extendido iterativamente hasta convertirse en una plataforma con tres tabs:

| Tab | Descripción |
|-----|-------------|
| **Chat Grupal** | Chat en tiempo real con Firebase Firestore. Las burbujas son componentes GenUI generados dinámicamente por Gemini. |
| **Gemini** | Chatbot 1-a-1 conversacional con Gemini (Vertex AI). Respuestas en texto plano, multi-turno. |
| **GenUI** | Chatbot 1-a-1 con Gemini donde las respuestas se renderizan como componentes Flutter ricos: tarjetas, listas, bloques de código, métricas. |

---

## Cómo se construyó — Las 5 Features

### Feature 001 — Chat Grupal con GenUI
La base de la aplicación. Un usuario ingresa su nombre y accede a una sala de chat compartida. Los mensajes se persisten en **Firebase Firestore** y se sincronizan en tiempo real. Las burbujas de chat no son widgets estáticos — son componentes generados dinámicamente por el paquete [`genui`](https://pub.dev/packages/genui): Gemini decide cómo renderizar visualmente cada mensaje según su contenido.

**Tecnologías clave**: Flutter Web, Firebase Firestore, `genui`, `firebase_ai` (Vertex AI)

---

### Feature 002 — Nombres de usuario en las burbujas
Se agregó identificación visual por nombre de usuario. Cada burbuja muestra el nombre del remitente. Los mensajes propios aparecen alineados a la derecha y los ajenos a la izquierda — la convención estándar de cualquier app de mensajería. Si abres dos pestañas del navegador con nombres distintos, puedes ver la conversación desde ambas perspectivas en tiempo real.

**Tecnologías clave**: `UserNotifier` (estado en memoria), `go_router` para navegación con nombre de sesión

---

### Feature 003 — Panel de Administrador
Un panel protegido por contraseña accesible solo para el presentador. Desde ahí se puede:
- **Limpiar el chat** — borra todos los mensajes de Firestore de un golpe (útil para resetear la demo entre corridas)
- **Ver usuarios conectados** — lista de quiénes están en la sala en tiempo real
- **Cambiar el fondo del chat** — el admin escribe un prompt en lenguaje natural y Gemini genera una descripción de fondo que se aplica en vivo para todos los participantes

**Tecnologías clave**: `firebase_ai` para generar el fondo, Firestore para sincronización del estado global

---

### Feature 004 — Tab de Chatbot Gemini (texto)
La interfaz de chat se reorganizó en **tabs**. El chat grupal pasó a ser un tab, y se agregó un segundo tab con un chatbot 1-a-1 conversacional usando **Gemini 2.5 Flash** via Vertex AI. Soporta conversación multi-turno con memoria de contexto dentro de la sesión. Las respuestas son texto plano con formato Markdown.

**Tecnologías clave**: `GenerativeModel` + `ChatSession` de `firebase_ai`, `DefaultTabController`, `AutomaticKeepAliveClientMixin`

---

### Feature 005 — Tab de Chatbot GenUI (componentes ricos)
El tercer tab lleva la idea del chatbot un paso más allá: en lugar de recibir texto, Gemini responde con **componentes Flutter estructurados**. Se definió un catálogo de 4 tipos de componentes:

| Componente | Cuándo lo usa Gemini |
|-----------|----------------------|
| `TextCard` | Respuestas de prosa o explicaciones |
| `ItemList` | Enumeraciones u opciones |
| `CodeBlock` | Código, comandos, sintaxis |
| `StatHighlight` | Un dato clave, métrica o número destacado |

Gemini recibe un system prompt que le instruye a siempre responder usando el componente más apropiado del catálogo. El resultado es una interfaz que se siente como un dashboard interactivo en lugar de un chat de texto.

**Tecnologías clave**: `genui`, `SurfaceController`, `SurfaceView`, catálogo de componentes con `CatalogItem` + `ObjectSchema`

---

## Stack tecnológico

- **Flutter** (Web + Mobile) — Dart 3, SDK ^3.11.5
- **Firebase** — Firestore (tiempo real), Firebase AI (Vertex AI / Gemini)
- **Gemini 2.5 Flash** — vía `firebase_ai` + `GenerativeModel`
- **genui** ^0.9.0 — renderizado de componentes Flutter generados por LLM
- **go_router** — navegación declarativa
- **provider** — gestión de estado

---

## Cómo correr la app

```bash
cd app
flutter pub get
flutter run -d chrome
```

> Requiere un proyecto Firebase configurado con Vertex AI habilitado y los archivos `google-services.json` / `GoogleService-Info.plist` en su lugar.

---

## Estructura del proyecto

```
app/lib/
├── features/
│   ├── chat/           # Feature 001-002: Chat grupal + burbujas GenUI
│   ├── admin/          # Feature 003: Panel de administrador
│   ├── enter_name/     # Feature 001: Pantalla de nombre de usuario
│   ├── home/           # Feature 004-005: HomePage con TabBar (3 tabs)
│   ├── gemini_chat/    # Feature 004: Tab chatbot Gemini texto
│   └── genui_chat/     # Feature 005: Tab chatbot GenUI componentes
│       ├── catalog/    # Definición de los 4 componentes del catálogo
│       └── widgets/    # GenuiUserBubble
├── models/             # GeminiMessage, GenuiConversationEntry
└── services/           # GenuiService, Firebase init
specs/                  # Documentación de cada feature (spec, plan, tasks)
```

---

## Metodología de desarrollo

Cada feature siguió el mismo ciclo:

1. **Spec** — descripción en lenguaje natural de lo que se quiere construir
2. **Plan** — arquitectura, estructura de archivos, decisiones técnicas
3. **Tasks** — lista ordenada de tareas implementables
4. **Implement** — código generado y revisado con GitHub Copilot

Todo el proceso fue asistido por **GitHub Copilot** dentro de VS Code, usando agentes especializados (`speckit.*`) para cada fase del ciclo.
