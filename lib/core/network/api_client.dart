import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final CookieJar cookieJar = CookieJar();

  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  static Future<void> loadToken() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      setToken(token);
    }
  }

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: "https://courier.yogayog.net/api/",
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        )
        ..interceptors.add(CookieManager(cookieJar))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              print("Request: ${options.method} ${options.path}");
              print("Data: ${options.data}");
              return handler.next(options);
            },
            onResponse: (response, handler) {
              print("Response: ${response.statusCode} ${response.data}");
              return handler.next(response);
            },
            onError: (DioException e, handler) {
              print("Error: ${e.message}");
              print("Error Response: ${e.response?.data}");
              return handler.next(e);
            },
          ),
        );
}
