// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../sdk.dart';
import '../controller/navigation_controller.dart';

class BilldeskSdkWebview extends StatefulWidget {
  final SdkConfig sdkConfig;
  const BilldeskSdkWebview({super.key, required this.sdkConfig});

  @override
  State<BilldeskSdkWebview> createState() => _BilldeskSdkWebviewState();
}

class _BilldeskSdkWebviewState extends State<BilldeskSdkWebview>
    with WidgetsBindingObserver {
  late NavigationController navigationController;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldNavigateBack =
            await navigationController.showConfirmationDialog(context);
        if (shouldNavigateBack == true) {
          navigationController.sdkWebViewController
              .exitAndInvokeCallback(false, null, context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(children: <Widget>[
            Expanded(
              child: Stack(
                children: navigationController.getInAppWebViewInstance(context),
              ),
            )
          ]),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    navigationController = Get.put(NavigationController(widget.sdkConfig));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<NavigationController>();
    super.dispose();
  }
}

class SdkWebView extends StatelessWidget {
  final SdkConfig config;
  const SdkWebView({super.key, required this.config});

  static void openSdkWebView(SdkConfig config, BuildContext context) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => SdkWebView(config: config),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: BuildConfig.loadConfig(isUATEnv: config.isUATEnv),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return BilldeskSdkWebview(sdkConfig: config);
        }
        return const Text("Loading...");
      },
    );
  }
}
