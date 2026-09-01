import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class PaperworkRequiredService {
  PaperworkRequiredService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<String> verifyPan(String pan) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.verifyPan,
        queryParameters: {'pan': pan},
      );
      final data = response.data;
      final details = data is Map && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : const <String, dynamic>{};
      if (data is! Map || data['success'] != true || details['full_name'] == null) {
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

  Future<void> uploadPan({required XFile image}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.uploadKycDocument,
        data: FormData.fromMap({
          'document_type': 'pan',
          'file': await MultipartFile.fromFile(image.path, filename: image.name),
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

class PaperworkRequiredException implements Exception {
  const PaperworkRequiredException(this.message);
  final String message;
}
