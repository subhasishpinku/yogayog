import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/bikescreen/choose_bike_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:yogayog/bikescreen/provider/bikescreen_provider.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/truckscreen/choose_truck_screen.dart';
import 'package:yogayog/truckscreen/provider/truck_local_provider.dart';

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

String _houseNumberFromAddress(String address) {
  final firstPart = address.split(',').first.trim();
  final match = RegExp(
    r'^(?:house\s*no\.?|h\.?\s*no\.?|flat|plot|#)?\s*([A-Za-z]?\d+[A-Za-z]?(?:[-/]\w+)?)',
    caseSensitive: false,
  ).firstMatch(firstPart);
  return match?.group(1) ?? '';
}

class _LocationDetails {
  const _LocationDetails({
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.houseNumber,
    required this.name,
    required this.mobile,
  });

  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
  final String houseNumber;
  final String name;
  final String mobile;
}

class _LocationDetailsSheet extends StatefulWidget {
  const _LocationDetailsSheet({
    required this.title,
    required this.initialAddress,
    required this.initialCity,
    required this.initialPincode,
    required this.initialState,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialHouseNumber,
    required this.initialName,
    required this.initialMobile,
    required this.searchPlaces,
    required this.getPlaceDetails,
    required this.getPincodeDetails,
    required this.openAddressSearch,
  });

  final String title;
  final String initialAddress;
  final String initialCity;
  final String initialPincode;
  final String initialState;
  final double? initialLatitude;
  final double? initialLongitude;
  final String initialHouseNumber;
  final String initialName;
  final String initialMobile;
  final Future<List<_PlaceSuggestion>> Function(String) searchPlaces;
  final Future<_DropLocation> Function(String) getPlaceDetails;
  final Future<_DropLocation?> Function(String) getPincodeDetails;
  final Future<_DropLocation?> Function() openAddressSearch;

  @override
  State<_LocationDetailsSheet> createState() => _LocationDetailsSheetState();
}

class _LocationDetailsSheetState extends State<_LocationDetailsSheet> {
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _stateController;
  late final TextEditingController _houseController;
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
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
    _houseController = TextEditingController(text: widget.initialHouseNumber);
    _nameController = TextEditingController(text: widget.initialName);
    _mobileController = TextEditingController(text: widget.initialMobile);
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _houseController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
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
        _houseController.text = _houseNumberFromAddress(location.address);
        _cityController.text = location.city;
        _pincodeController.text = location.pincode;
        _stateController.text = location.state;
        _latitude = location.latitude;
        _longitude = location.longitude;
        _suggestions = [];
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openAddressSearch() async {
    final location = await widget.openAddressSearch();
    if (!mounted || location == null) return;
    setState(() {
      _addressController.text = location.address;
      _houseController.text = _houseNumberFromAddress(location.address);
      _cityController.text = location.city;
      _pincodeController.text = location.pincode;
      _stateController.text = location.state;
      _latitude = location.latitude;
      _longitude = location.longitude;
      _suggestions = [];
      _error = null;
    });
  }

  Future<void> _lookupPincode(String value) async {
    final pincode = value.trim();
    if (pincode.length != 6) return;
    final location = await widget.getPincodeDetails(pincode);
    if (!mounted ||
        location == null ||
        _pincodeController.text.trim() != pincode) {
      return;
    }
    final isWestBengal =
        location.state.toLowerCase().contains('west bengal') ||
        location.address.toLowerCase().contains('west bengal');
    if (!isWestBengal) {
      setState(() => _error = 'Please enter a West Bengal PIN');
      return;
    }
    setState(() {
      _addressController.text = location.address;
      _houseController.text = _houseNumberFromAddress(location.address);
      _cityController.text = location.city;
      _stateController.text = location.state;
      _latitude = location.latitude;
      _longitude = location.longitude;
      _error = null;
    });
  }

