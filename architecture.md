# Sendero Seguro - Arquitectura de la Aplicación

## Descripción del Proyecto
Aplicación móvil para turismo responsable en veredas que permite a los usuarios navegar de forma segura, conocer rutas recomendadas y reportar incidentes.

## Funcionalidades Principales

### 1. Mapa con Ubicación Actual
- Muestra la ubicación del usuario en tiempo real
- Solicita permisos de ubicación al iniciar
- Vista de mapa híbrido con Google Maps

### 2. Zonas de Peligro
- Círculos rojos que marcan áreas peligrosas predefinidas
- Alertas automáticas cuando el usuario ingresa a una zona
- Información detallada sobre peligros, precauciones y recomendaciones

### 3. Rutas Seguras
- Lista de senderos recomendados con información detallada
- Mapas de ruta con puntos de interés
- Información sobre dificultad, duración y atracciones

### 4. Sistema de Reportes
- Formulario para crear nuevos reportes
- Categorización por tipo de incidente
- Almacenamiento local de reportes

## Arquitectura del Código

### Modelos de Datos
- `DangerZone`: Zona de peligro con coordenadas y información
- `SafeRoute`: Ruta segura con puntos y detalles
- `Report`: Reporte de usuario con ubicación y detalles
- `RoutePoint`: Punto específico de una ruta

### Servicios
- `LocationService`: Manejo de geolocalización y permisos
- `StorageService`: Almacenamiento local con SharedPreferences

### Pantallas Principales
- `HomePage`: Pantalla principal con mapa y navegación por tabs
- `RoutesScreen`: Lista de rutas seguras disponibles
- `RouteDetailScreen`: Detalle de una ruta específica
- `ReportsScreen`: Lista de reportes existentes
- `CreateReportScreen`: Formulario para crear nuevo reporte

### Widgets Reutilizables
- `DangerZoneDialog`: Diálogo de alerta para zonas peligrosas
- `RouteCard`: Tarjeta para mostrar información de rutas
- `ReportCard`: Tarjeta para mostrar reportes

## Configuración de Plataforma

### Android
- Permisos de ubicación en AndroidManifest.xml
- Configuración para Google Maps API
- Firma de releases mediante keystore dedicado

#### Clave de API de Google Maps
1. Ingresa a [Google Cloud Console](https://console.cloud.google.com/) con una cuenta autorizada y selecciona el proyecto del cliente. Si no existe, crea uno nuevo para la aplicación **Sendero Seguro**.
2. Habilita los servicios necesarios desde **APIs & Services > Library**:
   - **Maps SDK for Android** (obligatorio para mostrar mapas).
   - Opcionalmente **Geocoding API** o **Places API** si se requieren en futuras iteraciones.
3. Crea una credencial tipo **API key** en **APIs & Services > Credentials** y aplícale restricciones:
   - **Application restrictions**: selecciona *Android apps* y registra el `applicationId` (`com.sendero.seguro`) junto con la huella SHA-1 de los certificados de firma (debug y release si aplica).
   - **API restrictions**: limita la llave únicamente a las APIs habilitadas en el paso anterior.
4. Copia la clave generada en el archivo `android/local.properties` (no versionado) con el formato:
   ```properties
   MAPS_API_KEY=tu_clave_aqui
   ```
   Alternativamente, puedes exponerla como variable de entorno (`MAPS_API_KEY`) o pasarla al invocar Gradle (`./gradlew assembleDebug -PMAPS_API_KEY=...`).
5. Verifica el aprovisionamiento ejecutando `./gradlew :app:processDebugMainManifest` y comprobando que el valor se refleje en el manifest generado. Si la clave no está definida, Gradle emite una advertencia y el mapa cargará sin credenciales.
6. Comparte la clave de manera segura y evita publicarla en repositorios o sistemas de seguimiento de tickets.

#### Firma de releases
1. Genera un keystore para producción dentro de `android/app` (por ejemplo `android/app/release-keystore.jks`) con el siguiente comando:
   ```bash
   keytool -genkey -v -keystore android/app/release-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Crea el archivo `android/key.properties` (no debe versionarse) con el contenido:
   ```properties
   storePassword=TU_PASSWORD_DEL_KEYSTORE
   keyPassword=TU_PASSWORD_DE_LA_LLAVE
   keyAlias=upload
   storeFile=../app/release-keystore.jks
   ```
3. Guarda estos archivos en un lugar seguro y comparte las contraseñas solo con las personas autorizadas para publicar releases oficiales.

Cuando `key.properties` no está presente, la app reutiliza automáticamente la firma de depuración para facilitar el desarrollo local.

### iOS
- Descripción de uso de ubicación en Info.plist
- Configuración de permisos de ubicación

## Datos Predefinidos

### Zonas de Peligro
1. **Zona Rocosa Inestable** (4.1161999958575795, -73.6088337333233)
   - Radio: 150m
   - Peligros: Desprendimiento de rocas, terreno resbaladizo
   
2. **Zona de Quebrada** (4.110716544734726, -73.62999691007467)
   - Radio: 120m
   - Peligros: Crecientes súbitas, terreno fangoso

### Rutas Seguras
1. **Sendero del Mirador** - Fácil, 2 horas
2. **Ruta de las Cascadas** - Moderada, 3.5 horas  
3. **Camino Ancestral** - Fácil, 1.5 horas

## Tecnologías Utilizadas
- Flutter 3.6+
- Google Maps Flutter
- Geolocator para ubicación
- SharedPreferences para almacenamiento
- Permission Handler para permisos
- Material Design 3

## Próximas Mejoras
- Integración con backend (Firebase/Supabase)
- Fotos en reportes
- Notificaciones push
- Compartir rutas entre usuarios
- Modo offline con mapas descargados