# Flujo del repositorio

- Cuando el usuario solicite publicar cambios, subirlos directamente a `main`.
- No crear ramas de trabajo ni pull requests salvo que el usuario lo pida de forma
  explicita.
- `releases/` es una salida local: las APK se generan ahi, nunca se agregan a Git y
  no se publican en el repositorio.
- Antes de generar una APK release local, eliminar las APK anteriores de
  `releases/` para conservar solo la vigente.
