import 'package:flutter/material.dart';
import 'package:yogayog/internationaldetails/international_details_package.dart';

class InternationalImportPackage extends StatefulWidget {
  const InternationalImportPackage({super.key, this.values = const {}});
  final Map<String, dynamic> values;

  @override
  State<InternationalImportPackage> createState() => _InternationalImportPackageState();
}

class _InternationalImportPackageState extends State<InternationalImportPackage> {
  @override
  Widget build(BuildContext context) {
    return InternationalDetailsPackage(
      type: widget.values['packageType']?.toString() ?? 'Document',
      size: widget.values['packageSize']?.toString() ?? '0 - 500g',
      pieces: widget.values['pieces']?.toString() ?? '1',
      weight: widget.values['weight']?.toString() ?? '0.5',
      boxes: (widget.values['boxes'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          const [],
    );
  }
}
