# ECOS

Juego arcade 2D para Android en el que los movimientos del jugador generan ecos
que repiten su recorrido y modifican la partida.

Repositorio oficial: <https://github.com/7yrak/ecos>

## Descargar APK

- [Descargar ECOS 0.3.0 para Android](https://raw.githubusercontent.com/7yrak/ecos/main/releases/ECOS-0.3.0-android.apk)
- SHA-256: `5acf9c84c54b7cd9be7c25d5be7d191f74bce68729945ac4cf742d7bcf7ed7fb`

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

La Fase 1 se completo con ocho jugadores validados. La Fase 2 esta activa e incluye
menu, ajustes, tres etapas, audio procedural, feedback visual y presion contra el
movimiento lento. El nivel 1 se gana al sobrevivir 45 segundos: el primer eco sigue
la memoria del jugador y cada generacion posterior sigue a la anterior con 1.2
segundos de retraso. La cadena no tiene un limite fijo; moverse poco comprime su
distancia. El catalogo permite agregar niveles sin duplicar el controlador de partida.
