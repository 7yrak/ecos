# ECOS - Documento de diseno breve

## Propuesta

ECOS es un arcade 2D de partidas cortas en el que cada movimiento del jugador
regresa como un eco. Los ecos ayudan a recoger energia y activar elementos, pero
tambien se convierten en obstaculos. La dificultad nace de convivir con las propias
decisiones pasadas.

## Fantasia del jugador

Dominar una arena que conserva la memoria de cada movimiento y convertir el caos
creado por uno mismo en una cadena perfecta.

## Bucle principal

1. Entrar en una arena.
2. Mover una chispa con un dedo y recoger energia.
3. Generar periodicamente un eco desde el ultimo miembro de la cadena.
4. Evitar colisiones y usar ecos para multiplicar la puntuacion.
5. Sobrevivir hasta agotar el tiempo objetivo y completar el nivel.
6. Avanzar al siguiente nivel disponible o repetir para mejorar la puntuacion.

## Reglas provisionales

- Cada nivel declara dificultad, duracion, frecuencia de ecos y tiempos de etapa.
- El nivel 1, `PRIMERA RESONANCIA / INICIAL`, se completa sobreviviendo 45 segundos.
- Se crea un eco cada 5 segundos en el nivel 1.
- La primera grieta sigue al jugador durante su aviso de 0.7 segundos; las siguientes
  siguen al ultimo eco creado y abren donde este se encuentre.
- El nuevo eco conserva el desplazamiento grabado, lo aplica desde la posicion de su
  predecesor y limita sus muestras al interior visible de la arena.
- No existe un maximo de ecos activos. Al terminar su recorrido o persecucion quedan
  como resonancias peligrosas hasta que finaliza el nivel.
- Recorrer menos de 280 px en una ventana aumenta la velocidad de todos los ecos;
  el aviso crea un cazador y no hay limite superior de presion.
- Moverse activamente reduce la presion de forma gradual.
- Las faltas lentas se acumulan durante toda la partida aunque la presion temporal
  se recupere: el primer cazador alcanza 0.96x de la velocidad del jugador, el
  segundo 1.12x, el tercero 1.28x y los siguientes continuan aumentando.
- Chocar con un eco o peligro pierde el intento; agotar el tiempo gana el nivel.
- Una sola reanimacion puede ofrecerse mediante anuncio recompensado.
- La dificultad aumenta mediante tiempo objetivo, frecuencia, etapas, velocidad,
  cantidad de ecos y modificadores definidos por nivel.

Todos los valores son parametros de balance, no constantes definitivas.

## Prototipo de Fase 1

- El jugador se mueve hacia el punto tocado o arrastrado.
- La arena tiene limites que contienen y obstaculos que finalizan la partida.
- El recorrido se muestrea cada 0,05 segundos.
- La Fase 1 creaba un eco de cada segmento independiente de cinco segundos.
- La Fase 2 conserva los segmentos independientes como plantillas de desplazamiento.
  Cada generacion nace del ultimo eco, permanece como resonancia y la cadena crece sin
  limite fijo hasta ganar por tiempo o colisionar.
- La puntuacion suma supervivencia y ecos creados.
- La pantalla de resultado diferencia derrota y nivel superado; permite reintentar o
  avanzar cuando exista otro nivel en el catalogo.

Estos comportamientos fueron validados con ocho personas. Todas entendieron la regla
del eco y quisieron repetir; no se informaron fallos tecnicos criticos.

### Aprendizaje de T01

- La regla del eco se entiende sin explicacion.
- La puntuacion provoca intentos voluntarios de superacion.
- Despues de unas quince partidas, la experiencia se siente repetitiva porque la
  arena cambia poco.
- Acumular ecos como fuente principal de dificultad termina saturando el espacio y
  reduce la sensacion de que el jugador puede seguir mejorando.
- La vertical slice debe probar variacion durante la partida y una curva de
  dificultad que no dependa solamente de agregar ecos.

### Aprendizaje de T02-T08

- Siete jugadores adicionales indicaron que el prototipo necesita un menu y mas
  elementos de presentacion para resultar llamativo.
- Este comentario refuerza el alcance de la vertical slice: identidad visual, menu
  principal, tutorial, ajustes y resultados deben formar un flujo coherente.
