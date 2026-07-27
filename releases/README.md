# Salida local de Android

Este directorio recibe la APK release generada localmente.

Los archivos `*.apk` estan ignorados por Git y no deben publicarse en el repositorio.
El script `scripts/dev/export_android_release.sh` elimina la APK local anterior antes
de crear la vigente.
