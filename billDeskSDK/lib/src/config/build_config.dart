library sdk;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class BuildConfig {
  static String baseUrl = "";
  static String pgUrl = "";
  static String pgTxnUrl = "";
  static String filePath = "";
  static String pgUrlAlt = "";

  static Future<void> loadConfig({bool? isUATEnv}) async {
    const packagePrefix = "packages/billdesk_sdk";

    if (isUATEnv == true) {
      await dotenv.load(fileName: "$packagePrefix/assets/.env_uat");
      baseUrl = dotenv.get('baseUrl');
      pgUrl = dotenv.get('pgUrl');
      pgTxnUrl = dotenv.get('pgTxnUrl');
      filePath = '$packagePrefix/files/indexUat.html';
      pgUrlAlt = dotenv.get('pgUrl_alt');
    } else {
      await dotenv.load(fileName: "$packagePrefix/assets/.env_prod");
      baseUrl = dotenv.get('baseUrl');
      pgUrl = dotenv.get('pgUrl');
      pgTxnUrl = dotenv.get('pgTxnUrl');
      filePath = '$packagePrefix/files/indexProd.html';
    }
  }
}