  InputDecoration _decoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      decoration: _decoration(hint),
    );
  }

  void _confirm() {
    // if (_addressController.text.trim().isEmpty ||
    //     _pincodeController.text.trim().length != 6 ||
    //     _nameController.text.trim().isEmpty ||
    //     _mobileController.text.trim().length != 10) {
    //   setState(
    //     () => _error = 'Please enter address, valid PIN, name and phone',
    //   );
    //   return;
    // }
    Navigator.pop(
      context,
      _LocationDetails(
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        state: _stateController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        houseNumber: _houseController.text.trim().isNotEmpty
            ? _houseController.text.trim()
            : _houseNumberFromAddress(_addressController.text.trim()),
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 34,
                  height: 4,
                  color: const Color(0xFFD9DDE5),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _field(
                _addressController,
                'Full address',
                onChanged: _searchAddress,
                readOnly: true,
                onTap: _openAddressSearch,
              ),
              if (_suggestions.isNotEmpty)
                ..._suggestions
                    .take(4)
                    .map(
                      (suggestion) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(suggestion.description),
                        onTap: () => _selectAddress(suggestion),
                      ),
                    ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _pincodeController,
                      'Pickup PIN',
                      keyboardType: TextInputType.number,
                      onChanged: _lookupPincode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_houseController, 'House no.')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _field(_cityController, 'City')),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_stateController, 'State')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _field(_nameController, 'Name')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _field(
                      _mobileController,
                      'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 7),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                height: 43,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    '${widget.title} & Continue →',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    required this.getPincodeDetails,
    this.houseNumberController,
    this.phoneController,
    this.nameController,
  });

  final String title;
  final String initialAddress;
  final String initialCity;
  final String initialPincode;
  final String initialState;
  final double? initialLatitude;
  final double? initialLongitude;
  final Future<List<_PlaceSuggestion>> Function(String) searchPlaces;
  final Future<_DropLocation> Function(String) getPlaceDetails;
  final Future<_DropLocation?> Function(String) getPincodeDetails;
  final TextEditingController? houseNumberController;
  final TextEditingController? phoneController;
  final TextEditingController? nameController;

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
  late final TextEditingController _houseController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
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
    _houseController =
        widget.houseNumberController ??
        TextEditingController(
          text: _houseNumberFromAddress(widget.initialAddress),
        );
    _phoneController = widget.phoneController ?? TextEditingController();
    _nameController = widget.nameController ?? TextEditingController();
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
    if (widget.houseNumberController == null) _houseController.dispose();
    if (widget.phoneController == null) _phoneController.dispose();
    if (widget.nameController == null) _nameController.dispose();
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
        _houseController.text = _houseNumberFromAddress(location.address);
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

  Future<void> _lookupPincode(String value) async {
    final pincode = value.trim();
    if (pincode.length != 6) return;
    final location = await widget.getPincodeDetails(pincode);
    if (!mounted ||
        location == null ||
        _pincodeController.text.trim() != pincode)
      return;
    final isWestBengal =
        location.state.toLowerCase().contains('west bengal') ||
        location.address.toLowerCase().contains('west bengal');
    if (!isWestBengal) {
      setState(() {
        _pincodeController.clear();
        _addressController.clear();
        _cityController.clear();
        _stateController.clear();
        _latitude = null;
        _longitude = null;
        _error = 'Please enter a West Bengal PIN';
      });
      return;
    }
    setState(() {
      _addressController.text = location.address;
      _houseController.text = _houseNumberFromAddress(location.address);
      _cityController.text = location.city;
      _stateController.text = location.state;
      _latitude = location.latitude;
      _longitude = location.longitude;
      _error = null;
    });
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
            if (widget.houseNumberController != null) ...[
              _field(_houseController, 'House No'),
              _field(_phoneController, 'Phone', type: TextInputType.phone),
              _field(_nameController, 'Name'),
            ],
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
              'Pincode',
              type: TextInputType.number,
              onChanged: _lookupPincode,
            ),
            _field(_stateController, 'State'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            const _PickupLocation(
              address: '',
              city: '',
              pincode: '',
              state: '',
              latitude: null,
              longitude: null,
              clear: true,
            ),
          ),
          child: const Text('Clear'),
        ),
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
    this.clear = false,
  });

  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
  final bool clear;
}

class _TruckLocalScreenState extends State<TruckLocalScreen> {
  final packageController = TextEditingController();
  final weightController = TextEditingController(text: '20');
  final approximateWeightController = TextEditingController(text: '0.5');
  final pickupPincodeController = TextEditingController();
  final pickupHouseNumberController = TextEditingController();
  final dropHouseNumberController = TextEditingController();
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
  String? _pickupPincodeError;
  String _pickupState = '';
  double? _pickupLatitude;
  double? _pickupLongitude;
  String _dropAddress = 'Tap to add destination';
  String _dropCity = '';
  String _dropPincode = '';
  String? _dropPincodeError;
  String _dropState = '';
  double? _dropLatitude;
  double? _dropLongitude;
  gmaps.GoogleMapController? _routeMapController;
  bool _isLoadingRates = false;

