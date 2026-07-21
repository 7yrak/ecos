# Decisiones del proyecto

Las decisiones aceptadas solo se cambian registrando una nueva decision con su
motivo. Esto evita modificar la direccion del proyecto sin dejar rastro.

## D-001 - Motor y lenguaje

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: usar Godot 4 estable y GDScript.
- Motivo: el alcance es 2D, el equipo es pequeno y se necesita iteracion rapida sin
  coste de licencia del motor.
- Consecuencia: las integraciones Android se implementaran como plugins v2 o
  adaptadores compatibles con Godot.

## D-002 - Arquitectura

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: usar un monolito modular orientado a componentes.
- Motivo: Clean Architecture completa, ECS o microservicios no aportan valor al
  MVP y aumentarian el tiempo hasta la primera prueba.
- Consecuencia: gameplay, progresion, interfaz y plataforma tendran limites claros
  dentro de un solo proyecto.

## D-003 - Simulacion de ecos

- Fecha: 2026-07-18
- Estado: propuesta para validar en prototipo
- Decision: grabar muestras de posicion, tiempo y acciones, y reproducir datos
  inmutables en lugar de clonar toda la logica del jugador.
- Motivo: reduce complejidad y hace los ecos predecibles.
- Consecuencia: la frecuencia de muestreo y la interpolacion deben probarse en la
  Fase 1.

## D-004 - Backend

- Fecha: 2026-07-18
- Estado: aceptada para el MVP
- Decision: no utilizar cuentas ni backend durante las primeras fases.
- Motivo: no son necesarios para demostrar diversion y retencion.
- Consecuencia: el progreso inicial sera local; compras y servicios en linea se
  agregaran solo cuando exista evidencia de que aportan valor.

## D-005 - Monetizacion

- Fecha: 2026-07-18
- Estado: propuesta recomendada
- Decision: priorizar anuncios recompensados y limitar los intersticiales a pausas
  naturales.
- Motivo: permite monetizar sin interrumpir la partida.
- Consecuencia: la publicidad se implementara despues de validar el gameplay.

## D-006 - Configuracion inicial de Android

- Fecha: 2026-07-18
- Estado: provisional hasta publicacion
- Decision: usar orientacion vertical, 720 x 1280 y `com.tyrak.ecos`.
- Motivo: permite avanzar con el prototipo sin bloquearse por identidad comercial.
- Consecuencia: el paquete y el nombre del estudio deben confirmarse antes de crear
  la aplicacion definitiva en Google Play.

## D-007 - Renderizador

- Fecha: 2026-07-18
- Estado: aceptada para el prototipo
- Decision: usar el renderizador Compatibility.
- Motivo: ECOS es 2D y busca soportar dispositivos Android modestos.
- Consecuencia: el emulador local debe usar GPU host porque SwiftShader presenta el
  issue conocido `godotengine/godot#109550` con Godot 4.7.1.

## D-008 - Versionado e integracion continua

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: versionar todo ECOS en el repositorio de la carpeta actual y no usar
  Jenkins durante el prototipo.
- Motivo: un servidor Jenkins requiere instalacion, actualizaciones, credenciales y
  mantenimiento que no se justifican para un proyecto individual en Fase 1.
- Consecuencia: las validaciones se ejecutan mediante scripts locales. Cuando exista
  un remoto GitHub, la primera opcion de CI sera GitHub Actions.

## D-009 - Control y segmentacion de ecos

- Fecha: 2026-07-18
- Estado: reemplazada en Fase 2 por D-017
- Decision: mover hacia la posicion tocada y generar un eco por cada segmento de
  cinco segundos.
- Motivo: el control se entiende con un dedo y los segmentos independientes mantienen
  acotado el costo de grabacion y reproduccion.
- Consecuencia: velocidad, duracion y frecuencia se consideran parametros de balance
  que pueden cambiar despues de las pruebas con jugadores.

## D-010 - Salida de Fase 1 y prioridad de la vertical slice

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: cerrar la Fase 1 con ocho jugadores validados e iniciar la Fase 2 por
  el flujo de menu, tutorial, partida y resultado.
- Motivo: los ocho jugadores entendieron el eco y quisieron repetir, pero reportaron
  repeticion y falta de presentacion despues de varias partidas.
- Consecuencia: la vertical slice debe mejorar presentacion y variedad antes de
  agregar monetizacion o progresion extensa.

## D-011 - Pantalla adaptable y ajustes

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: usar `expand` entre 9:16 y 20:9, centrar el mundo de 720 x 1280 y
  persistir ajustes mediante un autoload local.
- Motivo: elimina barras negras sin alterar la fisica validada y mantiene las
  preferencias separadas de la interfaz.
