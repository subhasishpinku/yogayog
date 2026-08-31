class ApiEndpoints {
  // ================= AUTH =================
  static const String authSendOtp = "auth/send-otp";
  static const String authVerifyOtp = "auth/verify-otp";
  static const String authRegisterCustomer = "auth/register-customer";
  static const String mailSendOtp = "mail/send-otp";
  static const String mailVerifyOtp = "mail/verify-otp";
  static const String authLogout = "logout";
  static const String profile = "profile";
  static const String staticServices = "static-services";
  static const String trackOrder = "track-order";
  static const String customerWalletLedger = "customer-wallet-ledger";
  static const String bookings = "bookings";
  static const String locations = "locations";
  static const String rates = "rates";
  static const String createOrder = "order/create";
  static const String createPostpaidOrder = "order/create-postpaid";
  static const String pickupLocation = "locations/pickup";
  static const String nearbyBranches = "nearby-branches";
  static const String cutoffTimes = "cutoff-times";
  static const String contacts = "contacts";
  static const String pincodeServiceability = "check/pincode-serviceability";
  static const String termsAndConditions = "terms-and-conditions";
  static const String invoices = "orders/invoices";
  static const String sendIssue = "order/send-issue";
  static const String reschedulePickup = "order/reschedule-pickup";
  static String invoiceDownload(int orderId) => 'orders/$orderId/invoice/download';

  static String cutoffTime(int serviceId) => '$cutoffTimes/$serviceId';
}
