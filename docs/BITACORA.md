# Bitacora de desarrollo

Historial cronologico del proyecto. Las entradas anteriores no se reescriben; las
correcciones se documentan en una entrada nueva. La entrada mas reciente va
primero.

## 2026-07-18 - Solicitud de menu y mejor presentacion

Fase: Fase 1 - Prototipo de mecanica

Resultado:

- Se recibio feedback adicional de varios jugadores: el prototipo necesita un menu
  y mas elementos de presentacion para resultar llamativo.
- El comentario coincide con el alcance previsto de la Fase 2, que incluye inicio,
  tutorial, ajustes, partida y resultado.

Decision:

- Se agrega un menu principal con identidad visual como entregable explicito de la
  vertical slice.
- No se agregaran sistemas indefinidos bajo "mas cosas"; se priorizaran variedad de
  juego, claridad y presentacion.
- Este feedback no cuenta aun como T02-T05 porque faltan cantidad de jugadores y
  respuestas individuales del protocolo.

Siguiente accion:

- Identificar a cada tester adicional y completar su registro de Fase 1.

## 2026-07-18 - Resultado completo de T01

Fase: Fase 1 - Prototipo de mecanica

Resultado:

- T01 jugo aproximadamente quince partidas en un Galaxy S25 Ultra.
- Entendio sin explicacion que el eco repite movimientos anteriores.
- Quiso repetir para superar su puntuacion y no informo fallos tecnicos.
- Tras dominar el ritmo, percibio que la experiencia se vuelve repetitiva porque
  la arena cambia poco.
- La acumulacion de muchos ecos termino reduciendo su expectativa de seguir
  superandose.

Decision:

- T01 cuenta como una prueba completa y positiva para el criterio de Fase 1.
- La futura vertical slice debe introducir variedad y una curva de dificultad que
  no escale solamente mediante mas ecos.
- Se esperaran T02-T05 para confirmar si el problema es un patron antes de fijar la
  mecanica exacta que lo resolvera.

Siguiente accion:

- Ejecutar el mismo protocolo con cuatro personas adicionales.

## 2026-07-18 - Primera prueba externa positiva

Fase: Fase 1 - Prototipo de mecanica

Resultado:

- T01 confirmo que pudo instalar y probar la APK release en un telefono Android.
- No informo fallos tecnicos y evaluo espontaneamente el juego como "super buena".
- Se marco como cumplida la prueba en al menos un telefono fisico.

Decision:

- La Fase 1 permanece activa porque el criterio exige cinco testers, cuatro que
  comprendan el eco y tres que quieran repetir.
- No se infieren respuestas que T01 todavia no entrego.

Siguiente accion:

- Completar el registro de T01 y realizar cuatro pruebas adicionales antes de
  comenzar la Fase 2.

## 2026-07-18 - APK release para pruebas externas

Fase: Fase 1 - Prototipo de mecanica

Problema:

- Play Protect bloqueo la APK anterior al intentar instalarla desde GitHub.
- La APK estaba firmada con el certificado debug generico de Godot y declaraba
  `android:debuggable=true`.

Cambios:

- Se instalo la plantilla oficial `android_release.apk` de Godot 4.7.1.
- Se creo una clave local propia de ECOS, excluida del repositorio.
- Se agrego `scripts/dev/export_android_release.sh` con firma mediante variables de
  entorno y una comprobacion que rechaza APK depurables.
- Se reemplazo el artefacto publico por `releases/ECOS-0.1.0-android.apk`.

Verificacion:

- La APK no declara `debuggable`, `testOnly` ni permisos de Android.
- Las firmas APK v2 y v3 son validas.
- La instalacion limpia en Android 15 termino correctamente, el juego inicio y el
  log no mostro errores de aplicacion.
- SHA-256: `0db110a3282e615ce3464c3d272b9a613b6113bd0c8104137f12b953cbbc456b`.

Pendiente:

- Probar la nueva descarga en el telefono que presento el bloqueo.
- Respaldar la clave de firma fuera del equipo antes de una publicacion definitiva.

## 2026-07-18 - APK de Fase 1 disponible en GitHub

Fase: Fase 1 - Prototipo de mecanica

Resultado:

