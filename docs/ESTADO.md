# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-18
- Fase activa: Fase 1 - Prototipo de mecanica
- Hito activo: validacion de diversion con cinco personas
- Estado general: implementacion tecnica de Fase 1 completada; prueba externa pendiente
- Ultima sesion: prototipo jugable de movimiento y ecos validado en Android

## Ultimo resultado verificable

- Git esta inicializado en la rama `main`.
- Todo el codigo, la documentacion y la configuracion viven en este repositorio.
- El remoto oficial es `https://github.com/7yrak/ecos.git`.
- Godot 4.7.1, Java 21 y Android SDK 36 estan configurados.
- El proyecto base usa orientacion vertical, resolucion logica 720 x 1280 y el
  renderizador Compatibility.
- La APK debug `0.1.0` (`versionCode 2`) se exporto y firmo para ARM64 y x86_64.
- La APK instalable esta versionada en `releases/ECOS-0.1.0-debug.apk` para descarga
  directa desde GitHub.
- La APK se instalo y ejecuto en un emulador Android 15 x86_64.
- Se verifico visualmente la pantalla inicial y no hubo errores de aplicacion con
  el renderizado por GPU host.
- El jugador responde a toque, arrastre y mouse, con limites fisicos de arena.
- Cada tramo de cinco segundos se graba e instancia como un eco repetible.
- Chocar con un eco o un obstaculo finaliza la partida; tocar un limite solo detiene.
- El HUD muestra tiempo, puntos y ecos, y el boton de resultado reinicia la partida.
- Pasan 29 verificaciones headless, incluidos diez ciclos tecnicos consecutivos.

## Siguiente accion exacta

Instalar la APK en telefonos reales y ejecutar el protocolo de
`docs/PRUEBAS_FASE1.md` con al menos cinco personas.

## Tareas pendientes inmediatas

- [x] Crear una escena de arena y limites visibles.
- [x] Implementar entrada tactil y de mouse.
- [x] Implementar movimiento suave y limitado al area jugable.
- [x] Definir la estructura de datos de una muestra de recorrido.
- [x] Grabar posiciones con tiempo monotono.
- [x] Reproducir ecos con colisiones y reinicio.
- [x] Completar diez ciclos tecnicos consecutivos sin errores.
- [ ] Probar en al menos un telefono Android fisico.
- [ ] Obtener resultados de al menos cinco testers.
- [ ] Decidir si la mecanica pasa a vertical slice o requiere iteracion.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay bloqueos tecnicos para probar la Fase 1.
- La salida de la fase depende de cinco pruebas con personas reales.
- La identidad `com.tyrak.ecos` sigue siendo provisional y no bloquea el prototipo.

## Riesgos actuales

- Integrar anuncios antes de validar la diversion puede desperdiciar trabajo.
- Una mecanica de repeticion imprecisa puede sentirse injusta; el prototipo debe
  probar la grabacion temporal antes de crear arte definitivo.
- La monetizacion no garantiza ingresos; depende de adquisicion y retencion.

## Regla de cierre de sesion

Antes de terminar cualquier sesion:

1. Actualizar la fecha, fase, resultado y siguiente accion de este archivo.
2. Marcar tareas terminadas o agregar las nuevas.
3. Anadir una entrada al inicio de `docs/BITACORA.md`.
4. Registrar decisiones nuevas en `docs/DECISIONES.md`.
5. Indicar pruebas ejecutadas y cualquier fallo pendiente.
