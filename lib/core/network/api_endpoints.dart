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
  static const String nearbyBranches = "nearby-branches";
  static const String cutoffTimes = "cutoff-times";

  static String cutoffTime(int serviceId) => '$cutoffTimes/$serviceId';
}
