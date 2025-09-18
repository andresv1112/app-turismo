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