import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class ContactPersonsService {
  ContactPersonsService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<ContactPersonsData> getContacts() async {
    try {
      final response = await _dio.get(ApiEndpoints.contacts);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! Map) {
        throw ContactPersonsException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load contacts'
              : 'Invalid response from the server',
        );
      }
      return ContactPersonsData.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ContactPersonsException(data['message'].toString());
      }
      throw ContactPersonsException(
        error.message ?? 'Network error while loading contacts',
      );
    }
  }
}

class ContactPersonsData {
  const ContactPersonsData({
    required this.operations,
    required this.partnerSupport,
    required this.financeCommission,
    required this.internationalDesk,
  });

  final List<ContactPerson> operations;
  final List<ContactPerson> partnerSupport;
  final List<ContactPerson> financeCommission;
  final List<ContactPerson> internationalDesk;

  factory ContactPersonsData.fromJson(Map<String, dynamic> json) {
    List<ContactPerson> parse(String key) {
      final items = json[key];
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map(
            (item) => ContactPerson.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return ContactPersonsData(
      operations: parse('operations'),
      partnerSupport: parse('partner_support'),
      financeCommission: parse('finance_commission'),
      internationalDesk: parse('international_desk'),
    );
  }
}

class ContactPerson {
  const ContactPerson({
    required this.name,
    required this.designation,
    required this.email,
    required this.phone,
  });

  final String name;
  final String designation;
  final String email;
  final String phone;

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class ContactPersonsException implements Exception {
  const ContactPersonsException(this.message);

  final String message;
}
