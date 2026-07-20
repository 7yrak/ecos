# Estado actual

> Este archivo es la fuente principal para reanudar el trabajo. Debe ser breve y
> representar el estado real del repositorio.

## Resumen

- Fecha de actualizacion: 2026-07-20
- Fase activa: Fase 2 - Vertical slice
- Hito activo: validar el nivel 1 con cadena recursiva y victoria temporal
- Estado general: implementacion terminada; validacion fisica pendiente
- Ultima sesion: ecos sin limite fijo, descendencia recursiva y catalogo de niveles

## Ultimo resultado verificable

- El proyecto usa Godot 4.7.1, GDScript, Java 21, Android SDK 36, orientacion vertical
  y resolucion logica 720 x 1280 con renderizador Compatibility.
- La version de aplicacion avanza a `0.2.9` (`versionCode 12`).
- La APK release firmada esta en `releases/ECOS-0.2.9-android.apk`; es el unico
  artefacto vigente y su SHA-256 es
  `306f623cb13ba0d9cec0ed2364cc056968d3b2f3502df395a02e44042c111a84`.
- La APK usa firmas v2 y v3, `targetSdk 36`, ARM64 y x86_64; no solicita permisos ni
  contiene recursos de pruebas o desarrollo.
- El nivel 1 se llama `PRIMERA RESONANCIA`, tiene dificultad `INICIAL` y se gana al
  sobrevivir 45 segundos.
- Cada nivel define en el catalogo su duracion, intervalo de ecos y tiempos de etapa.
  Solo existe el nivel 1; el flujo avanza automaticamente cuando se agregue el nivel 2.
- La primera grieta sigue al jugador durante 0.7 segundos. Cada grieta posterior sigue
  al ultimo eco y el descendiente nace donde se encuentre su predecesor al abrirse.
- El eco conserva el desplazamiento grabado desde su nuevo origen. Sus muestras se
  limitan al interior visible para que la cadena trasladada no abandone la arena.
- No hay un maximo de ecos activos. Los recorridos y cazadores terminan como
  resonancias peligrosas que permanecen hasta la victoria o derrota.
- Los segmentos menores de 280 px crean cazadores. Las faltas lentas siguen
  acumulandose y cada nuevo cazador aumenta 0.2x sin limite superior configurado.
- La patrulla se activa a los 12 segundos y el pulso a los 24 segundos en el nivel 1.
- El HUD muestra tiempo transcurrido/objetivo, nivel, etapa, ecos activos y faltas.
- El resultado diferencia `NIVEL SUPERADO` de una colision y permite repetir el nivel.
- Pasan 159 verificaciones headless sin fugas de recursos, incluidas seis generaciones
  simultaneas, seguimiento de un predecesor en movimiento, victoria temporal,
  colisiones, reinicio, interfaz adaptable y diez ciclos tecnicos consecutivos.
- Menu, tutorial y textos explican la cadena, la ausencia de limite y la meta temporal.
- Volumen, vibracion y sensibilidad siguen persistiendo en `user://settings.cfg`.
- La identidad `com.tyrak.ecos` y el nombre del estudio siguen siendo provisionales.

## Siguiente accion exacta

Instalar `0.2.9` en Galaxy A25 y S25 y completar diez intentos del nivel 1. Confirmar
que las grietas siguen visualmente al ultimo eco, que se pueden observar mas de cuatro
generaciones sin caidas de rendimiento y que 45 segundos es una meta dificil pero
alcanzable. Registrar muertes, cantidad maxima de ecos y tiempo medio antes de disenar
el nivel 2.

## Tareas pendientes inmediatas

- [x] Implementar cadena recursiva desde el ultimo eco.
- [x] Eliminar el limite de cuatro ecos activos.
- [x] Mantener resonancias durante todo el nivel.
- [x] Agregar victoria temporal al nivel 1.
- [x] Crear catalogo extensible y flujo preparado para el siguiente nivel.
- [x] Actualizar HUD, resultado, tutorial y pruebas automatizadas.
- [ ] Validar legibilidad, balance y rendimiento en Galaxy A25 y S25.
- [ ] Ajustar los 45 segundos segun diez partidas fisicas.
- [ ] Disenar el nivel 2 con una diferencia jugable clara antes de agregarlo al catalogo.
- [ ] Confirmar nombre final del paquete Android y del estudio antes de publicar.

## Bloqueos

- No hay un telefono Android conectado por ADB; la validacion fisica requiere conectar
  el Galaxy A25 o S25 con depuracion USB autorizada.
- El nivel 2 no esta bloqueado tecnicamente, pero no debe definirse antes de obtener
  datos de dificultad y saturacion del nivel 1.

## Riesgos actuales

- Los ecos no tienen limite fijo: el tiempo del nivel acota el crecimiento, pero deben
  medirse FPS, memoria y legibilidad en un dispositivo de gama media.
- Limitar muestras al interior mantiene cada eco visible, pero puede aplanar recorridos
  contra los bordes y generar resonancias concentradas.
- Una cadena de resonancias persistentes puede hacer inevitable el final antes de los
  45 segundos; primero se ajustara duracion o persistencia, no se reintroducira un tope
  silencioso de ecos.
- El castigo por movimiento lento y la acumulacion recursiva pueden escalar al mismo
  tiempo; deben observarse juntos y no balancearse de forma aislada.
- Agregar niveles sin una diferencia jugable clara ocultaria problemas del bucle base.

## Regla de cierre de sesion

Antes de terminar cualquier sesion:

1. Actualizar la fecha, fase, resultado y siguiente accion de este archivo.
2. Marcar tareas terminadas o agregar las nuevas.
3. Anadir una entrada al inicio de `docs/BITACORA.md`.
4. Registrar decisiones nuevas en `docs/DECISIONES.md`.
5. Indicar pruebas ejecutadas y cualquier fallo pendiente.
