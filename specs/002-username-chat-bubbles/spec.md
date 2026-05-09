# Feature Specification: Username en Burbujas de Chat

**Feature Branch**: `002-username-chat-bubbles`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "ahora necesito aparezcan los nombres de los usuarios en cada burbuja, por ejemplo, si abro dos pestañas de mi navegador con el sitio web y pongo dos nombres de usuario diferentes, debería poder distinguir uno del otro, los mensajes de una pestaña deberían poder verse como recibidos en la otra y viceversa"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ver el nombre del remitente en cada burbuja (Priority: P1)

Como participante del chat, quiero ver el nombre de quien envió cada mensaje directamente en la burbuja correspondiente, para poder identificar quién dijo qué sin ambigüedad.

**Why this priority**: Es el núcleo de la funcionalidad solicitada. Sin esto, los usuarios no pueden distinguir entre mensajes propios y ajenos.

**Independent Test**: Se puede probar abriendo dos pestañas del navegador, ingresando nombres distintos en cada una, enviando un mensaje desde cada pestaña y verificando que en ambas pestañas el nombre del remitente aparece sobre (o dentro de) cada burbuja.

**Acceptance Scenarios**:

1. **Given** que dos usuarios "Ana" y "Luis" están en el chat, **When** "Ana" envía un mensaje, **Then** ese mensaje muestra "Ana" como remitente en la burbuja, visible para todos los participantes.
2. **Given** que soy el usuario "Luis" y recibo un mensaje de "Ana", **When** veo la lista de mensajes, **Then** el nombre "Ana" aparece claramente asociado a su burbuja de mensaje.
3. **Given** que envío un mensaje como "Luis", **When** lo veo en mi propia pantalla, **Then** mi nombre "Luis" aparece en mi burbuja (o se indica visualmente que es mío).

---

### User Story 2 - Distinguir visualmente mensajes propios de mensajes recibidos (Priority: P2)

Como usuario del chat, quiero que mis propios mensajes luzcan diferente a los mensajes que recibo de otras personas, para orientarme rápidamente en la conversación.

**Why this priority**: Mejora la experiencia de lectura del chat; es una convención estándar en aplicaciones de mensajería.

**Independent Test**: Se puede probar enviando un mensaje desde la pestaña A y verificando que en la pestaña A aparece con un estilo diferente al que muestra la pestaña B para el mismo mensaje.

**Acceptance Scenarios**:

1. **Given** que soy el usuario "Ana", **When** envío un mensaje, **Then** ese mensaje se muestra con un estilo visual diferente (color de burbuja, alineación u otro indicador) al de los mensajes recibidos de "Luis".
2. **Given** que soy el usuario "Luis" viendo el mismo mensaje enviado por "Ana", **When** lo veo en mi pantalla, **Then** ese mensaje aparece con el estilo de "mensaje recibido" (no como propio).

---

### User Story 3 - Mensajes en tiempo real con identidad del remitente (Priority: P3)

Como usuario del chat, quiero que cuando llegue un nuevo mensaje de otro participante en tiempo real, su nombre aparezca inmediatamente en la burbuja, sin necesidad de refrescar la página.

**Why this priority**: Garantiza que la identidad del remitente esté siempre visible independientemente del orden de llegada de los mensajes.

**Independent Test**: Puede probarse enviando un mensaje desde la pestaña B mientras la pestaña A está abierta; la burbuja con el nombre del remitente debe aparecer en la pestaña A en tiempo real.

**Acceptance Scenarios**:

1. **Given** que tengo el chat abierto en la pestaña A como "Ana", **When** el usuario "Luis" (en la pestaña B) envía un mensaje, **Then** la pestaña A muestra la burbuja del mensaje con el nombre "Luis" sin recargar la página.
2. **Given** que hay varios mensajes de distintos usuarios en el historial, **When** cargo el chat por primera vez, **Then** cada burbuja muestra el nombre de su respectivo remitente.

---

### Edge Cases

- ¿Qué ocurre si un usuario ingresa al chat sin haber introducido un nombre (campo vacío)?
- ¿Cómo se muestra la burbuja si el nombre del remitente es muy largo (más de 30 caracteres)?
- ¿Qué pasa si dos usuarios eligen exactamente el mismo nombre?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Cada burbuja de mensaje DEBE mostrar el nombre del usuario que lo envió.
- **FR-002**: El nombre mostrado en la burbuja DEBE ser el nombre que el remitente introdujo al unirse al chat.
- **FR-003**: Los mensajes enviados por el usuario actual DEBEN diferenciarse visualmente de los mensajes recibidos de otros usuarios.
- **FR-004**: Cuando se recibe un mensaje en tiempo real de otro usuario, la burbuja DEBE incluir el nombre del remitente desde el primer momento en que aparece.
- **FR-005**: Los mensajes históricos (cargados al abrir el chat) DEBEN mostrar el nombre del remitente en cada burbuja.
- **FR-006**: El sistema DEBE impedir que se envíe un mensaje si el nombre de usuario está vacío.

### Key Entities

- **ChatMessage**: Representa un mensaje individual en el chat. Atributos clave: contenido del mensaje, nombre del remitente (`senderName`), identificador de sesión del remitente (`senderId`), marca de tiempo.
- **ChatSession**: Representa la sesión activa de un usuario en el chat. Atributos clave: nombre de usuario elegido, identificador de sesión único.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: En una conversación con dos o más usuarios, el 100% de los mensajes muestra el nombre de su remitente de forma visible.
- **SC-002**: Un nuevo observador puede identificar quién envió cada mensaje en menos de 3 segundos de lectura, sin instrucciones adicionales.
- **SC-003**: Los mensajes propios y los mensajes recibidos son distinguibles visualmente por al menos dos indicadores (p. ej., alineación y color de burbuja).
- **SC-004**: Los mensajes entrantes en tiempo real aparecen con el nombre del remitente correcto en menos de 2 segundos desde su envío.

## Assumptions

- La aplicación ya cuenta con una pantalla de ingreso de nombre antes de acceder al chat; este flujo no cambia.
- El identificador de sesión del usuario es suficiente para distinguir "mensaje propio" de "mensaje recibido" en cada pestaña del navegador.
- Todos los usuarios se encuentran en la misma sala de chat (no se gestiona multiroom en esta feature).
- La sincronización en tiempo real de mensajes ya existe; esta feature solo añade la identidad del remitente.
- El nombre de usuario no necesita ser único globalmente; dos usuarios pueden tener el mismo nombre (se distinguen por el identificador de sesión internamente).
