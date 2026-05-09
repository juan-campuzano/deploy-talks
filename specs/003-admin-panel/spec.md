# Feature Specification: Admin Panel

**Feature Branch**: `003-admin-panel`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "ahora necesito crear un panel de administrador donde pueda limpiar el chat, ver las personas conectadas y cambiar el background del chat mediante un prompt a gemini usando firebase_ai, pero que solo pueda ingresar yo con una contraseña en especifico"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Acceso al Panel de Administrador (Priority: P1)

El administrador ingresa una contraseña específica para acceder al panel de administración. Sin la contraseña correcta, el acceso es denegado y el panel no es visible para ningún otro usuario.

**Why this priority**: Sin acceso seguro al panel, todas las demás funciones de administración serían inútiles o peligrosas. Es la base del sistema.

**Independent Test**: Puede probarse de forma independiente navegando a la ruta del panel, ingresando la contraseña correcta y verificando que se muestra el panel, luego ingresando una incorrecta y verificando que se deniega el acceso.

**Acceptance Scenarios**:

1. **Given** el administrador navega al panel de administración, **When** ingresa la contraseña correcta, **Then** obtiene acceso al panel y ve todas las opciones de administración
2. **Given** cualquier persona navega al panel de administración, **When** ingresa una contraseña incorrecta o no ingresa nada, **Then** el acceso es denegado y se muestra un mensaje de error
3. **Given** un usuario normal utiliza la aplicación de chat, **When** navega por la interfaz, **Then** no ve ningún acceso o enlace al panel de administración

---

### User Story 2 - Limpiar el Historial del Chat (Priority: P2)

El administrador puede eliminar todos los mensajes del chat de forma inmediata desde el panel de administración.

**Why this priority**: Mantener el chat limpio es una función operacional crítica, especialmente en entornos de presentaciones o demos.

**Independent Test**: Puede probarse enviando mensajes al chat, luego ejecutando la acción de limpieza y verificando que el historial queda vacío para todos los usuarios conectados.

**Acceptance Scenarios**:

1. **Given** el administrador está en el panel y hay mensajes en el chat, **When** hace clic en "Limpiar Chat" y confirma la acción, **Then** todos los mensajes son eliminados y el chat aparece vacío para todos los usuarios conectados
2. **Given** el administrador hace clic en "Limpiar Chat", **When** aparece la confirmación, **Then** si el administrador cancela, los mensajes permanecen intactos
3. **Given** el chat está vacío, **When** el administrador ejecuta la acción de limpiar, **Then** el sistema confirma que no hay mensajes que eliminar

---

### User Story 3 - Ver Personas Conectadas (Priority: P2)

El administrador puede ver en tiempo real cuántas personas y qué usuarios están conectados actualmente al chat.

**Why this priority**: Conocer la audiencia conectada es esencial para gestionar una presentación o demo en vivo.

**Independent Test**: Puede probarse conectando múltiples usuarios con diferentes nombres y verificando que el panel muestra la lista actualizada en tiempo real.

**Acceptance Scenarios**:

1. **Given** el administrador está en el panel, **When** hay usuarios conectados al chat, **Then** ve la lista de nombres de los usuarios conectados y el conteo total
2. **Given** un nuevo usuario se une al chat, **When** el administrador mira el panel, **Then** el nuevo usuario aparece en la lista sin necesidad de recargar la página
3. **Given** un usuario abandona el chat, **When** el administrador mira el panel, **Then** ese usuario desaparece de la lista de conectados

---

### User Story 4 - Cambiar el Background del Chat con IA (Priority: P3)

El administrador puede escribir un prompt en lenguaje natural y la IA (Gemini via Firebase AI) genera un fondo visual para el chat que todos los usuarios verán de inmediato.

**Why this priority**: Es una función de personalización que enriquece la experiencia visual de la demo, pero no afecta la funcionalidad core del chat.

**Independent Test**: Puede probarse ingresando un prompt descriptivo, ejecutando la generación y verificando que el fondo cambia tanto en el panel del admin como en la vista de todos los usuarios conectados.

**Acceptance Scenarios**:

1. **Given** el administrador está en el panel, **When** escribe un prompt descriptivo (ej. "un fondo espacial con estrellas") y confirma, **Then** la IA genera un fondo y este se aplica visualmente al chat para todos los usuarios conectados
2. **Given** el administrador envía un prompt, **When** la IA está procesando, **Then** se muestra un indicador de carga y el fondo anterior permanece hasta que el nuevo esté listo
3. **Given** el prompt de la IA no puede procesarse, **When** ocurre un error, **Then** el administrador ve un mensaje de error descriptivo y el fondo anterior permanece sin cambios
4. **Given** un nuevo usuario se conecta al chat, **When** hay un fondo personalizado activo, **Then** el nuevo usuario ve el fondo personalizado actual

