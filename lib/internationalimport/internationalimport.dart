import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yogayog/internationalimport/internationalimport_delivery_address.dart';
import 'package:yogayog/internationalimport/internationalimport_package.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/bikescreen/provider/bikescreen_provider.dart';
import 'package:yogayog/choosecourier/choose_courier_intranational_import.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/national_service_import.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';
import 'package:yogayog/internationalimport/provider/international_import_provider.dart';

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
    this.houseNumber = '',
    this.country = '',
    this.latitude,
    this.longitude,
  });
  final String address;
  final String city;
  final String pincode;
  final String state;
  final String houseNumber;
  final String country;
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
    this.initialHouseNumber = '',
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
  final String initialHouseNumber;
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
  late final TextEditingController _houseNumberController;
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
    _houseNumberController = TextEditingController(
      text: widget.initialHouseNumber,
    );
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
    _houseNumberController.dispose();
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
            _field(_houseNumberController, 'House No.'),
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
            _GeoLocation(
              address: _addressController.text.trim(),
              city: _cityController.text.trim(),
              pincode: _pincodeController.text.trim(),
              state: _stateController.text.trim(),
              houseNumber: _houseNumberController.text.trim(),
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

class InternationalImport extends StatefulWidget {
  const InternationalImport({super.key});

  @override
  State<InternationalImport> createState() => _InternationalImportState();
}

class _InternationalImportState extends State<InternationalImport> {
  static const placesKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo',
  );

  String selectedPackageType = 'Document';
  String selectedPackageSize = '0 - 500g';
  String selectedService = 'Express';

  final pickupNameController = TextEditingController();
  final pickupMobileController = TextEditingController();
  final dropNameController = TextEditingController();
  final dropMobileController = TextEditingController();
  final addressController = TextEditingController();
  final pickupHouseNumberController = TextEditingController();
  final dropHouseNumberController = TextEditingController();
  final countryController = TextEditingController(text: '');
  final cityController = TextEditingController();
  final pickupPinController = TextEditingController();
  final pinController = TextEditingController();
  final piecesController = TextEditingController(text: '1');
  final approximateWeightController = TextEditingController(text: '0.5');

  final List<PackageBox> packageBoxes = [];

  String pickupAddress = 'Tap to add destination';
  String pickupCity = '';
  String pickupPincode = '';
  String pickupState = '';
  String pickupHouseNumber = '';
  double? pickupLatitude;
  double? pickupLongitude;

  String dropAddress = 'Tap to add destination';
  String dropCity = '';
  String dropPincode = '';
  String dropState = '';
  String dropHouseNumber = '';
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
      if (dropNameController.text.trim().isEmpty) {
        dropNameController.text =
            preferences.getString(HomeService.profileNameKey) ?? '';
      }
      if (dropMobileController.text.trim().isEmpty) {
        dropMobileController.text =
            preferences.getString(HomeService.profileMobileKey) ?? '';
      }
    });
  }

  @override
  void dispose() {
    pickupNameController.dispose();
    pickupMobileController.dispose();
    dropNameController.dispose();
    dropMobileController.dispose();
    addressController.dispose();
    pickupHouseNumberController.dispose();
    dropHouseNumberController.dispose();
    countryController.dispose();
    cityController.dispose();
    pickupPinController.dispose();
    pinController.dispose();
    piecesController.dispose();
    approximateWeightController.dispose();
    for (final box in packageBoxes) {
      box.dispose();
    }
    super.dispose();
  }

  // ==================== Google Places API ====================

  Future<List<_PlaceSuggestion>> _searchPlaces(
    String query, {
    bool excludeIndia = false,
  }) async {
    if (query.trim().length < 2 || placesKey.isEmpty) return [];
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {'input': query.trim(), 'key': placesKey},
    );
    final data = response.data;
    if (data is! Map ||
        data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('Places search failed');
    }
    final predictions = data['predictions'];
    if (predictions is! List) return [];
    return predictions
        .whereType<Map>()
        .map(
          (item) => _PlaceSuggestion(
            placeId: item['place_id']?.toString() ?? '',
            description: item['description']?.toString() ?? '',
          ),
        )
        .where(
          (suggestion) =>
              !excludeIndia ||
              !suggestion.description.toLowerCase().contains('india'),
        )
        .toList();
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
      country: component('country'),
      latitude: location is Map ? coordinate(location['lat']) : null,
      longitude: location is Map ? coordinate(location['lng']) : null,
    );
  }

  // ==================== Pickup Location ====================

  bool _hasPickupContact() {
    final hasName = pickupNameController.text.trim().isNotEmpty;
    final hasMobile = pickupMobileController.text.trim().isNotEmpty;
    if (hasName && hasMobile) return true;
    _showMessage('Please enter pickup name and pickup number first');
    return false;
  }

  Future<void> _openPickupSearch() async {
    if (!_hasPickupContact()) return;
    if (placesKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return;
    }
    final selected = await showDialog<_GeoLocation>(
      context: context,
      builder: (_) => _PlaceSearchDialog(
        title: 'Choose Pickup Location',
        searchPlaces: (query) => _searchPlaces(query, excludeIndia: true),
        getPlaceDetails: _getPlaceDetails,
      ),
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
      pickupHouseNumber = selected.houseNumber;
      pickupHouseNumberController.text = pickupHouseNumber;
      addressController.text = selected.address;
      cityController.text = selected.city;
      countryController.text = _countryFromPickupAddress(
        selected.address,
        fallback: selected.country,
      );
    });
    await _savePickupLocation(
      address: selected.address,
      city: selected.city,
      pincode: selected.pincode,
      state: selected.state,
      latitude: selected.latitude,
      longitude: selected.longitude,
      houseNumber: selected.houseNumber,
    );
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
        dropLatitude = position.latitude;
        dropLongitude = position.longitude;
        dropAddress = [
          place?.street,
          place?.subLocality,
          place?.locality,
        ].where((value) => value?.trim().isNotEmpty == true).join(', ');
        dropCity = place?.locality ?? place?.subAdministrativeArea ?? '';
        dropPincode = place?.postalCode ?? '';
        pinController.text = dropPincode;
        dropState = place?.administrativeArea ?? '';
        if (dropAddress.isEmpty) dropAddress = 'Current location';
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => dropAddress = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _editPickup() async {
    if (!_hasPickupContact()) return;
    final result = await showDialog<_GeoLocation>(
      context: context,
      builder: (_) => _PickupEditDialog(
        initialAddress: pickupAddress == 'Tap to add destination'
            ? ''
            : pickupAddress,
        initialCity: pickupCity,
        initialPincode: pickupPincode,
        initialState: pickupState,
        initialHouseNumber: pickupHouseNumber,
        initialLatitude: pickupLatitude,
        initialLongitude: pickupLongitude,
        searchPlaces: (query) => _searchPlaces(query, excludeIndia: true),
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
      pickupHouseNumber = result.houseNumber;
      pickupHouseNumberController.text = pickupHouseNumber;
      pickupLatitude = result.latitude;
      pickupLongitude = result.longitude;
      addressController.text = result.address;
      cityController.text = result.city;
      countryController.text = _countryFromPickupAddress(
        result.address,
        fallback: result.country,
      );
    });
    await _savePickupLocation(
      address: result.address,
      city: result.city,
      pincode: result.pincode,
      state: result.state,
      latitude: result.latitude,
      longitude: result.longitude,
      houseNumber: result.houseNumber,
    );
  }

  Future<void> _openSavedLocations() async {
    if (!_hasPickupContact()) return;
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 8);
    if (!mounted) return;
    if (provider.errorMessage != null && provider.locations.isEmpty) {
      _showMessage(provider.errorMessage!);
      return;
    }
    final foreignLocations = provider.locations
        .where(_isOutsideIndiaLocation)
        .toList();
    if (foreignLocations.isEmpty) {
      _showMessage('No saved pickup locations found outside India');
      return;
    }
    final selected = await showDialog<SavedLocation>(
      context: context,
      builder: (_) => _SavedLocationDialog(
        title: 'Select International Pickup Location',
        locations: foreignLocations,
      ),
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
      addressController.text = selected.address;
      cityController.text = selected.city;
      countryController.text = _countryFromPickupAddress(
        selected.address,
        fallback: selected.country,
      );
    });
    await _savePickupLocation(
      address: selected.address,
      city: selected.city,
      pincode: selected.pincode,
      state: selected.state,
      latitude: selected.latitude,
      longitude: selected.longitude,
      country: selected.country.isEmpty
          ? _countryFromPickupAddress(selected.address)
          : selected.country,
    );
  }

  bool _isOutsideIndiaLocation(SavedLocation location) {
    final country = location.country.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );
    if (country == 'india' || country == 'in' || country == 'ind') {
      return false;
    }
    final locationText = '${location.city} ${location.address}'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '');
    return !locationText.contains('india');
  }

  Future<void> _openSavedDropLocations() async {
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 7);
    if (!mounted) return;
    if (provider.errorMessage != null && provider.locations.isEmpty) {
      _showMessage(provider.errorMessage!);
      return;
    }
    final indiaLocations = provider.locations.where(_isIndianLocation).toList();
    if (indiaLocations.isEmpty) {
      _showMessage('No saved drop locations found in India');
      return;
    }
    final selected = await showDialog<SavedLocation>(
      context: context,
      builder: (_) => _SavedLocationDialog(locations: indiaLocations),
    );
    if (selected == null || !mounted) return;
    setState(() {
      dropAddress = selected.address;
      dropCity = selected.city;
      dropPincode = selected.pincode;
      dropState = selected.state;
      dropLatitude = selected.latitude;
      dropLongitude = selected.longitude;
      dropHouseNumber = selected.houseNumber;
      dropHouseNumberController.text = dropHouseNumber;
      dropNameController.text = selected.name;
      dropMobileController.text = selected.mobile;
      addressController.text = dropAddress;
      cityController.text = dropCity;
      pinController.text = dropPincode;
    });
    await _saveDropLocation(
      address: selected.address,
      city: selected.city,
      pincode: selected.pincode,
      state: selected.state,
      latitude: selected.latitude,
      longitude: selected.longitude,
      houseNumber: selected.houseNumber,
    );
  }

  // ==================== Drop Location ====================

  Future<void> _editDrop() async {
    if (dropAddress == 'Tap to add destination') {
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
      await _saveDropLocation(
        address: selected.address,
        city: selected.city,
        pincode: selected.pincode,
        state: selected.state,
        latitude: selected.latitude,
        longitude: selected.longitude,
      );
      return;
    }

    final result = await showDialog<_GeoLocation>(
      context: context,
      builder: (_) => _PickupEditDialog(
        title: 'Edit Drop Location',
        initialAddress: dropAddress == 'Tap to add destination'
            ? ''
            : dropAddress,
        initialCity: dropCity,
        initialPincode: dropPincode,
        initialState: dropState,
        initialHouseNumber: dropHouseNumber,
        initialLatitude: dropLatitude,
        initialLongitude: dropLongitude,
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      dropAddress = result.address;
      dropCity = result.city;
      dropPincode = result.pincode;
      dropState = result.state;
      dropHouseNumber = result.houseNumber;
      dropHouseNumberController.text = dropHouseNumber;
      dropLatitude = result.latitude;
      dropLongitude = result.longitude;
      addressController.text = dropAddress;
      cityController.text = dropCity;
      pinController.text = dropPincode;
    });
    await _saveDropLocation(
      address: result.address,
      city: result.city,
      pincode: result.pincode,
      state: result.state,
      latitude: result.latitude,
      longitude: result.longitude,
      houseNumber: result.houseNumber,
    );
  }

  // ==================== Helper Methods ====================

  bool _isIndianLocation(SavedLocation location) {
    final country = location.country.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );
    final locationText =
        '${location.state} ${location.city} ${location.address}'
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z]'), '');
    const indianStateTokens = <String>{
      'andhrapradesh',
      'arunachalpradesh',
      'assam',
      'bihar',
      'chhattisgarh',
      'goa',
      'gujarat',
      'haryana',
      'himachalpradesh',
      'jharkhand',
      'karnataka',
      'kerala',
      'madhyapradesh',
      'maharashtra',
      'manipur',
      'meghalaya',
      'mizoram',
      'nagaland',
      'odisha',
      'punjab',
      'rajasthan',
      'sikkim',
      'tamilnadu',
      'telangana',
      'tripura',
      'uttarpradesh',
      'uttarakhand',
      'westbengal',
      'andamannicobarislands',
      'chandigarh',
      'dadraandnagarhavelianddamananddiu',
      'delhi',
      'jammuandkashmir',
      'ladakh',
      'lakshadweep',
      'puducherry',
    };
    const foreignCountryTokens = <String>{
      'unitedkingdom',
      'uk',
      'england',
      'london',
      'unitedstates',
      'usa',
      'canada',
      'australia',
      'newzealand',
      'france',
      'germany',
      'italy',
      'spain',
      'singapore',
      'malaysia',
      'uae',
      'dubai',
      'qatar',
      'saudiarabia',
      'japan',
      'china',
      'bangladesh',
      'nepal',
      'bhutan',
      'srilanka',
      'pakistan',
    };
    if (foreignCountryTokens.any((token) => locationText.contains(token))) {
      return false;
    }
    return country == 'india' ||
        country == 'in' ||
        country == 'ind' ||
        locationText.contains('india') ||
        indianStateTokens.any((token) => locationText.contains(token));
  }

  String _countryFromPickupAddress(String address, {String fallback = ''}) {
    final parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length > 1) {
      final last = parts.last;
      if (!RegExp(r'^\d{4,6}$').hasMatch(last)) return last;
    }
    return fallback.trim();
  }

  Future<void> _savePickupLocation({
    required String address,
    required String city,
    required String pincode,
    required String state,
    required double? latitude,
    required double? longitude,
    String country = 'India',
    String houseNumber = '',
  }) async {
    if (houseNumber.trim().isEmpty) {
      _showMessage('Please enter pickup housing no. first');
      return;
    }
    final provider = context.read<BikescreenProvider>();
    final saved = await provider.savePickupLocation(
      payload: {
        'name': pickupNameController.text.trim(),
        'mobile': pickupMobileController.text.trim(),
        'service_id': 8,
        'house_numb': houseNumber,
        'street': address,
        'city': city,
        'district': city,
        'state': state,
        'pin': pincode,
        'country': country,
        'country_cde': country.toLowerCase() == 'india' ? 'IN' : '',
        'lat': latitude ?? 0,
        'lon': longitude ?? 0,
        'flag': 'pick',
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Pickup location saved successfully'
          : provider.errorMessage ?? 'Unable to save pickup location',
    );
  }

  Future<void> _saveDropLocation({
    required String address,
    required String city,
    required String pincode,
    required String state,
    required double? latitude,
    required double? longitude,
    String houseNumber = '',
  }) async {
    if (houseNumber.trim().isEmpty) {
      _showMessage('Please enter drop housing no. first');
      return;
    }
    final provider = context.read<BikescreenProvider>();
    final saved = await provider.savePickupLocation(
      payload: {
        'name': dropNameController.text.trim(),
        'mobile': dropMobileController.text.trim(),
        'service_id': 8,
        'house_numb': houseNumber,
        'street': address,
        'city': city,
        'district': city,
        'state': state,
        'pin': pincode,
        'country': 'India',
        'country_cde': 'IN',
        'lat': latitude ?? 0,
        'lon': longitude ?? 0,
        'flag': 'drop',
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Drop location saved successfully'
          : provider.errorMessage ?? 'Unable to save drop location',
    );
  }

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
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
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

  Future<void> _openImportAddress() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => InternationalImportDeliveryAddress(
          values: {
            'address': addressController.text,
            'pickupHouse': pickupHouseNumberController.text,
            'dropHouse': dropHouseNumberController.text,
            'weight': approximateWeightController.text,
            'country': countryController.text,
            'city': cityController.text,
            'pickupPin': pickupPinController.text,
            'dropPin': pinController.text,
          },
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      addressController.text = result['address'] ?? addressController.text;
      pickupHouseNumberController.text =
          result['pickupHouse'] ?? pickupHouseNumberController.text;
      dropHouseNumberController.text =
          result['dropHouse'] ?? dropHouseNumberController.text;
      approximateWeightController.text =
          result['weight'] ?? approximateWeightController.text;
      countryController.text = result['country'] ?? countryController.text;
      cityController.text = result['city'] ?? cityController.text;
      pickupPinController.text =
          result['pickupPin'] ?? pickupPinController.text;
      pinController.text = result['dropPin'] ?? pinController.text;
      pickupHouseNumber = pickupHouseNumberController.text;
      dropHouseNumber = dropHouseNumberController.text;
    });
  }

  Future<void> _openImportPackage() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => InternationalImportPackage(
          values: {
            'packageType': selectedPackageType,
            'packageSize': selectedPackageSize,
            'pieces': piecesController.text,
            'weight': approximateWeightController.text,
            'boxes': packageBoxes
                .map(
                  (box) => {
                    'length': box.lengthController.text,
                    'breadth': box.breadthController.text,
                    'height': box.heightController.text,
                  },
                )
                .toList(),
          },
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      selectedPackageType =
          result['packageType']?.toString() ?? selectedPackageType;
      selectedPackageSize =
          result['packageSize']?.toString() ?? selectedPackageSize;
      piecesController.text =
          result['pieces']?.toString() ?? piecesController.text;
      approximateWeightController.text =
          result['weight']?.toString() ?? approximateWeightController.text;
      for (final box in packageBoxes) {
        box.dispose();
      }
      packageBoxes.clear();
      final savedBoxes = result['boxes'];
      if (savedBoxes is List) {
        for (final item in savedBoxes.whereType<Map>()) {
          final box = PackageBox();
          box.lengthController.text = item['length']?.toString() ?? '';
          box.breadthController.text = item['breadth']?.toString() ?? '';
          box.heightController.text = item['height']?.toString() ?? '';
          packageBoxes.add(box);
        }
      }
      if (selectedPackageType == 'Non-document') {
        _syncPackageBoxes(int.tryParse(piecesController.text) ?? 1);
      }
    });
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
          // InkWell(
          //   onTap: _openSavedLocations,
          //   borderRadius: BorderRadius.circular(12),
          //   child: Container(
          //     height: 49,
          //     padding: const EdgeInsets.symmetric(horizontal: 14),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFF8F8FC),
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: const Color(0xFFE1E1E6)),
          //     ),
          //     child: const Row(
          //       children: [
          //         Icon(Icons.search, color: Color(0xFF667085), size: 23),
          //         SizedBox(width: 12),
          //         Expanded(
          //           child: Text(
          //             'Search saved pickup location',
          //             style: TextStyle(color: Color(0xFF667085), fontSize: 14),
          //           ),
          //         ),
          //         Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 27),
            child: _locationContactFields(pickup: true),
          ),
          const SizedBox(height: 8),
          _locationRow(
            'PICKUP',
            pickupAddress,
            pickupCity,
            pickupPincode,
            true,
            _openPickupSearch,
            editOnTap: _editPickup,
            showContactFields: false,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Divider(height: 5),
          ),
          // InkWell(
          //   onTap: _openSavedDropLocations,
          //   borderRadius: BorderRadius.circular(12),
          //   child: Container(
          //     height: 49,
          //     padding: const EdgeInsets.symmetric(horizontal: 14),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFF8F8FC),
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: const Color(0xFFE1E1E6)),
          //     ),
          //     child: const Row(
          //       children: [
          //         Icon(Icons.search, color: Color(0xFF667085), size: 23),
          //         SizedBox(width: 12),
          //         Expanded(
          //           child: Text(
          //             'Search saved drop location',
          //             style: TextStyle(color: Color(0xFF667085), fontSize: 14),
          //           ),
          //         ),
          //         Icon(Icons.keyboard_arrow_down, color: Color(0xFF667085)),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 27),
            child: _locationContactFields(pickup: false),
          ),
          const SizedBox(height: 8),
          _locationRow(
            'DROP',
            dropAddress,
            dropCity,
            dropPincode,
            false,
            _editDrop,
            showContactFields: false,
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
    VoidCallback onTap, {
    VoidCallback? editOnTap,
    bool showContactFields = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
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
                        fontWeight: pickup
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: pickup ? Colors.black : const Color(0xFF8A8F9C),
                      ),
                    ),
                    if (city.isNotEmpty)
                      Text(
                        city,
                        style: const TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 13,
                        ),
                      ),
                    if (pincode.isNotEmpty)
                      Text(
                        'PIN: $pincode',
                        style: const TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: editOnTap ?? onTap,
                child: Text(
                  'Edit',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                onPressed: pickup
                    ? _openSavedLocations
                    : _openSavedDropLocations,
                child: const Text(
                  'Save',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showContactFields) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 27),
            child: _locationContactFields(pickup: pickup),
          ),
        ],
      ],
    );
  }

  Widget _locationContactFields({required bool pickup}) {
    final nameController = pickup ? pickupNameController : dropNameController;
    final mobileController = pickup
        ? pickupMobileController
        : dropMobileController;

    return Row(
      children: [
        Expanded(
          child: _textField(
            controller: nameController,
            hintText: pickup ? 'Pickup name' : 'Drop name',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _textField(
            controller: mobileController,
            hintText: pickup ? 'Pickup number' : 'Drop number',
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
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

  Future<bool> _validateBeforeReview() async {
    if (pickupHouseNumberController.text.trim().isEmpty) {
      _showMessage('Please enter pickup housing no. first');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return false;
      await _openImportAddress();
      return false;
    }
    if (dropHouseNumberController.text.trim().isEmpty) {
      _showMessage('Please enter drop housing no. first');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return false;
      await _openImportAddress();
      return false;
    }
    return true;
  }

  Future<void> _reviewAndConfirm() async {
    if (!await _validateBeforeReview()) return;
    FocusScope.of(context).unfocus();
    final approximateWeight =
        double.tryParse(approximateWeightController.text) ?? 0;
    final volumetricWeight = packageBoxes.fold<double>(
      0,
      (total, box) => total + box.volumetricWeight,
    );
    final weight = approximateWeight > 0 ? approximateWeight : 1.0;
    final preferences = await SharedPreferences.getInstance();
    final paymentMode =
        preferences
            .getString(HomeService.profilePaymentModeKey)
            ?.trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[\s_-]'), '') ??
        '';
    final isPrepaid = paymentMode == 'prepaid';
    final paymentModeLabel = isPrepaid ? 'Pre-Paid' : 'Post-Paid';
    final ratesPayload = <String, dynamic>{
      'service_id': 7,
      'sub_service_id': 8,
      'type': 'import',
      'package_type_id': 1,
      'weight': weight,
      'pickup_pincode': pickupPincode.trim(),
      'delivery_pincode': pinController.text.trim(),
      'pickup_lat': pickupLatitude ?? 0,
      'pickup_lng': pickupLongitude ?? 0,
      'drop_lat': dropLatitude ?? 0,
      'drop_lng': dropLongitude ?? 0,
      'country': countryController.text.trim(),
      'destination': 'India',
      'payment_type': isPrepaid ? 'prepaid' : 'postpaid',
      'payment_mode': paymentModeLabel,
      'rate_type': 'forward',
    };
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
    final orderPayload = <String, dynamic>{
      'order_type': 'domestic',
      'service_id': 7,
      'sub_service_id': 8,
      'pickup_date': DateTime.now().toIso8601String().split('T').first,
      'payment_method': 'ONLINE',
      'payment_mode': paymentModeLabel,
      'price': 0,
      'package_type_id': 1,
      'pieces': int.tryParse(piecesController.text) ?? 1,
      'dead_weight': weight,
      'volumetric_weight': volumetricWeight,
      'chargeable_weight': weight > volumetricWeight
          ? weight
          : volumetricWeight,
      'hsn_code': '',
      'boxes': boxes,
      'pickup': {
        'name': pickupNameController.text.trim(),
        'mobile': pickupMobileController.text.trim(),
        'address': pickupAddress,
        'house_no': pickupHouseNumber,
        'city': pickupCity,
        'state': pickupState,
        'pincode': pickupPincode,
        'lat': pickupLatitude ?? 0,
        'lng': pickupLongitude ?? 0,
        'country': 'India',
      },
      'drop': {
        'name': dropNameController.text.trim(),
        'mobile': dropMobileController.text.trim(),
        'address': dropAddress,
        'house_no': dropHouseNumber,
        'city': dropCity,
        'state': dropState,
        'pincode': pinController.text.trim(),
        'lat': dropLatitude ?? 0,
        'lng': dropLongitude ?? 0,
        'country': countryController.text.trim(),
      },
    };
    final provider = context.read<InternationalImportProvider>();
    NationalRateResponse? rates;
    if (isPrepaid) {
      rates = await provider.loadRates(payload: ratesPayload);
    }
    if (!mounted) return;
    if (isPrepaid && (rates == null || rates.rates.isEmpty)) {
      _showMessage(provider.errorMessage ?? 'No courier rates available');
      return;
    }
    final rateSummary =
        rates?.rates
            .map(
              (rate) =>
                  '${rate.carrierName}: Rs ${rate.price.toStringAsFixed(2)}',
            )
            .join('\n') ??
        '';
    final confirmationText =
        'Type: Import\n'
        'Package: $selectedPackageType\n'
        'Weight: $weight kg\n'
        'Pickup PIN: ${pickupPincode.trim()}\n'
        'Drop PIN: ${pinController.text.trim()}\n'
        'Country: ${ratesPayload['country']}\n'
        'Destination: India\n'
        'Payment: $paymentModeLabel\n\n'
        '${isPrepaid ? 'Available rates\n$rateSummary' : ''}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Shipment'),
        content: SingleChildScrollView(child: Text(confirmationText)),
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
    if (!isPrepaid) {
      final postpaidPayload = Map<String, dynamic>.from(orderPayload)
        ..remove('payment_method')
        ..remove('payment_mode')
        ..remove('price');
      final created = await provider.createPostpaidOrder(
        payload: postpaidPayload,
      );
      if (!mounted) return;
      if (created == null) {
        _showMessage(
          provider.errorMessage ?? 'Unable to create post-paid order',
        );
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()));
      _showMessage('Post-paid order created successfully');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseCourierInternationalImport(
          approximateWeightKg: approximateWeight,
          volumetricWeightKg: volumetricWeight,
          origin: pickupCity.isEmpty ? 'Pickup' : pickupCity,
          destination: countryController.text.trim().isEmpty
              ? 'India'
              : countryController.text.trim(),
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
          'International Import Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            _locationCard(),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openImportAddress,
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Delivery Address'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  foregroundColor: const Color(0xFF17249B),
                  side: const BorderSide(color: Color(0xFF17249B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // ignore: dead_code
            if (false) ...[
              _label('DELIVERY ADDRESS'),
              _textField(
                controller: addressController,
                hintText: 'Full address',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: pickupHouseNumberController,
                      hintText: 'Pickup housing no.',
                      onChanged: (value) => pickupHouseNumber = value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _textField(
                      controller: dropHouseNumberController,
                      hintText: 'Drop housing no.',
                      onChanged: (value) => dropHouseNumber = value,
                    ),
                  ),
                ],
              ),

              _label('APPROX. WEIGHT (KG)'),
              _textField(
                controller: approximateWeightController,
                hintText: 'e.g. 2.5',
                keyboardType: TextInputType.number,
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('PICK COUNTRY'),
                        _textField(
                          controller: countryController,
                          hintText: 'Country',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('PICK CITY'),
                        _textField(
                          controller: cityController,
                          hintText: 'City',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          hintText: 'Drop PIN',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openImportPackage,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Select Your Package'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  foregroundColor: const Color(0xFF17249B),
                  side: const BorderSide(color: Color(0xFF17249B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // ignore: dead_code
            if (false) ...[
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
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
      ),
    );
  }
}

// ==================== Saved Location Dialog ====================

class _SavedLocationDialog extends StatefulWidget {
  const _SavedLocationDialog({
    this.title = 'Select Drop Location',
    required this.locations,
  });
  final String title;
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
      return '${location.name} ${location.mobile} ${location.address} '
              '${location.city} ${location.state} ${location.country} '
              '${location.pincode}'
          .toLowerCase()
          .contains(query);
    }).toList();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search country, state, city or address',
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
                            '${location.country}, ${location.state}, '
                            '${location.city}, ${location.pincode}',
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
