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
<img width="908" height="857" alt="image" src="https://github.com/user-attachments/assets/bcc2403c-41fe-4677-8162-df98bbc8a59f" 
<img width="927" height="636" alt="image" src="https://github.com/user-attachments/assets/fe151137-d998-4307-a9c3-3b40fcf99e29" />

- Pestaña "Art Institute": puedes cargar una cuadrícula de obras; tocar una obra muestra su imagen grande y metadatos.
<img width="702" height="1600" alt="image" src="https://github.com/user-attachments/assets/6f87af07-9634-4e37-b03e-73291fec3d73" />
<img width="702" height="1600" alt="image" src="https://github.com/user-attachments/assets/ba6197a9-4356-4fb0-98a6-725e4b484bc3" />


## Generar APK
1. Asegúrate de tener `Android SDK Command-line Tools` instalado y un Java JDK disponible.
2. Desde la raíz del proyecto:

```powershell
flutter build apk --release
```

El APK generado estará en `build/app/outputs/flutter-apk/app-release.apk`.