- Consecuencia: los nuevos elementos de gameplay usan coordenadas internas de la
  arena; volumen, vibracion y sensibilidad se consultan mediante `SettingsStore`.

## D-012 - Dificultad por etapas y limite de ecos

- Fecha: 2026-07-18
- Estado: reemplazada parcialmente por D-022 y D-023
- Decision: introducir barreras fijas al inicio, patrulla a los 12 segundos y pulso
  a los 24; mantener como maximo cuatro ecos activos.
- Motivo: la validacion mostro que acumular ecos sin limite vuelve la dificultad
  repetitiva e inevitable.
- Consecuencia: el quinto eco reemplaza al mas antiguo, pero el total creado sigue
  contando para puntuacion y resultado; los tiempos quedan como parametros de balance.

## D-013 - Feedback procedural sin assets externos

- Fecha: 2026-07-18
- Estado: aceptada
- Decision: sintetizar en memoria cuatro sonidos breves y dibujar ondas vectoriales
  para eco, etapa, pulso e impacto.
- Motivo: permite validar respuesta audiovisual sin licencias, descargas ni una
  dependencia de contenido definitivo durante la vertical slice.
- Consecuencia: la mezcla actual es provisional y debe ajustarse en dispositivos
  fisicos antes de producir o comprar audio final.

## D-014 - Presion contra movimiento lento

- Fecha: 2026-07-18
- Estado: reemplazada por D-017
- Decision: medir distancia por segmento y acelerar todos los ecos entre x1.2 y x1.6
  cuando el recorrido sea inferior a 280 px.
- Motivo: moverse extremadamente lento conserva recorridos faciles y puede convertirse
  en una estrategia dominante que elimina el aumento de dificultad.
- Consecuencia: la presion sube hasta tres niveles, se comunica en HUD y banner, y
  baja gradualmente cuando el jugador vuelve a recorrer suficiente distancia.

## D-015 - Fragmentos obtenibles mediante juego

- Fecha: 2026-07-18
- Estado: aceptada para Fase 3
- Decision: toda apariencia inicial puede obtenerse jugando; no habra limite diario
  duro ni mejoras de poder comprables.
- Motivo: el progreso debe ser exigente pero alcanzable y no convertir la tienda en
  un bloqueo artificial.
- Consecuencia: partidas menores de diez segundos no pagan, el rendimiento aumenta
  la recompensa y los precios se ajustan con datos de tiempo real de desbloqueo.

## D-016 - Duelo de Ecos como primer modo online

- Fecha: 2026-07-18
- Estado: propuesta aceptada para investigacion futura
- Decision: prototipar un 1v1 en arenas separadas donde cada segmento generado se
  envia como peligro al rival.
- Motivo: aprovecha la mecanica central y reduce la dependencia de sincronizar
  movimiento directo entre telefonos.
- Consecuencia: requiere servidor autoritativo, cuentas, matchmaking, reconexion y
  anti-trampa; no entra al MVP local ni maneja Fragmentos hasta ser seguro.

## D-017 - Ecos desde el origen y presion sin limite

- Fecha: 2026-07-18
- Estado: reemplazada por D-018 despues de prueba fisica
- Decision: mantener una ruta acumulada desde el inicio, crear cada eco en el origen
  y aumentar su velocidad 0.2x por cada segmento lento sin imponer un maximo.
- Motivo: los segmentos independientes hacian aparecer ecos en puntos intermedios y
  el limite 1.6x permitia sostener indefinidamente la estrategia de movimiento lento.
- Consecuencia: los ecos siguen el historial compartido sin reiniciar ni
  teletransportarse; cada segmento activo reduce un nivel de presion hasta x1.0.

## D-018 - Grietas, trayectoria unica y cazadores

- Fecha: 2026-07-18
- Estado: reemplazada parcialmente por D-020
- Decision: crear ecos desde anclas alternadas del perimetro con 0.7 segundos de
  aviso; reproducir una ruta transformada una vez, terminar como resonancia y usar
  cazadores para segmentos lentos.
- Motivo: originar todos los ecos en el mismo punto volvio la partida predecible y
  aburrida, mientras los reinicios de ruta no tenian una explicacion visual coherente.
- Consecuencia: ninguna ruta se reinicia o teletransporta; las amenazas expiran,
  quedarse quieto genera persecucion y la presion mantiene su crecimiento ilimitado.

## D-019 - Faltas lentas acumulativas

- Fecha: 2026-07-18
- Estado: reemplazada por D-025
- Decision: conservar durante toda la partida cada infraccion de movimiento lento y
  usarla como velocidad minima de los cazadores futuros.
- Motivo: los cazadores iniciales eran faciles de esquivar y recuperar un segmento
  activo borraba la escalada antes de llegar al segundo o tercer castigo.