- "Mas cosas" no implica agregar sistemas sin validar; primero se priorizaran
  variedad durante la partida y claridad del flujo.

## Vertical slice de Fase 2

Implementado:

- Menu principal animado, tutorial y flujo hacia partida y resultado.
- Interfaz adaptable desde 9:16 hasta 20:9.
- Ajustes persistentes de volumen, vibracion y sensibilidad.
- Vibracion breve al terminar una ronda cuando esta habilitada.
- Tres tipos de obstaculo: barrera fija, patrulla movil y pulso intermitente.
- Nivel 1 con objetivo de 45 segundos y tres etapas: fija desde el inicio, patrulla a
  los 12 segundos y pulso a los 24.
- Catalogo explicito para agregar niveles sin duplicar el controlador de partida.
- Cadena recursiva de ecos sin limite fijo y resonancias persistentes durante el nivel.
- Sonidos procedurales diferentes para eco, etapa, pulso e impacto.
- Ondas expansivas y flashes comunican eventos sin ocultar el HUD.
- Aviso visual y sonoro que sigue al ultimo miembro de la cadena antes de crear otro.
- Ecos que conservan el desplazamiento grabado desde su predecesor y terminan como
  resonancias persistentes.
- Ecos cazadores para recorridos inferiores al umbral de movimiento.
- Presion de ritmo reversible desde x1.0, sin limite superior, para impedir la
  estrategia de movimiento extremadamente lento.
- Reincidencia acumulativa que vuelve cada nuevo cazador mas rapido sin depender
  del ajuste de sensibilidad.

Siguiente iteracion:

- Pruebas externas para ajustar los 45 segundos, velocidad y ventanas seguras.
- Disenar e incorporar el nivel 2 como una nueva entrada explicita del catalogo.
- Ajuste de volumen y mezcla segun la respuesta en dispositivos fisicos.

## Alcance del MVP

- Un modo infinito.
- Una arena base con variaciones generadas.
- Tres tipos de obstaculo.
- Cinco modificadores.
- Diez cosmeticos.
- Tutorial, ajustes, progresion local y desafio diario.
- Anuncios recompensados y, solo despues de validacion, intersticiales limitados.

## Economia de Fragmentos

Nombre provisional de la moneda: Fragmentos.

Principios:

- Se obtiene jugando; ninguna apariencia basica exige pagar dinero real.
- Una partida valida de al menos diez segundos entrega una recompensa minima.
- Sobrevivir, alcanzar etapas y mejorar puntuacion aumenta la recompensa.
- No hay un limite diario que impida seguir progresando mediante juego.
- Los precios iniciales deben permitir una apariencia comun en unas 10 a 15 partidas
  y una especial en unas 40 a 60, sujetos a datos reales.
- Las apariencias son cosmeticas y no mejoran velocidad, colision ni puntuacion.
- Un anuncio recompensado futuro puede duplicar la recompensa de una partida, pero
  nunca sera obligatorio para conseguir contenido.

Formula candidata para Fase 3:

- Menos de 10 segundos: 0 Fragmentos para evitar reinicios de granja.
- Partida valida: 1 Fragmento.
- Cada 1.000 puntos: +1 Fragmento.
- Alcanzar etapa 3: +1 Fragmento.
- Balance inicial de tienda: 30 comun, 75 rara y 150 especial.

## Horizonte online - Duelo de Ecos

Concepto recomendado para un primer prototipo 1v1:

- Cada jugador ocupa una arena separada con la misma semilla y reglas.
- Cada segmento de eco completado aparece, con aviso previo, en la arena rival.
- Gana el ultimo jugador con vida o la mayor puntuacion al terminar 90 segundos.
- Separar las arenas evita que la latencia controle directamente el movimiento local.
- El servidor debe ser autoritativo para tiempo, resultado, recompensas y validacion
  de recorridos.
- Se requieren cuentas, matchmaking, reconexion, versionado de protocolo y medidas
  anti-trampa antes de relacionar el modo con Fragmentos.

Este modo no bloquea el MVP local. Solo se prototipa despues de validar retencion y
serializar `EchoTimeline` de forma compacta.

## Fuera del alcance

- Multijugador, chat, clanes y cuentas dentro del MVP local.
- Campana narrativa extensa.
- Pase de batalla o suscripcion.
- Backend propio.
- Contenido 3D.
