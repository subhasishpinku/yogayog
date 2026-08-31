// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'package:billdesk_sdk/src/utilities/sdk_logger.dart';
import 'package:billdesk_sdk/src/model/order_info.dart';
import 'package:billdesk_sdk/src/providers/sdk_presenter.dart';
import 'package:billdesk_sdk/src/model/flow_type.dart';
import 'package:billdesk_sdk/src/error/sdk_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
class SdkWebViewController {
  late SdkConfig sdkConfig;
  late InAppWebViewController inAppWebViewController;
  RxBool shouldModelClose = false.obs;
  late Map<String, dynamic> paymentsConfig;
  String? orderId;
  String? customerRefId;
  late SdkPresenter presenter;
  late String merchantId;
  late String bdOrderId;
  late String orderDate;

  RxBool bdModelShouldModalClose = false.obs;
  RxBool bdModalError = false.obs;
  RxBool loading = true.obs;
  bool upiFlowTriggered = false;
  late FlowType flowType;

  SdkWebViewController(this.sdkConfig);

  Future<dio.Response<dynamic>?> getApiResponse(
    FlowType flowType,
    SdkPresenter presenter,
  ) async {
    dio.Response<dynamic>? response;
    final String? authToken = paymentsConfig["authToken"] as String?;
    merchantId = (paymentsConfig["merchantId"] as String?) ?? '';
    bdOrderId = (paymentsConfig["bdOrderId"] as String?) ?? "";

    switch (flowType) {
      case FlowType.payments:
        response = await presenter.getOrder(
              authToken,
              merchantId,
              paymentsConfig["bdOrderId"] as String?,
              sdkConfig);
        orderId = response?.data["orderid"] as String?;
        break;
      case FlowType.emandate:
          response = await presenter.getMandateOrder(
              authToken,
              merchantId,
              paymentsConfig["mandateTokenId"] as String?,
              sdkConfig);
        orderId = response?.data["mandate_tokenid"] as String?;
        break;
      case FlowType.modify_mandate:
          response = await presenter.getModifyMandateOrder(
              authToken,
              merchantId,
              paymentsConfig["mandateTokenId"] as String?,
              sdkConfig);
        orderId = response?.data["mandate_tokenid"] as String?;
        break;
      case FlowType.payment_plus_mandate:
        response = await presenter.getOrder(
              authToken,
              merchantId,
              paymentsConfig["bdOrderId"] as String?,
              sdkConfig);
        orderId = response?.data["orderid"] as String?;
        break;
    }
      orderDate = (response?.data["order_date"] as String?) ?? "";
      customerRefId = response?.data["customer_refid"] as String?;
    return response;
  }

  bool isCallBackInvoked = false;

  Future<void> exitAndInvokeCallback(
    bool upiIntentFlow,
    SdkPresenter? presenter,
    BuildContext context, {
    bool isSSLError = false,
  }) async {
    if (isCallBackInvoked) return; // prevent multiple invocations
    isCallBackInvoked = true;

    final String finalOrderId = orderId ?? "";

    try {
      bool isCancelledByUser = true;

      final dynamic cancelledByUser =
          presenter?.sdkContext?.scope.get("final_response.isCancelledByUser");
      if (cancelledByUser is bool) {
        isCancelledByUser = cancelledByUser;
      } else if (upiIntentFlow == true) {
        isCancelledByUser = false;
      }

      if (isSSLError) {
        isCancelledByUser = false;
      }

      final txnInfoMap = <String, dynamic>{
        "isCancelledByUser": isCancelledByUser,
        "orderId": finalOrderId,
        "customerRefId": customerRefId ?? "",
        "merchantId": paymentsConfig["merchantId"]
      };

      final txnInfo = TxnInfo(txnInfoMap: txnInfoMap);

      // ✅ Safe navigation check
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      sdkConfig.responseHandler.onTransactionResponse(txnInfo);
    } catch (e, stack) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      final sdkError = SdkError(
        msg: 'An unexpected exception occurred.',
        description: e.toString(),
        SDK_ERROR: SdkError.SERVICE_ERROR,
      );
      SdkLogger.e("exitAndInvokeCallback error: $e", stack);
      sdkConfig.responseHandler.onError(sdkError);
    }
  }
}
