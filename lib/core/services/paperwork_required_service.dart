import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class PaperworkRequiredService {
  PaperworkRequiredService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<List<KycDocument>> getDocuments() async {
    try {
      final response = await _dio.get(ApiEndpoints.uploadKycDocument);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! List) {
        throw const PaperworkRequiredException('Unable to load KYC documents');
      }
      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => KycDocument.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaperworkRequiredException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while loading KYC documents',
      );
    }
  }

  Future<String> verifyPan(String pan) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyPan,
        data: {'pan': pan},
      );
      final data = response.data;
      final details = data is Map && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : const <String, dynamic>{};
      if (data is! Map ||
          data['success'] != true ||
          details['full_name'] == null) {
        throw PaperworkRequiredException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to verify PAN'
              : 'Invalid PAN verification response',
        );
      }
      return details['full_name'].toString();
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaperworkRequiredException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while verifying PAN',
      );
    }
  }

  Future<void> uploadPan({required String number, required XFile image}) async {
    await uploadDocument(documentType: 'pan', number: number, image: image);
  }

  Future<String> verifyAadhar(String aadhar) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyAadhar,
        data: {'aadhaar': aadhar},
      );
      final data = response.data;
      final details = data is Map && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : const <String, dynamic>{};
      final isVerified =
          data is Map && (data['success'] == true || data['status'] == true);
      if (!isVerified) {
        throw PaperworkRequiredException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to verify Aadhaar'
              : 'Invalid Aadhaar verification response',
        );
      }
      return details['full_name']?.toString() ?? '';
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaperworkRequiredException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while verifying Aadhaar',
      );
    }
  }

  Future<String> verifyVoter(String voterNo) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyVoter,
        data: {'voter_no': voterNo},
      );
      final data = response.data;
      final details = data is Map && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : const <String, dynamic>{};
      if (data is! Map ||
          data['success'] != true ||
          details['full_name'] == null) {
        throw PaperworkRequiredException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to verify Voter ID'
              : 'Invalid Voter ID verification response',
        );
      }
      return details['full_name'].toString();
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaperworkRequiredException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while verifying Voter ID',
      );
    }
  }

  Future<void> uploadDocument({
    required String documentType,
    String number = '',
    required XFile image,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.uploadKycDocument,
        data: FormData.fromMap({
          'document_type': documentType,
          'number': number,
          'file': await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data;
      if (response.statusCode == null ||
          response.statusCode! >= 400 ||
          (data is Map && data['success'] == false)) {
        throw PaperworkRequiredException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to upload PAN image'
              : 'Unable to upload PAN image',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaperworkRequiredException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while uploading PAN image',
      );
    }
  }
}

class KycDocument {
  const KycDocument({
    required this.type,
    required this.label,
    this.number,
    required this.uploaded,
    this.downloadUrl,
  });

  final String type;
  final String label;
  final String? number;
  final bool uploaded;
  final String? downloadUrl;

  factory KycDocument.fromJson(Map<String, dynamic> json) => KycDocument(
    type: json['type']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    number: json['number']?.toString(),
    uploaded: json['uploaded'] == true,
    downloadUrl: json['download_url']?.toString(),
  );
}

class PaperworkRequiredException implements Exception {
  const PaperworkRequiredException(this.message);
  final String message;
}
