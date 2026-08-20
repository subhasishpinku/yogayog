import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/contactpersons_service.dart';
import 'package:yogayog/contactpersons/provider/contactpersons_provider.dart';
import 'package:provider/provider.dart';

class ContactPersons extends StatefulWidget {
  const ContactPersons({super.key});

  @override
  State<ContactPersons> createState() => _ContactPersonsState();
}

class _ContactPersonsState extends State<ContactPersons> {
  static const _green = AppColors.primaryMain;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ContactPersonsProvider>().loadContacts(),
    );
  }

  List<_ContactGroup> _groupsFrom(ContactPersonsData? data) {
    if (data == null) return const [];
    _Contact convert(ContactPerson person) => _Contact(
      person.initials,
      person.name,
      person.designation,
      person.email,
      phone: person.phone,
    );
    return [
      _ContactGroup('OPERATIONS', data.operations.map(convert).toList()),
      _ContactGroup(
        'PARTNER SUPPORT',
        data.partnerSupport.map(convert).toList(),
      ),
      _ContactGroup(
        'FINANCE & COMMISSION',
        data.financeCommission.map(convert).toList(),
      ),
      _ContactGroup(
        'INTERNATIONAL DESK',
        data.internationalDesk.map(convert).toList(),
      ),
    ].where((group) => group.contacts.isNotEmpty).toList();
  }

  /*
  final _groups = const [
    _ContactGroup('OPERATIONS', [
      _Contact(
        'RK',
        'Rajesh Kumar',
        'Hub Manager – Tollygunge',
        'rajesh.kumar@yogayog.in',
      ),
      _Contact(
        'SP',
        'Sumit Pal',
        'Operations Executive',
        'sumit.pal@yogayog.in',
      ),
    ]),
    _ContactGroup('PARTNER SUPPORT', [
      _Contact(
        'PD',
        'Priya Das',
        'Collection Center Support',
        'partner.support@yogayog.in',
      ),
      _Contact(
        'AM',
        'Arjun Mehta',
        'Onboarding & Training',
        'arjun.mehta@yogayog.in',
      ),
    ]),
    _ContactGroup('FINANCE & COMMISSION', [
      _Contact(
        'NS',
        'Neha Singh',
        'Finance – Commission Payouts',
        'finance@yogayog.in',
      ),
    ]),
    _ContactGroup('INTERNATIONAL DESK', [
      _Contact(
        'VR',
        'Vikram Roy',
        'International Shipments',
        'international@yogayog.in',
      ),
    ]),
  ]; */

  Future<void> _callContact(_Contact contact) async {
    final phone = contact.phone.trim();
    if (phone.isEmpty) {
      _showMessage('Contact number unavailable');
      return;
    }
    final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && mounted) {
      _showMessage('Unable to open phone dialer');
    }
  }

  Future<void> _emailContact(_Contact contact) async {
    final email = contact.email.trim();
    if (email.isEmpty) {
      _showMessage('Email address unavailable');
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Yogayog Support'},
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      _showMessage('Unable to open email app');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactPersonsProvider>();
    final groups = _groupsFrom(provider.contacts);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _green,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F8),
        body: Column(
          children: [
            const _ContactHeader(),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(child: Text(provider.errorMessage!))
                  : groups.isEmpty
                  ? const Center(child: Text('No contact persons found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 5, bottom: 24),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return _ContactGroupSection(
                          group: group,
                          onCall: _callContact,
                          onEmail: _emailContact,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _ContactPersonsState._green),
          Positioned(
            right: -18,
            top: -58,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hintGray, width: 15),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Contact Persons',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Reach the right person quickly',
                    style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactGroupSection extends StatelessWidget {
  final _ContactGroup group;
  final ValueChanged<_Contact> onCall;
  final ValueChanged<_Contact> onEmail;

  const _ContactGroupSection({
    required this.group,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 10, 7, 7),
          child: Text(
            group.title,
            style: const TextStyle(
              color: Color(0xFF7B8493),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: .7,
            ),
          ),
        ),
        ...group.contacts.map(
          (contact) => _ContactCard(
            contact: contact,
            onCall: () => onCall(contact),
            onEmail: () => onEmail(contact),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final _Contact contact;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      margin: const EdgeInsets.only(left: 7, right: 7, bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F5EE),
              shape: BoxShape.circle,
            ),
            child: Text(
              contact.initials,
              style: const TextStyle(
                color: _ContactPersonsState._green,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  contact.role,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B8493),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  contact.email,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _ContactPersonsState._green,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _ActionButton(
            icon: '📞',
            color: const Color(0xFFE8F5EF),
            onTap: onCall,
          ),
          const SizedBox(width: 7),
          _ActionButton(
            icon: '✉️',
            color: const Color(0xFFFFF4C9),
            onTap: onEmail,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(icon, style: const TextStyle(fontSize: 17)),
    ),
  );
}

class _ContactGroup {
  final String title;
  final List<_Contact> contacts;
  const _ContactGroup(this.title, this.contacts);
}

class _Contact {
  final String initials;
  final String name;
  final String role;
  final String email;
  final String phone;

  const _Contact(
    this.initials,
    this.name,
    this.role,
    this.email, {
    this.phone = '',
  });
}
