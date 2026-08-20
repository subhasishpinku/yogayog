import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yogayog/bikescreen/choose_bike_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';
import 'package:yogayog/bikescreen/provider/bikescreen_provider.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/truckscreen/choose_truck_screen.dart';

class PackageBox {
  final lengthController = TextEditingController();
  final breadthController = TextEditingController();
  final heightController = TextEditingController();

  double get volumetricWeight {
    final length = double.tryParse(lengthController.text) ?? 0;
    final breadth = double.tryParse(breadthController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;

    return (length * breadth * height) / 5000;
  }

  void dispose() {
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
  }
}

class TruckLocalScreen extends StatefulWidget {
  const TruckLocalScreen({super.key});

  @override
  State<TruckLocalScreen> createState() => _TruckLocalScreenState();
}

class _PlaceSuggestion {
  const _PlaceSuggestion({required this.placeId, required this.description});

  final String placeId;
  final String description;
}

class _DropLocation {
  const _DropLocation({
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
}

class _PickupEditDialog extends StatefulWidget {
  const _PickupEditDialog({
    required this.initialAddress,
    required this.initialCity,
    required this.initialPincode,
    required this.initialState,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.searchPlaces,
    required this.getPlaceDetails,
  });

  final String initialAddress;
  final String initialCity;
  final String initialPincode;
  final String initialState;
  final double? initialLatitude;
  final double? initialLongitude;
  final Future<List<_PlaceSuggestion>> Function(String) searchPlaces;
  final Future<_DropLocation> Function(String) getPlaceDetails;

  @override
  State<_PickupEditDialog> createState() => _PickupEditDialogState();
}

class _PickupEditDialogState extends State<_PickupEditDialog> {
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _stateController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  Timer? _debounce;
  List<_PlaceSuggestion> _suggestions = [];
  String? _error;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _cityController = TextEditingController(text: widget.initialCity);
    _pincodeController = TextEditingController(text: widget.initialPincode);
    _stateController = TextEditingController(text: widget.initialState);
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _latitudeController = TextEditingController(
      text: _latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: _longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _searchAddress(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final result = await widget.searchPlaces(value);
        if (!mounted) return;
        setState(() {
          _suggestions = result;
          _error = null;
        });
      } catch (error) {
        if (!mounted) return;
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    });
  }

  Future<void> _selectAddress(_PlaceSuggestion suggestion) async {
    try {
      final location = await widget.getPlaceDetails(suggestion.placeId);
      if (!mounted) return;
      setState(() {
        _addressController.text = location.address;
        _cityController.text = location.city;
        _pincodeController.text = location.pincode;
        _stateController.text = location.state;
        _latitude = location.latitude;
        _longitude = location.longitude;
        _latitudeController.text = _latitude?.toString() ?? '';
        _longitudeController.text = _longitude?.toString() ?? '';
        _suggestions = [];
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? type,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: type,
        onChanged: onChanged,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Pickup Location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_addressController, 'Address', onChanged: _searchAddress),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_suggestions.isNotEmpty)
              Column(
                children: _suggestions.take(4).map((suggestion) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(suggestion.description),
                    onTap: () => _selectAddress(suggestion),
                  );
                }).toList(),
              ),
            _field(_cityController, 'City'),
            _field(_pincodeController, 'Pincode', type: TextInputType.number),
            _field(_stateController, 'State'),
            _field(_latitudeController, 'Latitude', readOnly: true),
            _field(_longitudeController, 'Longitude', readOnly: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _PickupLocation(
              address: _addressController.text.trim(),
              city: _cityController.text.trim(),
              pincode: _pincodeController.text.trim(),
              state: _stateController.text.trim(),
              latitude: _latitude,
              longitude: _longitude,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _PlaceSearchDialog extends StatefulWidget {
  const _PlaceSearchDialog({
    this.title = 'Choose Drop Location',
    required this.searchPlaces,
    required this.getPlaceDetails,
  });

  final Future<List<_PlaceSuggestion>> Function(String) searchPlaces;
  final Future<_DropLocation> Function(String) getPlaceDetails;
  final String title;

  @override
  State<_PlaceSearchDialog> createState() => _PlaceSearchDialogState();
}

class _PlaceSearchDialogState extends State<_PlaceSearchDialog> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<_PlaceSuggestion> _suggestions = [];
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final suggestions = await widget.searchPlaces(value);
        if (!mounted) return;
        setState(() {
          _suggestions = suggestions;
          _error = null;
          _loading = false;
        });
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    });
  }

