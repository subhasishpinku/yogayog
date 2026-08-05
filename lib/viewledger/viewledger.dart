import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class Viewledger extends StatefulWidget {
  const Viewledger({super.key});

  @override
  State<Viewledger> createState() => _ViewledgerState();
}

class _ViewledgerState extends State<Viewledger> {
  static const _blue = AppColors.primaryBlue;
  static const _background = Color(0xFFF4F4FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _balanceSummary(),
                  const SizedBox(height: 16),
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _transactionCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: _blue,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF4D59A7),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'My Wallet Ledger',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'All wallet transactions & balance',
            style: TextStyle(color: Color(0xFFD2D5FF), fontSize: 13),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _headerButton(
                icon: Icons.refresh,
                label: 'Refresh',
                onPressed: () => _showMessage('Ledger refreshed'),
              ),
              const SizedBox(width: 10),
              _headerButton(
                icon: Icons.file_download_outlined,
                label: 'Export CSV',
                yellow: true,
                onPressed: () => _showMessage('CSV export started'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool yellow = false,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: TextButton.styleFrom(
        backgroundColor: yellow
            ? AppColors.primaryButton
            : const Color(0xFF4D59A7),
        foregroundColor: yellow ? _blue : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _balanceSummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'CURRENT BALANCE',
                amount: '₹10,000',
                color: _blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'TOTAL CREDIT',
                amount: '₹10,000',
                color: const Color(0xFF2DBE58),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _summaryCard(
          title: 'TOTAL DEBIT',
          amount: '₹0.00',
          color: const Color(0xFFD13A2E),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(16, 15, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '127156796817',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '↑ Credit',
                  style: TextStyle(
                    color: Color(0xFF27943D),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yogayog Credit',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Description: Wallet',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '🗓️ 31 Jul 2026, 7:13 AM',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '+₹10,000',
                    style: TextStyle(
                      color: Color(0xFF27943D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Balance: ₹10,000',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