- Se agrego `releases/ECOS-0.1.0-debug.apk` al repositorio para permitir su descarga
  directa desde GitHub.
- El APK pesa 57,4 MB y conserva la firma debug validada de la Fase 1.
- SHA-256: `e0ff8705b277e939916bba64491b27348fe49061cdc6a2cedd97e0ab6895b8bd`.

Siguiente accion:

- Descargar el APK desde el README y ejecutar el protocolo con cinco testers.

## Plantilla

```text
## AAAA-MM-DD - Titulo de la sesion

Fase:
Objetivo:

Cambios:
-

Decisiones:
-

Verificacion:
-

Pendiente:
-

Siguiente accion:
-
```

## 2026-07-18 - Prototipo jugable de Fase 1

Fase: Fase 1 - Prototipo de mecanica

Objetivo: implementar y validar el bucle basico de movimiento, grabacion y colision
con ecos.

Cambios:

- Se reemplazo la pantalla tecnica por una arena jugable vertical.
- Se implemento movimiento suave mediante toque, arrastre y mouse.
- Se agregaron limites fisicos y dos obstaculos peligrosos.
- Se implemento `EchoTimeline` con muestras ordenadas, interpolacion y copias
  inmutables.
- Se graba un tramo cada cinco segundos y se crea un eco que lo reproduce en bucle.
- Se agregaron colisiones con ecos, puntuacion, tiempo, contador de ecos, pantalla
  de resultado y reinicio tactil.
- Se creo un runner de pruebas headless y un protocolo para cinco testers.
- Se identifico la build del prototipo como `0.1.0`.

Decisiones:

- El prototipo usa movimiento hacia la posicion tocada, no un joystick virtual.
- Cada eco reproduce en bucle un segmento independiente de cinco segundos.
- Los limites contienen al jugador; los ecos y obstaculos terminan la partida.
- La Fase 2 no comienza hasta evaluar la comprension y repeticion con cinco personas.

Verificacion:

- Pasan 29 verificaciones automatizadas.
- Se completan diez ciclos tecnicos consecutivos sin errores.
- Se verifican interpolacion, copias inmutables, capas fisicas y creacion de ecos.
- Las pruebas fisicas confirman colision mortal con obstaculos y contencion en muros.
- La APK se instalo en Android 15 x86_64.
- Se verificaron visualmente movimiento tactil, eco, resultado y reinicio.
- El log Android quedo limpio despues de corregir el cambio de `monitoring` dentro
  de la senal fisica.

Pendiente:

- Ejecutar `docs/PRUEBAS_FASE1.md` con al menos cinco personas en telefonos reales.
- Ajustar velocidad, intervalo o control segun los resultados.

Siguiente accion:

- Realizar las pruebas externas y decidir si la mecanica pasa a Fase 2.

## 2026-07-18 - Publicacion del repositorio

Fase: Fase 1 - Prototipo de mecanica

Objetivo: publicar el historial local en el repositorio GitHub oficial de ECOS.

Cambios:

- Se configuro `https://github.com/7yrak/ecos.git` como remoto `origin`.
- Se preparo la publicacion de la rama `main` con seguimiento remoto.

Decisiones:

- `https://github.com/7yrak/ecos` es el repositorio remoto oficial.
- El repositorio remoto es publico.

Verificacion:

- GitHub CLI esta autenticado con acceso al repositorio.
- El repositorio remoto estaba vacio antes de la primera publicacion.
- No existia historial remoto que pudiera ser sobrescrito.

Pendiente:

- Agregar GitHub Actions cuando las pruebas automatizadas de la Fase 1 aporten
  una validacion util.

Siguiente accion:

- Implementar movimiento tactil y limites de arena.

## 2026-07-18 - Versionado inicial

Fase: Fase 1 - Prototipo de mecanica

Objetivo: versionar en la carpeta actual todo el trabajo completado hasta el cierre
de la Fase 0.

Cambios:

- Se confirmo `/home/tyrak/proyectos/ecos` como raiz del repositorio Git.
- Se revisaron los archivos incluidos y las exclusiones de `.gitignore`.
- Se preparo el primer commit del proyecto en la rama `main`.

Decisiones:

