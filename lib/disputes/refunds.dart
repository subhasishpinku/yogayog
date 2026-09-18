import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/disputes/provider/disputes_provider.dart';

class Refunds extends StatefulWidget {
  const Refunds({super.key});

  @override
  State<Refunds> createState() => _RefundsState();
}

class _RefundsState extends State<Refunds> {
  static const _blue = AppColors.primaryMain;
  static const _background = Color(0xFFF5F6FA);
  int _selectedTab = 0;
  final _provider = DisputesProvider();
  List<DisputeIssue> _issues = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _loadIssues() async {
    final issues = await _provider.getIssues();
    if (!mounted) return;
    setState(() {
      _issues = issues;
      _isLoading = false;
      _errorMessage = _provider.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 84,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 18),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My claims',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3),
            Text(
              'Track every support request',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 20),
        children: [
          Row(
            children: [
              _tabButton('Open (${_openCount()})', 0),
              const SizedBox(width: 7),
              _tabButton('Resolved (${_resolvedCount()})', 1),
            ],
          ),
          const SizedBox(height: 15),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _emptyCard(_errorMessage!)
          else
            ...(_claimsForSelectedTab().isEmpty
                ? <Widget>[
                    _emptyCard(
                      _selectedTab == 0
                          ? 'No open claims yet'
                          : 'No resolved claims yet',
                    ),
                  ]
                : _claimsForSelectedTab()
                      .map(
                        (claim) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: _apiClaimCard(claim),
                        ),
                      )
                      .toList()),
        ],
      ),
    );
  }

  int _openCount() => _issues.where((claim) => !_isClosed(claim)).length;

  int _resolvedCount() => _issues.where(_isClosed).length;

  bool _isClosed(DisputeIssue claim) {
    return {
      'resolved',
      'refunded',
      'closed',
    }.contains(claim.status.toLowerCase());
  }

  List<DisputeIssue> _claimsForSelectedTab() {
    return _issues.where((claim) {
      final closed = _isClosed(claim);
      return _selectedTab == 1 ? closed : !closed;
    }).toList();
  }

  Widget _emptyCard(String message) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _apiClaimCard(DisputeIssue claim) {
    final closed = _isClosed(claim);
    final statusText = closed ? 'Resolved' : 'Reviewing';
    final statusBackground = closed
        ? const Color(0xFFE4F8E8)
        : const Color(0xFFFFF3C4);
    final statusForeground = closed
        ? const Color(0xFF198345)
        : const Color(0xFF8B6900);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${_issueLabel(claim.claimType)} · ${claim.claimId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _pill(statusText, statusBackground, statusForeground),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order ${claim.orderId} · Submitted ${claim.createdAt}',
            style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _bar(_blue)),
              const SizedBox(width: 6),
              Expanded(child: _bar(closed ? _blue : const Color(0xFFFFC400))),
              const SizedBox(width: 6),
              Expanded(child: _bar(closed ? _blue : const Color(0xFFD9DDE5))),
            ],
          ),
          const SizedBox(height: 14),
          _timelineItem(Icons.check, 'Claim submitted', claim.createdAt, true),
          const SizedBox(height: 14),
          _timelineItem(
            closed ? Icons.check : Icons.circle,
            closed ? 'Claim resolved' : 'Evidence under review',
            closed ? claim.status : 'We’ll update you within 48 hours',
            closed,
          ),
        ],
      ),
    );
  }

  String _issueLabel(String code) {
    switch (code) {
      case 'item_mismatch':
        return 'Package issue';
      case 'not_received_shipment':
        return 'Delivery issue';
      case 'damaged':
        return 'Payment & refund';
      default:
        return code.isEmpty ? 'Claim' : code;
    }
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF667085),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _reviewingClaim() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Package issue · YCG-2025-\n00921',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              _pill(
                'Reviewing',
                const Color(0xFFFFF3C4),
                const Color(0xFF8B6900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '₹149 requested · Submitted today at 5:54 PM',
            style: TextStyle(color: Color(0xFF667085), fontSize: 10),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _bar(_blue)),
              const SizedBox(width: 6),
              Expanded(child: _bar(const Color(0xFFFFC400))),
              const SizedBox(width: 6),
              Expanded(child: _bar(const Color(0xFFD9DDE5))),
            ],
          ),
          const SizedBox(height: 14),
          _timelineItem(
            Icons.check,
            'Claim submitted',
            'Today · 5:54 PM',
            true,
          ),
          const SizedBox(height: 14),
          _timelineItem(
            Icons.circle,
            'Evidence under review',
            'We’ll update you within 48 hours',
            false,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E7ED)),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionText('View claim details'),
              const Spacer(),
              _actionText('Contact support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _refundedClaim() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Refund · YCG-2025-00872',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              _pill(
                'Refunded',
                const Color(0xFFE4F8E8),
                const Color(0xFF198345),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            '₹210 sent to UPI · Aug 3, 2025',
            style: TextStyle(color: Color(0xFF667085), fontSize: 10),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Transaction ID',
                style: TextStyle(color: Color(0xFF667085), fontSize: 10),
              ),
              const Spacer(),
              _actionText('View details'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(Color color) => Container(
    height: 4,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );

  Widget _timelineItem(
    IconData icon,
    String title,
    String detail,
    bool active,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 19,
          height: 19,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _blue : const Color(0xFFFFC400),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: active ? 13 : 8,
            color: active ? Colors.white : const Color(0xFF775B00),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              detail,
              style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _pill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionText(String label) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(label))),
      child: Text(
        label,
        style: const TextStyle(
          color: _blue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
