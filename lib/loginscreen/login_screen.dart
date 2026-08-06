import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/loginscreen/provider/auth_provider.dart';
import 'package:yogayog/otpscreen/otp_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  Country _selectedCountry = Country.parse('IN');

  static const Color primaryBlue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.sendOtp(phone);
    if (!mounted) return;

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Unable to send OTP')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OtpScreen(
              phoneNumber: '+${_selectedCountry.phoneCode} $phone',
              mobileNumber: phone,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MOBILE NUMBER',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              _buildCountryCode(),
                              const SizedBox(width: 10),
                              Expanded(child: _buildPhoneField()),
                            ],
                          ),

                          const SizedBox(height: 18),

                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color(0xFF98A2B3),
                                fontSize: 12,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'By continuing you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' and\n'),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: context.watch<AuthProvider>().isLoading
                                  ? null
                                  : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: yellow,
                                foregroundColor: primaryBlue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: context.watch<AuthProvider>().isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Center(
                            child: GestureDetector(
                              onTap: () {
                                // Login screen navigation
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(text: 'Returning user? '),
                                    TextSpan(
                                      text: 'Log in instead',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF2F2F7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 122,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(18, 27, 18, 10),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your mobile number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We'll send a 4-digit OTP to verify",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          Positioned(
            top: -55,
            right: -35,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCode() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: true,
          favorite: const ['IN'],
          countryListTheme: CountryListThemeData(
            flagSize: 28,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, color: Color(0xFF667085)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
          },
        );
      },
      child: Container(
        width: 72,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedCountry.flagEmoji,
              style: const TextStyle(fontSize: 19),
            ),
            const SizedBox(height: 2),
            Text(
              '+${_selectedCountry.phoneCode}',
              style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Enter mobile number',
          hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }
}
