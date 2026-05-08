# Feature Specification: Flutter Web Chat con Burbujas Generadas por IA

**Feature Branch**: `001-firebase-genui-chat`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "I need to make a flutter web application that uses the package https://pub.dev/packages/genui, I want the app to be a chat with firebase and the chat bubbles will be generated with gen_ui"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Enviar y Recibir Mensajes en el Chat (Priority: P1)

Un usuario abre la aplicación web, escribe su nombre y accede a la sala de chat. Puede escribir un mensaje y enviarlo. Tanto su burbuja como las burbujas de los demás participantes son generadas dinámicamente por `gen_ui` — el LLM decide cómo renderizar visualmente cada mensaje. Todos los participantes ven los mensajes en tiempo real.

**Why this priority**: Es la funcionalidad central de la aplicación. Sin ella, no existe producto.

**Independent Test**: Se puede probar de forma aislada abriendo la app, enviando un mensaje y verificando que aparece como burbuja visible en pantalla y en la base de datos de Firebase.

**Acceptance Scenarios**:

1. **Given** el usuario tiene un nombre en sesión y está en la sala de chat, **When** escribe un mensaje y presiona "Enviar", **Then** el mensaje aparece como una burbuja generada por `gen_ui` tanto en su pantalla como en la de los demás participantes en tiempo real.
2. **Given** dos usuarios están en la misma sala, **When** uno envía un mensaje, **Then** ambos ven una burbuja `gen_ui` con el contenido correcto y el nombre del remitente visible.
3. **Given** el usuario envía un mensaje vacío, **When** presiona "Enviar", **Then** el sistema NO envía el mensaje y muestra un aviso visual.

---

### User Story 2 - Identificación por Nombre de Usuario (Priority: P2)

Un usuario nuevo visita la aplicación, escribe un nombre de usuario y accede directamente al chat. No se requiere registro de cuenta, email ni contraseña.

**Why this priority**: Sin un nombre de usuario no es posible identificar a los participantes del chat en las burbujas de mensajes.

**Independent Test**: Se puede probar de forma aislada abriendo la app, ingresando un nombre y verificando que se accede al chat y que los mensajes del usuario aparecen con ese nombre.

**Acceptance Scenarios**:

1. **Given** el usuario abre la aplicación por primera vez, **When** escribe un nombre de usuario válido y confirma, **Then** accede directamente al chat sin pasos adicionales.
2. **Given** el usuario intenta continuar con un nombre vacío o solo espacios, **When** intenta confirmar, **Then** el sistema muestra un aviso y no permite avanzar.
3. **Given** el usuario tiene un nombre asignado en la sesión actual, **When** navega directamente a la URL del chat, **Then** accede sin ver la pantalla de nombre nuevamente.
4. **Given** el usuario cierra el navegador y vuelve a abrir la app, **When** se carga la página, **Then** se le pide nuevamente el nombre de usuario (la sesión no persiste entre navegaciones).

---

### User Story 3 - Visualización del Historial de Mensajes (Priority: P3)

Un usuario que se une a una sala de chat puede ver los mensajes anteriores enviados en esa sala, mostrados como burbujas generadas por `gen_ui`, ordenados cronológicamente.

**Why this priority**: Permite a los usuarios entender el contexto de la conversación en curso.

**Independent Test**: Se puede probar accediendo a una sala con mensajes previos y verificando que el historial carga correctamente con burbujas renderizadas.

**Acceptance Scenarios**:

1. **Given** existe historial de mensajes en la sala, **When** el usuario entra al chat, **Then** los mensajes anteriores se cargan y se muestran como burbujas ordenadas del más antiguo al más reciente.
2. **Given** la sala no tiene mensajes previos, **When** el usuario entra, **Then** se muestra un estado vacío amigable indicando que no hay mensajes aún.
3. **Given** hay muchos mensajes en la sala, **When** el usuario carga el historial, **Then** los mensajes se cargan de forma paginada o progresiva para evitar degradación del rendimiento.

---

### User Story 4 - Distinción Visual entre Mensajes Propios y Ajenos (Priority: P3)

Todas las burbujas son generadas por `gen_ui`, pero el LLM recibe contexto sobre si el mensaje es propio o ajeno. Las burbujas propias aparecen alineadas a la derecha y las ajenas a la izquierda, con estilos visuales diferenciados generados por el LLM.

**Why this priority**: Es una convención estándar de UX en aplicaciones de chat que mejora la legibilidad.

**Independent Test**: Se puede probar enviando mensajes desde dos cuentas diferentes y verificando la alineación y estilo visual de cada burbuja.

**Acceptance Scenarios**:

1. **Given** el usuario envía un mensaje, **When** la burbuja se renderiza, **Then** aparece alineada a la derecha con estilo visual de "mensaje propio".
2. **Given** otro usuario envía un mensaje, **When** la burbuja se renderiza para el observador, **Then** aparece alineada a la izquierda con estilo visual de "mensaje ajeno" y el nombre del remitente visible.

