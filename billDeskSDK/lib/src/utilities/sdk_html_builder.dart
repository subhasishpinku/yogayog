class SdkHtmlBuilder {
  static String buildSdkFormHtml({
    required Map<String, dynamic> flowConfig,
    required String prefsJson,
    required String netBankingJson,
    required String savedCardsJson,
    required String formActionUrl,
    required String flowType,
  }) {
    return """
    <!DOCTYPE html>
    <html>
    <body>
      <form id="sdklaunch" method="POST" action="$formActionUrl">
        <input type="hidden" name="flowType" value="$flowType">
        <input type="hidden" name="merchantId" value="${flowConfig['merchantId'] ?? ''}">
        <input type="hidden" name="bdOrderId" value="${flowConfig['bdOrderId'] ?? ''}">
        <input type="hidden" name="mandateTokenId" value="${flowConfig['mandateTokenId'] ?? ''}">
        <input type="hidden" name="authToken" value="${flowConfig['authToken'] ?? ''}">
        <input type="hidden" name="childWindow" value="${flowConfig['childWindow'] ?? false}">
        <input type="hidden" name="retryCount" value="${flowConfig['retryCount'] ?? 0}">
        <input type="hidden" name="showConvenienceFeeDetails" value="${flowConfig['showConvenienceFeeDetails'] ?? false}">
        <input type="hidden" name="returnUrl" value="${flowConfig['returnUrl'] ?? ''}">

        <!-- Nested config as JSON strings -->
        <input type="hidden" name="prefs" value='$prefsJson'>
        <input type="hidden" name="netBanking" value='$netBankingJson'>
        <input type="hidden" name="savedCards" value='$savedCardsJson'>
      </form>

      <script type="text/javascript">
        // Submit the form automatically
        document.getElementById('sdklaunch').submit();
      </script>
    </body>
    </html>
    """;
  }
}
