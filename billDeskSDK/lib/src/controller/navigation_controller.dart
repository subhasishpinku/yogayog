// ignore_for_file: use_build_context_synchronously, avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:billdesk_sdk/sdk.dart';
import 'package:billdesk_sdk/src/overlays/app_not_found.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/sdk_context.dart';
import '../screens/payment_processing_overlay.dart';
import '../utilities/order_config_validator.dart';
import '../utilities/sdk_html_builder.dart';
import '../utilities/sdk_logger.dart';
import 'package:dio/dio.dart' as dio;

class NavigationController extends GetxController {
  final SdkConfig sdkConfig;
  final GlobalKey webViewKey = GlobalKey();
  final RxBool isLoading = false.obs;
  final RxBool isInitialLoad = true.obs;
  final RxString currentUrl = ''.obs;
  final RxBool isDone = false.obs;
  final RxBool bdModelShouldModalClose = false.obs;
  final RxDouble progress = 0.0.obs;

  late SdkPresenter presenter;
  late SdkWebViewController sdkWebViewController;
  late InAppWebViewController inAppWebViewController;
  late BuildContext context;
  late FlowType flowType;
  List<String> urls = [];
  late String currentFlowType;

  bool isSdkExecuted = false;
  final int minLoaderDisplayTime = 1000;
  DateTime? loadStartTime;

  static NavigationController get to => Get.find();

  // Initialize presenter synchronously in constructor to avoid LateInitializationError
  NavigationController(this.sdkConfig) {
    presenter = SdkPresenter(
      sdkContext: SdkContext(scope: Scope()),
    );
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeSdk();
    _observeModalClose();
  }

  void _observeModalClose() {
    debounce(bdModelShouldModalClose, (shouldModalClose) {
      if (shouldModalClose == true) {
        sdkWebViewController.exitAndInvokeCallback(false, presenter, context);
      }
    });
  }

