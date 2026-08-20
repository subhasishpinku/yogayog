import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class TermPrivacyService {
  TermPrivacyService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<TermsPrivacyDocument> getTermsAndConditions() async {
    try {
      final response = await _dio.get(ApiEndpoints.termsAndConditions);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['value'] is! Map) {
        throw TermPrivacyException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load terms and privacy'
              : 'Invalid response from the server',
        );
      }
      return TermsPrivacyDocument.fromJson(
        Map<String, dynamic>.from(data['value'] as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw TermPrivacyException(data['message'].toString());
      }
      throw TermPrivacyException(
        error.message ?? 'Network error while loading terms and privacy',
      );
    }
  }
}

class TermsPrivacyDocument {
  const TermsPrivacyDocument({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final List<TermsPrivacySection> sections;

  factory TermsPrivacyDocument.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    return TermsPrivacyDocument(
      title: json['title']?.toString() ?? 'Terms & Privacy',
      lastUpdated: json['last_updated']?.toString() ?? '',
      sections: rawSections is List
          ? rawSections
                .whereType<Map>()
                .map(
                  (item) => TermsPrivacySection.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class TermsPrivacySection {
  const TermsPrivacySection({required this.title, required this.content});

  final String title;
  final List<TermsPrivacyContent> content;

  factory TermsPrivacySection.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    return TermsPrivacySection(
      title: json['title']?.toString() ?? '',
      content: rawContent is List
          ? rawContent
                .whereType<Map>()
                .map(
                  (item) => TermsPrivacyContent.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class TermsPrivacyContent {
  const TermsPrivacyContent({required this.type, required this.text});

  final String type;
  final String text;

  factory TermsPrivacyContent.fromJson(Map<String, dynamic> json) {
    return TermsPrivacyContent(
      type: json['type']?.toString() ?? 'paragraph',
      text: json['text']?.toString() ?? '',
    );
  }
}

class TermPrivacyException implements Exception {
  const TermPrivacyException(this.message);

  final String message;

  @override
  String toString() => message;
}
