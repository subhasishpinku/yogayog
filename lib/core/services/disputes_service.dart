import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class DisputesService {
  DisputesService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<void> sendIssue({
    required int orderId,
    required String issue,
    required String description,
    required List<XFile> photos,
    XFile? video,
  }) async {
    try {
      final fields = <String, dynamic>{
        'order_id': orderId,
        'issue': issue,
        'description': description,
        'photos[]': [
          for (final photo in photos)
            await MultipartFile.fromFile(photo.path, filename: photo.name),
        ],
      };
      if (video != null) {
        fields['video'] = await MultipartFile.fromFile(
          video.path,
          filename: video.name,
        );
      }
      final response = await _dio.post(
        ApiEndpoints.sendIssue,
        data: FormData.fromMap(fields),
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data;
      if (response.statusCode == null || response.statusCode! >= 400 ||
          data is Map && data['success'] == false) {
        throw DisputesException(
          data is Map && data['message'] != null
              ? data['message'].toString()
              : 'Unable to submit claim',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw DisputesException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Unable to submit claim',
      );
    }
  }
}

class DisputesException implements Exception {
  const DisputesException(this.message);
  final String message;
  @override
  String toString() => message;
}
