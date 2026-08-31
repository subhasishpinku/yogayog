import 'package:billdesk_sdk/src/error/sdk_error.dart';

class SdkService {
  void getOrder({
    required ServiceCallBack<Map<String, dynamic>, SdkException> serviceCallBack,
  }) {}
  void getTemplateMinorVer(
      {required String majorVersion,
      required ServiceCallBack<dynamic, SdkException> serviceCallBack}) {}
  void getPreferences(
      {required ServiceCallBack<dynamic, SdkException> serviceCallBack}) {}
  void getTemplate(
      {required String majorVersion,
      required ServiceCallBack<dynamic, SdkException> serviceCallBack}) {}
  void getFallback(
      {required String majorVersion,
      required String buildTimestamp,
      required String platform,
      required String deviceId,
      required ServiceCallBack<dynamic, SdkException> serviceCallBack}) {}
}

class ServiceCallBack<T, P> {
  void onSuccess(T response) {}
  void onFailure(P error) {}
}

class ServiceCallBackObject
    implements ServiceCallBack<Map<String, dynamic>, SdkException> {
  @override
  void onFailure(SdkException error) {}

  @override
  void onSuccess(Map<String, dynamic> response) {
    throw UnimplementedError();
  }
}