- Todo el codigo, documentacion y configuracion del juego se versionara en este
  mismo repositorio.
- Jenkins no se utilizara durante el prototipo; agregaria mantenimiento sin aportar
  valor en esta etapa.
- Si se necesita integracion continua, se comenzara con GitHub Actions despues de
  configurar el remoto.

Verificacion:

- Caches de Godot, builds, capturas, configuracion del IDE y credenciales estan
  ignorados.
- La identidad Git local esta configurada.
- GitHub CLI esta autenticado, pero el repositorio todavia no tiene remoto `origin`.

Pendiente:

- Decidir si el futuro repositorio remoto sera publico o privado.
- Configurar `origin` y publicar `main` si el usuario lo solicita.

Siguiente accion:

- Continuar con el prototipo de movimiento de la Fase 1.

## 2026-07-18 - Fase 0 completada

Fase: Fase 0 - Preparacion

Objetivo: crear un proyecto reproducible y comprobar una ejecucion Android real.

Cambios:

- Se inicializo Git en la rama `main` y se agregaron exclusiones para builds,
  caches, IDE y credenciales.
- Se instalo Godot 4.7.1 estable y la plantilla Android debug.
- Se instalaron Android SDK Platform 36, Build Tools 36.0.0, Platform Tools 37,
  el emulador y una imagen Android 15 x86_64.
- Se creo el proyecto Godot vertical 720 x 1280 con renderizador Compatibility.
- Se creo una pantalla inicial, un icono provisional y anillos animados.
- Se agrego el preset `Android Debug` para ARM64 y x86_64.
- Se agregaron scripts reproducibles de verificacion, exportacion e instalacion.

Decisiones:

- Se fijo Godot 4.7.1 y Target SDK 36.
- Se mantiene Compatibility por su soporte para juegos 2D y dispositivos modestos.
- El paquete provisional es `com.tyrak.ecos`.
- La orientacion provisional es vertical.

Verificacion:

- El proyecto abre y ejecuta en Godot headless sin errores de escena o script.
- La APK debug se genero, firmo y verifico correctamente.
- La APK contiene bibliotecas ARM64 y x86_64.
- La APK se instalo en Android 15 y el proceso `com.tyrak.ecos` permanecio activo.
- Se comprobo visualmente la pantalla inicial a 1080 x 2400.
- No aparecieron errores de la aplicacion usando la GPU host del emulador.
- SwiftShader produjo el issue conocido `godotengine/godot#109550`; no se cambio el
  renderizador porque el problema pertenece al compilador virtual de SwiftShader.

Pendiente:

- Confirmar el paquete Android y el nombre del estudio antes de Google Play.
- Desarrollar la mecanica del jugador y los ecos.

Siguiente accion:

- Comenzar la Fase 1 con movimiento tactil y limites de arena.

## 2026-07-18 - Inicio formal del proyecto

Fase: Fase 0 - Preparacion

Objetivo: definir el concepto inicial, seleccionar la arquitectura y crear un
sistema que permita reanudar el desarrollo sin perder contexto.

Cambios:

- Se definio el concepto inicial de ECOS.
- Se selecciono Godot 4 con GDScript.
- Se definio una arquitectura de monolito modular con adaptadores para Android.
- Se creo el roadmap por fases y el alcance inicial del MVP.
- Se crearon los documentos de estado, bitacora, decisiones y diseno.
- Se inspecciono el entorno local.

Decisiones:

- El primer lanzamiento sera un juego 2D de partidas de 45 a 90 segundos.
- El MVP funcionara sin backend.
- Los anuncios y las compras se aislaran detras de servicios para no acoplar el
  gameplay a un proveedor.

Verificacion:

- El directorio solo contenia configuracion de IntelliJ.
- El directorio no estaba inicializado como repositorio Git.
- Java y Git estan disponibles.
- Godot, Android SDK, `adb`, `sdkmanager` y Gradle no estan disponibles.

Pendiente:

- Confirmar orientacion, estilo visual, publico y plataforma inicial.
- Preparar el entorno de desarrollo.
- Construir el primer prototipo jugable.

Siguiente accion:

- Resolver las decisiones pendientes de `docs/ESTADO.md` y completar la Fase 0.
