# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-18
- Fase activa: Fase 2 - Vertical slice
- Hito activo: variedad de arena y control de saturacion de ecos
- Estado general: interfaz base de Fase 2 completada; variedad jugable pendiente
- Ultima sesion: pantalla adaptable y ajustes persistentes validados en Android

## Ultimo resultado verificable

- Git esta inicializado en la rama `main`.
- Todo el codigo, la documentacion y la configuracion viven en este repositorio.
- El remoto oficial es `https://github.com/7yrak/ecos.git`.
- Godot 4.7.1, Java 21 y Android SDK 36 estan configurados.
- El proyecto base usa orientacion vertical, resolucion logica 720 x 1280 y el
  renderizador Compatibility.
- La APK release `0.2.1` (`versionCode 4`) se exporto y firmo para ARM64 y x86_64.
- La APK instalable esta versionada en `releases/ECOS-0.2.1-android.apk` para descarga
  directa desde GitHub.
- La APK publica no es depurable, no es `testOnly` y no solicita permisos de Android.
- La APK se instalo y ejecuto en un emulador Android 15 x86_64.
- Se verifico visualmente la pantalla inicial y no hubo errores de aplicacion con
  el renderizado por GPU host.
- El jugador responde a toque, arrastre y mouse, con limites fisicos de arena.
- Cada tramo de cinco segundos se graba e instancia como un eco repetible.
- Chocar con un eco o un obstaculo finaliza la partida; tocar un limite solo detiene.
- El HUD muestra tiempo, puntos y ecos, y el boton de resultado reinicia la partida.
- Pasan 46 verificaciones headless, incluidos diez ciclos tecnicos consecutivos y
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
- La APK `0.2.1` se instalo y recorrio por toque en Android 15 sin errores.

## Siguiente accion exacta

Disenar e implementar progresion de arena con tres tipos de obstaculo y un limite
de ecos activos que evite saturacion.

## Tareas pendientes inmediatas

- [x] Cerrar Fase 1 con al menos cinco testers.
- [x] Crear menu principal con identidad visual.
- [x] Agregar tutorial accesible desde el menu.
- [x] Implementar navegacion entre menu, partida y resultado.
- [x] Validar el flujo nuevo en Android.
- [x] Adaptar la interfaz y arena a relaciones de aspecto altas.
- [x] Agregar ajustes de sonido, vibracion y sensibilidad.
- [ ] Disenar progresion de arena y control de saturacion de ecos.
- [ ] Implementar tres tipos de obstaculo.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay bloqueos tecnicos para continuar la Fase 2.
- La identidad `com.tyrak.ecos` sigue siendo provisional y no bloquea el prototipo.

## Riesgos actuales

- Aumentar dificultad solo mediante ecos produce saturacion y repeticion.
- Agregar contenido sin una curva clara puede ocultar el problema en vez de resolverlo.
- La monetizacion no garantiza ingresos; depende de adquisicion y retencion.

## Regla de cierre de sesion

Antes de terminar cualquier sesion:

1. Actualizar la fecha, fase, resultado y siguiente accion de este archivo.
2. Marcar tareas terminadas o agregar las nuevas.
3. Anadir una entrada al inicio de `docs/BITACORA.md`.
4. Registrar decisiones nuevas en `docs/DECISIONES.md`.
5. Indicar pruebas ejecutadas y cualquier fallo pendiente.
