import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  // Punto fijo para la polilínea (ejemplo: Universidad - ajusta según tu necesidad)
  static const LatLng _destinoFijo = LatLng(-3.9930, -79.2050); // Coordenadas de ejemplo

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 1. Verificar si el GPS está encendido
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage =
            'El GPS está desactivado. Por favor actívalo para usar el mapa.';
        _isLoading = false;
      });
      _showErrorDialog(
          'GPS desactivado', 'Por favor activa el GPS en la configuración de tu dispositivo.');
      return;
    }

    // 2. Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Pedir permiso
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'Permiso de ubicación denegado. Sin permiso, no puedo mostrar tu ubicación.';
          _isLoading = false;
        });
        _showErrorDialog(
          'Permiso denegado',
          'Esta aplicación necesita acceso a tu ubicación para mostrar el mapa centrado en tu posición actual.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Permisos denegados permanentemente. Ve a configuración de la app para habilitarlos.';
        _isLoading = false;
      });
      _showErrorDialog(
        'Permiso denegado permanentemente',
        'Debes ir a la configuración de la aplicación y habilitar los permisos de ubicación manualmente.',
      );
      return;
    }

    // 3. Obtener ubicación actual
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        
        // Crear marcador en ubicación actual
        _markers.add(
          Marker(
            markerId: const MarkerId('ubicacion_actual'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(
              title: 'Tu ubicación actual',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );

        // Crear polilínea desde ubicación actual hasta punto fijo
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('ruta_universidad'),
            points: [
              LatLng(position.latitude, position.longitude),
              _destinoFijo,
            ],
            color: Colors.blue,
            width: 5,
          ),
        );

        // Mover cámara a ubicación actual
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener ubicación: $e';
        _isLoading = false;
      });
      _showErrorDialog(
        'Error',
        'No se pudo obtener tu ubicación. Asegúrate de que el GPS esté activo y que la aplicación tenga permisos.',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa con Ubicación Actual'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Obteniendo tu ubicación...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _initializeMap();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(0, 0),
                    zoom: 15.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  mapType: MapType.normal,
                ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
