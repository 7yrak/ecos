# Entorno de desarrollo

## Versiones fijadas

- Sistema comprobado: Ubuntu 26.04 x86_64.
- Godot: 4.7.1 estable, edicion GDScript.
- Java: OpenJDK 21.
- Android SDK Platform: 36. La plantilla de Godot 4.7.1 declara Target SDK 36.
- Android Build Tools: 36.0.0.
- Android Platform Tools: 35.0.0 o superior.
- Android Emulator: 36.6.11.
- Imagen de prueba: Android 15, API 35, x86_64.
- Android NDK: no requerido para la exportacion debug de la Fase 0.
- CMake: no requerido para la exportacion debug de la Fase 0.

## Rutas locales

- Godot: `~/.local/opt/godot/4.7.1`.
- Acceso directo: `~/.local/bin/godot4`.
- Plantillas: `~/.local/share/godot/export_templates/4.7.1.stable`.
- Android SDK: `~/Android/Sdk`.
- Java SDK: `/usr/lib/jvm/java-21-openjdk-amd64`.

Estas rutas no forman parte del repositorio. El proyecto no debe guardar rutas
absolutas ni credenciales de firma.

En la Fase 0 se instala solo la plantilla Android debug. Las plantillas de release
y fuente Gradle, el NDK y CMake se agregaran cuando se prepare el AAB o un plugin
Android nativo.

## Comandos

```bash
./scripts/dev/check_environment.sh
./scripts/dev/test.sh
./scripts/dev/godot.sh --editor --path .
./scripts/dev/godot.sh --path .
./scripts/dev/export_android_debug.sh
./scripts/dev/export_android_release.sh
./scripts/dev/install_android_debug.sh
```

La exportacion release lee la firma desde
`~/.local/share/ecos/signing/release.env`. El keystore y su clave son secretos
locales: no se versionan y deben respaldarse en un lugar seguro antes de publicar
en Google Play.

El dispositivo virtual local se llama `ecos_api35`. En este equipo debe iniciarse
con `-gpu host`; SwiftShader presenta el issue conocido de Godot `#109550` y no
renderiza correctamente los shaders GLES3.

## Identidad provisional

- Nombre: ECOS.
- Paquete Android: `com.tyrak.ecos`.
- Orientacion: vertical.
- Resolucion logica: 720 x 1280.

El paquete debe confirmarse antes de publicar el primer artefacto en Google Play.
