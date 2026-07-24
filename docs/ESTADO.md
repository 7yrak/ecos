# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-23
- Fase activa: Fase 3 - MVP de contenido
- Hito activo: validar tres niveles, economia y poderes en dispositivos fisicos
- Estado general: implementacion y release `0.4.0` terminados; validacion fisica pendiente
- Ultima sesion: se publico la primera entrega con niveles, tienda y progreso persistente

## Ultimo resultado verificable

- El proyecto usa Godot 4.7.1, GDScript, Java 21, Android SDK 36, orientacion vertical
  y resolucion logica 720 x 1280 con renderizador Compatibility.
- La version vigente es `0.4.0` (`versionCode 14`).
- La APK firmada esta en `releases/ECOS-0.4.0-android.apk`; es el unico artefacto
  vigente y su SHA-256 es
  `cd92843cca343122d904d86d96a2e1077c08a4bff9851e3d40b4e62b1048345c`.
- La APK usa firmas v2 y v3, `targetSdk 36`, ARM64 y x86_64; no solicita permisos ni
  contiene recursos de pruebas o desarrollo.
- `0.4.0` usa un certificado nuevo porque la clave privada anterior no estaba
  disponible. Debe desinstalarse `0.3.0` antes de instalar esta version.
- Certificado SHA-256:
  `30138bb0de7250cbbe749724966e8feb46d58a6916de929cd6192584575bcfb2`.
- El nivel 1, `PRIMERA ESTELA / INICIAL`, se gana al sobrevivir 45 segundos.
- El nivel 2, `CONTRACORRIENTE / INTERMEDIA`, dura 55 segundos y cambia barreras,
  patrulla y pulso a una arena de corredores verticales.
- El nivel 3, `NUCLEO ROJO / AVANZADA`, dura 65 segundos y usa barreras inclinadas,
  patrulla vertical, pulsos mas exigentes y ecos cada cuatro segundos.
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
- `ARCHIVO // TIENDA` ofrece cuatro skins, los tres niveles y tres poderes permanentes:
  Pulso, Estabilizador y Desfase.
- Las partidas validas otorgan Fragmentos; cada primera victoria agrega un bono y los
  niveles siguientes se compran con la moneda obtenida al jugar.
- Billetera, inventario, equipamiento, nivel seleccionado y primeras victorias se
  guardan localmente con esquema versionado.
- Pasan 206 verificaciones headless sin fugas de recursos, incluidas posiciones
  pasadas exactas, cadena recursiva, seis generaciones, presion reversible, victoria,
  colisiones, reinicio, interfaz adaptable y diez ciclos tecnicos consecutivos.
- La identidad `com.tyrak.ecos` y el nombre del estudio siguen siendo provisionales.

## Siguiente accion exacta

Desinstalar `0.3.0`, instalar `0.4.0` en Galaxy A25 y S25 y ejecutar los tres niveles
y habilidades. Registrar tiempo medio, causa de muerte, recompensa por sesion, tiempo
hasta cada compra y si las arenas 2 y 3 dejan ventanas de reaccion justas.

## Tareas pendientes inmediatas

- [x] Sustituir recorridos finitos por seguimiento vivo retardado.
- [x] Encadenar cada generacion al eco anterior.
- [x] Eliminar cazadores y resonancias como comportamientos separados.
- [x] Convertir la presion lenta en compresion reversible de toda la cadena.
- [x] Actualizar HUD, tutorial, pruebas y documentacion.
- [x] Exportar y auditar la APK `0.3.0`.
- [x] Incorporar niveles 2 y 3 con contenido propio.
- [x] Implementar Fragmentos, tienda y guardado local versionado.
- [x] Incorporar skins y tres poderes permanentes.
- [x] Ampliar la suite a 206 verificaciones.
- [x] Generar y auditar la APK `0.4.0`.
- [ ] Validar seguimiento, legibilidad y rendimiento en Galaxy A25 y S25.
- [ ] Balancear duraciones, frecuencias, precios, bonos y poderes.
- [ ] Respaldar la nueva clave release fuera del equipo actual.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay un telefono Android conectado por ADB; la validacion fisica requiere conectar
  el Galaxy A25 o S25 con depuracion USB autorizada.
- Los niveles 2 y 3 estan implementados, pero su balance requiere dispositivos fisicos.

## Riesgos actuales

- La cadena no tiene limite fijo; los 45 segundos acotan memoria y nodos, pero deben
  medirse FPS y legibilidad en un dispositivo de gama media.
- Cada generacion agrega 1.2 segundos de retraso. Las generaciones lejanas pueden
  quedar demasiado separadas para sentirse relacionadas con el jugador.
- Una presion alta reduce el retraso de todas las generaciones y puede comprimir la
  cadena de forma brusca; debe observarse antes de limitarla artificialmente.
- Si el seguimiento resulta inevitable, debe ajustarse primero retraso, gracia de
  colision o paso de presion, manteniendo una sola regla de movimiento.
- Los poderes pueden reducir demasiado la dificultad si sus precios o efectos quedan
  fuera de escala.
- Comprar etapas puede sentirse como bloqueo si las recompensas no abren la siguiente
  dentro de un numero razonable de partidas.
- Perder la nueva clave de firma volveria a impedir actualizaciones directas; debe
  existir al menos una copia de seguridad externa.

## Regla de cierre de sesion

Antes de terminar cualquier sesion:

1. Actualizar la fecha, fase, resultado y siguiente accion de este archivo.
2. Marcar tareas terminadas o agregar las nuevas.
3. Anadir una entrada al inicio de `docs/BITACORA.md`.
4. Registrar decisiones nuevas en `docs/DECISIONES.md`.
5. Indicar pruebas ejecutadas y cualquier fallo pendiente.
