import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/termsprivacy/provider/term_privacy_provider.dart';
import 'package:yogayog/core/services/term_privacy_services.dart';

class TermPrivacy extends StatefulWidget {
  const TermPrivacy({super.key});

  @override
  State<TermPrivacy> createState() => _TermPrivacyState();
}

class _TermPrivacyState extends State<TermPrivacy> {
  static const blue = AppColors.primaryMain;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TermPrivacyProvider>().loadTermsAndConditions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TermPrivacyProvider>();
    final document = provider.document;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          document?.title ?? 'Terms & Privacy',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _body(provider, document),
    );
  }

  Widget _body(TermPrivacyProvider provider, TermsPrivacyDocument? document) {
    if (provider.isLoading && document == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && document == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : provider.loadTermsAndConditions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (document == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: provider.loadTermsAndConditions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _documentHeader(document.title),
          const SizedBox(height: 14),
          ...document.sections.map(
            (section) =>
                _section(section.title, section.content.map(_content).toList()),
          ),
          if (document.lastUpdated.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Last updated: ${document.lastUpdated}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _content(TermsPrivacyContent content) {
    return content.type.toLowerCase() == 'bullet'
        ? _bullet(content.text)
        : _paragraph(content.text);
  }

  Widget _documentHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            color: Color(0xFFFFC400),
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please read these terms carefully before using Yogayog services.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: blue,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ...children,
        ],
      ),
    );
  }

  Widget _paragraph(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4B5565),
        fontSize: 13,
        height: 1.5,
      ),
    ),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: blue),
        ),
        const SizedBox(width: 9),
        Expanded(child: _paragraph(text)),
      ],
    ),
  );
}