  Future<void> _selectPlace(_PlaceSuggestion suggestion) async {
    setState(() => _loading = true);
    try {
      final location = await widget.getPlaceDetails(suggestion.placeId);
      if (mounted) Navigator.pop(context, location);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search address, city or pincode',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (_loading) const LinearProgressIndicator(),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                if (_suggestions.isNotEmpty)
                  Column(
                    children: _suggestions.take(4).map((suggestion) {
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(suggestion.description),
                        onTap: () => _selectPlace(suggestion),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _PickupLocation {
  const _PickupLocation({
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
}

class _TruckLocalScreenState extends State<TruckLocalScreen> {
  final packageController = TextEditingController();
  final weightController = TextEditingController(text: '2');
  final approximateWeightController = TextEditingController(text: '0.5');
  final pickupPincodeController = TextEditingController();
  final pincodeController = TextEditingController();
  final piecesController = TextEditingController(text: '1');
  final pickupNameController = TextEditingController();
  final pickupPhoneController = TextEditingController();
  final dropNameController = TextEditingController();
  final dropPhoneController = TextEditingController();
  final List<PackageBox> packageBoxes = [];
  String selectedPackageSize = '0 - 500g';
  String selectedPackageType = 'Document';
  String _pickupAddress = 'Fetching current location...';
  String _pickupCity = '';
  String _pickupPincode = '';
  String _pickupState = '';
  double? _pickupLatitude;
  double? _pickupLongitude;
  String _dropAddress = 'Tap to add destination';
  String _dropCity = '';
  String _dropPincode = '';
  String _dropState = '';
  double? _dropLatitude;
  double? _dropLongitude;

  static const _googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo',
  );

  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  @override
  void initState() {
    super.initState();
    _loadCurrentPickupLocation();
  }

  @override
  void dispose() {
    packageController.dispose();
    weightController.dispose();
    approximateWeightController.dispose();
    pickupPincodeController.dispose();
    pincodeController.dispose();
    piecesController.dispose();
    pickupNameController.dispose();
    pickupPhoneController.dispose();
    dropNameController.dispose();
    dropPhoneController.dispose();
    for (final box in packageBoxes) {
      box.dispose();
    }
    super.dispose();
  }

  Future<List<_PlaceSuggestion>> _searchPlaces(String query) async {
    if (query.trim().length < 2 || _googlePlacesApiKey.isEmpty) return [];
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': query.trim(),
        'key': _googlePlacesApiKey,
        'components': 'country:in',
      },
    );
    final data = response.data;
    if (data is! Map ||
        data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception(
        data is Map
            ? data['error_message'] ?? 'Places search failed'
            : 'Places search failed',
      );
    }
    final predictions = data['predictions'];
    return predictions is List
        ? predictions
              .whereType<Map>()
              .map(
                (item) => _PlaceSuggestion(
                  placeId: item['place_id']?.toString() ?? '',
                  description: item['description']?.toString() ?? '',
                ),
              )
              .toList()
        : [];
  }

  Future<_DropLocation> _getPlaceDetails(String placeId) async {
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'fields': 'formatted_address,address_component,geometry',
        'key': _googlePlacesApiKey,
      },
    );
    final data = response.data;
    final result = data is Map ? data['result'] : null;
    if (data is! Map || data['status'] != 'OK' || result is! Map) {
      throw Exception(
        data is Map
            ? data['error_message'] ?? 'Unable to load place'
            : 'Unable to load place',
      );
    }
    String component(String type) {
      final components = result['address_components'];
      if (components is! List) return '';
      for (final item in components.whereType<Map>()) {
        final types = item['types'];
        if (types is List && types.contains(type))
          return item['long_name']?.toString() ?? '';
      }
      return '';
    }

    final geometry = result['geometry'];
    final location = geometry is Map ? geometry['location'] : null;
    double? coordinate(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    return _DropLocation(
      address: result['formatted_address']?.toString() ?? '',
      city: component('locality').isNotEmpty
          ? component('locality')
          : component('administrative_area_level_2'),
      pincode: component('postal_code'),
      state: component('administrative_area_level_1'),
      latitude: location is Map ? coordinate(location['lat']) : null,
      longitude: location is Map ? coordinate(location['lng']) : null,
    );
  }

  Future<void> _editDrop() async {
    if (_googlePlacesApiKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return;
    }
    final selected = await showDialog<_DropLocation>(
      context: context,
      builder: (_) => _PlaceSearchDialog(
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _dropAddress = selected.address;
      _dropCity = selected.city;
      _dropPincode = selected.pincode;
      pincodeController.text = selected.pincode;
      _dropState = selected.state;
      _dropLatitude = selected.latitude;
      _dropLongitude = selected.longitude;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openSavedLocations() async {
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 1);
    if (!mounted) return;
    if (provider.errorMessage != null && provider.locations.isEmpty) {
      _showMessage(provider.errorMessage!);
      return;
    }
    final selected = await showDialog<SavedLocation>(
      context: context,
      builder: (_) => _SavedLocationDialog(locations: provider.locations),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _pickupAddress = selected.address;
      _pickupCity = selected.city;
      _pickupPincode = selected.pincode;
      pickupPincodeController.text = selected.pincode;
      _pickupState = selected.state;
      _pickupLatitude = selected.latitude;
      _pickupLongitude = selected.longitude;
    });
  }

  Future<void> _openSavedDropLocations() async {
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 1);
    if (!mounted) return;
    if (provider.errorMessage != null && provider.locations.isEmpty) {
      _showMessage(provider.errorMessage!);
      return;
    }
    final selected = await showDialog<SavedLocation>(
      context: context,
      builder: (_) => _SavedLocationDialog(locations: provider.locations),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _dropAddress = selected.address;
      _dropCity = selected.city;
      _dropPincode = selected.pincode;
      pincodeController.text = selected.pincode;
      _dropState = selected.state;
      _dropLatitude = selected.latitude;
      _dropLongitude = selected.longitude;
    });
  }

  Future<void> _loadCurrentPickupLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Please turn on location services');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required');
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      if (!mounted) return;
      setState(() {
        _pickupLatitude = position.latitude;
        _pickupLongitude = position.longitude;
        _pickupAddress = [
          place?.street,
          place?.subLocality,
          place?.locality,
        ].where((value) => value?.trim().isNotEmpty == true).join(', ');
        _pickupCity = place?.locality ?? place?.subAdministrativeArea ?? '';
        _pickupPincode = place?.postalCode ?? '';
        pickupPincodeController.text = _pickupPincode;
        _pickupState = place?.administrativeArea ?? '';
        if (_pickupAddress.isEmpty) _pickupAddress = 'Current location';
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _pickupAddress = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _editPickup() async {
    final result = await showDialog<_PickupLocation>(
      context: context,
      builder: (_) => _PickupEditDialog(
        initialAddress: _pickupAddress,
        initialCity: _pickupCity,
        initialPincode: _pickupPincode,
        initialState: _pickupState,
        initialLatitude: _pickupLatitude,
        initialLongitude: _pickupLongitude,
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _pickupAddress = result.address;
      _pickupCity = result.city;
      _pickupPincode = result.pincode;
      pickupPincodeController.text = result.pincode;
      _pickupState = result.state;
      _pickupLatitude = result.latitude;
      _pickupLongitude = result.longitude;
    });
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    TextInputType? type,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _chooseVehicle() {
    // if (packageController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please enter package description')),
    //   );
    // if (weightController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please enter Approx weight')),
    //   );

    //   final approximateWeight =
    //       double.tryParse(approximateWeightController.text) ?? 0;

    //   final volumetricWeight = packageBoxes.fold<double>(
    //     0,
    //     (total, box) => total + box.volumetricWeight,
    //   );
    //  Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (_) => ChooseTruckScreen(
    //             approximateWeightKg: approximateWeight,
    //             volumetricWeightKg: volumetricWeight,
    //           ),
    //         ),
    //       );
    //   return;
    // }
    if (pickupNameController.text.trim().isEmpty ||
        pickupPhoneController.text.trim().length != 10 ||
        dropNameController.text.trim().isEmpty ||
        dropPhoneController.text.trim().length != 10) {
      _showMessage(
        'Please enter pickup and drop name with valid 10-digit phone number',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChooseTruckScreen(approximateWeightKg: 0, volumetricWeightKg: 0),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _packageTypeCard({
    required String title,
    required IconData icon,
    required String packageType,
  }) {
    final isSelected = selectedPackageType == packageType;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackageType = packageType;

          if (packageType == 'Non-document') {
            _syncPackageBoxes(int.tryParse(piecesController.text) ?? 1);
          } else {
            for (final box in packageBoxes) {
              box.dispose();
            }
            packageBoxes.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 68,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF8FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A6A6) : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF008C8C) : Colors.brown,
              size: 25,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _onPiecesChanged(String value) {
    if (selectedPackageType != 'Non-document') return;

    final count = int.tryParse(value) ?? 0;

    setState(() {
      _syncPackageBoxes(count);
    });
  }

  void _syncPackageBoxes(int count) {
    final safeCount = count < 0 ? 0 : count;

    while (packageBoxes.length < safeCount) {
      packageBoxes.add(PackageBox());
    }

    while (packageBoxes.length > safeCount) {
      packageBoxes.last.dispose();
      packageBoxes.removeLast();
    }
  }

  Widget _packageBoxesWidget() {
    final totalWeight = packageBoxes.fold<double>(
      0,
      (total, box) => total + box.volumetricWeight,
    );
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E1E6)),
      ),
      child: Column(
        children: [
          ...List.generate(
            packageBoxes.length,
            (index) => _packageBoxCard(index, packageBoxes[index]),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Volumetric Weight: ${totalWeight.toStringAsFixed(2)} kg',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageBoxCard(int index, PackageBox box) {
    InputDecoration decoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Box ${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF536078),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (packageBoxes.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      box.dispose();
                      packageBoxes.removeAt(index);
                      piecesController.text = packageBoxes.length.toString();
                    });
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.close, color: Colors.white, size: 15),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: box.lengthController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: decoration('Length (cm)'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: box.breadthController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: decoration('Breadth (cm)'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: box.heightController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: decoration('Height (cm)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Volumetric weight: ${box.volumetricWeight.toStringAsFixed(2)} kg',
            style: const TextStyle(
              color: Color(0xFF536078),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageSizeChip(String size) {
    final isSelected = selectedPackageSize == size;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackageSize = size;
          if (size == '0 - 500g') {
            approximateWeightController.text = '0.5';
          } else if (size == '500g - 1kg') {
            approximateWeightController.text = '1';
          } else {
            approximateWeightController.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFF) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF009B9B)
                : const Color(0xFFD0D0D0),
          ),
        ),
        child: Text(
          size,
          style: TextStyle(
            color: isSelected ? const Color(0xFF008C8C) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSteps(),

                    const SizedBox(height: 14),

                    _buildLocationCard(),

                    const SizedBox(height: 22),

                    // const Text(
                    //   'Select Your Package',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    const SizedBox(height: 8),

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _packageTypeCard(
                    //         title: 'Document',
                    //         icon: Icons.mail_outline,
                    //         packageType: 'Document',
                    //       ),
                    //     ),
                    //     const SizedBox(width: 18),
                    //     Expanded(
                    //       child: _packageTypeCard(
                    //         title: 'Non-document',
                    //         icon: Icons.inventory_2_outlined,
                    //         packageType: 'Non-document',
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const Text(
                    //   'Select Package Size',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    // const SizedBox(height: 8),

                    // Wrap(
                    //   spacing: 8,
                    //   children: [
                    //     _packageSizeChip('0 - 500g'),
                    //     _packageSizeChip('500g - 1kg'),
                    //     _packageSizeChip('Greater than 1kg'),
                    //   ],
                    // ),

                    // const SizedBox(height: 18),

                    // const Text(
                    //   'Enter Package Details',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    // const SizedBox(height: 10),
                    // Row(
                    //   children: [
                    //     const SizedBox(
                    //       width: 190,
                    //       child: Text(
                    //         'Number of Total Pieces :',
                    //         style: TextStyle(
                    //           fontSize: 13,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: _textField(
                    //         controller: piecesController,
                    //         hintText: '1',
                    //         keyboardType: TextInputType.number,
                    //         onChanged: _onPiecesChanged,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 8),

                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const SizedBox(
                    //       width: 190,
                    //       child: Padding(
                    //         padding: EdgeInsets.only(top: 14),
                    //         child: Text(
                    //           'Approximate Weight (KG) :',
                    //           style: TextStyle(
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           _textField(
                    //             controller: approximateWeightController,
                    //             hintText: 'e.g., 2.5',
                    //             keyboardType: TextInputType.number,
                    //           ),
                    //           if (selectedPackageSize != 'Greater than 1kg')
                    //             Padding(
                    //               padding: const EdgeInsets.only(
                    //                 left: 4,
                    //                 top: 4,
                    //               ),
                    //               child: Text(
                    //                 '💡 Weight set to '
                    //                 '${approximateWeightController.text}kg '
                    //                 'for this size',
                    //                 style: const TextStyle(
                    //                   color: Color(0xFF536078),
                    //                   fontSize: 12,
                    //                 ),
                    //               ),
                    //             ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // if (selectedPackageType == 'Non-document') ...[
                    //   const SizedBox(height: 16),
                    //   _packageBoxesWidget(),
                    // ],

                    // const Text(
                    //   'PACKAGE DESCRIPTION',
                    //   style: TextStyle(
                    //     color: Color(0xFF667085),
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w600,
                    //     letterSpacing: .6,
                    //   ),
                    // ),

                    // const SizedBox(height: 6),

                    // TextField(
                    //   controller: packageController,
                    //   decoration: _inputDecoration(
                    //     'e.g. Documents, parcel, spare parts...',
                    //   ),
                    // ),
                    const SizedBox(height: 16),

                    const Text(
                      'PIN CODE',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _pinCodeField(
                            label: 'Pickup PIN',
                            controller: pickupPincodeController,
                            hint: 'Pickup PIN',
                            readOnly: true,
                            onChanged: (value) => _pickupPincode = value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _pinCodeField(
                            label: 'Drop PIN',
                            controller: pincodeController,
                            hint: 'Drop PIN',
                            onChanged: (value) {
                              if (value.length == 6) _dropPincode = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'APPROX. WEIGHT',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('2 kg'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 90,
                          height: 49,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE0E2E8)),
                          ),
                          child: const Text(
                            'kg',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _chooseVehicle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Choose Vehicle →',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Container(
        color: blue,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  'Local Truck Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 3),

            const Text(
              'Bike or Truck — picked up in minutes',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Row(
      children: [
        _stepItem('1', 'Address', true),
        _stepLine(),
        _stepItem('2', 'Vehicle', false),
        _stepLine(),
        _stepItem('3', 'Confirm', false),
      ],
    );
  }

  Widget _stepItem(String number, String title, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? yellow : Colors.white,
            border: Border.all(
              color: active ? const Color(0xFFD6A900) : const Color(0xFFD9DCE5),
              width: 1.5,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? blue : const Color(0xFF8A8F9C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: active ? blue : const Color(0xFF8A8F9C),
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: const Color(0xFFD9DCE5),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _savedLocationSearchBox(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationIndicator(yellow),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP',
                      style: TextStyle(
                        color: Color(0xFF8A8F9C),
                        fontSize: 11,
                        letterSpacing: .8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      _pickupAddress,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_pickupCity.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _pickupCity,
                        style: const TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '${_pickupPincode.isNotEmpty ? _pickupPincode : 'Pincode unavailable'}, ${_pickupState.isNotEmpty ? _pickupState : 'State unavailable'}',
                      style: const TextStyle(
                        color: Color(0xFF8A8F9C),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: _editPickup,
                child: const Text(
                  'Edit',
                  style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _contactField(pickupNameController, 'Pickup name'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _contactField(
                  pickupPhoneController,
                  'Pickup phone',
                  phone: true,
                ),
              ),
            ],
          ),

          const Divider(height: 22),

          _savedDropLocationSearchBox(),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationIndicator(blue),

              const SizedBox(width: 14),

              Expanded(
                child: InkWell(
                  onTap: _editDrop,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DROP',
                        style: TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 11,
                          letterSpacing: .8,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        _dropAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _dropAddress == 'Tap to add destination'
                              ? const Color(0xFF8A8F9C)
                              : Colors.black,
                          fontSize: 14,
                          fontWeight: _dropAddress == 'Tap to add destination'
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      if (_dropAddress != 'Tap to add destination') ...[
                        if (_dropCity.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _dropCity,
                            style: const TextStyle(
                              color: Color(0xFF8A8F9C),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          '${_dropPincode.isNotEmpty ? _dropPincode : 'Pincode unavailable'}, ${_dropState.isNotEmpty ? _dropState : 'State unavailable'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A8F9C),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _contactField(dropNameController, 'Drop name')),
              const SizedBox(width: 10),
              Expanded(
                child: _contactField(
                  dropPhoneController,
                  'Drop phone',
                  phone: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactField(
    TextEditingController controller,
    String hint, {
    bool phone = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: phone ? TextInputType.phone : TextInputType.name,
      maxLength: phone ? 10 : null,
      inputFormatters: phone ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: _inputDecoration(hint).copyWith(counterText: ''),
    );
  }

  Widget _savedLocationSearchBox() {
    return InkWell(
      onTap: _openSavedLocations,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E2E8)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFF667085)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search saved pickup location',
                style: TextStyle(color: Color(0xFF667085)),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
          ],
        ),
      ),
    );
  }

  Widget _locationIndicator(Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Container(width: 2, height: 30, color: const Color(0xFFD9DCE5)),
      ],
    );
  }

  Widget _pinCodeField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: _inputDecoration(hint).copyWith(counterText: ''),
        ),
      ],
    );
  }

  Widget _savedDropLocationSearchBox() {
    return InkWell(
      onTap: _openSavedDropLocations,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E2E8)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFF667085)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search saved drop location',
                style: TextStyle(color: Color(0xFF667085)),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF667085), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }
}

class _SavedLocationDialog extends StatefulWidget {
  const _SavedLocationDialog({required this.locations});

  final List<SavedLocation> locations;

  @override
  State<_SavedLocationDialog> createState() => _SavedLocationDialogState();
}

class _SavedLocationDialogState extends State<_SavedLocationDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final locations = widget.locations.where((location) {
      if (query.isEmpty) return true;
      return '${location.name} ${location.address} ${location.city} ${location.pincode}'
          .toLowerCase()
          .contains(query);
    }).toList();

    return AlertDialog(
      title: const Text('Select Pickup Location'),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search address or city',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: locations.isEmpty
                  ? const Center(child: Text('No saved locations found'))
                  : ListView.separated(
                      itemCount: locations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final location = locations[index];
                        return ListTile(
                          leading: Icon(
                            location.flag == 'pick'
                                ? Icons.location_on
                                : Icons.location_on_outlined,
                            color: AppColors.primaryMain,
                          ),
                          title: Text(
                            location.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${location.city}, ${location.pincode}, ${location.state}',
                          ),
                          onTap: () => Navigator.pop(context, location),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
