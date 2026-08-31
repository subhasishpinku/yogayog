import '../../sdk.dart';

class OrderConfigValidator {
  static void validateOrderConfig(SdkConfiguration sdkConfig) {
    final flowType = sdkConfig.flowType;
    final flowConfig = sdkConfig.flowConfig;

    isBlankOrNull(flowConfig?['authToken'] as String?, 'OToken');

    if (flowType == FlowType.payments || flowType == FlowType.payment_plus_mandate) {
      isBlankOrNull(flowConfig?['bdOrderId'] as String?, 'bdOrderId');
    } else if (flowType == FlowType.emandate || flowType == FlowType.modify_mandate) {
      isBlankOrNull(flowConfig?['mandateTokenId'] as String?, 'mandate_tokenid');
    }
  }

  static void isBlankOrNull(String? input, String? varName) {
    if (input == null || input.isEmpty) {
      throw SdkException(sdkError: getSdkError('$varName is required'));
    }
  }

  static SdkError getSdkError(String msg) {
    return SdkError(
      msg: msg,
      description: msg,
      SDK_ERROR: SdkError.SERVICE_ERROR,
    );
  }
}
