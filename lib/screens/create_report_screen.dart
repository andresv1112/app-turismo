import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sendero_seguro/services/location_service.dart';
import 'package:sendero_seguro/services/storage_service.dart';
import 'package:sendero_seguro/models/report.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final LocationService _locationService = LocationService.instance;
  final StorageService _storageService = StorageService();

  String _selectedCategory = 'Seguridad';
  Position? _currentPosition;
  bool _isGettingLocation = true;
  bool _isSubmitting = false;
  bool _isPermissionPermanentlyDenied = false;

  final List<String> _categories = [
    'Seguridad',
    'Infraestructura',
    'Medio Ambiente',
    'Vida Silvestre',
    'Sendero',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isGettingLocation = true;
      });
    }

    try {
      final status = await _locationService.requestLocationPermission();
      if (!mounted) return;

      if (status == PermissionStatus.permanentlyDenied) {
        setState(() {
          _currentPosition = null;
          _isGettingLocation = false;
          _isPermissionPermanentlyDenied = true;
        });
        return;
      }

      if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
        setState(() {
          _currentPosition = null;
          _isGettingLocation = false;
          _isPermissionPermanentlyDenied = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se necesita el permiso de ubicación para continuar'),
          ),
        );
        return;
      }

      final position = await _locationService.getCurrentLocation(requestPermission: false);
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
        _isPermissionPermanentlyDenied = false;
      });

      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación actual'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        _isPermissionPermanentlyDenied = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación actual'),
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || _currentPosition == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        timestamp: DateTime.now(),
      );

      await _storageService.saveReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar el reporte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Nuevo Reporte'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isGettingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Obteniendo ubicación...'),
                ],
              ),
            )
          : _currentPosition == null
              ? _buildLocationError()
              : _buildForm(),
      bottomNavigationBar: _currentPosition != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Enviar Reporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLocationError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _isPermissionPermanentlyDenied
                  ? 'Permiso de ubicación bloqueado'
                  : 'No se pudo obtener la ubicación',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isPermissionPermanentlyDenied
                  ? 'Para continuar debes habilitar el permiso de ubicación desde los ajustes de tu dispositivo.'
                  : 'Para crear un reporte necesitamos tu ubicación actual. Verifica que tengas los permisos de ubicación activados.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isPermissionPermanentlyDenied
                  ? () async {
                      await openAppSettings();
                      if (!mounted) return;
                      await _getCurrentLocation();
                    }
                  : _getCurrentLocation,
              child: Text(_isPermissionPermanentlyDenied ? 'Abrir ajustes' : 'Reintentar'),
            ),
            if (_isPermissionPermanentlyDenied) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _getCurrentLocation,
                child: const Text('Ya habilité el permiso'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubicación actual:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Categoría',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              items: _categories.map((category) => DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(category), size: 20),
                    const SizedBox(width: 8),
                    Text(category),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Título',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Escribe un título descriptivo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un título';
                }
                if (value.trim().length < 5) {
                  return 'El título debe tener al menos 5 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe detalladamente lo que observaste...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                if (value.trim().length < 10) {
                  return 'La descripción debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu reporte ayudará a otros turistas a estar más seguros. Por favor proporciona información precisa y útil.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Espacio para el botón flotante
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'seguridad':
        return Icons.security;
      case 'infraestructura':
        return Icons.build;
      case 'medio ambiente':
        return Icons.eco;
      case 'vida silvestre':
        return Icons.pets;
      case 'sendero':
        return Icons.hiking;
      case 'otros':
      default:
        return Icons.info;
    }
  }
}