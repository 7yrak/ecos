# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-20
- Fase activa: Fase 2 - Vertical slice
- Hito activo: validar perseguidores recursivos con memoria en dispositivos fisicos
- Estado general: implementacion y release terminados; validacion fisica pendiente
- Ultima sesion: se recupero la esencia de ecos que siguen continuamente al jugador

## Ultimo resultado verificable

- El proyecto usa Godot 4.7.1, GDScript, Java 21, Android SDK 36, orientacion vertical
  y resolucion logica 720 x 1280 con renderizador Compatibility.
- La version vigente es `0.3.0` (`versionCode 13`).
- La APK release firmada esta en `releases/ECOS-0.3.0-android.apk`; es el unico
  artefacto vigente y su SHA-256 es
  `5acf9c84c54b7cd9be7c25d5be7d191f74bce68729945ac4cf742d7bcf7ed7fb`.
- La APK usa firmas v2 y v3, `targetSdk 36`, ARM64 y x86_64; no solicita permisos ni
  contiene recursos de pruebas o desarrollo.
- El nivel 1, `PRIMERA ESTELA / INICIAL`, se gana al sobrevivir 45 segundos.
- Cada cinco segundos aparece una grieta sobre el ultimo miembro de la cadena.
- El primer eco registra las posiciones del jugador y las sigue con 1.2 segundos de
  retraso. Cada generacion posterior hace lo mismo con el eco anterior.
- La prioridad de fisica sigue el orden jugador, eco 1, eco 2 y siguientes, evitando
  que una generacion lea una posicion atrasada de su predecesor.
- No hay un maximo de ecos activos y todos permanecen en movimiento durante el nivel.
- Los segmentos de cinco segundos solo miden distancia. Recorrer menos de 280 px
  agrega 0.2x de presion y reduce el retraso efectivo de toda la cadena.
- Un segmento activo resta un nivel de presion y vuelve a ampliar la distancia. Las
  faltas lentas se conservan como estadistica del intento.
- Se eliminaron cazadores separados, recorridos trasladados, recorte contra bordes y
  resonancias estaticas.
- El HUD muestra nivel, etapa, faltas y presion de cadena; el tutorial explica el
  seguimiento retardado y la compresion por movimiento lento.
- Pasan 164 verificaciones headless sin fugas de recursos, incluidas posiciones
  pasadas exactas, cadena recursiva, seis generaciones, presion reversible, victoria,
  colisiones, reinicio, interfaz adaptable y diez ciclos tecnicos consecutivos.
- La identidad `com.tyrak.ecos` y el nombre del estudio siguen siendo provisionales.

## Siguiente accion exacta

Instalar `0.3.0` en Galaxy A25 y S25 y completar diez intentos del nivel 1. Confirmar
que el primer eco sigue la estela del jugador, que las generaciones posteriores siguen
a la anterior sin saltos y que la compresion por faltas se entiende visualmente.
Registrar tiempo medio, muertes por eco y si el retraso base de 1.2 segundos permite
reaccionar antes de disenar el nivel 2.

## Tareas pendientes inmediatas

- [x] Sustituir recorridos finitos por seguimiento vivo retardado.
- [x] Encadenar cada generacion al eco anterior.
- [x] Eliminar cazadores y resonancias como comportamientos separados.
- [x] Convertir la presion lenta en compresion reversible de toda la cadena.
- [x] Actualizar HUD, tutorial, pruebas y documentacion.
- [x] Exportar y auditar la APK `0.3.0`.
- [ ] Validar seguimiento, legibilidad y rendimiento en Galaxy A25 y S25.
- [ ] Ajustar el retraso de 1.2 segundos segun diez partidas fisicas.
- [ ] Disenar el nivel 2 con una diferencia jugable clara.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay un telefono Android conectado por ADB; la validacion fisica requiere conectar
  el Galaxy A25 o S25 con depuracion USB autorizada.
- El nivel 2 debe esperar datos de dificultad y legibilidad del seguimiento nuevo.

## Riesgos actuales

- La cadena no tiene limite fijo; los 45 segundos acotan memoria y nodos, pero deben
  medirse FPS y legibilidad en un dispositivo de gama media.
- Cada generacion agrega 1.2 segundos de retraso. Las generaciones lejanas pueden
  quedar demasiado separadas para sentirse relacionadas con el jugador.
- Una presion alta reduce el retraso de todas las generaciones y puede comprimir la
  cadena de forma brusca; debe observarse antes de limitarla artificialmente.
- Si el seguimiento resulta inevitable, debe ajustarse primero retraso, gracia de
  colision o paso de presion, manteniendo una sola regla de movimiento.
- Agregar niveles antes de validar esta esencia ocultaria problemas del bucle base.

## Regla de cierre de sesion

Antes de terminar cualquier sesion:

1. Actualizar la fecha, fase, resultado y siguiente accion de este archivo.
2. Marcar tareas terminadas o agregar las nuevas.
3. Anadir una entrada al inicio de `docs/BITACORA.md`.
4. Registrar decisiones nuevas en `docs/DECISIONES.md`.
5. Indicar pruebas ejecutadas y cualquier fallo pendiente.