  Future<void> initializeSdk() async {
    SdkLogger.init(level: Level.debug);
    sdkWebViewController = SdkWebViewController(sdkConfig);

    SdkLogger.i("SDK initialized successfully!");

    try {
      final SdkConfiguration config = sdkConfig.sdkConfigJson;
      flowType = config.flowType!;
      currentFlowType = config.flowType!.name;

      if (flowType == FlowType.payment_plus_mandate) {
        config.flowType = flowType = FlowType.payments;
      }

      _validateConfig(config);

      sdkWebViewController.paymentsConfig = config.flowConfig!;

      await _loadConfiguration();
      //* getOrder details api call
      await _fetchOrderDetails();
      sdkWebViewController.loading.value = false;
    } catch (e, stackTrace) {
      final String errorDetails = 'Exception: $e\nStack trace: $stackTrace';
      Navigator.of(context).pop();
      SdkLogger.e(errorDetails);
      if (e is SdkException) {
        sdkConfig.responseHandler.onError(e.sdkError);
      }
      sdkWebViewController.loading.value = false;
    }
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final dio.Response<dynamic>? orderResponse =
          await sdkWebViewController.getApiResponse(
        flowType,
        presenter,
      );

      presenter.sdkContext?.scope.set("orderResponse", orderResponse);
      assert(BuildConfig.filePath.isNotEmpty, "filePath must be initialized");
    } catch (e, stackTrace) {
      _logSdkError(
        'Exception during getApiResponse',
        e,
        stackTrace,
        'Some exception occurred while loading web view.',
      );
      sdkWebViewController.loading.value = false;
    }
  }

  void _validateConfig(SdkConfiguration config) {
    try {
      OrderConfigValidator.validateOrderConfig(config);
    } on SdkException catch (e) {
      sdkConfig.responseHandler.onError(e.sdkError);
    }
  }

  void _logSdkError(
      String title, Object e, StackTrace stack, String uiMessage) {
    final String errorDetails = '$title: $e\nStack trace: $stack';
    final SdkError sdkError = SdkError(
      msg: uiMessage,
      description: e.toString().split('\n')[0],
      SDK_ERROR: SdkError.SERVICE_ERROR,
    );
    SdkLogger.e(errorDetails);
    sdkConfig.responseHandler.onError(sdkError);
  }

  Future<void> _loadConfiguration() async {
    if (BuildConfig.filePath.isEmpty) {
      await BuildConfig.loadConfig(isUATEnv: sdkConfig.isUATEnv);
    }
  }

  List<Widget> getInAppWebViewInstance(BuildContext context) {
    this.context = context;

    return [
      Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: Colors.white),
          ),
          InAppWebView(
            key: webViewKey,
            initialSettings: getInAppWebViewOptions(),
            initialFile: BuildConfig.filePath,
            onWebViewCreated: setWebViewController,
            onLoadStart: _updateParams,
            onProgressChanged: progressListener,
            onLoadStop: _loadWebPage,
            onLoadResource: loadResourceHandler,
            onReceivedError: pageLoadErrorListener,
            onReceivedHttpError: httpErrorListener,
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
            onReceivedServerTrustAuthRequest: setCertificateToSite,
            onPermissionRequest: androidPermissionRequest,
            onCreateWindow: setChildWindow,
            onCloseWindow: (controller) async {
              await inAppWebViewController.evaluateJavascript(
                  source: "window.localStorage.clear();");
            },
          ),
        ],
      ),
      Obx(
        () => isLoading.value && isSdkExecuted && !isInitialLoad.value
            ? const PaymentProcessingOverlay(
                message: "We're processing your payment request!")
            : const SizedBox.shrink(),
      ),
    ];
  }

  Future<void> loadResourceHandler(
      InAppWebViewController controller, LoadedResource resource) async {
    if (resource.url.toString().contains(".js") && !isSdkExecuted) {
      // executeSdkModal(controller);
    }
  }

  Future<void> executeSdkModal(InAppWebViewController controller) async {
    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        sdkConfig.sdkConfigJson.toJson(),
      );
      _filterJsonProperty(json); // optional filtering

      // Extract nested config for form submission
      final Map<String, dynamic> flowConfig = Map<String, dynamic>.from(
        (json['flowConfig'] as Map?) ?? <String, dynamic>{},
      );
      final Map<String, dynamic> prefs = Map<String, dynamic>.from(
        (flowConfig['prefs'] as Map?) ?? <String, dynamic>{},
      );
      final Map<String, dynamic> netBanking = Map<String, dynamic>.from(
        (flowConfig['netBanking'] as Map?) ?? <String, dynamic>{},
      );
      final List<dynamic> savedCards = List<dynamic>.from(
        (flowConfig['savedCards'] as List?) ?? <dynamic>[],
      );
      final String flowType = (json['flowType'] as String?) ?? '';

      // Convert nested objects to JSON strings for hidden fields
      final String prefsJson = jsonEncode(prefs);
      final String netBankingJson = jsonEncode(netBanking);
      final String savedCardsJson = jsonEncode(savedCards);

      // Determine form action URL based on environment
      final String formActionUrl = sdkConfig.shouldUseOldUat == true
          ? "https://uat1.billdesk.com/pgtxnsimulator/v1_2/embeddedsdk"
          : sdkConfig.isUATEnv == true
              ? "https://uat1.billdesk.com/u2/web/v1_2/embeddedsdk"
              : "https://pay.billdesk.com/web/v1_2/embeddedsdk";

      // Use SdkHtmlBuilder to generate HTML
      final String htmlContent = SdkHtmlBuilder.buildSdkFormHtml(
        flowConfig: flowConfig,
        prefsJson: prefsJson,
        netBankingJson: netBankingJson,
        savedCardsJson: savedCardsJson,
        formActionUrl: formActionUrl,
        flowType: flowType,
      );

      // Load the HTML into WebView
      await controller.loadData(
          data: htmlContent, baseUrl: WebUri("about:blank"));
    } catch (e) {
      final SdkError sdkError = SdkError(
          msg: 'Error during loading BillDeskSdk in WebView',
          description: e.toString(),
          SDK_ERROR: SdkError.SERVICE_ERROR);
      SdkLogger.e('Error during loading BillDeskSdk in WebView', e.toString());
      sdkConfig.responseHandler.onError(sdkError);
    }
  }

  Future<bool?> setChildWindow(InAppWebViewController controller,
      CreateWindowAction createWindowRequest) async {
    final RxString currentTitle = 'Redirecting...'.obs;
    final RxInt currentProgress = 0.obs;

    showDialog<void>(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            if (!await inAppWebViewController.canGoBack()) {
              final NavigatorState navigator = Navigator.of(context);
              final bool? shouldNavigateBack =
                  await showConfirmationDialog(context);
              if (shouldNavigateBack ?? false) {
                navigator.pop();
              }
            }
          },
          child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                iconTheme: const IconThemeData(color: Color(0xff001e2e)),
                shadowColor: Colors.white,
                title: Obx(() => Text(currentTitle.value,
                    style: const TextStyle(color: Color(0xff001e2e)))),
                backgroundColor: const Color(0xfff7f7f9),
              ),
              body: SafeArea(
                  child: Stack(
                children: [
                  InAppWebView(
                      initialSettings: InAppWebViewSettings(
                        enableViewportScale: true,
                        thirdPartyCookiesEnabled: false,
                        geolocationEnabled: false,
                      ),
                      windowId: createWindowRequest.windowId,
                      onReceivedServerTrustAuthRequest: setCertificateToSite,
                      onProgressChanged: (controller, progress) {
                        currentProgress.value = progress;
                      },
                      onTitleChanged: (controller, title) {
                        currentTitle.value = title ?? currentTitle.value;
                      },
                      onCloseWindow: (controller) {
                        Navigator.of(context).pop();
                      },
                      onReceivedHttpError: httpErrorListener,
                      onReceivedError: pageLoadErrorListener),
                  Obx(() => currentProgress.value != 100
                      ? const LinearProgressIndicator()
                      : Container())
                ],
              ))),
        );
      },
    );
    return true;
  }

  InAppWebViewSettings getInAppWebViewOptions() {
    return InAppWebViewSettings(
      javaScriptCanOpenWindowsAutomatically: true,
      useOnLoadResource: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      supportMultipleWindows: true,
      useHybridComposition: true,
      thirdPartyCookiesEnabled: false,
      geolocationEnabled: false,
      allowsInlineMediaPlayback: true,
      transparentBackground: true,
      allowsBackForwardNavigationGestures: false, // disables back gesture
      // Disabled zoom controls
      supportZoom: false,
      builtInZoomControls: false,
      displayZoomControls: false,
      textZoom: 100, 
    );
  }

  Future<PermissionResponse> androidPermissionRequest(
    InAppWebViewController controller,
    PermissionRequest request,
  ) async {
    return PermissionResponse(
      resources: request.resources,
      action: PermissionResponseAction.GRANT,
    );
  }

  Future<Map<String, dynamic>> _getBuildInfo() async {
    final fileContent = await rootBundle.loadString(
      "packages/billdesk_sdk/files/info.json",
    );

    return Map<String, dynamic>.from(jsonDecode(fileContent) as Map);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    final snackBar = SnackBar(content: Text('Copied to Clipboard: $text'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> showBuildInfoDialogue() async {
    final Map<String, dynamic> sdkBuildInfo = await _getBuildInfo();
    final List<TableRow> itemList = [];
    final List<String> versionInfo =
        (sdkBuildInfo["version"] as String).split(".");

    final Map<String, dynamic> items = {
      "flowType": currentFlowType,
      "SDK version": "f${sdkBuildInfo["version"]}",
      "Build Number": sdkBuildInfo["build"],
      "Major version": versionInfo[0],
      "Minor version": versionInfo[1]
    };

    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      items["OS version"] = "Android ${androidDeviceInfo.version.release}";
      items["Manufacturer"] = androidDeviceInfo.manufacturer;
      items["Device model name"] = androidDeviceInfo.model;
      items["OS Api level"] = androidDeviceInfo.version.sdkInt;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      items["OS version"] = "ios ${iosDeviceInfo.systemVersion}";
      items["Device model name"] = iosDeviceInfo.systemName;
      items["Manufacturer"] = iosDeviceInfo.model;
    }

    if (flowType == FlowType.emandate || flowType == FlowType.modify_mandate) {
      items["mandate id"] = sdkWebViewController.orderId;
    } else {
      items["order id"] = sdkWebViewController.orderId;
    }

    items.addAll({
      "merchant id": sdkWebViewController.merchantId,
      "bdOrderId": sdkWebViewController.bdOrderId,
      "order date": sdkWebViewController.orderDate,
      "isUatEnv": sdkConfig.isUATEnv
    });

    items.forEach((key, value) {
      if (value != "" && value != null) {
        itemList.add(TableRow(children: [
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(5.0), // Add desired padding
              child: Text(key),
            ),
          ),
          TableCell(
            child: Padding(
              padding: const EdgeInsets.all(5.0), // Add desired padding
              child: GestureDetector(
                  onTap: () {
                    _copyToClipboard("$value");
                  },
                  child: Text("$value",
                      softWrap: true,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
          ),
        ]));
      }
    });

    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Container(
                alignment: Alignment.center, child: const Text("BillDesk SDK Info")),
            content: SizedBox(
              width: 900,
              child: SingleChildScrollView(
                child: ListBody(children: [
                  Table(
                    children: itemList,
                  )
                ]),
              ),
            ),
          );
        });
  }

  Future<void> _updateParams(
      InAppWebViewController controller, Uri? uri) async {
    if (isInitialLoad.value) {
      // This is the initial load, don't show the loader yet
      isInitialLoad.value = false;
    } else if (uri.toString() != currentUrl.value) {
      // This is navigation to a new page, show the loader
      isLoading.value = true;
      loadStartTime = DateTime.now();
    }
    currentUrl.value = uri.toString();
    if (sdkConfig.isUATEnv == true && Platform.isAndroid) {
      await _safeUpdateUrlByKey(controller);
    }

    // Add a new JavaScript handler to detect page load progress
    _addJavaScriptHandlers(controller);

    final dio.Response<dynamic>? orderDetails =
      presenter.sdkContext?.scope.get("orderResponse")
        as dio.Response<dynamic>?;
    final String? redirectUrl = orderDetails?.data?['ru'] as String?;

    if (redirectUrl != null && uri.toString().startsWith(redirectUrl)) {
      presenter.sdkContext?.scope
          .set("final_response.isCancelledByUser", false);
      presenter.sdkContext?.scope.set("bd-modal.shouldModalClose", true);

      bdModelShouldModalClose.value = true;
    }

    // Inject JavaScript to report load progress
    if (isSdkExecuted) {
      _injectSafeJavaScript(controller);
    }
  }

  Future<void> _safeUpdateUrlByKey(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: """
      setTimeout(() => {
        if (typeof updateUrlByKey === 'function') {
          updateUrlByKey(${sdkConfig.shouldUseOldUat});
        }
      }, 500)
    """);
  }

  void _addJavaScriptHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
        handlerName: "pageLoadProgress",
        callback: (args) {
          final int progress = (args[0] as num?)?.toInt() ?? 0;
          if (progress == 100) {
            // isLoading.value = false;
            _handleLoadComplete();
          }
        });

    controller.addJavaScriptHandler(
        handlerName: "sdkExecutionEvent",
        callback: (args) {
          final Map<String, dynamic> sdkStatus =
              Map<String, dynamic>.from(jsonDecode(args[0] as String) as Map);

          if (sdkStatus["isExecuted"] == true) {
            isSdkExecuted = true;
          }
        });

    controller.addJavaScriptHandler(
        handlerName: "buildDetailEvent",
        callback: (args) async {
            final Map<String, dynamic> buildInfoEvent =
              Map<String, dynamic>.from(jsonDecode(args[0] as String) as Map);

          if (buildInfoEvent["alert"] == true) {
            showBuildInfoDialogue();
          }
        });
  }

  void _handleLoadComplete() {
    if (loadStartTime != null) {
      final elapsedTime =
          DateTime.now().difference(loadStartTime!).inMilliseconds;
      if (elapsedTime < minLoaderDisplayTime) {
        Future<void>.delayed(
            Duration(milliseconds: minLoaderDisplayTime - elapsedTime), () {
          isLoading.value = false;
        });
      } else {
        isLoading.value = false;
      }
    } else {
      isLoading.value = false;
    }
  }

  void _loadWebPage(InAppWebViewController controller, Uri? uri) async {
    // isLoading.value = false;
    _handleLoadComplete();
    if (uri.toString().contains("billdesksdk://web-flow")) {
      controller.evaluateJavascript(source: """
                    document.getElementById("loading-info").innerText = "Processing payment. please wait. Don't click back or refresh the page"
                  """).then((value) async {
        final Map<String, String> params = Uri.parse(uri.toString()).queryParameters;
        presenter.sdkContext?.scope.set("final_response.isCancelledByUser",
            _getSdkState(params["status"]!));
        presenter.sdkContext?.scope.set("bd-modal.shouldModalClose", true);
        bdModelShouldModalClose.value = true;
        isDone.value = false;

        await Future<void>.delayed(const Duration(seconds: 2));

        await InAppWebViewController.clearAllCache();
        sdkWebViewController.exitAndInvokeCallback(false, presenter, context);
      });
    } else if (uri.toString().contains(BuildConfig.filePath)) {
      if (!isSdkExecuted) executeSdkModal(controller);

      if (sdkConfig.isUATEnv == true && Platform.isIOS) {
        await _safeUpdateUrlByKey(controller);
      }
    }
  }

  Map<String, dynamic> _filterJsonProperty(Map<String, dynamic> json) {
    json["flowConfig"].remove("orderid");
    json["flowConfig"].remove("mandate_tokenid");

    if (json["flowType"] == "eMandate") {
      json["flowType"] = "emandate";
    }

    return json;
  }

  void setWebViewController(InAppWebViewController controller) {
    inAppWebViewController = controller;
  }

  void progressListener(InAppWebViewController controller, int progress) {
    if (progress == 100) {
      isDone.value = true;
    }
    this.progress.value = progress.toDouble();
  }

  void pageLoadErrorListener(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    SdkLogger.e(
        "controller: $controller, url: ${request.url}, message: ${error.description}");
  }

  void httpErrorListener(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    SdkLogger.e(
        "HTTP Error → URL: ${request.url}, Status Code: ${errorResponse.statusCode}, Description: ${errorResponse.reasonPhrase}");
  }

  Future<ServerTrustAuthResponse?> setCertificateToSite(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge) async {
    ServerTrustAuthResponseAction? dialogResponse;

    final String url = challenge.protectionSpace.host;

    final SslError? sslError = challenge.protectionSpace.sslError;

    final String? sslErrorMessage = sslError?.message;

    final bool isValidError = sslError?.code != SslErrorType.UNSPECIFIED;

    if (!url.contains(BuildConfig.filePath) &&
        !urls.contains(url) &&
        isValidError) {
      urls.add(url.toString());

      dialogResponse = await showDialog<ServerTrustAuthResponseAction>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('SSL Error'),
            content:
                Text('Ssl Certificate Error: $sslErrorMessage!\n Url : $url'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(ServerTrustAuthResponseAction.CANCEL);
                },
              ),
              TextButton(
                child: const Text('Proceed'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(ServerTrustAuthResponseAction.PROCEED);
                },
              ),
            ],
          );
        },
      );
      SdkLogger.e('Ssl Certificate Error: $sslErrorMessage!\n Url : $url');
    }

    if (dialogResponse == ServerTrustAuthResponseAction.CANCEL) {
      InAppWebViewController.clearAllCache();
      sdkWebViewController.exitAndInvokeCallback(false, presenter, context,
          isSSLError: true);
    }
    // Return the appropriate action based on the user's choice
    return ServerTrustAuthResponse(
        action: dialogResponse ?? ServerTrustAuthResponseAction.PROCEED);
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final Uri uri = navigationAction.request.url!;
    final scheme = uri.scheme.toLowerCase();
    final urlString = uri.toString().toLowerCase();

    // Allow common schemes
    if (["http", "https", "file", "chrome", "data", "javascript", "about"]
        .contains(scheme)) {
      return NavigationActionPolicy.ALLOW;
    }

    // BillDesk SDK callback
    if (urlString.contains("billdesksdk://web-flow")) {
      final params = uri.queryParameters;
      final status = params["status"];
      if (status != null) {
        presenter.sdkContext?.scope.set(
          "final_response.isCancelledByUser",
          _getSdkState(status),
        );
      }
      presenter.sdkContext?.scope.set("bd-modal.shouldModalClose", true);
      bdModelShouldModalClose.value = true;
      return NavigationActionPolicy.CANCEL;
    }

    // Supported UPI app schemes
    const upiSchemes = [
      "upi",
      "bhim",
      "gpay",
      "paytmmp",
      "paytm",
      "phonepe",
    ];

    if (upiSchemes.contains(scheme)) {
      if (!sdkWebViewController.upiFlowTriggered) {
        sdkWebViewController.upiFlowTriggered = true;

        await handleUpiDeepLink(
          context: context,
          uri: uri,
          sdkWebViewController: sdkWebViewController,
          presenter: presenter,
        );
      }
      return NavigationActionPolicy.CANCEL;
    }

    // Suppress any other unknown custom scheme
    return NavigationActionPolicy.CANCEL;
  }

  bool _getSdkState(String status) {
    final sdkState = SdkState.getSdkStateNameByCode(status.toString());
    if (sdkState == SdkState.PAYMENT_ATTEMPTED) {
      return false;
    }
    return true;
  }

  Future<bool?> showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Abort Payment?'),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(true); // Allow navigation back
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        backgroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(100, 0),
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                  const SizedBox(width: 16.0), // Add spacing between buttons
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(false); // Cancel navigation back
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        elevation: 4,
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(100, 0),
                      ),
                      child: const Text('No'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleUpiDeepLink({
    required BuildContext context,
    required Uri uri,
    required SdkWebViewController sdkWebViewController,
    required SdkPresenter presenter,
  }) async {
    try {
      // Try to launch the UPI app
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // App not installed or launch failed
        _showAppNotInstalledOverlay(context, sdkWebViewController, presenter);
      }
    } catch (e) {
      // Explicit error
      SdkLogger.e("UPI launch failed: $e");
      _showAppNotInstalledOverlay(context, sdkWebViewController, presenter);
    }
  }

  Future<void> _injectSafeJavaScript(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: """
    function setupLoadListener() {
      if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
        window.addEventListener('load', function() {
          window.flutter_inappwebview.callHandler('pageLoadProgress', 100);
        });
      } else {
        setTimeout(setupLoadListener, 100);
      }
    }
    setupLoadListener();
  """);
  }

  void _showAppNotInstalledOverlay(
      BuildContext context,
      SdkWebViewController sdkWebViewController,
      SdkPresenter presenter) {
    PlatformAdaptiveDialog.show(
      context: context,
      title: "App not accessible",
      message: "Sorry, we are unable to access this app on your device.",
      buttonText: "Cancel Payment",
      onButtonPressed: () async {
        await sdkWebViewController.exitAndInvokeCallback(
            false, presenter, context);
      },
    );
  }
}
