# ECOS

Juego arcade 2D para Android en el que los movimientos del jugador generan ecos
que repiten su recorrido y modifican la partida.

Repositorio oficial: <https://github.com/7yrak/ecos>

## Descargar APK

- [Descargar ECOS 0.2.9 para Android](https://raw.githubusercontent.com/7yrak/ecos/main/releases/ECOS-0.2.9-android.apk)
- SHA-256: `306f623cb13ba0d9cec0ed2364cc056968d3b2f3502df395a02e44042c111a84`

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
movimiento lento. El nivel 1 se gana al sobrevivir 45 segundos: cada eco nuevo nace
del ultimo eco, la cadena no tiene un limite fijo y sus resonancias permanecen durante
el intento. Las faltas lentas generan cazadores progresivos. El catalogo ya permite
agregar niveles deliberadamente sin duplicar el controlador de partida.
