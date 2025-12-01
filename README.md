# Laboratorio — Consumo de API's con Flutter

Este repositorio contiene una aplicación que consume APIs públicas y sirve como entrega para la actividad:

- Activity 1: Buscar y mostrar Pokémon con todas sus características (imagen, tipos, habilidades, estadísticas) usando PokeAPI (`https://pokeapi.co/api/v2/pokemon/{name}`).
- Activity 2: Consumir una API pública (ej. Art Institute of Chicago) y mostrar obras con imágenes y metadatos.

Este README detalla cómo ejecutar el proyecto, cómo generar una APK y cómo subir el repositorio a GitHub.

## Estructura del proyecto
- `lib/main.dart` — Implementación principal: dos pestañas (Pokémon y Art Institute). Cada pestaña muestra primero una lista y permite ver detalles.
- `pubspec.yaml` — Dependencias (usa `http`).

## Requisitos previos
- Flutter instalado (se probó con Flutter 3.38.3+).
- Para Windows Desktop: Visual Studio con la carga de trabajo "Desktop development with C++".
- Para generar APK: Android Studio y `Android SDK` (instalar `Android SDK Command-line Tools`).

Verifica con:

```powershell
flutter doctor -v
```

Corrige las alertas que `flutter doctor` muestre antes de compilar.

## Ejecutar la app (desde la raíz del proyecto)

```powershell
cd 'C:\Users\APP MOVILES\Downloads\fluteer\pokemonapi_flutter-main\pokemonapi_flutter-main'
flutter pub get
flutter run -d windows
```

Para Android (emulador o dispositivo conectado):

```powershell
flutter devices
flutter run -d <device-id>
```

## ¿Qué hace la app?
- Pestaña "Pokémon": puedes buscar por nombre (p.ej. `ditto`) o cargar una lista de Pokémon; tocar un Pokémon muestra la pantalla de detalles con imagen oficial, tipos, habilidades y estadísticas.
- Pestaña "Art Institute": puedes cargar una cuadrícula de obras; tocar una obra muestra su imagen grande y metadatos.

## Generar APK
1. Asegúrate de tener `Android SDK Command-line Tools` instalado y un Java JDK disponible.
2. Desde la raíz del proyecto:

```powershell
flutter build apk --release
```

El APK generado estará en `build/app/outputs/flutter-apk/app-release.apk`.

Si recibes errores relacionados con el Android toolchain, abre Android Studio → SDK Manager → SDK Tools → marca "Android SDK Command-line Tools" e instálalo.

## Subir el proyecto a GitHub
1. Crea un repositorio vacío en GitHub.
2. Desde la raíz del proyecto ejecuta:

```powershell
git init
git add .
git commit -m "Initial commit - Pokémon & Art Institute app"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

Reemplaza `<your-username>` y `<repo-name>` por tus datos.

## Capturas y entrega
- Toma capturas de pantalla de la app en ejecución y súbelas a la entrega en el aula virtual junto con el enlace a tu repositorio.

## Errores comunes y soluciones
- "No pubspec.yaml file found": asegúrate de ejecutar comandos desde la carpeta que contiene `pubspec.yaml`.
- CMake generator mismatch (Visual Studio versiones diferentes): elimina `windows/CMakeCache.txt` y la carpeta `windows/CMakeFiles`, luego ejecuta `flutter clean` y `flutter run -d windows`.

Ejemplo (PowerShell):

```powershell
Remove-Item .\windows\CMakeCache.txt -Force -ErrorAction SilentlyContinue
Remove-Item .\windows\CMakeFiles -Recurse -Force -ErrorAction SilentlyContinue
flutter clean
flutter run -d windows
```

## Siguientes pasos (opcional)
- Añadir tests unitarios / widget tests.
- Subir releases a GitHub Releases o a Google Play (requiere cuenta de desarrollador).

Si quieres que yo:
- ejecute `flutter build apk` aquí (solo si el entorno tiene Android SDK y JDK), o
- te guíe paso a paso mientras ejecutas los comandos en tu máquina para arreglar cualquier error,

dime cuál opción prefieres y continúo.

---
_Archivo generado/actualizado por asistencia automatizada para mejorar la entrega y facilitar la compilación y subida del proyecto._

