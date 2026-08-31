import 'package:flutter/material.dart';
import 'package:yogayog/internationaldetails/international_details_address.dart';

class InternationalImportDeliveryAddress extends StatefulWidget {
  const InternationalImportDeliveryAddress({super.key, this.values = const {}});
  final Map<String, String> values;

  @override
  State<InternationalImportDeliveryAddress> createState() =>
      _InternationalImportDeliveryAddressState();
}

class _InternationalImportDeliveryAddressState
    extends State<InternationalImportDeliveryAddress> {
  @override
  Widget build(BuildContext context) {
    return InternationalDetailsAddress(
      address: widget.values['address'] ?? '',
      pickupHouse: widget.values['pickupHouse'] ?? '',
      dropHouse: widget.values['dropHouse'] ?? '',
      weight: widget.values['weight'] ?? '0.5',
      country: widget.values['country'] ?? '',
      city: widget.values['city'] ?? '',
      pickupPin: widget.values['pickupPin'] ?? '',
      dropPin: widget.values['dropPin'] ?? '',
    );
  }
}
