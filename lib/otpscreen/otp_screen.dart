import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/loginscreen/login_save.dart';
import 'package:yogayog/loginscreen/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/otpscreen/provider/otp_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String mobileNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.mobileNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color primaryBlue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _seconds = 28;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _resendOtp() async {
    if (_seconds != 0) return;

    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.sendOtp(widget.mobileNumber);
    if (!mounted) return;
    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Unable to resend OTP'),
        ),
      );
      return;
    }

    setState(() => _seconds = 28);
    _startTimer();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP resent successfully')));
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP')),
      );
      return;
    }

    final otpProvider = context.read<OtpProvider>();
    final verified = await otpProvider.verifyOtp(
      mobile: widget.mobileNumber,
      otp: otp,
    );
    if (!mounted) return;

    if (!verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(otpProvider.errorMessage ?? 'Invalid OTP')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginSaveScreen(mobileNumber: widget.mobileNumber),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(30, 24, 30, 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildOtpFields(),

                      const SizedBox(height: 16),

                      _buildResendText(),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: context.watch<OtpProvider>().isLoading
                              ? null
                              : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            foregroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: context.watch<OtpProvider>().isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Verify & Continue',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
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
              flex: 1,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF2F2F7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 178,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(32, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Sent to ${widget.phoneNumber}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          Positioned(
            top: 58,
            right: -35,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 49,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            autofocus: index == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onChanged(value, index),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryBlue, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryBlue, width: 2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendText() {
    return GestureDetector(
      onTap: _resendOtp,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 12),
          children: [
            const TextSpan(text: "Didn't get it? "),

            TextSpan(
              text: 'Resend OTP',
              style: TextStyle(
                color: _seconds == 0 ? primaryBlue : const Color(0xFF98A2B3),
                fontWeight: FontWeight.bold,
              ),
            ),

            if (_seconds > 0) TextSpan(text: ' in ${_seconds}s'),
          ],
        ),
      ),
    );
  }
}
