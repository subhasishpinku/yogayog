import 'package:billdesk_sdk/src/providers/http_service.dart';
import 'package:billdesk_sdk/src/utilities/sdk_constant.dart';
import 'package:dio/dio.dart';
import '../../sdk.dart';
import '../model/sdk_context.dart';

class SdkPresenter {
  SdkContext? sdkContext;
  SdkService? sdkService;

  SdkPresenter({
    this.sdkContext,
    this.sdkService,
  });

  Future<Response<dynamic>?> getOrder(
    String? authToken,
    String? merchantId,
    String? billdeskOrderId,
    SdkConfig config,
  ) async {
    final Map<String, String> headers = {
      'Authorization': authToken ?? '',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'mercid': merchantId,
      'bdorderid': billdeskOrderId,
    };

    return await HttpService().post(
        routeDetails: SdkApiConstants.ORDER_DETAILS,
        reqHeaders: headers,
        body: body,
        config: config);
  }

  Future<Response<dynamic>?> getMandateOrder(
    String? authToken,
    String? mercid,
    String? mandateTokenId,
    SdkConfig config,
  ) async {
    final Map<String, String> headers = {
      'Authorization': authToken ?? '',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'mercid': mercid,
      'mandate_tokenid': mandateTokenId,
    };

    return await HttpService().post(
        routeDetails: SdkApiConstants.MANDATE_DETAILS,
        reqHeaders: headers,
        body: body,
        config: config);
  }

  Future<Response<dynamic>?> getModifyMandateOrder(
    String? authToken,
    String? mercid,
    String? mandateTokenId,
    SdkConfig config,
  ) async {
    final Map<String, String> headers = {
      'Authorization': authToken ?? '',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final Map<String, dynamic> body = {
      'mercid': mercid,
      'mandate_tokenid': mandateTokenId,
    };

    return await HttpService().post(
      routeDetails: SdkApiConstants.MODIFY_MANDATE_DETAILS,
      reqHeaders: headers,
      body: body,
      config: config,
    );
  }
}

