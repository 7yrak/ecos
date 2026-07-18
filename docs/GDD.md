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
3. Generar periodicamente un eco del recorrido anterior.
4. Evitar colisiones y usar ecos para multiplicar la puntuacion.
5. Terminar la partida, recibir monedas y desbloquear cosmeticos.
6. Repetir intentando superar la puntuacion anterior.

## Reglas provisionales

- Una partida dura normalmente entre 45 y 90 segundos.
- Se crea un eco cada 5 segundos.
- Cada eco reproduce una ventana anterior del movimiento.
- Chocar con un eco o peligro termina la partida.
- Una sola reanimacion puede ofrecerse mediante anuncio recompensado.
- La dificultad aumenta agregando velocidad, ecos y modificadores.

Todos los valores son parametros de balance, no constantes definitivas.

## Prototipo de Fase 1

- El jugador se mueve hacia el punto tocado o arrastrado.
- La arena tiene limites que contienen y obstaculos que finalizan la partida.
- El recorrido se muestrea cada 0,05 segundos.
- Cada cinco segundos se crea un eco del segmento anterior.
- Cada eco repite su segmento en bucle y colisionar con el termina la partida.
- La puntuacion suma supervivencia y ecos creados.
- La pantalla de resultado permite reiniciar inmediatamente.

Estos comportamientos estan implementados, pero su diversion y claridad deben
validarse con al menos cinco personas antes de la Fase 2.

## Alcance del MVP

- Un modo infinito.
- Una arena base con variaciones generadas.
- Tres tipos de obstaculo.
- Cinco modificadores.
- Diez cosmeticos.
- Tutorial, ajustes, progresion local y desafio diario.
- Anuncios recompensados y, solo despues de validacion, intersticiales limitados.

## Fuera del alcance

- Multijugador, chat, clanes y cuentas.
- Campana narrativa extensa.
- Pase de batalla o suscripcion.
- Backend propio.
- Contenido 3D.
