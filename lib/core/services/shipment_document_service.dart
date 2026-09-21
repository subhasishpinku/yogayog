import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class ShipmentDocumentService {
  ShipmentDocumentService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<void> uploadDocument({
    required String orderId,
    required String documentType,
    required XFile file,
  }) async {
    try {
      print(
        'Uploading document: orderId=$orderId, documentType=$documentType, file=${file.path}',
      );
      final response = await _dio.post(
        ApiEndpoints.uploadShipmentDocument,
        data: FormData.fromMap({
          'order_id': orderId,
          'document_type': documentType,
          'file': await MultipartFile.fromFile(file.path, filename: file.name),
        }),
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data;
      if ((response.statusCode ?? 500) >= 400 ||
          (data is Map && data['success'] == false)) {
        throw ShipmentDocumentException(
          data is Map && data['message'] != null
              ? data['message'].toString()
              : 'Unable to upload document',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw ShipmentDocumentException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while uploading document',
      );
    }
  }
}

class ShipmentDocumentException implements Exception {
  const ShipmentDocumentException(this.message);

  final String message;
}