---

### Edge Cases

- ¿Qué pasa si el administrador cierra el panel sin cerrar sesión y otro navega a la URL?
- ¿Qué ocurre si la sesión del admin caduca mientras el panel está abierto?
- ¿Cómo se maneja una solicitud de generación de fondo mientras otra está en curso?
- ¿Qué sucede si el prompt a Gemini produce contenido inapropiado o no genera una imagen válida?
- ¿Qué pasa si se intenta limpiar el chat mientras se están enviando mensajes activamente?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE proveer una ruta o pantalla protegida por contraseña para el panel de administración
- **FR-002**: El sistema DEBE denegar el acceso al panel cuando la contraseña ingresada no coincide con la contraseña configurada
- **FR-003**: El sistema DEBE permitir al administrador eliminar todos los mensajes del chat con una acción de confirmación previa
- **FR-004**: El sistema DEBE reflejar la limpieza del chat en tiempo real para todos los usuarios conectados
- **FR-005**: El sistema DEBE mostrar en tiempo real la lista de nombres de usuarios actualmente conectados al chat
- **FR-006**: El sistema DEBE actualizar la lista de usuarios conectados automáticamente cuando alguien se une o abandona
- **FR-007**: El sistema DEBE permitir al administrador ingresar un prompt en lenguaje natural para generar un fondo del chat
- **FR-008**: El sistema DEBE enviar el prompt a Gemini via Firebase AI y utilizar la respuesta para actualizar el fondo del chat
- **FR-009**: El sistema DEBE aplicar el fondo generado a todos los usuarios conectados en tiempo real
- **FR-010**: El sistema DEBE persistir el fondo activo para que nuevos usuarios que se conecten también lo vean
- **FR-011**: El sistema DEBE mostrar un indicador de carga mientras la IA procesa el prompt
- **FR-012**: El sistema DEBE mostrar un mensaje de error descriptivo si la generación del fondo falla, sin alterar el fondo actual
- **FR-013**: El sistema DEBE requerir confirmación antes de ejecutar la acción de limpiar el chat
- **FR-014**: El panel de administración NO DEBE ser accesible ni visible para usuarios regulares del chat

### Key Entities

- **AdminSession**: Representa una sesión autenticada del administrador; atributos: estado de autenticación, timestamp de inicio de sesión
- **ChatMessage**: Mensajes en el historial del chat; afectados por la acción de limpieza
- **ConnectedUser**: Usuario activo en el chat; atributos: nombre, timestamp de conexión
- **ChatBackground**: Fondo activo del chat; atributos: tipo (color, gradiente, imagen, CSS generado), valor, timestamp de última actualización, prompt que lo generó

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El administrador puede autenticarse en el panel en menos de 15 segundos desde que navega a la URL
- **SC-002**: La acción de limpiar el chat se propaga a todos los usuarios conectados en menos de 2 segundos
- **SC-003**: La lista de usuarios conectados se actualiza en menos de 3 segundos tras un cambio de conexión
- **SC-004**: El cambio de fondo generado por IA se aplica a todos los usuarios en menos de 5 segundos una vez que la IA responde
- **SC-005**: Los intentos de acceso con contraseña incorrecta son rechazados el 100% de las veces
- **SC-006**: El fondo generado persiste correctamente para usuarios que se conectan después del cambio

## Assumptions

- La contraseña de administrador se almacena de forma segura en la configuración del lado del cliente (variable de entorno o configuración de build), ya que es un único administrador personal
- La aplicación ya cuenta con un sistema de chat funcional con usuarios identificados por nombre
- Los usuarios conectados pueden ser rastreados mediante presencia en Firebase Realtime Database o Firestore
- Gemini via Firebase AI responderá con un valor utilizable para un fondo CSS (color, gradiente o descripción que se traduzca a estilos visuales) — no necesariamente genera imágenes, sino que puede generar valores CSS o nombres de gradientes
- El panel de administración es una pantalla separada dentro de la misma aplicación Flutter, no una aplicación web independiente
- No se requiere registro de auditoría de acciones del administrador para esta versión
- La sesión del administrador persiste solo mientras la aplicación está abierta; no hay tokens de sesión persistentes entre reinicios
