
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation; 


  LocationPickerScreen({super.key, this.initialLocation});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  Set<Marker> _markers = {};
  String _address = 'Presiona y mantén presionado en el mapa para seleccionar una ubicación';


  late LatLng _currentCameraPosition;

  @override
  void initState() {
    super.initState();

    _currentCameraPosition = widget.initialLocation ?? const LatLng(14.7397, -91.9542); // Ejemplo: Huehuetenango, Guatemala

   
    if (widget.initialLocation != null) {
      _pickedLocation = widget.initialLocation;
      _markers.add(
        Marker(
          markerId: const MarkerId('initial-picked-location'),
          position: widget.initialLocation!,
          infoWindow: const InfoWindow(title: 'Ubicación Previa'),
        ),
      );
      // Opcional: Obtener la dirección para la ubicación inicial si existe
      _getAddressFromCoordinates(widget.initialLocation!);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapLongPress(LatLng latLng) async {
    setState(() {
      _pickedLocation = latLng;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('picked-location'),
          position: latLng,
          infoWindow: InfoWindow(
            title: 'Ubicación Seleccionada',
            snippet: 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    });
    _getAddressFromCoordinates(latLng);
  }

  Future<void> _getAddressFromCoordinates(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude, localeIdentifier: 'es');
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        setState(() {
          _address = fullAddress;
        });
      } else {
        setState(() {
          _address = 'Dirección no encontrada para estas coordenadas.';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Error al obtener la dirección: $e';
      });
      print('Error getting address: $e');
    }
  }

  void _confirmLocation() {
    if (_pickedLocation != null) {
      Navigator.pop(context, {
        'latitude': _pickedLocation!.latitude,
        'longitude': _pickedLocation!.longitude,
        'address': _address,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una ubicación en el mapa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition( // Usar _currentCameraPosition para la posición inicial
                target: _currentCameraPosition,
                zoom: 12,
              ),
              onMapCreated: _onMapCreated,
              onLongPress: _onMapLongPress,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ubicación seleccionada:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _address,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirmar Ubicación',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}