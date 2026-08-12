import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:yogayog/homescreen/home_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinController = TextEditingController();
  final _stateController = TextEditingController();
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _mobileController,
      _accountTypeController,
      _addressController,
      _cityController,
      _pinController,
      _stateController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fillProfile(ProfileData profile) {
    if (_filled) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _mobileController.text = profile.mobile;
    _accountTypeController.text = profile.accountType ?? '';
    _addressController.text = profile.address ?? '';
    _cityController.text = profile.city ?? '';
    _pinController.text = profile.pin ?? '';
    _stateController.text = profile.state ?? '';
    _filled = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final profile = provider.profile;
    if (profile != null) _fillProfile(profile);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: provider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                children: [
                  _profileBanner(profile),
                  const SizedBox(height: 5),
                  _sectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    children: [
                      _field('FULL NAME', _nameController, 'Enter full name'),
                      _field(
                        'EMAIL',
                        _emailController,
                        'Email address',
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _field(
                        'MOBILE NUMBER',
                        _mobileController,
                        'Mobile number',
                        readOnly: true,
                        keyboardType: TextInputType.phone,
                      ),
                      _field(
                        'ACCOUNT TYPE',
                        _accountTypeController,
                        'Account type',
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _sectionCard(
                    title: 'Address Information',
                    icon: Icons.location_on_outlined,
                    children: [
                      _field('ADDRESS', _addressController, 'Full address'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _field('CITY', _cityController, 'City'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              'PIN CODE',
                              _pinController,
                              'PIN code',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      _field('STATE', _stateController, 'State'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: AppColors.primaryMain,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _profileBanner(ProfileData? profile) {
    final initials = profile?.initials ?? 'U';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryMain,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.primaryButton,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name.isNotEmpty == true
                      ? profile!.name
                      : 'Your Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Update your profile information',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryMain),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: (value) => label == 'FULL NAME' && value!.trim().isEmpty
            ? 'Name is required'
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF1F2F6) : Colors.white,
          suffixIcon: readOnly
              ? const Icon(Icons.lock_outline, size: 17)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.primaryMain,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile changes are ready to save.')),
    );
  }
}