  static const _googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo',
  );

  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
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
    packageController.dispose();
    weightController.dispose();
    approximateWeightController.dispose();
    pickupPincodeController.dispose();
    pickupHouseNumberController.dispose();
    dropHouseNumberController.dispose();
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
        'location': '22.5726,88.3639',
        'radius': 300000,
        'strictbounds': 'true',
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
              .where((item) {
                final description = item['description']?.toString() ?? '';
                final normalized = description.toLowerCase();
                return normalized.contains('west bengal') ||
                    normalized.contains('kolkata');
              })
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

  Future<_DropLocation?> _getGoogleLocationFromPincode(String pincode) async {
    if (_googlePlacesApiKey.isEmpty) return null;
    final response = await Dio().get(
      'https://maps.googleapis.com/maps/api/geocode/json',
      queryParameters: {
        'address': '$pincode, India',
        'components': 'country:IN|postal_code:$pincode',
        'key': _googlePlacesApiKey,
      },
    );
    final data = response.data;
    final results = data is Map ? data['results'] : null;
    if (data is! Map ||
        data['status'] != 'OK' ||
        results is! List ||
        results.isEmpty) {
      return null;
    }
    final result = Map<String, dynamic>.from(results.first as Map);
    String component(String type) {
      final components = result['address_components'];
      if (components is! List) return '';
      for (final item in components.whereType<Map>()) {
        if (item['types'] is List && item['types'].contains(type)) {
          return item['long_name']?.toString() ?? '';
        }
      }
      return '';
    }

    final geometry = result['geometry'];
    final location = geometry is Map ? geometry['location'] : null;
    double? coordinate(Object? value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    return _DropLocation(
      address: result['formatted_address']?.toString() ?? '$pincode, India',
      city: component('locality').isNotEmpty
          ? component('locality')
          : component('administrative_area_level_2'),
      pincode: component('postal_code').isEmpty
          ? pincode
          : component('postal_code'),
      state: component('administrative_area_level_1'),
      latitude: location is Map ? coordinate(location['lat']) : null,
      longitude: location is Map ? coordinate(location['lng']) : null,
    );
  }

  Future<void> _updateAddressFromPincode({
    required bool pickup,
    required String pincode,
  }) async {
    if (pincode.length != 6) return;
    final location = await _getGoogleLocationFromPincode(pincode);
    if (!mounted || location == null) {
      if (mounted) {
        setState(() {
          if (pickup) {
            pickupPincodeController.clear();
            _pickupPincode = '';
            _pickupPincodeError = 'Enter a valid West Bengal PIN';
          } else {
            pincodeController.clear();
            _dropPincode = '';
            _dropPincodeError = 'Enter a valid West Bengal PIN';
          }
        });
      }
      return;
    }
    final current = pickup
        ? pickupPincodeController.text
        : pincodeController.text;
    if (current != pincode) return;
    final isWestBengal =
        location.state.toLowerCase().contains('west bengal') ||
        location.address.toLowerCase().contains('west bengal');
    if (!isWestBengal) {
      setState(() {
        if (pickup) {
          pickupPincodeController.clear();
          _pickupPincode = '';
          _pickupPincodeError = 'PIN must be within West Bengal';
          _pickupAddress = 'Tap to add pickup location';
          _pickupCity = '';
          _pickupState = '';
          _pickupLatitude = null;
          _pickupLongitude = null;
        } else {
          pincodeController.clear();
          _dropPincode = '';
          _dropPincodeError = 'PIN must be within West Bengal';
          _dropAddress = 'Tap to add destination';
          _dropCity = '';
          _dropState = '';
          _dropLatitude = null;
          _dropLongitude = null;
        }
      });
      _showMessage('Pickup and drop locations must be within West Bengal');
      return;
    }
    setState(() {
      if (pickup) {
        _pickupPincodeError = null;
        _pickupAddress = location.address;
        _pickupCity = location.city;
        _pickupState = location.state;
        _pickupPincode = pincode;
        _pickupLatitude = location.latitude;
        _pickupLongitude = location.longitude;
        pickupHouseNumberController.text = _houseNumberFromAddress(
          location.address,
        );
      } else {
        _dropPincodeError = null;
        _dropAddress = location.address;
        _dropCity = location.city;
        _dropState = location.state;
        _dropPincode = pincode;
        _dropLatitude = location.latitude;
        _dropLongitude = location.longitude;
      }
    });
  }

  Future<_DropLocation?> _openDropSearchDialog({
    bool validateContact = true,
  }) async {
    if (validateContact && !_validateDropContact()) return null;
    if (_googlePlacesApiKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return null;
    }
    final selected = await showDialog<_DropLocation>(
      context: context,
      builder: (_) => _PlaceSearchDialog(
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (selected == null || !mounted) return selected;
    setState(() {
      _dropAddress = selected.address;
      dropHouseNumberController.text = _houseNumberFromAddress(
        selected.address,
      );
      _dropCity = selected.city;
      _dropPincode = selected.pincode;
      pincodeController.text = selected.pincode;
      _dropState = selected.state;
      _dropLatitude = selected.latitude;
      _dropLongitude = selected.longitude;
    });
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: _dropLocationPayload(selected),
    );
    if (!mounted) return selected;
    // _showMessage(
    //   saved
    //       ? 'Drop address saved successfully'
    //       : context.read<BikescreenProvider>().errorMessage ??
    //             'Unable to save drop address',
    // );
    return selected;
  }

  Future<void> _openLocationDetails({required bool pickup}) async {
    final result = await showModalBottomSheet<_LocationDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationDetailsSheet(
        title: pickup ? 'Pickup details' : 'Drop details',
        initialAddress: pickup
            ? _pickupAddress
            : _dropAddress == 'Tap to add destination'
            ? ''
            : _dropAddress,
        initialCity: pickup ? _pickupCity : _dropCity,
        initialPincode: pickup ? _pickupPincode : _dropPincode,
        initialState: pickup ? _pickupState : _dropState,
        initialLatitude: pickup ? _pickupLatitude : _dropLatitude,
        initialLongitude: pickup ? _pickupLongitude : _dropLongitude,
        initialHouseNumber: pickup
            ? pickupHouseNumberController.text
            : dropHouseNumberController.text,
        initialName: pickup
            ? pickupNameController.text
            : dropNameController.text,
        initialMobile: pickup
            ? pickupPhoneController.text
            : dropPhoneController.text,
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
        getPincodeDetails: _getGoogleLocationFromPincode,
        openAddressSearch: pickup
            ? _openPickupSearchDialog
            : () => _openDropSearchDialog(validateContact: false),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (pickup) {
        _pickupAddress = result.address;
        _pickupCity = result.city;
        _pickupPincode = result.pincode;
        pickupPincodeController.text = result.pincode;
        _pickupState = result.state;
        _pickupLatitude = result.latitude;
        _pickupLongitude = result.longitude;
        pickupHouseNumberController.text = result.houseNumber.isNotEmpty
            ? result.houseNumber
            : _houseNumberFromAddress(result.address);
        pickupNameController.text = result.name;
        pickupPhoneController.text = result.mobile;
      } else {
        _dropAddress = result.address;
        _dropCity = result.city;
        _dropPincode = result.pincode;
        pincodeController.text = result.pincode;
        _dropState = result.state;
        _dropLatitude = result.latitude;
        _dropLongitude = result.longitude;
        dropHouseNumberController.text = result.houseNumber.isNotEmpty
            ? result.houseNumber
            : _houseNumberFromAddress(result.address);
        dropNameController.text = result.name;
        dropPhoneController.text = result.mobile;
      }
    });
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: {
        'name': result.name,
        'mobile': result.mobile,
        'service_id': 1,
        'house_numb': result.houseNumber.isNotEmpty
            ? result.houseNumber
            : _houseNumberFromAddress(result.address),
        'street': result.address,
        'city': result.city,
        'district': result.city,
        'state': result.state,
        'pin': result.pincode,
        'country': 'India',
        'country_cde': 'IN',
        'flag': pickup ? 'pick' : 'drop',
        'lat': result.latitude,
        'lon': result.longitude,
      },
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? '${pickup ? 'Pickup' : 'Drop'} address saved successfully'
          : context.read<BikescreenProvider>().errorMessage ??
                'Unable to save address',
    );
  }

  Future<void> _openPickupDetailsBottomSheet() async {
    await _openLocationDetails(pickup: true);
  }

  Future<void> _openDropDetailsBottomSheet() async {
    await _openLocationDetails(pickup: false);
  }

  Future<_DropLocation?> _openPickupSearchDialog() async {
    if (_googlePlacesApiKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return null;
    }
    final selected = await showDialog<_DropLocation>(
      context: context,
      builder: (_) => _PlaceSearchDialog(
        title: 'Choose Pickup Location',
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
      ),
    );
    if (selected == null || !mounted) return selected;
    setState(() {
      _pickupAddress = selected.address;
      pickupHouseNumberController.text = _houseNumberFromAddress(
        selected.address,
      );
      _pickupCity = selected.city;
      _pickupPincode = selected.pincode;
      pickupPincodeController.text = selected.pincode;
      _pickupState = selected.state;
      _pickupLatitude = selected.latitude;
      _pickupLongitude = selected.longitude;
    });
    return selected;
  }

  Future<void> _editDrop() async {
    if (!_validateDropContact()) return;
    // if (pincodeController.text.trim().length != 6) {
    //   _showMessage('Please enter drop PIN first');
    //   return;
    // }
    if (_googlePlacesApiKey.isEmpty) {
      _showMessage('Google Places API key is not configured');
      return;
    }
    final result = await showDialog<_PickupLocation>(
      context: context,
      builder: (_) => _PickupEditDialog(
        title: 'Edit Drop Location',
        initialAddress: _dropAddress,
        initialCity: _dropCity,
        initialPincode: _dropPincode,
        initialState: _dropState,
        initialLatitude: _dropLatitude,
        initialLongitude: _dropLongitude,
        searchPlaces: _searchPlaces,
        getPlaceDetails: _getPlaceDetails,
        getPincodeDetails: _getGoogleLocationFromPincode,
        houseNumberController: dropHouseNumberController,
        phoneController: dropPhoneController,
        nameController: dropNameController,
      ),
    );
    if (result == null || !mounted) return;
    if (result.clear) {
      setState(() {
        _dropAddress = 'Tap to add destination';
        _dropCity = '';
        _dropPincode = '';
        pincodeController.clear();
        _dropState = '';
        _dropLatitude = null;
        _dropLongitude = null;
      });
      return;
    }
    final selected = _DropLocation(
      address: result.address,
      city: result.city,
      pincode: result.pincode,
      state: result.state,
      latitude: result.latitude,
      longitude: result.longitude,
    );
    setState(() {
      _dropAddress = result.address;
      _dropCity = result.city;
      _dropPincode = result.pincode;
      pincodeController.text = result.pincode;
      _dropState = result.state;
      _dropLatitude = result.latitude;
      _dropLongitude = result.longitude;
    });
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: _dropLocationPayload(selected),
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Drop location saved successfully'
          : context.read<BikescreenProvider>().errorMessage ??
                'Unable to save drop location',
    );
  }

  Map<String, dynamic> _dropLocationPayload(_DropLocation location) {
    return {
      'name': dropNameController.text.trim(),
      'mobile': dropPhoneController.text.trim(),
      'service_id': 1,
      'house_numb': dropHouseNumberController.text.trim(),
      'street': location.address,
      'city': location.city,
      'district': location.city,
      'state': location.state,
      'pin': location.pincode,
      'country': 'India',
      'country_cde': 'IN',
      'lat': location.latitude,
      'lon': location.longitude,
      'flag': 'drop',
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateDropContact() {
    final name = dropNameController.text.trim();
    final phone = dropPhoneController.text.trim();
    // if (name.isEmpty) {
    //   _showMessage('Please enter drop name first');
    //   return false;
    // }
    // if (phone.length != 10) {
    //   _showMessage('Please enter a valid 10-digit drop phone number first');
    //   return false;
    // }
    return true;
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
      builder: (_) => _SavedLocationDialog(
        title: 'Select Pickup Location',
        locations: provider.locations,
      ),
    );
    if (selected == null || !mounted) return;
    final houseNumber = selected.houseNumber.trim().isNotEmpty
        ? selected.houseNumber.trim()
        : _houseNumberFromAddress(selected.address);
    setState(() {
      pickupNameController.text = selected.name;
      pickupPhoneController.text = selected.mobile;
      _pickupAddress = selected.address;
      pickupHouseNumberController.text = houseNumber;
      _pickupCity = selected.city;
      _pickupPincode = selected.pincode;
      pickupPincodeController.text = selected.pincode;
      _pickupState = selected.state;
      _pickupLatitude = selected.latitude;
      _pickupLongitude = selected.longitude;
    });
  }

  Future<void> _openSavedDropLocations() async {
    if (!_validateDropContact()) return;
    final provider = context.read<BikescreenProvider>();
    await provider.loadLocations(serviceId: 1);
    if (!mounted) return;
    if (provider.errorMessage != null && provider.locations.isEmpty) {
      _showMessage(provider.errorMessage!);
      return;
    }
    final selected = await showDialog<SavedLocation>(
      context: context,
      builder: (_) => _SavedLocationDialog(
        title: 'Select Drop Location',
        locations: provider.locations,
      ),
    );
    if (selected == null || !mounted) return;
    final houseNumber = selected.houseNumber.trim().isNotEmpty
        ? selected.houseNumber.trim()
        : _houseNumberFromAddress(selected.address);
    setState(() {
      dropNameController.text = selected.name;
      dropPhoneController.text = selected.mobile;
      _dropAddress = selected.address;
      dropHouseNumberController.text = houseNumber;
      _dropCity = selected.city;
      _dropPincode = selected.pincode;
      pincodeController.text = selected.pincode;
      _dropState = selected.state;
      _dropLatitude = selected.latitude;
      _dropLongitude = selected.longitude;
    });
    await _chooseVehicle();
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
        pickupHouseNumberController.text = _houseNumberFromAddress(
          _pickupAddress,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _pickupAddress = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _pickLocationFromMap({required bool pickup}) async {
    const initial = gmaps.LatLng(22.5726, 88.3639);
    final selected = await showDialog<gmaps.LatLng>(
      context: context,
      builder: (dialogContext) {
        gmaps.LatLng? marker = initial;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              pickup ? 'Choose Pickup Location' : 'Choose Drop Location',
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: gmaps.GoogleMap(
                initialCameraPosition: const gmaps.CameraPosition(
                  target: initial,
                  zoom: 15,
                ),
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                markers: marker == null
                    ? {}
                    : {
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('selected_location'),
                          position: marker!,
                          draggable: true,
                          onDragEnd: (value) =>
                              setDialogState(() => marker = value),
                        ),
                      },
                onTap: (value) {
                  setDialogState(() => marker = value);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: marker == null
                    ? null
                    : () {
                        Navigator.pop(dialogContext, marker);
                      },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;

    try {
      final places = await placemarkFromCoordinates(
        selected.latitude,
        selected.longitude,
      );
      if (!mounted) return;
      final place = places.isNotEmpty ? places.first : null;
      final fullAddress = [
        place?.name,
        place?.street,
        place?.subLocality,
        place?.locality,
      ].where((value) => value?.trim().isNotEmpty == true).join(', ');
      final address = fullAddress.isEmpty
          ? 'Selected map location'
          : fullAddress;
      final pincode = place?.postalCode ?? '';
      setState(() {
        if (pickup) {
          _pickupAddress = address;
          _pickupCity = place?.locality ?? place?.subAdministrativeArea ?? '';
          _pickupState = place?.administrativeArea ?? '';
          _pickupPincode = pincode;
          pickupPincodeController.text = pincode;
          pickupHouseNumberController.text = _houseNumberFromAddress(address);
          _pickupLatitude = selected.latitude;
          _pickupLongitude = selected.longitude;
        } else {
          _dropAddress = address;
          _dropCity = place?.locality ?? place?.subAdministrativeArea ?? '';
          _dropState = place?.administrativeArea ?? '';
          _dropPincode = pincode;
          pincodeController.text = pincode;
          dropHouseNumberController.text = _houseNumberFromAddress(address);
          _dropLatitude = selected.latitude;
          _dropLongitude = selected.longitude;
        }
      });
    } catch (_) {
      _showMessage('Unable to read address from selected map location');
    }
  }

  Future<void> _editPickup() async {
    if (pickupPincodeController.text.trim().length != 6) {
      _showMessage('Please enter pickup PIN first');
      return;
    }
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
        getPincodeDetails: _getGoogleLocationFromPincode,
        houseNumberController: pickupHouseNumberController,
        phoneController: pickupPhoneController,
        nameController: pickupNameController,
      ),
    );
    if (result == null || !mounted) return;
    if (result.clear) {
      setState(() {
        _pickupAddress = '';
        _pickupCity = '';
        _pickupPincode = '';
        pickupPincodeController.clear();
        _pickupState = '';
        _pickupLatitude = null;
        _pickupLongitude = null;
      });
      return;
    }
    setState(() {
      _pickupAddress = result.address;
      _pickupCity = result.city;
      _pickupPincode = result.pincode;
      pickupPincodeController.text = result.pincode;
      _pickupState = result.state;
      _pickupLatitude = result.latitude;
      _pickupLongitude = result.longitude;
    });
    final saved = await context.read<BikescreenProvider>().savePickupLocation(
      payload: {
        'name': pickupNameController.text.trim(),
        'mobile': pickupPhoneController.text.trim(),
        'service_id': 1,
        'house_numb': pickupHouseNumberController.text.trim(),
        'street': result.address,
        'city': result.city,
        'district': result.city,
        'state': result.state,
        'pin': result.pincode,
        'country': 'India',
        'country_cde': 'IN',
        "flag": "pick",
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

  Future<void> _chooseVehicle() async {
    if (_isLoadingRates) return;
    // if (pickupHouseNumberController.text.trim().isEmpty) {
    //   _showMessage('Please enter pickup house number');
    //   return;
    // }
    // if (dropHouseNumberController.text.trim().isEmpty) {
    //   _showMessage('Please enter drop house number');
    //   return;
    // }
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
    // if (pickupNameController.text.trim().isEmpty ||
    //     pickupPhoneController.text.trim().length != 10 ||
    //     dropNameController.text.trim().isEmpty ||
    //     dropPhoneController.text.trim().length != 10) {
    //   _showMessage(
    //     'Please enter pickup and drop name with valid 10-digit phone number',
    //   );
    //   return;
    // }
    if (!_isWithinWestBengalServiceArea(_pickupLatitude, _pickupLongitude) ||
        !_isWithinWestBengalServiceArea(_dropLatitude, _dropLongitude)) {
      _showMessage(
        'Pickup and drop locations must be within 300 km of Kolkata',
      );
      return;
    }
    final pickupDropDistance = Geolocator.distanceBetween(
      _pickupLatitude!,
      _pickupLongitude!,
      _dropLatitude!,
      _dropLongitude!,
    );
    if (pickupDropDistance > 300000) {
      _showMessage('Pickup and drop distance must be within 300 km');
      return;
    }
    final weight = double.tryParse(weightController.text.trim());
    if (weight == null || weight <= 0) {
      _showMessage('Please enter a valid weight');
      return;
    }
    if (_pickupPincode.trim().isEmpty || _dropPincode.trim().isEmpty) {
      _showMessage('Please select valid pickup and drop pincodes');
      return;
    }
    final provider = context.read<TruckLocalProvider>();
    final pincodeResults = await Future.wait([
      provider.checkPincode(pincode: _pickupPincode.trim()),
      provider.checkPincode(pincode: _dropPincode.trim()),
    ]);
    // if (!mounted) return;
    // if (pincodeResults.any((result) => result == null)) {
    //   _showMessage(
    //     provider.errorMessage ?? 'Unable to check pincode serviceability',
    //   );
    //   return;
    // }
    // final hasAvailableServiceMessage = pincodeResults.any(
    //   (result) => result!.message.toLowerCase().contains(
    //     'service is available for this pincode',
    //   ),
    // );
    // if (hasAvailableServiceMessage) {
    //   _showMessage('Truck service is not available for this pincode');
    //   return;
    // }
    setState(() => _isLoadingRates = true);
    final rates = await provider.loadRates(
      payload: {
        'service_id': 1,
        'sub_service_id': 3,
        'package_type_id': 1,
        'weight': weight,
        'pickup_lat': _pickupLatitude,
        'pickup_lng': _pickupLongitude,
        'drop_lat': _dropLatitude,
        'drop_lng': _dropLongitude,
        'pickup_pincode': _pickupPincode.trim(),
        'delivery_pincode': _dropPincode.trim(),
      },
    );
    if (!mounted) return;
    setState(() => _isLoadingRates = false);
    if (rates == null || rates.rates.isEmpty) {
      _showMessage(
        context.read<TruckLocalProvider>().errorMessage ??
            'No truck rate found',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseTruckScreen(
          rateResponse: rates,
          approximateWeightKg: weight,
          volumetricWeightKg: 0,
          pickupAddress: _pickupAddress,
          dropAddress: _dropAddress,
          pickup: {
            'name': pickupNameController.text.trim(),
            'mobile': pickupPhoneController.text.trim(),
            'address': _pickupAddress,
            'house_no': pickupHouseNumberController.text.trim(),
            'city': _pickupCity,
            'state': _pickupState,
            'pincode': _pickupPincode,
            'lat': _pickupLatitude,
            'lng': _pickupLongitude,
            'country': 'India',
          },
          drop: {
            'name': dropNameController.text.trim(),
            'mobile': dropPhoneController.text.trim(),
            'address': _dropAddress,
            'house_no': dropHouseNumberController.text.trim(),
            'city': _dropCity,
            'state': _dropState,
            'pincode': _dropPincode,
            'lat': _dropLatitude,
            'lng': _dropLongitude,
            'country': 'India',
          },
          onDropDetailsRequired: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openDropDetailsBottomSheet();
            });
          },
        ),
      ),
    );
  }

  bool _isWithinWestBengalServiceArea(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    const kolkataLatitude = 22.5726;
    const kolkataLongitude = 88.3639;
    return Geolocator.distanceBetween(
          kolkataLatitude,
          kolkataLongitude,
          latitude,
          longitude,
        ) <=
        300000;
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
                    const SizedBox(height: 14),

                    _buildLocationCard(),

                    const SizedBox(height: 22),
                    if (_pickupAddress.trim().isNotEmpty &&
                        _dropAddress.trim().isNotEmpty &&
                        _dropAddress != 'Tap to add destination' &&
                        _pickupLatitude != null &&
                        _pickupLongitude != null &&
                        _dropLatitude != null &&
                        _dropLongitude != null)
                      _buildRouteMap(),

                    // const Text(
                    //   'Select Your Package',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),

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
                    // const SizedBox(height: 16),

                    // const Text(
                    //   'PIN CODE',
                    //   style: TextStyle(
                    //     color: Color(0xFF667085),
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w600,
                    //     letterSpacing: .6,
                    //   ),
                    // ),
                    // const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoadingRates ? null : _chooseVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoadingRates
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Choose Vehicle →',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
      height: 110,
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
                  'Truck Delivery',
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
            const SizedBox(height: 6),
            // _buildSteps(),
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
            color: active ? yellow : Colors.white24,
            border: Border.all(
              color: active ? const Color(0xFFD6A900) : Colors.white54,
              width: 1.5,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? blue : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: active ? yellow : Colors.white70,
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
        color: Colors.white54,
      ),
    );
  }

  Future<void> _updateRouteMarkerFromDrag({
    required bool pickup,
    required gmaps.LatLng location,
  }) async {
    final previous = pickup
        ? gmaps.LatLng(_pickupLatitude!, _pickupLongitude!)
        : gmaps.LatLng(_dropLatitude!, _dropLongitude!);
    if (!mounted) return;
    setState(() {
      if (pickup) {
        _pickupLatitude = location.latitude;
        _pickupLongitude = location.longitude;
      } else {
        _dropLatitude = location.latitude;
        _dropLongitude = location.longitude;
      }
    });

    try {
      final places = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      final place = places.isNotEmpty ? places.first : null;
      final state = place?.administrativeArea ?? '';
      if (!state.toLowerCase().contains('west bengal')) {
        if (mounted) {
          setState(() {
            if (pickup) {
              _pickupLatitude = previous.latitude;
              _pickupLongitude = previous.longitude;
            } else {
              _dropLatitude = previous.latitude;
              _dropLongitude = previous.longitude;
            }
          });
          _showMessage(
            pickup
                ? 'Pickup marker must stay within West Bengal'
                : 'Drop marker must stay within West Bengal',
          );
        }
        return;
      }

      final fullAddress = [
        place?.name,
        place?.street,
        place?.subLocality,
        place?.locality,
      ].where((value) => value?.trim().isNotEmpty == true).join(', ');
      final address = fullAddress.isEmpty
          ? 'Selected map location'
          : fullAddress;
      final pincode = place?.postalCode ?? '';
      if (!mounted) return;
      setState(() {
        if (pickup) {
          _pickupAddress = address;
          _pickupCity = place?.locality ?? place?.subAdministrativeArea ?? '';
          _pickupPincode = pincode;
          pickupPincodeController.text = pincode;
          _pickupState = state;
          pickupHouseNumberController.text = _houseNumberFromAddress(address);
        } else {
          _dropAddress = address;
          _dropCity = place?.locality ?? place?.subAdministrativeArea ?? '';
          _dropPincode = pincode;
          pincodeController.text = pincode;
          _dropState = state;
          dropHouseNumberController.text = _houseNumberFromAddress(address);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (pickup) {
          _pickupLatitude = previous.latitude;
          _pickupLongitude = previous.longitude;
        } else {
          _dropLatitude = previous.latitude;
          _dropLongitude = previous.longitude;
        }
      });
      _showMessage('Unable to read address from dragged map marker');
    }
  }

  List<gmaps.LatLng> _curvedRoutePoints(
    gmaps.LatLng pickup,
    gmaps.LatLng drop,
  ) {
    final deltaLatitude = drop.latitude - pickup.latitude;
    final deltaLongitude = drop.longitude - pickup.longitude;
    final distance = math.sqrt(
      deltaLatitude * deltaLatitude + deltaLongitude * deltaLongitude,
    );
    if (distance == 0) return [pickup, drop];
    final curveOffset = (distance * .35).clamp(.01, .08);
    final control = gmaps.LatLng(
      (pickup.latitude + drop.latitude) / 2 -
          deltaLongitude / distance * curveOffset,
      (pickup.longitude + drop.longitude) / 2 +
          deltaLatitude / distance * curveOffset,
    );

    return List<gmaps.LatLng>.generate(20, (index) {
      final t = index / 19;
      final inverse = 1 - t;
      return gmaps.LatLng(
        inverse * inverse * pickup.latitude +
            2 * inverse * t * control.latitude +
            t * t * drop.latitude,
        inverse * inverse * pickup.longitude +
            2 * inverse * t * control.longitude +
            t * t * drop.longitude,
      );
    });
  }

  Widget _buildRouteMap() {
    const kolkata = gmaps.LatLng(22.5726, 88.3639);
    final pickup = _pickupLatitude != null && _pickupLongitude != null
        ? gmaps.LatLng(_pickupLatitude!, _pickupLongitude!)
        : null;
    final drop = _dropLatitude != null && _dropLongitude != null
        ? gmaps.LatLng(_dropLatitude!, _dropLongitude!)
        : null;
    final points = [if (pickup != null) pickup, if (drop != null) drop];
    final center = points.isEmpty
        ? kolkata
        : gmaps.LatLng(
            points.map((point) => point.latitude).reduce((a, b) => a + b) /
                points.length,
            points.map((point) => point.longitude).reduce((a, b) => a + b) /
                points.length,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              gmaps.GoogleMap(
                onMapCreated: (controller) => _routeMapController = controller,
                initialCameraPosition: gmaps.CameraPosition(
                  target: center,
                  zoom: points.length > 1 ? 11.5 : 12.5,
                ),
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                markers: {
                  if (pickup != null)
                    gmaps.Marker(
                      markerId: const gmaps.MarkerId('pickup_route_marker'),
                      position: pickup,
                      draggable: true,
                      onDragEnd: (location) => _updateRouteMarkerFromDrag(
                        pickup: true,
                        location: location,
                      ),
                      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                        gmaps.BitmapDescriptor.hueYellow,
                      ),
                      infoWindow: const gmaps.InfoWindow(title: 'Pickup'),
                    ),
                  if (drop != null)
                    gmaps.Marker(
                      markerId: const gmaps.MarkerId('drop_route_marker'),
                      position: drop,
                      draggable: true,
                      onDragEnd: (location) => _updateRouteMarkerFromDrag(
                        pickup: false,
                        location: location,
                      ),
                      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
                        gmaps.BitmapDescriptor.hueAzure,
                      ),
                      infoWindow: const gmaps.InfoWindow(title: 'Drop'),
                    ),
                },
                polylines: pickup != null && drop != null
                    ? {
                        gmaps.Polyline(
                          polylineId: const gmaps.PolylineId('pickup_to_drop'),
                          points: _curvedRoutePoints(pickup, drop),
                          color: Colors.black,
                          width: 4,
                        ),
                      }
                    : {},
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  children: [
                    _routeZoomButton(
                      icon: Icons.add,
                      onPressed: () => _routeMapController?.animateCamera(
                        gmaps.CameraUpdate.zoomIn(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _routeZoomButton(
                      icon: Icons.remove,
                      onPressed: () => _routeMapController?.animateCamera(
                        gmaps.CameraUpdate.zoomOut(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Column(
      children: [
        _truckLocationCard(pickup: true),
        const SizedBox(height: 6),
        _truckLocationCard(pickup: false),
      ],
    );
  }

  Widget _truckLocationCard({required bool pickup}) {
    final address = pickup ? _pickupAddress : _dropAddress;
    final city = pickup ? _pickupCity : _dropCity;
    final pincode = pickup ? _pickupPincode : _dropPincode;
    final state = pickup ? _pickupState : _dropState;
    const showInlineLocationFields = false;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _truckLocationHeader(pickup: pickup),
          // ignore: dead_code
          if (showInlineLocationFields) ...[
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _pinCodeField(
                        label: 'Drop PIN',
                        controller: pincodeController,
                        hint: 'Drop PIN',
                        readOnly: false,
                        onChanged: (value) {
                          _dropPincode = value;
                          _dropPincodeError = null;
                          if (value.trim().isEmpty) {
                            setState(() {
                              _dropAddress = 'Tap to add destination';
                              _dropCity = '';
                              _dropState = '';
                              _dropLatitude = null;
                              _dropLongitude = null;
                            });
                          }
                          _updateAddressFromPincode(
                            pickup: false,
                            pincode: value,
                          );
                        },
                      ),
                      if (_dropPincodeError != null)
                        Text(
                          _dropPincodeError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DROP HOUSE NO',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: dropHouseNumberController,
                        decoration: InputDecoration(
                          hintText: 'Drop House No',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E2E8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E2E8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => _pickLocationFromMap(pickup: pickup),
                icon: Icon(
                  Icons.map_outlined,
                  color: pickup ? yellow : Colors.black,
                  size: 22,
                ),
                tooltip: pickup ? 'Choose pickup on map' : 'Choose drop on map',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: pickup
                      ? _openPickupDetailsBottomSheet
                      : _openDropDetailsBottomSheet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup ? 'PICKUP' : 'DROP',
                        style: const TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 11,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: !pickup && address == 'Tap to add destination'
                              ? const Color(0xFF8A8F9C)
                              : Colors.black,
                          fontSize: 14,
                          fontWeight:
                              !pickup && address == 'Tap to add destination'
                              ? FontWeight.normal
                              : FontWeight.bold,
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
                      Text(
                        '${pincode.isNotEmpty ? pincode : 'Pincode unavailable'}, ${state.isNotEmpty ? state : 'State unavailable'}',
                        style: const TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                // onPressed: pickup ? _editPickup : _editDrop,
                onPressed: pickup
                    ? _openPickupDetailsBottomSheet
                    : _openDropDetailsBottomSheet,

                icon: const Icon(Icons.edit, color: blue, size: 16),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _truckLocationHeader({required bool pickup}) {
    final accent = pickup ? const Color(0xFFFFB800) : const Color(0xFF5EA8FF);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: pickup ? const Color(0xFF121214) : const Color(0xFF1E2B43),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: accent,
            child: Text(
              pickup ? 'P' : 'D',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            pickup ? 'PICKUP' : 'DROP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: pickup ? _openSavedLocations : _openSavedDropLocations,
            icon: const Icon(Icons.folder, size: 22),
            label: const Text('SAVED ADDRESS'),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              side: BorderSide(color: accent.withOpacity(.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildLocationCard() {
    return Container(
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
          // _savedLocationSearchBox(),
          // const SizedBox(height: 12),
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
          const SizedBox(height: 3),
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
          const SizedBox(height: 10),
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

              Column(
                children: [
                  TextButton(
                    onPressed: _editPickup,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: TextButton(
                      onPressed: _openSavedLocations,
                      child: const Text(
                        'Save\nAddress',
                        style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 22),

          // _savedDropLocationSearchBox(),
          // const SizedBox(height: 12),
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
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationIndicator(blue),

              const SizedBox(width: 14),

              Expanded(
                child: InkWell(
                  onTap: _openDropSearchDialog,
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

              Column(
                children: [
                  TextButton(
                    onPressed: _editDrop,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: TextButton(
                      onPressed: _openSavedDropLocations,
                      child: const Text(
                        'Save\nAddress',
                        style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  */

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
  const _SavedLocationDialog({
    this.title = 'Select Pickup Location',
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
      return '${location.name} ${location.address} ${location.city} ${location.pincode} ${location.name} ${location.mobile}'
          .toLowerCase()
          .contains(query);
    }).toList();

    return AlertDialog(
      title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.w800)),
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
                filled: true,
                fillColor: Color(0xFFF7F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFE4E7EF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFFE4E7EF)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: locations.isEmpty
                  ? const Center(child: Text('No saved locations found'))
                  : ListView.separated(
                      itemCount: locations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final location = locations[index];
                        final name = location.name.trim().isEmpty
                            ? 'Saved location'
                            : location.name.trim();
                        final initial = name.substring(0, 1).toUpperCase();
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context, location),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFFFD95A),
                                  width: 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x18000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFFF1F3FF),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Color(0xFF172786),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (location.mobile.trim().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              location.mobile,
                                              style: const TextStyle(
                                                color: Color(0xFF172786),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        Text(
                                          location.address,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF8A8F9C),
                                            fontSize: 12,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${location.city}, ${location.pincode}, ${location.state}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF8A8F9C),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 15,
                                      color: Color(0xFF98A0AE),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
