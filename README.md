# ECOS

Juego arcade 2D para Android en el que los movimientos del jugador generan ecos
que repiten su recorrido y modifican la partida.

Repositorio oficial: <https://github.com/7yrak/ecos>

## APK Android

Las APK no se almacenan ni distribuyen desde este repositorio. La version release se
genera localmente en `releases/` mediante `scripts/dev/export_android_release.sh` en
Linux o `scripts/dev/export_android_release.ps1` en Windows; esa salida esta ignorada
por Git.

La firma usada desde `0.4.0` reemplaza la identidad de desarrollo anterior porque la
clave privada de `0.3.0` no estaba disponible. Para pasar desde `0.3.0` se debe
desinstalar la aplicacion anterior.

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
Al alcanzar 3 y 6 ecos, el jugador puede romper el limite: la arena y la camara se
expanden, aparece un peligro nuevo y decidir antes de la apertura automatica entrega
una bonificacion de puntuacion.
Cada nivel tiene ademas una coreografia fija de muros, compuertas y barridos sorpresa:
aparecen siempre en el mismo segundo y lugar, con un aviso breve, para que repetir
tambien signifique aprender la memoria del nivel.
Menu, tutorial, tienda, HUD, gameplay y resultados comparten una identidad de
transmision neon. Cada nivel usa una paleta propia y la tienda muestra vistas previas
animadas de skins, etapas y poderes. El menu tiene arte cinematografico propio y cada
nivel revela una arquitectura ilustrada diferente a medida que el mundo se expande.
