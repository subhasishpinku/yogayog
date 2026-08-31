import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:billdesk_sdk/sdk.dart';
import 'package:billdesk_sdk/src/error/sdk_exception_handler.dart';
import 'package:billdesk_sdk/src/sdk_service/ssl_pinning_certificate_service.dart';
import 'package:billdesk_sdk/src/utilities/sdk_constant.dart';
import 'package:billdesk_sdk/src/utilities/sdk_logger.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:intl/intl.dart';

class HttpService {
  late dio.Dio _dio;
  static final HttpService _singleton = HttpService._internal();

  factory HttpService() {
    return _singleton;
  }

  HttpService._internal();

  Future<dio.Response<dynamic>?> post({
    String? host,
    required SdkApiConstants routeDetails,
    Map<String, dynamic>? queryParams,
    required Map<String, String> reqHeaders,
    required Map<String, dynamic> body,
    required SdkConfig config,
  }) async {
    SdkLogger.d("Excecuting ${routeDetails.value} Api");

    String baseUrl = BuildConfig.pgUrl;
    String endPoint = routeDetails.route;

    final options = dio.BaseOptions(
        followRedirects: false,
        headers: appendHeaders(reqHeaders),
        validateStatus: (status) {
          return status != null;
        });
    _dio = dio.Dio(options);

    if (config.isUATEnv == true) {
      baseUrl =
        config.shouldUseOldUat ? BuildConfig.pgUrlAlt : BuildConfig.pgUrl;
      endPoint = config.shouldUseOldUat ? endPoint : "/u2$endPoint";
    }

    final List<String> allowedFingerprints =
      await CertificateService.getFingerprintsForEnv(baseUrl);

    _dio.options.baseUrl = baseUrl;

    _dio.interceptors.add(
      CertificatePinningInterceptor(
          allowedSHAFingerprints: allowedFingerprints),
    );

    final uri = Uri.parse(baseUrl);

    Uri finalUri = Uri(
      scheme: uri.scheme,
      host: host ?? uri.host,
      path: endPoint,
    );

    if (queryParams != null && queryParams.isNotEmpty) {
      finalUri = appendQueryParams(finalUri, queryParams);
    }

    try {
      final response = await _dio.post<dynamic>(
        finalUri.toString(),
        data: body,
        options: dio.Options(headers: reqHeaders),
      );

      SdkLogger.i(response.toString());

      if (response.statusCode == 200) {
        return response;
      } else {
        _throwException(response);
      }
    } on SocketException {
      throw FetchedDataException('No Internet Exception', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException('Api not responding', uri.toString());
    } on dio.DioException catch (e) {
      if (e.response != null) {
        _throwException(e.response!);
      }
      rethrow;
    }

    throw FetchedDataException('Unable to Process', uri.toString());
  }

  Map<String, String> appendHeaders(Map<String, String> reqHeaders) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'BD-Timestamp': getDBTimeStamp(),
      'BD-TraceId': getBDTraceId()
    };

    headers.addAll(reqHeaders);

    return headers;
  }

  Uri appendQueryParams(Uri baseUrl, Map<String, dynamic> queryParams) {
    final Uri uri = baseUrl;
    final Map<String, dynamic> combinedParams = Map.from(uri.queryParametersAll)
      ..addAll(queryParams);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      queryParameters: combinedParams,
    );
  }

  String getBDTraceId() {
    final Random random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(
            5, (index) => availableChars[random.nextInt(availableChars.length)])
        .join();

    return getDBTimeStamp() + randomString;
  }

  String getDBTimeStamp() {
    final DateTime now = DateTime.now();
    final String time = DateFormat('yyyyMMddHHmmss').format(now);
    return time;
  }

  dynamic _throwException(dio.Response<dynamic> response) {
    final String message = response.data?.toString() ?? 'Unable to Process';
    final String requestPath =
        response.requestOptions.baseUrl + response.requestOptions.path;

    switch (response.statusCode) {
      case 200:
        return response;
      case 400:
        throw BadRequestException(message, requestPath);
      case 401:
      case 403:
        throw UnAuthorizedException(message, requestPath);
      case 500:
      default:
        throw FetchedDataException(message, requestPath);
    }
  }
}
