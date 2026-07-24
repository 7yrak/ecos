# ECOS

Juego arcade 2D para Android en el que los movimientos del jugador generan ecos
que repiten su recorrido y modifican la partida.

Repositorio oficial: <https://github.com/7yrak/ecos>

## Descargar APK

- [Descargar ECOS 0.4.0 para Android](https://raw.githubusercontent.com/7yrak/ecos/main/releases/ECOS-0.4.0-android.apk)
- SHA-256: `cd92843cca343122d904d86d96a2e1077c08a4bff9851e3d40b4e62b1048345c`

La firma de `0.4.0` reemplaza la identidad de desarrollo anterior porque la clave
privada de `0.3.0` no estaba disponible. Para pasar desde `0.3.0` se debe desinstalar
la aplicacion anterior antes de instalar `0.4.0`.

Android puede solicitar autorizacion para instalar aplicaciones desde el navegador
o gestor de archivos. Play Protect tambien puede pedir analizar la aplicacion porque
se distribuye fuera de Google Play. La APK no solicita permisos de Android.

## Como retomar el proyecto

1. Leer [`docs/ESTADO.md`](docs/ESTADO.md).
2. Revisar la fase activa en [`docs/ROADMAP.md`](docs/ROADMAP.md).
3. Consultar las decisiones vigentes en [`docs/DECISIONES.md`](docs/DECISIONES.md).
4. Continuar desde la primera tarea pendiente de `docs/ESTADO.md`.
5. Al cerrar la sesion, actualizar el estado y agregar una entrada a
   [`docs/BITACORA.md`](docs/BITACORA.md).

## Documentacion

- `docs/ESTADO.md`: fotografia breve y actual del proyecto.
- `docs/BITACORA.md`: historial cronologico de trabajo y resultados.
- `docs/ROADMAP.md`: fases, entregables y criterios de salida.
- `docs/DECISIONES.md`: decisiones tecnicas y de producto.
- `docs/GDD.md`: definicion del juego y alcance del MVP.
- `docs/ENTORNO.md`: versiones, rutas y comandos de desarrollo.
- `docs/PRUEBAS_FASE1.md`: protocolo y resultados de validacion del prototipo.

## Estado

La Fase 3 esta activa. El juego incluye tres niveles con arenas y ritmos propios,
cuatro skins, tres poderes permanentes y una tienda con Fragmentos obtenidos al jugar.
Billetera, compras, equipamiento, nivel seleccionado y primeras victorias se guardan
localmente. El primer eco sigue la memoria del jugador y cada generacion posterior
sigue a la anterior; moverse poco comprime toda la cadena.