---

### Edge Cases

- ¿Qué sucede cuando el usuario pierde la conexión a internet mientras escribe un mensaje?
- ¿Cómo se comporta el chat si Firebase retarda la sincronización de mensajes?
- ¿Qué pasa si `gen_ui` no puede renderizar una burbuja debido a datos malformados?
- ¿Cómo se maneja el scroll automático cuando llegan nuevos mensajes mientras el usuario revisa el historial?
- ¿Qué sucede si un usuario intenta acceder a la URL del chat sin haber ingresado su nombre?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE solicitar al usuario un nombre de usuario (texto libre, mínimo 1 carácter sin contar espacios) antes de acceder al chat.
- **FR-002**: El sistema DEBE redirigir automáticamente a usuarios sin nombre de usuario a la pantalla de entrada al intentar acceder al chat.
- **FR-003**: El sistema DEBE permitir a los usuarios enviar mensajes de texto en tiempo real, almacenados en Firebase Firestore.
- **FR-004**: El sistema DEBE renderizar TODAS las burbujas de chat (mensajes propios y ajenos) como superficies dinámicas generadas por `gen_ui`, sin usar widgets de burbuja Flutter estándar.
- **FR-005**: El sistema DEBE pasar al LLM el contexto `isOwn: true/false` para que genere estilos visuales diferenciados: propios alineados a la derecha, ajenos a la izquierda.
- **FR-006**: El sistema DEBE actualizar la interfaz en tiempo real cuando llegan nuevos mensajes, sin requerir recarga de página.
- **FR-007**: Los usuarios DEBEN poder ver el historial de mensajes previos al unirse a una sala de chat, cargados desde Firebase Firestore.
- **FR-008**: El sistema DEBE validar que los mensajes no estén vacíos antes de permitir su envío.
- **FR-009**: El sistema DEBE mostrar el nombre o identificador del remitente en cada burbuja de mensaje ajeno.
- **FR-010**: El sistema DEBE permitir al usuario cambiar su nombre de usuario o salir del chat, lo que lo devuelve a la pantalla de entrada de nombre.
- **FR-011**: El sistema DEBE funcionar correctamente en navegadores web modernos (Chrome, Firefox, Safari, Edge).

### Key Entities *(include if feature involves data)*

- **Usuario**: Participante del chat identificado únicamente por el nombre de usuario elegido en la sesión. Atributos clave: nombre de usuario (elegido al entrar), identificador de sesión anónimo.
- **Mensaje**: Unidad de comunicación enviada por un usuario en una sala. Atributos clave: contenido de texto, identificador del remitente, marca de tiempo, identificador de sala.
- **Sala de Chat**: Espacio de conversación donde los mensajes se agrupan. Atributos clave: identificador único, lista de participantes (asumido como sala pública compartida en v1).
- **Burbuja de Chat (gen_ui)**: Representación visual de cualquier mensaje (propio o ajeno), generada dinámicamente por el paquete `gen_ui`. El LLM recibe el texto, el nombre del remitente y si el mensaje es propio, y decide cómo renderizarlo visualmente.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Un usuario puede completar el flujo completo de ingresar nombre, enviar mensaje y visualizar la respuesta en menos de 1 minuto.
- **SC-002**: Los mensajes aparecen en la interfaz del receptor en menos de 2 segundos desde que el remitente los envía, bajo condiciones normales de red.
- **SC-003**: El historial de mensajes carga correctamente para salas con hasta 500 mensajes sin degradación visible de la interfaz.
- **SC-004**: El 100% de los mensajes enviados se muestran como burbujas correctamente renderizadas por `gen_ui`, sin errores de visualización.
- **SC-005**: El 100% de los usuarios puede ingresar al chat con solo escribir un nombre, sin necesidad de instrucciones externas.
- **SC-006**: La aplicación funciona de forma consistente en los cuatro navegadores principales (Chrome, Firefox, Safari, Edge).

## Assumptions

- Los usuarios acceden a la aplicación desde un navegador web moderno con conexión a internet estable.
- Se asume una sala de chat única o un número reducido de salas públicas para la versión inicial (v1); la gestión de múltiples salas privadas queda fuera de scope.
- No se requiere autenticación formal en v1; el acceso al chat se habilita con solo proporcionar un nombre de usuario. La identidad no persiste entre sesiones del navegador.
- El paquete `gen_ui` de pub.dev acepta parámetros suficientes para diferenciar visualmente los mensajes propios de los ajenos (alineación, color, estilo).
- Los mensajes son únicamente de texto en v1; archivos adjuntos, imágenes o emojis enriquecidos están fuera de scope.
- Se reutilizará la infraestructura de Firebase (proyecto existente o nuevo) configurada por el equipo de desarrollo.
- La aplicación Flutter se construye en modo web (`flutter build web`) y no requiere soporte nativo de iOS/Android en esta iteración.
- No se requieren notificaciones push para la versión inicial.
