import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yogayog/choosecourier/choose_courier.dart';
import 'package:yogayog/bikescreen/provider/bikescreen_provider.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:yogayog/nationaldetails/provider/national_provider.dart';
import 'package:yogayog/core/services/national_service.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/constants/app_colors.dart';

class _PlaceSuggestion {
  const _PlaceSuggestion({required this.placeId, required this.description});
  final String placeId;
  final String description;
}

class _GeoLocation {
  const _GeoLocation({
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    this.latitude,
    this.longitude,
  });
  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
}

class _PlaceSearchDialog extends StatefulWidget {
  const _PlaceSearchDialog({
    this.title = 'Choose Drop Location',
    required this.searchPlaces,
    required this.getPlaceDetails,
  });

  final Future<List<_PlaceSuggestion>> Function(String) searchPlaces;
  final Future<_GeoLocation> Function(String) getPlaceDetails;
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

class _PickupEditDialog extends StatefulWidget {
  const _PickupEditDialog({
    this.title = 'Edit Pickup Location',
    required this.initialAddress,
    required this.initialCity,
    required this.initialPincode,
    required this.initialState,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.searchPlaces,
    required this.getPlaceDetails,
  });

  final String title;
  final String initialAddress;
  final String initialCity;
  final String initialPincode;
  final String initialState;
  final double? initialLatitude;
  final double? initialLongitude;
  final Future<List<_PlaceSuggestion>> Function(String) searchPlaces;
  final Future<_GeoLocation> Function(String) getPlaceDetails;

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
      title: Text(widget.title),
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
            _field(
              _pincodeController,
              'Pickup PIN',
              type: TextInputType.number,
            ),
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
            _GeoLocation(
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

class NationalDetails extends StatefulWidget {
  const NationalDetails({super.key});

  @override
  State<NationalDetails> createState() => _NationalDetailsState();
}

class _NationalDetailsState extends State<NationalDetails> {
  static const placesKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo',
  );

  String selectedPackageType = 'Document';
  String selectedPackageSize = '0 - 500g';
  String selectedService = 'Express';

  final receiverNameController = TextEditingController();
  final mobileController = TextEditingController();
  final pickupNameController = TextEditingController();
  final pickupPhoneController = TextEditingController();
  final pickupPinController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pinController = TextEditingController();
  final piecesController = TextEditingController(text: '1');
  final approximateWeightController = TextEditingController(text: '0.5');

  final List<PackageBox> packageBoxes = [];

  String pickupAddress = 'Fetching current location...';
  String pickupCity = '';
  String pickupPincode = '';
  String pickupState = '';
  double? pickupLatitude;
  double? pickupLongitude;

  String dropAddress = 'Tap to add destination';
  String dropCity = '';
  String dropPincode = '';
  String dropState = '';
  double? dropLatitude;
  double? dropLongitude;

  @override
  void initState() {
    super.initState();
    _loadSavedProfileContact();
    _loadCurrentPickupLocation();
  }

  Future<void> _loadSavedProfileContact() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      if (pickupNameController.text.trim().isEmpty) {
        pickupNameController.text =
            preferences.getString(HomeService.profileNameKey) ?? '';
      }
      if (pickupPhoneController.text.trim().isEmpty) {
        pickupPhoneController.text =
            preferences.getString(HomeService.profileMobileKey) ?? '';
      }
    });
  }

  @override
  void dispose() {
    receiverNameController.dispose();
    mobileController.dispose();
    pickupNameController.dispose();
    pickupPhoneController.dispose();
    pickupPinController.dispose();
    addressController.dispose();
    cityController.dispose();
    pinController.dispose();
    piecesController.dispose();
    approximateWeightController.dispose();
    for (final box in packageBoxes) {
      box.dispose();
    }
    super.dispose();
  }

  // ==================== Google Places API ====================

  Future<List<_PlaceSuggestion>> _searchPlaces(String query) async {
    if (query.trim().length < 2 || placesKey.isEmpty) return [];
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': query.trim(),
        'key': placesKey,
        'components': 'country:in',
      },
    );
    final data = response.data;
    if (data is! Map ||
        data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('Places search failed');
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

  Future<_GeoLocation> _getPlaceDetails(String placeId) async {
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'fields': 'formatted_address,address_component,geometry',
        'key': placesKey,
      },
    );
    final data = response.data;
    final result = data is Map ? data['result'] : null;
    if (data is! Map || data['status'] != 'OK' || result is! Map) {
      throw Exception('Unable to load place');
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

    return _GeoLocation(
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

  // ==================== Pickup Location ====================

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
        pickupLatitude = position.latitude;
        pickupLongitude = position.longitude;
        pickupAddress = [
          place?.street,
          place?.subLocality,
          place?.locality,
        ].where((value) => value?.trim().isNotEmpty == true).join(', ');
        pickupCity = place?.locality ?? place?.subAdministrativeArea ?? '';
        pickupPincode = place?.postalCode ?? '';
        pickupPinController.text = pickupPincode;
        pickupState = place?.administrativeArea ?? '';
        if (pickupAddress.isEmpty) pickupAddress = 'Current location';
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => pickupAddress = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _editPickup() async {
    final result = await showDialog<_GeoLocation>(
      context: context,
      builder: (_) => _PickupEditDialog(
        initialAddress: pickupAddress,
        initialCity: pickupCity,
        initialPincode: pickupPincode,
        initialState: pickupState,
        initialLatitude: pickupLatitude,
        initialLongitude: pickupLongitude,
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      pickupAddress = result.address;
      pickupCity = result.city;
      pickupPincode = result.pincode;
      pickupPinController.text = pickupPincode;
      pickupState = result.state;
      pickupLatitude = result.latitude;
      pickupLongitude = result.longitude;
    });
    if (!await _checkNationalPincode(result.pincode)) return;
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: {
        'name': pickupNameController.text.trim(),
        'mobile': pickupPhoneController.text.trim(),
        'service_id': 1,
        'house_numb': '',
        'street': result.address,
        'city': result.city,
        'district': result.city,
        'state': result.state,
        'pin': result.pincode,
        'country': 'India',
        'country_cde': 'IN',
        'lat': result.latitude,
        'lon': result.longitude,
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Pickup location saved successfully'
          : context.read<BikescreenProvider>().errorMessage ??
                'Unable to save pickup location',
    );
  }

  Future<void> _openSavedLocations() async {
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 4);
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
      pickupAddress = selected.address;
      pickupCity = selected.city;
      pickupPincode = selected.pincode;
      pickupPinController.text = pickupPincode;
      pickupState = selected.state;
      pickupLatitude = selected.latitude;
      pickupLongitude = selected.longitude;
    });
    if (!await _checkNationalPincode(selected.pincode)) return;
  }

  Future<void> _openSavedDropLocations() async {
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 4);
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
      dropAddress = selected.address;
      dropCity = selected.city;
      dropPincode = selected.pincode;
      pinController.text = dropPincode;
      dropState = selected.state;
      dropLatitude = selected.latitude;
      dropLongitude = selected.longitude;
      addressController.text = dropAddress;
      cityController.text = dropCity;
    });
    if (!await _checkNationalPincode(selected.pincode)) return;
    if (await _rejectUnserviceableKolkataRoute()) return;
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: {
        'name': receiverNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'service_id': 4,
        'house_numb': '',
        'street': selected.address,
        'city': selected.city,
        'district': selected.city,
        'state': selected.state,
        'pin': selected.pincode,
        'country': 'India',
        'country_cde': 'IN',
        'lat': selected.latitude,
        'lon': selected.longitude,
        'flag': 'drop',
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Drop address saved successfully'
          : context.read<BikescreenProvider>().errorMessage ??
                'Unable to save drop address',
    );
  }

  // ==================== Drop Location ====================

  Future<void> _openDropSearchDialog() async {
    if (placesKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return;
    }
    final selected = await showDialog<_GeoLocation>(
      context: context,
      builder: (_) => _PlaceSearchDialog(
        title: 'Choose Drop Location',
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      dropAddress = selected.address;
      dropCity = selected.city;
      dropPincode = selected.pincode;
      dropState = selected.state;
      dropLatitude = selected.latitude;
      dropLongitude = selected.longitude;
      addressController.text = dropAddress;
      cityController.text = dropCity;
      pinController.text = dropPincode;
    });
    if (!await _checkNationalPincode(selected.pincode)) return;
    if (await _rejectUnserviceableKolkataRoute()) return;
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: {
        'name': receiverNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'service_id': 4,
        'house_numb': '',
        'street': selected.address,
        'city': selected.city,
        'district': selected.city,
        'state': selected.state,
        'pin': selected.pincode,
        'country': 'India',
        'country_cde': 'IN',
        'lat': selected.latitude,
        'lon': selected.longitude,
        'flag': 'drop',
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Drop address saved successfully'
          : context.read<BikescreenProvider>().errorMessage ??
                'Unable to save drop address',
    );
  }

  void _dropLocationAction() {
    if (dropAddress == 'Tap to add destination') {
      _openDropSearchDialog();
    } else {
      _editDrop();
    }
  }

  Future<void> _editDrop() async {
    if (placesKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return;
    }
    final selected = await showDialog<_GeoLocation>(
      context: context,
      builder: (_) => _PickupEditDialog(
        title: 'Edit Drop Location',
        initialAddress: dropAddress,
        initialCity: dropCity,
        initialPincode: dropPincode,
        initialState: dropState,
        initialLatitude: dropLatitude,
        initialLongitude: dropLongitude,
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      dropAddress = selected.address;
      dropCity = selected.city;
      dropPincode = selected.pincode;
      dropState = selected.state;
      dropLatitude = selected.latitude;
      dropLongitude = selected.longitude;
      addressController.text = dropAddress;
      cityController.text = dropCity;
      pinController.text = dropPincode;
    });
    if (!await _checkNationalPincode(selected.pincode)) return;
    if (await _rejectUnserviceableKolkataRoute()) return;
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: {
        'name': receiverNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'service_id': 4,
        'house_numb': '',
        'street': selected.address,
        'city': selected.city,
        'district': selected.city,
        'state': selected.state,
        'pin': selected.pincode,
        'country': 'India',
        'country_cde': 'IN',
        'lat': selected.latitude,
        'lon': selected.longitude,
        'flag': 'drop',
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Drop location saved successfully'
          : context.read<BikescreenProvider>().errorMessage ??
                'Unable to save drop location',
    );
  }

  // ==================== Helper Methods ====================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  // ==================== Widget Builders ====================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF536078),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: const TextStyle(color: Color(0xFF536078), fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF536078), fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE1E1E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF17249B), width: 1.5),
        ),
      ),
    );
  }

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _openSavedLocations,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 49,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1E1E6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF667085), size: 23),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search saved pickup location',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 14),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _locationRow(
            'PICKUP',
            pickupAddress,
            pickupCity,
            pickupPincode,
            true,
            _editPickup,
          ),
          _contactRow(
            nameController: pickupNameController,
            phoneController: pickupPhoneController,
            nameLabel: 'PICKUP NAME',
            phoneLabel: 'PICKUP PHONE',
            nameHint: 'Pickup name',
            phoneHint: 'Pickup phone',
          ),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Divider(height: 20),
          ),
          InkWell(
            onTap: _openSavedDropLocations,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 49,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1E1E6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF667085), size: 23),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search saved drop location',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 14),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _locationRow(
            'DROP',
            dropAddress,
            dropCity,
            dropPincode,
            false,
            _dropLocationAction,
          ),
          _contactRow(
            nameController: receiverNameController,
            phoneController: mobileController,
            nameLabel: 'DROP NAME',
            phoneLabel: 'DROP PHONE',
            nameHint: 'Drop name',
            phoneHint: 'Drop phone',
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required String nameLabel,
    required String phoneLabel,
    required String nameHint,
    required String phoneHint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(nameLabel),
                _textField(controller: nameController, hintText: nameHint),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(phoneLabel),
                _textField(
                  controller: phoneController,
                  hintText: phoneHint,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow(
    String label,
    String address,
    String city,
    String pincode,
    bool pickup,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: pickup ? const Color(0xFFFFC400) : Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                if (pickup)
                  Container(
                    width: 2,
                    height: 26,
                    color: const Color(0xFFD9DCE5),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8A8F9C),
                    fontSize: 11,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: pickup ? FontWeight.w700 : FontWeight.normal,
                    color: pickup ? Colors.black : const Color(0xFF8A8F9C),
                  ),
                ),
                if (city.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    city,
                    style: const TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 13,
                    ),
                  ),
                ],
                if (pincode.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'PIN: $pincode',
                    style: const TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
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
            (index) => _boxCard(box: packageBoxes[index], index: index),
          ),
          const SizedBox(height: 10),
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

  Widget _boxCard({required PackageBox box, required int index}) {
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
                  fontSize: 14,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _dimensionField(
                  controller: box.lengthController,
                  hintText: 'Length (cm)',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dimensionField(
                  controller: box.breadthController,
                  hintText: 'Breadth (cm)',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dimensionField(
                  controller: box.heightController,
                  hintText: 'Height (cm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Volumetric Weight: ${box.volumetricWeight.toStringAsFixed(2)} kg',
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

  Widget _dimensionField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF536078), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFF00A6A6)),
        ),
      ),
    );
  }

  bool _isKolkataLocation(String city, String address) {
    final value = '$city $address'.toLowerCase();
    return value.contains('kolkata') || value.contains('calcutta');
  }

  Future<void> _showUnserviceableRouteAlert() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Service unavailable'),
        content: const Text('This area is not serviceable for this time'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() {
      pickupAddress = 'Tap to add pickup location';
      pickupCity = '';
      pickupPincode = '';
      pickupState = '';
      pickupLatitude = null;
      pickupLongitude = null;
      pickupPinController.clear();
      dropAddress = 'Tap to add destination';
      dropCity = '';
      dropPincode = '';
      dropState = '';
      dropLatitude = null;
      dropLongitude = null;
      pinController.clear();
      addressController.clear();
      cityController.clear();
    });
  }

  Future<bool> _rejectUnserviceableKolkataRoute() async {
    if (!_isKolkataLocation(pickupCity, pickupAddress) ||
        !_isKolkataLocation(dropCity, dropAddress)) {
      return false;
    }
    await _showUnserviceableRouteAlert();
    return true;
  }

  Future<bool> _checkNationalPincode(String pincode) async {
    final value = pincode.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      _showMessage('Please enter a valid 6-digit pincode');
      return false;
    }
    final provider = context.read<NationalProvider>();
    final serviceable = await provider.checkPincode(value);
    if (!mounted) return false;
    if (!serviceable) {
      _showMessage(
        provider.errorMessage ??
            provider.result?.message ??
            'This pincode is not serviceable',
      );
      return false;
    }
    return true;
  }

  Future<void> _reviewAndConfirm() async {
    FocusScope.of(context).unfocus();
    if (!await _checkNationalPincode(pickupPincode) ||
        !await _checkNationalPincode(dropPincode)) {
      return;
    }
    if (await _rejectUnserviceableKolkataRoute()) return;
    if (pickupNameController.text.trim().isEmpty ||
        pickupPhoneController.text.trim().length != 10 ||
        receiverNameController.text.trim().isEmpty ||
        mobileController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter pickup and drop name with valid 10-digit phone number',
          ),
        ),
      );
      return;
    }
    final approximateWeight =
        double.tryParse(approximateWeightController.text) ?? 0;
    final volumetricWeight = packageBoxes.fold<double>(
      0,
      (total, box) => total + box.volumetricWeight,
    );
    final weight = approximateWeight > 0 ? approximateWeight : 1.0;
    final boxes = packageBoxes.isEmpty
        ? [
            {
              'pieces': int.tryParse(piecesController.text) ?? 1,
              'length': 0,
              'breadth': 0,
              'height': 0,
              'weight': weight,
            },
          ]
        : packageBoxes
              .map(
                (box) => {
                  'pieces': 1,
                  'length': double.tryParse(box.lengthController.text) ?? 0,
                  'breadth': double.tryParse(box.breadthController.text) ?? 0,
                  'height': double.tryParse(box.heightController.text) ?? 0,
                  'weight': weight,
                },
              )
              .toList();
    final ratesPayload = <String, dynamic>{
      'service_id': 4,
      'package_type_id': 1,
      'weight': weight,
      'pickup_pincode': pickupPincode.trim(),
      'delivery_pincode': dropPincode.trim(),
      'payment_type': 'prepaid',
      'drop_lat': dropLatitude ?? 0,
      'pickup_lat': pickupLatitude ?? 0,
      'pickup_lng': pickupLongitude ?? 0,
      'drop_lng': dropLongitude ?? 0,
      'rate_type': 'forward',
    };
    final orderPayload = <String, dynamic>{
      'order_type': 'domestic',
      'service_id': 4,
      'sub_service_id': 5,
      'pickup_date': DateTime.now().toIso8601String().split('T').first,
      'payment_method': 'ONLINE',
      'price': 0,
      'package_type_id': 1,
      'pieces': int.tryParse(piecesController.text) ?? 1,
      'dead_weight': weight,
      'volumetric_weight': volumetricWeight,
      'chargeable_weight': weight > volumetricWeight ? weight : volumetricWeight,
      'hsn_code': '8517',
      'boxes': boxes,
      'pickup': {
        'name': pickupNameController.text.trim(),
        'mobile': pickupPhoneController.text.trim(),
        'address': pickupAddress,
        'house_no': '',
        'city': pickupCity,
        'state': pickupState,
        'pincode': pickupPincode,
        'lat': pickupLatitude ?? 0,
        'lng': pickupLongitude ?? 0,
        'country': 'India',
      },
      'drop': {
        'name': receiverNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'address': dropAddress,
        'house_no': '',
        'city': dropCity,
        'state': dropState,
        'pincode': dropPincode,
        'lat': dropLatitude ?? 0,
        'lng': dropLongitude ?? 0,
        'country': 'India',
      },
    };
    final provider = context.read<NationalProvider>();
    final rates = await provider.loadRates(payload: ratesPayload);
    if (!mounted) return;
    if (rates == null || rates.rates.isEmpty) {
      _showMessage(provider.errorMessage ?? 'No courier rates available');
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('national_rates_response', jsonEncode(rates.raw));
    await preferences.setString(
      'national_rates_payload',
      jsonEncode(ratesPayload),
    );
    await preferences.setString(
      'national_order_payload',
      jsonEncode(orderPayload),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Shipment'),
        content: SingleChildScrollView(
          child: Text(
            'Package type: $selectedPackageType\n'
            'Package size: $selectedPackageSize\n'
            'Pieces: ${piecesController.text}\n'
            'Weight: ${weight.toStringAsFixed(2)} kg\n'
            'Service: $selectedService\n\n'
            'Pickup details\n'
            'Name: ${pickupNameController.text.trim()}\n'
            'Phone: ${pickupPhoneController.text.trim()}\n'
            'Address: $pickupAddress\n'
            'City: $pickupCity\n'
            'State: $pickupState\n'
            'Pincode: $pickupPincode\n\n'
            'Drop details\n'
            'Name: ${receiverNameController.text.trim()}\n'
            'Phone: ${mobileController.text.trim()}\n'
            'Address: $dropAddress\n'
            'City: $dropCity\n'
            'State: $dropState\n'
            'Pincode: $dropPincode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseCourier(
          approximateWeightKg: approximateWeight,
          volumetricWeightKg: volumetricWeight,
          origin: pickupCity.isEmpty ? 'Pickup' : pickupCity,
          destination: dropCity.isEmpty ? 'Drop' : dropCity,
          rates: rates,
          orderPayload: orderPayload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4FA),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Receiver Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _locationCard(),
            const SizedBox(height: 14),

            _label('DELIVERY ADDRESS'),
            _textField(controller: addressController, hintText: 'Full address'),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('APPROX. WEIGHT (KG)'),
                      _textField(
                        controller: approximateWeightController,
                        hintText: 'e.g. 2.5',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('CITY'),
                      _textField(controller: cityController, hintText: 'City'),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('PICKUP PIN'),
                      _textField(
                        controller: pickupPinController,
                        hintText: 'Pickup PIN',
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DROP PIN'),
                      _textField(
                        controller: pinController,
                        hintText: 'PIN',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Select Your Package',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _packageTypeCard(
                    title: 'Document',
                    icon: Icons.mail_outline,
                    packageType: 'Document',
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _packageTypeCard(
                    title: 'Non-document',
                    icon: Icons.inventory_2_outlined,
                    packageType: 'Non-document',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Select Package Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                _packageSizeChip('0 - 500g'),
                _packageSizeChip('500g - 1kg'),
                _packageSizeChip('Greater than 1kg'),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Enter Package Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const SizedBox(
                  width: 190,
                  child: Text(
                    'Number of Total Pieces :',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _textField(
                    controller: piecesController,
                    hintText: '1',
                    keyboardType: TextInputType.number,
                    onChanged: _onPiecesChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 190,
                  child: Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Text(
                      'Approximate Weight (KG) :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textField(
                        controller: approximateWeightController,
                        hintText: 'e.g., 2.5',
                        keyboardType: TextInputType.number,
                      ),
                      if (selectedPackageSize != 'Greater than 1kg')
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            '💡 Weight set to ${approximateWeightController.text}kg for this size',
                            style: const TextStyle(
                              color: Color(0xFF536078),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (selectedPackageType == 'Non-document') ...[
              const SizedBox(height: 16),
              _packageBoxesWidget(),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton(
                onPressed: _reviewAndConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC400),
                  foregroundColor: const Color(0xFF101B8F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Review & Confirm →',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Saved Location Dialog ====================

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
