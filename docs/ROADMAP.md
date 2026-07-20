# Roadmap de ECOS

Cada fase tiene un resultado verificable. No se avanza por fecha: se avanza cuando
se cumplen sus criterios de salida.

## Fase 0 - Preparacion

Estado: completada el 2026-07-18.

Objetivo: dejar el proyecto reproducible y las decisiones basicas cerradas.

Entregables:

- Repositorio Git inicializado.
- Godot 4 estable y plantillas de exportacion instaladas.
- Android SDK configurado.
- Proyecto Godot vacio que abra sin errores.
- Exportacion de prueba instalada en un dispositivo o emulador.
- Identidad provisional: nombre, paquete Android y orientacion.

Criterio de salida:

- Un proyecto vacio se ejecuta tanto en escritorio como en Android.

## Fase 1 - Prototipo de mecanica

Estado: completada el 2026-07-18 con 8 jugadores validados.

Objetivo: demostrar que controlar al jugador y convivir con sus ecos es divertido.

Entregables:

- Movimiento tactil de un dedo.
- Grabacion temporal de posicion y acciones.
- Reproduccion de uno o mas ecos.
- Colision entre jugador, ecos, limites y obstaculos.
- Reinicio inmediato de la partida.
- Contadores basicos de tiempo y puntuacion.

Criterio de salida:

- Diez partidas consecutivas sin fallos tecnicos.
- Al menos 5 personas prueban el juego.
- La mayoria entiende la regla sin una explicacion extensa y quiere repetir.

## Fase 2 - Vertical slice

Estado: activa desde el 2026-07-18.

Avance: menu, tutorial, navegacion, interfaz adaptable, ajustes persistentes,
progresion de arena, tres obstaculos y feedback audiovisual completados. El nivel 1
tiene victoria a los 45 segundos, cadena recursiva sin limite fijo, resonancias
persistentes, cazadores y faltas lentas acumulativas. El catalogo permite incorporar
niveles nuevos sin duplicar el controlador. Pendiente: validacion final en dispositivos
fisicos y diseno del nivel 2.

Objetivo: representar la calidad visual y sonora esperada del producto final.

Entregables:

- Flujo completo: inicio, partida, resultado y repeticion.
- Menu principal con identidad visual y acceso claro a jugar, tutorial y ajustes.
- Interfaz adaptable desde 9:16 hasta 20:9.
- Una arena terminada.
- Tres obstaculos.
- Progresion dentro de la partida que introduzca variedad sin depender solamente
  de acumular ecos.
- Condicion de victoria temporal y estructura extensible de niveles.
- Efectos visuales, sonido y vibracion.
- Tutorial de menos de un minuto.
- Ajustes de sonido, vibracion y sensibilidad.

Criterio de salida:

- Una persona puede instalar, aprender y jugar sin ayuda del desarrollador.
- Rendimiento estable en al menos un dispositivo Android de gama media o baja.

## Fase 3 - MVP de contenido

Objetivo: conseguir suficiente variedad para medir retencion.

Entregables:

- Modo infinito.
- Generacion de arena mediante semillas.
- Cinco modificadores de dificultad.
- Moneda local y progresion.
- Fragmentos obtenibles siempre mediante juego, sin contenido cosmetico obligatorio
  exclusivo de pago.
- Tienda con costos iniciales de 30, 75 y 150 Fragmentos sujetos a balance.
- Diez cosmeticos desbloqueables.
- Misiones sencillas y desafio diario.
- Guardado local versionado.

Criterio de salida:

- No se pierde el progreso al cerrar o actualizar el juego.
- El contenido soporta varias sesiones sin mostrar todo en el primer dia.

## Fase futura - Prototipo online

Estado: idea aceptada; no bloquea el MVP local.

Objetivo: validar si los ecos pueden sostener partidas 1v1 sin exigir movimiento
compartido de baja latencia.

Entregables:

- Duelo de Ecos en arenas separadas con la misma semilla.
- Intercambio de segmentos grabados entre rivales.
- Servidor autoritativo para reloj, resultado y recompensas.
- Matchmaking basico, reconexion y abandono.
- Recompensas online desactivables hasta contar con control anti-trampa.

Criterio de salida:

- Dos dispositivos completan veinte partidas sin desincronizacion critica.
- La partida sigue siendo comprensible con latencia variable y perdida de paquetes.
- El modo local funciona aunque los servicios online no esten disponibles.

## Fase 4 - Medicion y monetizacion

Objetivo: medir el embudo y monetizar sin romper el ritmo del juego.

Entregables:

- Interfaz `AnalyticsService` con eventos del embudo.
- Interfaz `AdsService` con implementacion falsa y Android.
- Consentimiento de privacidad antes de solicitar anuncios cuando corresponda.
- Anuncio recompensado para revivir una vez.
- Anuncio recompensado para duplicar monedas.
- Intersticial limitado y solo en resultados.
- Compra unica para retirar intersticiales, si se decide incluirla.

Criterio de salida:

- Se pueden probar todos los flujos con anuncios de prueba.
- La partida funciona aunque anuncios, compras o red no esten disponibles.
- No se muestra publicidad durante el gameplay.

## Fase 5 - Prueba cerrada

Objetivo: corregir fallos y validar comprension y retencion inicial.

Entregables:

- AAB firmado en un canal de prueba de Google Play.
- Politica de privacidad y declaracion de seguridad de datos.
- Pruebas en distintas resoluciones y versiones de Android.
- Registro de errores, bloqueos y comentarios de jugadores.

Criterio de salida:

- Finalizacion del tutorial igual o superior al 70% como objetivo inicial.
- Sesiones sin fallos por encima del 99,5% como objetivo inicial.
- No quedan errores criticos conocidos.

## Fase 6 - Soft launch

Objetivo: validar retencion, anuncios y pagina de tienda con trafico limitado.

Entregables:

- Ficha de Google Play con icono, capturas y video corto.
- Lanzamiento limitado geograficamente o por volumen.
- Panel semanal de instalacion, tutorial, sesiones, retencion y anuncios.
- Experimentos pequeños de dificultad y recompensas.

Criterio de salida:

- Retencion D1 objetivo de 25% o superior.
- Retencion D7 objetivo de 8% a 10% o superior.
- Tres o mas partidas por sesion.
- Los anuncios no producen una caida importante de retencion.

## Fase 7 - Lanzamiento y operacion

Objetivo: publicar ampliamente solo si el soft launch demuestra potencial.

Entregables:

- Lanzamiento en produccion.
- Calendario de contenido ligero.
- Seguimiento semanal de estabilidad, retencion e ingresos.
- Lista priorizada de experimentos y mejoras.

Criterio de salida:

- Esta fase es continua mientras el juego sea sostenible.
