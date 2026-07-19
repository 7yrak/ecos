# Decisiones del proyecto

Las decisiones aceptadas solo se cambian registrando una nueva decision con su
motivo. Esto evita modificar la direccion del proyecto sin dejar rastro.

## D-001 - Motor y lenguaje

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: usar Godot 4 estable y GDScript.
- Motivo: el alcance es 2D, el equipo es pequeno y se necesita iteracion rapida sin
  coste de licencia del motor.
- Consecuencia: las integraciones Android se implementaran como plugins v2 o
  adaptadores compatibles con Godot.

## D-002 - Arquitectura

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: usar un monolito modular orientado a componentes.
- Motivo: Clean Architecture completa, ECS o microservicios no aportan valor al
  MVP y aumentarian el tiempo hasta la primera prueba.
- Consecuencia: gameplay, progresion, interfaz y plataforma tendran limites claros
  dentro de un solo proyecto.

## D-003 - Simulacion de ecos

- Fecha: 2026-07-18
- Estado: propuesta para validar en prototipo
- Decision: grabar muestras de posicion, tiempo y acciones, y reproducir datos
  inmutables en lugar de clonar toda la logica del jugador.
- Motivo: reduce complejidad y hace los ecos predecibles.
- Consecuencia: la frecuencia de muestreo y la interpolacion deben probarse en la
  Fase 1.

## D-004 - Backend

- Fecha: 2026-07-18
- Estado: aceptada para el MVP
- Decision: no utilizar cuentas ni backend durante las primeras fases.
- Motivo: no son necesarios para demostrar diversion y retencion.
- Consecuencia: el progreso inicial sera local; compras y servicios en linea se
  agregaran solo cuando exista evidencia de que aportan valor.

## D-005 - Monetizacion

- Fecha: 2026-07-18
- Estado: propuesta recomendada
- Decision: priorizar anuncios recompensados y limitar los intersticiales a pausas
  naturales.
- Motivo: permite monetizar sin interrumpir la partida.
- Consecuencia: la publicidad se implementara despues de validar el gameplay.

## D-006 - Configuracion inicial de Android

- Fecha: 2026-07-18
- Estado: provisional hasta publicacion
- Decision: usar orientacion vertical, 720 x 1280 y `com.tyrak.ecos`.
- Motivo: permite avanzar con el prototipo sin bloquearse por identidad comercial.
- Consecuencia: el paquete y el nombre del estudio deben confirmarse antes de crear
  la aplicacion definitiva en Google Play.

## D-007 - Renderizador

- Fecha: 2026-07-18
- Estado: aceptada para el prototipo
- Decision: usar el renderizador Compatibility.
- Motivo: ECOS es 2D y busca soportar dispositivos Android modestos.
- Consecuencia: el emulador local debe usar GPU host porque SwiftShader presenta el
  issue conocido `godotengine/godot#109550` con Godot 4.7.1.

## D-008 - Versionado e integracion continua

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: versionar todo ECOS en el repositorio de la carpeta actual y no usar
  Jenkins durante el prototipo.
- Motivo: un servidor Jenkins requiere instalacion, actualizaciones, credenciales y
  mantenimiento que no se justifican para un proyecto individual en Fase 1.
- Consecuencia: las validaciones se ejecutan mediante scripts locales. Cuando exista
  un remoto GitHub, la primera opcion de CI sera GitHub Actions.

## D-009 - Control y segmentacion de ecos

- Fecha: 2026-07-18
- Estado: aceptada para prueba de Fase 1
- Decision: mover hacia la posicion tocada y generar un eco por cada segmento de
  cinco segundos.
- Motivo: el control se entiende con un dedo y los segmentos independientes mantienen
  acotado el costo de grabacion y reproduccion.
- Consecuencia: velocidad, duracion y frecuencia se consideran parametros de balance
  que pueden cambiar despues de las pruebas con jugadores.

## D-010 - Salida de Fase 1 y prioridad de la vertical slice

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: cerrar la Fase 1 con ocho jugadores validados e iniciar la Fase 2 por
  el flujo de menu, tutorial, partida y resultado.
- Motivo: los ocho jugadores entendieron el eco y quisieron repetir, pero reportaron
  repeticion y falta de presentacion despues de varias partidas.
- Consecuencia: la vertical slice debe mejorar presentacion y variedad antes de
  agregar monetizacion o progresion extensa.

## Decisiones pendientes del usuario

- Estilo visual definitivo.
- Publico objetivo y clasificacion de edad buscada.
- Android solamente o futura version para otras plataformas.
- Nombre de paquete Android y nombre del estudio/desarrollador.
