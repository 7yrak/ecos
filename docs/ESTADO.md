# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-18
- Fase activa: Fase 2 - Vertical slice
- Hito activo: validacion externa para cerrar la vertical slice
- Estado general: alcance funcional de Fase 2 completado; balance fisico pendiente
- Ultima sesion: ecos acumulativos desde el origen y presion sin limite superior

## Ultimo resultado verificable

- Git esta inicializado en la rama `main`.
- Todo el codigo, la documentacion y la configuracion viven en este repositorio.
- El remoto oficial es `https://github.com/7yrak/ecos.git`.
- Godot 4.7.1, Java 21 y Android SDK 36 estan configurados.
- El proyecto base usa orientacion vertical, resolucion logica 720 x 1280 y el
  renderizador Compatibility.
- La APK release `0.2.5` (`versionCode 8`) se exporto y firmo para ARM64 y x86_64.
- La APK instalable esta versionada en `releases/ECOS-0.2.5-android.apk` para descarga
  directa desde GitHub.
- La APK publica no es depurable, no es `testOnly` y no solicita permisos de Android.
- La APK se instalo y ejecuto en un emulador Android 15 x86_64.
- Se verifico visualmente la pantalla inicial y no hubo errores de aplicacion con
  el renderizado por GPU host.
- El jugador responde a toque, arrastre y mouse, con limites fisicos de arena.
- El recorrido se acumula desde el inicio; cada cinco segundos nace en el origen un
  eco retardado que sigue ese historial compartido sin reiniciar ventanas.
- Chocar con un eco o un obstaculo finaliza la partida; tocar un limite solo detiene.
- El HUD muestra tiempo, puntos y ecos, y el boton de resultado reinicia la partida.
- Pasan 92 verificaciones headless, incluidos diez ciclos tecnicos consecutivos y
  el flujo completo de navegacion.
- T01 jugo unas quince partidas en un Galaxy S25 Ultra, entendio el eco sin ayuda,
  quiso superar su puntuacion y no informo fallos tecnicos.
- T01 detecto repeticion despues de dominar el ritmo: la partida cambia poco y la
  acumulacion de ecos dificulta continuar superandose.
- T02-T08 jugaron unas diez partidas en promedio en Galaxy A25 y S25; los siete
  entendieron el eco, quisieron repetir y no informaron fallos tecnicos.
- Los ocho testers confirmaron que la mecanica motiva inicialmente, pero termina
  repetitiva y necesita variedad, menu y mejor presentacion.
- El menu principal permite jugar y abrir un tutorial; el resultado permite repetir
  la ronda o volver al menu sin recargar toda la aplicacion.
- El menu y la arena ocupan pantallas desde 9:16 hasta 20:9 sin barras negras; el
  mundo de juego conserva sus coordenadas internas y se centra verticalmente.
- Volumen, vibracion y sensibilidad se guardan en `user://settings.cfg` y se
  restauran al relanzar la aplicacion.
- La sensibilidad modifica velocidad y aceleracion; la vibracion se aplica al final
  de una ronda cuando esta habilitada.
- La arena usa barreras fijas, una patrulla movil y un pulso con aviso seguro.
- La patrulla aparece a los 12 segundos y el pulso a los 24; el HUD informa la etapa.
- Solo cuatro ecos permanecen activos y el resultado conserva el total creado.
- La presentacion inicial se comprobo en Android 15 a 1080 x 2400 sin errores de
  aplicacion; patrulla, pulso y reinicio se validaron de forma automatizada.
- Eco, etapa, pulso e impacto tienen sonidos PCM sintetizados en memoria.
- Eco, etapa, pulso e impacto generan ondas o flashes visuales no bloqueantes.
- Se corrigio la posicion global de ecos en relaciones 20:9.
- La compilacion debug mostro la onda del eco en Android 15 sin errores de audio ni
  GDScript. El release final se verifico por firma y metadatos; falta probarlo en un
  telefono fisico.
- Cada segmento mide la distancia recorrida. Recorrer menos de 280 px aumenta la
  presion 0.2x sin limite superior configurado.
- Recuperar un ritmo activo reduce la presion de a un nivel por segmento; HUD,
  banner, sonido y efecto dorado comunican el cambio sin detener la partida.
- El origen compartido se comprobo en Android 15 a 1080 x 2400 con dos ecos activos
  y una partida de 11.1 segundos sin errores; la presion se reinicia entre partidas.
- La Fase 3 define Fragmentos ganables jugando, precios iniciales para cosmeticos y
  proteccion contra rondas demasiado cortas usadas para cultivar moneda.
- El primer concepto online es Duelo de Ecos 1v1: arenas separadas con igual semilla
  e intercambio de segmentos, respaldado por un servidor autoritativo.

## Siguiente accion exacta

Instalar `0.2.5` en Galaxy A25 y S25. Confirmar que todos los ecos nacen en el punto
inicial, probar varios segmentos lentos para superar x1.6 y luego moverse activamente
para validar la recuperacion; completar diez partidas para decidir el cierre de Fase 2.

## Tareas pendientes inmediatas

- [x] Cerrar Fase 1 con al menos cinco testers.
- [x] Crear menu principal con identidad visual.
- [x] Agregar tutorial accesible desde el menu.
- [x] Implementar navegacion entre menu, partida y resultado.
- [x] Validar el flujo nuevo en Android.
- [x] Adaptar la interfaz y arena a relaciones de aspecto altas.
- [x] Agregar ajustes de sonido, vibracion y sensibilidad.
- [x] Disenar progresion de arena y control de saturacion de ecos.
- [x] Implementar tres tipos de obstaculo.
- [x] Agregar sonido y efectos visuales de impacto y cambio de etapa.
- [x] Detectar movimiento lento y aumentar progresivamente la velocidad de los ecos.
- [x] Hacer que los ecos nazcan en el origen y sigan una ruta acumulada sin bucles.
- [x] Eliminar el limite superior de presion solicitado en la prueba fisica.
- [x] Definir las reglas iniciales de Fragmentos y el concepto online 1v1.
- [ ] Validar tiempos de etapa y limite de ecos con jugadores externos.
- [ ] Validar el umbral y los multiplicadores de presion en telefonos fisicos.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay bloqueos tecnicos para continuar la Fase 2.
- La identidad `com.tyrak.ecos` sigue siendo provisional y no bloquea el prototipo.

## Riesgos actuales

- Aumentar dificultad solo mediante ecos produce saturacion y repeticion.
- Un umbral de movimiento demasiado agresivo puede castigar a jugadores nuevos o
  con necesidades de accesibilidad; debe ajustarse con pruebas fisicas.
- Una presion muy alta puede volver ilegible el movimiento; se mantiene sin limite
  por diseno, pero debe observarse su comportamiento real en sesiones largas.
- Agregar contenido sin una curva clara puede ocultar el problema en vez de resolverlo.
- La monetizacion no garantiza ingresos; depende de adquisicion y retencion.

## Regla de cierre de sesion

Antes de terminar cualquier sesion:

1. Actualizar la fecha, fase, resultado y siguiente accion de este archivo.
2. Marcar tareas terminadas o agregar las nuevas.
3. Anadir una entrada al inicio de `docs/BITACORA.md`.
4. Registrar decisiones nuevas en `docs/DECISIONES.md`.
5. Indicar pruebas ejecutadas y cualquier fallo pendiente.
