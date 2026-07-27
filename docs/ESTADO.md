# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-27
- Fase activa: Fase 3 - MVP de contenido
- Hito activo: validar expansion del mundo, tres niveles, economia y poderes
- Estado general: expansion y coreografias fijas implementadas; APK local pendiente de validacion fisica
- Ultima sesion: cada nivel recibio obstaculos sorpresa deterministas para aprender al repetir

## Ultimo resultado verificable

- El proyecto usa Godot 4.7.1, GDScript, Java 21, Android SDK 36, orientacion vertical
  y resolucion logica 720 x 1280 con renderizador Compatibility.
- La version de trabajo es `0.6.0` (`versionCode 16`).
- Las APK no forman parte de Git. La APK firmada se genera solo de forma local en
  `releases/`, que conserva unicamente el artefacto vigente.
- La salida local actual es `ECOS-0.6.0-android.apk`, SHA-256
  `040081100A24848B70C6DB8E167C2C4106DC626BB9CAEFDAC4154FA5CEB0E655`.
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
- Con 3 y 6 ecos la arena alcanza saturacion critica y ofrece `ROMPER EL LIMITE`.
- Romperlo manualmente entrega 250 puntos; si no se decide en cuatro segundos, el
  sector se abre automaticamente para evitar detener el ritmo.
- Cada apertura mueve los limites fisicos, anima la arena y aleja la camara. El sector
  2 libera la patrulla y el sector 3 la tormenta de pulso.
- `PRIMERA ESTELA` tiene 6 patrones sorpresa, `CONTRACORRIENTE` 8 y `NUCLEO ROJO`
  10. Cada patron conserva tiempo, posicion, tamano, trayectoria y duracion.
- Los patrones usan muros, compuertas y barridos. Una huella amarilla no letal avisa
  entre 0.65 y 1.25 segundos antes de activar la colision.
- El HUD nombra el patron, marca `¡AHORA!` al activarlo y registra cuantos patrones
  de la memoria fija del nivel fueron descubiertos.
- Los segmentos de cinco segundos solo miden distancia. Recorrer menos de 280 px
  agrega 0.2x de presion y reduce el retraso efectivo de toda la cadena.
- Un segmento activo resta un nivel de presion y vuelve a ampliar la distancia. Las
  faltas lentas se conservan como estadistica del intento.
- Se eliminaron cazadores separados, recorridos trasladados, recorte contra bordes y
  resonancias estaticas.
- El HUD muestra sector, saturacion, faltas y presion de cadena; el tutorial explica
  seguimiento, compresion y la decision de romper el limite.
- `ARCHIVO // TIENDA` ofrece cuatro skins, los tres niveles y tres poderes permanentes:
  Pulso, Estabilizador y Desfase.
- Las partidas validas otorgan Fragmentos; cada primera victoria agrega un bono y los
  niveles siguientes se compran con la moneda obtenida al jugar.
- Billetera, inventario, equipamiento, nivel seleccionado y primeras victorias se
  guardan localmente con esquema versionado.
- Pasan 287 verificaciones headless, incluidas posiciones
  pasadas exactas, cadena recursiva, seis generaciones, presion reversible, victoria,
  expansion fisica, coreografias deterministas, avisos no letales, barridos, camara,
  recompensas, colisiones, reinicio, interfaz adaptable y diez ciclos tecnicos.
- La identidad `com.tyrak.ecos` y el nombre del estudio siguen siendo provisionales.

## Siguiente accion exacta

Ejecutar los tres niveles en Galaxy A25 y S25 y observar si la expansion a los 3 y 6
ecos se entiende, si el boton puede pulsarse bajo presion y si el zoom final mantiene
legibles jugador, ecos y peligros.

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
- [x] Convertir la saturacion en tres sectores de arena expansibles.
- [x] Agregar decision manual, apertura automatica, riesgo, recompensa y nuevo HUD.
- [x] Ampliar la suite a 219 verificaciones.
- [x] Retirar las APK del repositorio y convertir `releases/` en salida local ignorada.
- [x] Generar y auditar localmente la APK firmada `0.5.0`.
- [x] Incorporar 24 patrones sorpresa fijos entre los tres niveles.
- [x] Agregar aviso, activacion, trayectoria, retirada y memoria visible del nivel.
- [x] Ampliar la suite a 287 verificaciones y generar la APK local `0.6.0`.
- [ ] Validar seguimiento, legibilidad y rendimiento en Galaxy A25 y S25.
- [ ] Balancear umbrales 3/6, espera de 4 segundos, zoom y bono de 250 puntos.
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
- El zoom del sector 3 aumenta el espacio real, pero reduce el tamano aparente de
  jugador, ecos y obstaculos; debe validarse en pantallas pequenas.
- La combinacion de ecos, obstaculos base y patrones fijos puede crear cruces mas
  exigentes de lo previsto; deben medirse muertes por patron y ajustar huecos antes
  de reducir los avisos.
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
