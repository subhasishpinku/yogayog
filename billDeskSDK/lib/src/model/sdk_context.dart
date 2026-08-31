import 'package:get/get_connect/http/src/response/response.dart';

class SdkContext {
  late Scope scope;

  SdkContext({
    required this.scope,
  });
}

class Scope {
  final Map<String, dynamic> mapData = <String, dynamic>{};

  void set(String key, dynamic value) {
    mapData[key] = value;
  }

  dynamic get(String key) {
    return mapData[key];
  }
}

class ScopeData {
  late String key;
  late Response<dynamic> value;

  ScopeData({
    required this.key,
    required this.value,
  });
}
