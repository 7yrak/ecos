# Bitacora de desarrollo

Historial cronologico del proyecto. Las entradas anteriores no se reescriben; las
correcciones se documentan en una entrada nueva. La entrada mas reciente va
primero.

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
