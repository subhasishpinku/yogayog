import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';

class LoginSaveScreen extends StatefulWidget {
  const LoginSaveScreen({super.key});

  @override
  State<LoginSaveScreen> createState() => _LoginSaveScreenState();
}

class _LoginSaveScreenState extends State<LoginSaveScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pinController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final addressController = TextEditingController();

  String? accountType;
  String? paymentMode;
  bool acceptedTerms = false;

  static const Color cyan = Color(0xFF19C7D4);
  // static const Color primaryBlue = Color(0xFF29358F);
  // static const Color yellow = Color(0xFFFFC400);

  static const Color primaryBlue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pinController.dispose();
    cityController.dispose();
    stateController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildHeader(),

                const SizedBox(height: 22),

                _inputField(
                  controller: nameController,
                  hint: 'Enter Full Name',
                  icon: Icons.account_circle_outlined,
                ),

                const SizedBox(height: 14),

                _selectField(
                  value: accountType,
                  hint: 'Select Account type',
                  icon: Icons.manage_accounts_outlined,
                  items: const ['Individual', 'Business', 'Corporate'],
                  onChanged: (value) {
                    setState(() => accountType = value);
                  },
                ),

                const SizedBox(height: 14),

                _selectField(
                  value: paymentMode,
                  hint: 'Select Payment mode',
                  icon: Icons.qr_code_2,
                  items: const ['Cash', 'Online Payment', 'Card'],
                  onChanged: (value) {
                    setState(() => paymentMode = value);
                  },
                ),

                const SizedBox(height: 14),

                _inputField(
                  controller: emailController,
                  hint: 'Enter Email',
                  icon: Icons.mark_email_unread_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 115,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        if (emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter email first')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Address Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _inputField(
                  controller: pinController,
                  hint: 'Enter pin code',
                  icon: Icons.location_on_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _inputField(
                        controller: cityController,
                        hint: 'Enter City',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _inputField(
                        controller: stateController,
                        hint: 'Enter State',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _inputField(
                  controller: addressController,
                  hint: 'Enter Address',
                  icon: Icons.location_on_outlined,
                  maxLines: 1,
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Checkbox(
                      value: acceptedTerms,
                      activeColor: cyan,
                      onChanged: (value) {
                        setState(() {
                          acceptedTerms = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I accept the terms and conditions',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Dashboard()),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 40,
            errorBuilder: (_, __, ___) {
              return const Text(
                'YOGAYOG',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          const Text(
            'Create Your Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Join us to securely manage your shipments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: maxLength != null
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _selectField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: cyan, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
