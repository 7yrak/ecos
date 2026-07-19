# Bitacora de desarrollo

Historial cronologico del proyecto. Las entradas anteriores no se reescriben; las
correcciones se documentan en una entrada nueva. La entrada mas reciente va
primero.

## 2026-07-18 - Ecos desde el origen y presion ilimitada

Fase: Fase 2 - Vertical slice

Origen del cambio:

- Una prueba fisica detecto que los segmentos independientes hacian aparecer cada
  eco en el punto donde comenzaba el tramo anterior, un comportamiento poco natural.
- La misma prueba aprobo el castigo por movimiento lento, pero solicito que su
  velocidad continuara creciendo mientras el jugador no recuperara el ritmo.

Cambios:

- La partida conserva una sola ruta acumulada desde el punto inicial.
- Cada eco nace exclusivamente en ese origen y sigue el historial compartido con su
  retraso correspondiente.
- Se elimino el bucle por `fmod`: al alcanzar el final disponible, el eco espera las
  siguientes muestras en lugar de teletransportarse al comienzo de un tramo.
- La distancia de cada ventana se calcula por separado sin cortar la ruta principal.
- Cada tramo menor de 280 px suma 0.2x a todos los ecos sin limite superior; cada
  tramo activo resta un nivel hasta volver a x1.0.
- El tutorial explica el origen comun y que la aceleracion no tiene limite.
- La version avanza a `0.2.5` (`versionCode 8`).

Verificacion:

- Pasan 92 verificaciones headless sin fugas de recursos.
- Las pruebas confirman origen comun, historial vivo, ausencia de teletransporte,
  presion superior al antiguo x1.6, recuperacion y reinicio.
- La APK debug se instalo en Android 15 a 1080 x 2400. Una ruta sin cruces llego a
  11.1 segundos con dos ecos activos en posiciones diferentes y sin errores.
- El release tiene firmas v2 y v3 validas, `targetSdk 36`, no solicita permisos y
  excluye recursos de desarrollo.
- SHA-256: `10d147c1e5f4f4c04540791eeddc97a136c254207a33b0e2ff466adcb4996d28`.

Siguiente accion:

- Validar `0.2.5` en Galaxy A25 y S25 durante diez partidas, confirmando el origen
  comun y observando la legibilidad de velocidades superiores a x1.6.

## 2026-07-18 - Presion de ecos y diseno de progresion

Fase: Fase 2 - Vertical slice

Cambios:

- Cada segmento de cinco segundos calcula la distancia recorrida por el jugador.
- Recorrer menos de 280 px eleva un nivel de presion y acelera todos los ecos a
  1.2x, 1.4x o 1.6x; el limite evita que la dificultad crezca sin control.
- Un segmento con movimiento suficiente reduce la presion de manera gradual.
- El multiplicador aparece en el HUD y los cambios se anuncian con banner, sonido,
  flash y un arco dorado en los ecos acelerados.
- El tutorial explica que permanecer lento provoca ecos mas rapidos.
- Se definio la economia de Fragmentos para Fase 3: siempre obtenibles jugando,
  cosmeticos sin ventaja, recompensa minima solo para rondas validas y precios
  iniciales de 30, 75 y 150 Fragmentos sujetos a balance.
- Se definio Duelo de Ecos como concepto online 1v1 futuro, con arenas separadas,
  igual semilla, intercambio de segmentos y servidor autoritativo.
- La version avanza a `0.2.4` (`versionCode 7`).

Verificacion:

- Pasan 88 verificaciones headless sin fugas de recursos.
- Las pruebas cubren tres niveles de presion, limite 1.6x, recuperacion, aplicacion
  a ecos nuevos y existentes, reinicio y calculo de distancia.
- La APK debug se instalo en Android 15 a 1080 x 2400 y mostro el aviso de ritmo
  bajo, el HUD en 1.2x y el efecto del eco sin errores de aplicacion.
- El release tiene firmas v2 y v3 validas, `targetSdk 36`, no solicita permisos y
  excluye archivos sensibles y recursos de desarrollo.
- SHA-256: `a4383eec8ddec2d9d5a96b81e0387f1264282716119927156d3cd60911fd6689`.

Siguiente accion:

- Validar `0.2.4` en Galaxy A25 y S25 alternando segmentos lentos y activos. Ajustar
  el umbral o multiplicadores si castigan a jugadores normales y cerrar Fase 2 al
  cumplir el criterio de rendimiento.

## 2026-07-18 - Feedback audiovisual procedural

Fase: Fase 2 - Vertical slice

Cambios:

- Se creo `GameplayFeedback` con cuatro sonidos PCM sintetizados en memoria.
- Crear un eco, cambiar de etapa, activar el pulso y chocar tienen tonos distintos.
- Los mismos eventos generan ondas expansivas y flashes de pantalla.
- La transicion de etapa incorpora una entrada visual con escala.
- Los reproductores se reutilizan y se limpian al destruir o reiniciar la partida.
- En modo headless se validan datos y eventos sin iniciar el driver de audio falso.
- Se corrigio el doble desplazamiento de ecos en pantallas altas al configurarlos
  despues de agregarlos al arbol.
- La version avanza a `0.2.3` (`versionCode 6`).

Verificacion:

