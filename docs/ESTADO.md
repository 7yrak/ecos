# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-27
- Fase activa: Fase 3 - MVP de contenido
- Hito activo: validar nueve etapas 2.5D, sus coreografias y el rendimiento movil
- Estado general: expansion de contenido y pausa implementadas; APK pendiente de validacion fisica
- Ultima sesion: se corrigio el desplazamiento tactil de la tienda sobre tarjetas y botones

## Ultimo resultado verificable

- El proyecto usa Godot 4.7.1, GDScript, Java 21, Android SDK 36, orientacion vertical
  y resolucion logica 720 x 1280 con renderizador Compatibility.
- La version de trabajo es `0.10.1` (`versionCode 21`).
- Las APK no forman parte de Git. La APK firmada se genera solo de forma local en
  `releases/`, que conserva unicamente el artefacto vigente.
- La salida local actual es `ECOS-0.10.1-android.apk`, SHA-256
  `1C17C8D3BD31FDA801A354CFC1B5A4E45724AB584E9BD04A2A8EAACDF2F7B1F0`.
- La APK usa firmas v2 y v3, `targetSdk 36`, ARM64 y x86_64; no solicita permisos ni
  contiene recursos de pruebas o desarrollo.
- `0.4.0` usa un certificado nuevo porque la clave privada anterior no estaba
  disponible. Debe desinstalarse `0.3.0` antes de instalar esta version.
- Certificado SHA-256:
  `30138bb0de7250cbbe749724966e8feb46d58a6916de929cd6192584575bcfb2`.
- El lenguaje visual combina arte ilustrado con reticula jerarquica, barrido ambiental,
  brillos por capas, esquinas de telemetria y transiciones procedimentales acotadas.
- El menu usa una ilustracion vertical original con la senal perseguida por sus ecos.
  Cada nivel incorpora ademas una arquitectura ambiental ilustrada propia.
- La expansion no solo agranda el espacio: revela progresivamente mas arte lateral del
  mundo. Las texturas de nivel se cargan bajo demanda para no retener los seis mundos
  en memoria.
- El gameplay usa una presentacion 2.5D real en un `SubViewport`: camara ortografica
  inclinada, geometria con volumen, iluminacion, materiales emisivos, sombras y
  particulas sincronizadas con el estado autoritativo 2D.
- Jugador, ecos, obstaculos base y sorpresas se representan en 3D. Colisiones, entrada,
  tiempos y coreografias permanecen en 2D para no perder precision ni determinismo.
- Ajustes guarda un modo de calidad 2.5D alta a 720 x 1280 y otro de rendimiento a
  540 x 960 con menos particulas y sin sombras dinamicas.
- Toda la interfaz usa Oxanium y conserva su licencia OFL dentro de `assets/fonts/`.
- Las nueve etapas se distribuyen entre seis mundos: Marea Esmeralda, Corriente
  Electrica, Nucleo Carmesi, Forja Ambar, Vacio Violeta y Santuario Glacial.
  Arena, HUD, bordes, avisos, obstaculos, materiales y resultados heredan su identidad.
- El jugador y los ecos incorporan nucleo animado, orbitas y estelas acotadas. Las
  alertas y aperturas agregan sacudida de camara determinista.
- El menu presenta una composicion mas profunda y una jerarquia renovada; tutorial,
  ajustes, tienda y resultados usan los mismos paneles, color, brillo y movimiento.
- La tienda muestra una vista previa procedimental de cada skin, nivel y poder antes
  de comprarlo o equiparlo.
- Las listas de tienda se desplazan arrastrando directamente las tarjetas. El gesto
  tambien funciona al comenzar sobre comprar/seleccionar y cancela la accion si
  supera 8 px, evitando compras accidentales.
- El nivel 1, `PRIMERA ESTELA / INICIAL`, se gana al sobrevivir 45 segundos.
- El nivel 2, `CONTRACORRIENTE / INTERMEDIA`, dura 55 segundos y cambia barreras,
  patrulla y pulso a una arena de corredores verticales.
- El nivel 3, `NUCLEO ROJO / AVANZADA`, dura 65 segundos y usa barreras inclinadas,
  patrulla vertical, pulsos mas exigentes y ecos cada cuatro segundos.