- Consecuencia: la presion temporal aun baja al moverse activamente, pero las faltas
  no; el segundo cazador supera la velocidad normal del jugador y la progresion no
  tiene limite superior ni puede neutralizarse aumentando la sensibilidad.

## D-020 - Los ecos conservan el recorrido real

- Fecha: 2026-07-19
- Estado: reemplazada por D-022
- Decision: cada eco de trayectoria nace donde comenzo su segmento y reproduce una
  sola vez las coordenadas exactas que recorrio el jugador, sin rotar, escalar ni
  trasladar las muestras a anclas externas.
- Motivo: transformar los recorridos separo las amenazas de las decisiones pasadas
  del jugador y elimino la mecanica central expresada por el nombre ECOS.
- Consecuencia: el aviso aparece en el origen real del segmento y la resonancia queda
  en su destino real. Se conservan la reproduccion unica, el limite de amenazas y los
  cazadores para segmentos lentos.

## D-021 - Conservar solo la APK vigente

- Fecha: 2026-07-19
- Estado: aceptada
- Decision: `releases/` contiene unicamente la APK de la version vigente; al publicar
  una nueva se elimina el binario anterior en el mismo cambio.
- Motivo: Git ya conserva el historial y duplicar APK antiguas aumenta innecesariamente
  el tamano actual del repositorio.
- Consecuencia: README y estado apuntan siempre al unico artefacto instalable actual;
  las versiones anteriores se recuperan desde el historial de Git si fueran necesarias.

## D-022 - Cadena recursiva sin limite fijo

- Fecha: 2026-07-20
- Estado: reemplazada parcialmente por D-025
- Decision: la primera grieta sigue al jugador y cada grieta posterior sigue al ultimo
  eco creado; al abrirse, el nuevo eco aplica el desplazamiento grabado desde la
  posicion actual de su predecesor y queda como resonancia hasta finalizar el nivel.
- Motivo: los ecos deben formar una descendencia visible y recursiva, no amenazas
  independientes que desaparecen o se retiran al alcanzar una cantidad arbitraria.
- Consecuencia: se elimina el maximo de cuatro ecos, las muestras trasladadas se
  limitan al interior de la arena y el costo de mantener la cadena queda acotado por
  la duracion temporal de cada nivel. Debe validarse legibilidad y rendimiento fisico.

## D-023 - Victoria temporal y catalogo explicito de niveles

- Fecha: 2026-07-20
- Estado: aceptada
- Decision: cada nivel declara nombre, dificultad, duracion, intervalo de ecos y
  activacion de etapas. El unico nivel actual es `PRIMERA RESONANCIA / INICIAL`, con
  victoria al sobrevivir 45 segundos.
- Motivo: una meta de tiempo ofrece cierre, permite balancear cada arena y evita que
  una partida con ecos ilimitados crezca indefinidamente.
- Consecuencia: el resultado diferencia victoria y derrota; avanza automaticamente
  solo cuando el siguiente nivel exista en el catalogo. Los niveles futuros se agregan
  de forma deliberada, con contenido y pruebas propias, no mediante generacion vacia.

## D-024 - Publicacion directa en main

- Fecha: 2026-07-20
- Estado: aceptada
- Decision: cuando el usuario solicite publicar una entrega, hacer commit y push
  directamente a `main`; no crear ramas ni pull requests salvo solicitud explicita.
- Motivo: el repositorio usa un flujo individual y el usuario quiere que la version
  disponible en `main` quede actualizada inmediatamente.
- Consecuencia: cada publicacion debe validar antes el alcance, las pruebas y el
  artefacto. `releases/` conserva solo la APK vigente en el mismo commit publicado.

## D-025 - Perseguidores recursivos con memoria

- Fecha: 2026-07-20
- Estado: aceptada
- Decision: cada eco registra las posiciones en vivo de su predecesor y las sigue con
  1.2 segundos de retraso. El primero sigue al jugador y los siguientes forman una
  cadena recursiva; no existen reproducciones finitas, cazadores separados ni
  resonancias estaticas.
- Motivo: trasladar un segmento hacia el ultimo eco hacia que la amenaza recorriera
  una ruta independiente y luego se detuviera, por lo que no se percibia que los ecos
  persiguieran al jugador.
- Consecuencia: todas las generaciones permanecen en movimiento. Un segmento lento
  comprime el retraso de la cadena completa en pasos de 0.2x; recuperar distancia lo
  amplia nuevamente. La dificultad se concentra en una sola regla legible y el nivel
  inicial pasa a llamarse `PRIMERA ESTELA`.

## Decisiones pendientes del usuario

- Estilo visual definitivo.
- Publico objetivo y clasificacion de edad buscada.
- Android solamente o futura version para otras plataformas.
- Nombre de paquete Android y nombre del estudio/desarrollador.