- Pasan 76 verificaciones headless sin fugas de recursos.
- Se comprobo la posicion global del eco en un viewport 20:9.
- La APK debug se instalo en Android 15 a 1080 x 2400.
- Se capturo la onda del primer eco y no hubo errores de audio ni GDScript.
- El release tiene firmas v2 y v3 validas, no solicita permisos y excluye recursos
  de desarrollo.
- El AVD termino antes de reinstalar el release final; la prueba en telefono fisico
  queda pendiente.
- SHA-256: `8830f17a9cbab18dc64fc2d61e2f395db5354b6da6aa99d039c3055f8bcfb787`.

Siguiente accion:

- Validar `0.2.3` en Galaxy A25 y S25 y cerrar Fase 2 si sonido, claridad, dificultad
  y rendimiento cumplen el criterio de salida.

## 2026-07-18 - Progresion de arena y limite de ecos

Fase: Fase 2 - Vertical slice

Cambios:

- Se creo `ArenaObstacle`, un componente reutilizable con modos fijo, patrulla y
  pulso.
- La partida comienza con dos barreras fijas, activa la patrulla a los 12 segundos
  y el pulso a los 24.
- El pulso alterna aviso, peligro y ventana segura con color propio.
- El HUD informa etapa y ocupacion de ecos.
- Se limito la arena a cuatro ecos activos; el quinto retira al mas antiguo.
- El total de ecos creados se conserva para puntuacion y resultado.
- El tutorial explica los colores y el limite.
- La version avanza a `0.2.2` (`versionCode 5`).

Verificacion:

- Pasan 66 verificaciones headless.
- Las pruebas cubren activacion, movimiento, pulso, reinicio y limite de ecos.
- Se comprobo la presentacion inicial en Android 15 a 1080 x 2400.
- El proceso Android no registro errores de aplicacion.
- La APK no solicita permisos y tiene firmas v2 y v3 validas.
- SHA-256: `7886fdcb454c0de0cacaa0f9df432a0e781a87b03043805ff41c7f21f49585f8`.

Siguiente accion:

- Agregar respuesta sonora y efectos de impacto y etapa, y validar el balance con
  jugadores externos.

## 2026-07-18 - Pantalla adaptable y ajustes persistentes

Fase: Fase 2 - Vertical slice

Cambios:

- Se activo el modo de expansion para ocupar pantallas entre 9:16 y 20:9.
- El mundo jugable conserva 720 x 1280 y se centra verticalmente; HUD, overlays e
  instrucciones se adaptan al viewport completo.
- Se agrego `SettingsStore` como autoload con persistencia en `user://settings.cfg`.
- El menu incorpora volumen, vibracion y sensibilidad.
- La sensibilidad modifica velocidad y aceleracion del jugador.
- El final de ronda solicita vibracion breve cuando el ajuste esta activo.
- La exportacion excluye `tests/`, `scripts/dev/`, `build/` y `releases/`.
- La version avanza a `0.2.1` (`versionCode 4`).

Verificacion:

- Pasan 46 verificaciones headless.
- Se verifico un viewport 720 x 1600 en pruebas automatizadas.
- En Android 15, menu y arena ocuparon 1080 x 2400 sin barras negras.
- Los valores 50%, vibracion inactiva y sensibilidad 1.20x persistieron despues de
  cerrar y relanzar la aplicacion.
- No hubo errores de aplicacion.
- Firmas APK v2 y v3 validas.
- SHA-256: `63601a003b4c0d5ea19f26a4bb85e2431f0ffdd7dd1d6981a7c4eb14377b3ee8`.

Siguiente accion:

- Implementar progresion de arena, tres tipos de obstaculo y limite de ecos activos.

## 2026-07-18 - Fase 1 cerrada e inicio de Fase 2

Fase: Fase 2 - Vertical slice

Validacion de Fase 1:

- T02-T08 representan siete jugadores adicionales en Galaxy A25 y S25.
- Jugaron unas diez partidas en promedio; 7 de 7 entendieron el eco y 7 de 7
  quisieron repetir hasta percibir repeticion.
- Con T01, el total es de ocho testers, todos con comprension y repeticion voluntaria,
  sin fallos tecnicos criticos.
- La Fase 1 cumple su criterio de salida y queda cerrada.

Cambios de Fase 2:

- Se agrego un controlador de aplicacion que intercambia menu y partida.
- Se creo un menu principal animado con identidad visual, acceso a jugar y tutorial.
- El tutorial explica movimiento, ecos y peligros en tres pasos.
- El resultado ahora permite repetir la ronda sin recargar la aplicacion o volver
  al menu principal.
- La suite cubre el flujo nuevo y aumento de 29 a 37 verificaciones.
- La APK release avanza a `0.2.0` (`versionCode 3`).

Verificacion:

- Las 37 verificaciones headless pasan.
- La APK se instalo sobre la version anterior y tambien se probo con datos limpios
  en Android 15.
- Menu, tutorial, partida, resultado y regreso al menu respondieron por toque.
- No hubo errores de aplicacion en el inicio limpio.
- Firmas APK v2 y v3 validas.
- SHA-256: `615ab27e7de94036b70fd9df7cbe86b345d53ec5bc771e441cd9ef67c7ba6d38`.

Pendiente:

- Adaptar el contenido 9:16 a pantallas 19.5:9 y 20:9 para eliminar barras negras.
- Implementar ajustes y comenzar la variacion de arena y obstaculos.

Siguiente accion:

- Resolver la adaptacion responsive sin alterar la fisica validada.

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