- Los niveles 4 a 9 son Forja Ascendente, Abismo Violeta, Santuario Glacial, Motor
  del Sol, Horizonte Roto y Corazon de Hielo. Duran entre 68 y 90 segundos y contienen
  entre 9 y 14 patrones cada uno.
- Cada 3.6 a 5 segundos, segun la etapa, aparece una grieta sobre el ultimo miembro
  de la cadena.
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
- Las nueve etapas suman 93 patrones sorpresa. Cada patron conserva tiempo, posicion,
  tamano, trayectoria y duracion entre intentos.
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
- El boton `II` abre una pausa real durante el intento. Continuar, reiniciar y salir
  al menu estan disponibles sin tener que perder; toda la simulacion queda detenida.
- `ARCHIVO // TIENDA` ofrece cuatro skins, nueve niveles y tres poderes permanentes:
  Pulso, Estabilizador y Desfase.
- Las partidas validas otorgan Fragmentos; cada primera victoria agrega un bono y los
  niveles siguientes se compran con la moneda obtenida al jugar.
- Billetera, inventario, equipamiento, nivel seleccionado y primeras victorias se
  guardan localmente con esquema versionado.
- Pasan 348 verificaciones headless, incluidas las nueve etapas, pausa, salida al menu,
  identidades y arte visual por nivel, posiciones
  pasadas exactas, cadena recursiva, seis generaciones, presion reversible, victoria,
  expansion fisica, coreografias deterministas, avisos no letales, barridos, camara,
  recompensas, colisiones, reinicio, interfaz adaptable y diez ciclos tecnicos.
- La identidad `com.tyrak.ecos` y el nombre del estudio siguen siendo provisionales.

## Siguiente accion exacta

Ejecutar una muestra de las nueve etapas en Galaxy A25 y S25 y medir fluidez,
temperatura y legibilidad con seis o mas ecos, patrones activos y el sector 3 abierto.

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
- [x] Renovar menu, tutorial, ajustes, tienda, gameplay, HUD y resultados.
- [x] Incorporar paletas visuales propias para los tres niveles.
- [x] Ampliar la suite a 290 verificaciones y generar la APK local `0.7.0`.
- [x] Integrar arte cinematografico de menu y tres escenarios ilustrados.
- [x] Reemplazar la tipografia generica y reforzar la silueta de los obstaculos.
- [x] Ampliar la suite a 291 verificaciones y generar la APK local `0.8.0`.
- [x] Convertir el gameplay a una presentacion 2.5D sincronizada.
- [x] Agregar calidad alta y modo de rendimiento persistentes.
- [x] Ampliar la suite a 296 verificaciones y generar la APK local `0.9.0`.
- [x] Ampliar el catalogo de tres a nueve etapas.
- [x] Incorporar 69 patrones adicionales y tres familias ambientales texturizadas.
- [x] Agregar pausa con continuar, reiniciar y salir al menu.
- [x] Ampliar la suite a 344 verificaciones y generar la APK local `0.10.0`.
- [x] Habilitar desplazamiento tactil directo sobre todas las tarjetas de tienda.
- [x] Evitar compras o selecciones accidentales durante un arrastre.
- [x] Ampliar la suite a 348 verificaciones y generar la APK local `0.10.1`.
- [ ] Validar seguimiento, legibilidad y rendimiento en Galaxy A25 y S25.
- [ ] Balancear umbrales 3/6, espera de 4 segundos, zoom y bono de 250 puntos.
- [ ] Balancear duraciones, frecuencias, precios, bonos y poderes.
- [ ] Respaldar la nueva clave release fuera del equipo actual.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay un telefono Android conectado por ADB; la validacion fisica requiere conectar
  el Galaxy A25 o S25 con depuracion USB autorizada.
- Las nueve etapas estan implementadas, pero su balance requiere dispositivos fisicos.

## Riesgos actuales

- La cadena no tiene limite fijo; los 45 segundos acotan memoria y nodos, pero deben
  medirse FPS y legibilidad en un dispositivo de gama media.
- Corazon de Hielo dura 90 segundos y genera mas ecos que las etapas originales; es
  el caso critico para medir memoria, temperatura y legibilidad.
- El render 3D agrega costo de GPU. El modo de rendimiento reduce resolucion,
  particulas y sombras, pero ambos perfiles deben medirse en Galaxy A25 y S25.
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
