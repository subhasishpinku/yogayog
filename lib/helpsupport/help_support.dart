import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  static const blue = AppColors.primaryMain;
  static const yellow = AppColors.primaryButton;

  final faqs = const [
    'How can I track my shipment?',
    'How do I add money to my wallet?',
    'Can I cancel a booking?',
    'How long does delivery take?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _welcomeCard(),
          const SizedBox(height: 16),
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _supportAction(
                  Icons.chat_bubble_outline,
                  'Live Chat',
                  'Chat with us',
                  _showMessage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _supportAction(
                  Icons.phone_outlined,
                  'Call Us',
                  'Speak to support',
                  _showMessage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _faqCard(),
          const SizedBox(height: 18),
          _contactCard(),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: yellow,
            child: Icon(Icons.support_agent, color: blue, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Our support team is ready to assist you with your bookings.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportAction(
    IconData icon,
    String title,
    String subtitle,
    void Function(String) onTap,
  ) {
    return InkWell(
      onTap: () => onTap(title),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: blue, size: 25),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          for (var i = 0; i < faqs.length; i++) ...[
            ListTile(
              dense: true,
              leading: const Icon(Icons.help_outline, color: blue, size: 20),
              title: Text(faqs[i], style: const TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showMessage(faqs[i]),
            ),
            if (i != faqs.length - 1)
              const Divider(height: 1, indent: 52, endIndent: 12),
          ],
        ],
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: blue),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email support',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'support@yogayog.com',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showMessage('Email support selected'),
            child: const Text('Contact', style: TextStyle(color: blue)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$message selected')));
  }
}
