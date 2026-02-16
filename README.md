# Google Maps - Ubicación Actual

Aplicación Flutter que muestra un mapa centrado en la ubicación actual del usuario, con un marcador y una polilínea hacia un punto fijo.

## Requisitos Técnicos

### Google Cloud Console
- API Key configurada con Maps SDK for Android y Maps SDK for iOS habilitados
- API Key restringida para seguridad

### Permisos
- `ACCESS_FINE_LOCATION` - Ubicación GPS precisa
- `ACCESS_COARSE_LOCATION` - Ubicación aproximada  
- Manejo de permisos en tiempo de ejecución con feedback al usuario

### Funcionalidades
- ✅ Verificación de GPS activo
- ✅ Solicitud de permisos con diálogos explicativos
- ✅ Mapa centrado en ubicación actual (NO coordenada fija)
- ✅ Marcador con InfoWindow "Tu ubicación actual"
- ✅ Polilínea desde ubicación actual hasta punto fijo

## Configuración

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd flutter_maps_2526
```

### 2. Configurar API Key

Crea un archivo `.env` en la raíz del proyecto:
```bash
cp .env.example .env
```

Edita `.env` y agrega tu API Key de Google Maps:
```
GOOGLE_MAPS_API_KEY=TU_API_KEY_AQUI
```

### 3. Para eject Web
Ejecuta el script de configuración:
```bash
./setup_web.sh
```

### 4. Instalar dependencias
```bash
flutter pub get
```

## Ejecutar la Aplicación

### Web (Chrome)
```bash
./setup_web.sh && flutter run -d chrome
```

### Android
```bash
flutter run
```

### iOS
```bash
flutter run
```

## Configuración de API Key en Código Nativo

### Android (`android/app/src/main/AndroidManifest.xml`)
La API key está configurada en la línea 37:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" 
           android:value="TU_API_KEY_AQUI"/>
```

### iOS (`ios/Runner/AppDelegate.swift`)
La API key está configurada en la línea 11:
```swift
GMSServices.provideAPIKey("TU_API_KEY_AQUI")
```

## Estructura del Proyecto

```
lib/
├── main.dart              # Punto de entrada
└── screens/
    └── mapa_screen.dart   # Pantalla principal con mapa
```

## Manejo de Errores

La aplicación maneja los siguientes escenarios:
- GPS desactivado → Diálogo pidiendo activarlo
- Permiso denegado → Explicación clara de por qué se necesita
- Permiso denegado permanentemente → Instrucciones para ir a configuración
- Error al obtener ubicación → Botón para reintentar

## Seguridad

- El archivo `.env` está en `.gitignore` y NO se sube al repositorio
- `.env.example` muestra la estructura sin exponer la API key real
- Script `setup_web.sh` inyecta la API key automáticamente para web

## Desarrollo

**Autor**: Ricardo  
**Fecha**: Febrero 2026  
**Framework**: Flutter 3.38.6
