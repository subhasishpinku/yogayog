import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/services/disputes_service.dart';
import 'package:yogayog/core/services/home_service.dart';

class DisputesProvider extends ChangeNotifier {
  DisputesProvider({DisputesService? service, HomeService? homeService})
    : _service = service ?? DisputesService(),
      _homeService = homeService ?? HomeService();
  final DisputesService _service;
  final HomeService _homeService;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<TrackOrderData?> trackOrder(String trackingNumber) async {
    final value = trackingNumber.trim();
    if (value.isEmpty) return null;

    _errorMessage = null;
    try {
      return await _homeService.trackOrder(value);
    } on HomeException catch (error) {
      _errorMessage = error.message;
      return null;
    }
  }

  Future<List<DisputeIssue>> getIssues() async {
    _errorMessage = null;
    try {
      final claims = await _service.getIssues();
      return claims.map(DisputeIssue.fromJson).toList();
    } on DisputesException catch (error) {
      _errorMessage = error.message;
      return const [];
    }
  }

  Future<bool> submitIssue({required int orderId, required String issue, required String description, required List<XFile> photos, XFile? video}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.sendIssue(orderId: orderId, issue: issue, description: description, photos: photos, video: video);
      return true;
    } on DisputesException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

class DisputeIssue {
  const DisputeIssue({
    required this.claimId,
    required this.claimType,
    required this.orderId,
    required this.status,
    required this.remarks,
    required this.createdAt,
  });

  factory DisputeIssue.fromJson(Map<String, dynamic> json) {
    return DisputeIssue(
      claimId: json['claim_id']?.toString() ?? '',
      claimType: json['claim_type']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  final String claimId;
  final String claimType;
  final String orderId;
  final String status;
  final String remarks;
  final String createdAt;
}
