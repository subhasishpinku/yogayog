import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/viewledger_service.dart';
import 'package:yogayog/viewledger/provider/viewledger_provider.dart';
import 'package:provider/provider.dart';

class Viewledger extends StatefulWidget {
  const Viewledger({super.key});

  @override
  State<Viewledger> createState() => _ViewledgerState();
}

class _ViewledgerState extends State<Viewledger> {
  static const _blue = AppColors.primaryMain;
  static const _background = Color(0xFFF4F4FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ViewledgerProvider>().loadLedger();
    });
  }

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
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF4D59A7),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Wallet Ledger',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
                onPressed: _exportCsv,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    final provider = context.read<ViewledgerProvider>();
    final csv = provider.exportCsv();

    if (csv.isEmpty) {
      _showMessage('No ledger transactions to export');
      return;
    }

    try {
      final location = await FilePicker.platform.saveFile(
        dialogTitle: 'Save wallet ledger CSV',
        fileName: 'wallet_ledger.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: Uint8List.fromList(utf8.encode(csv)),
      );

      if (!mounted) return;
      _showMessage(
        location == null ? 'CSV export cancelled' : 'CSV saved successfully',
      );
    } catch (_) {
      if (mounted) _showMessage('Unable to export CSV');
    }
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
    final ledger = context.watch<ViewledgerProvider>().ledger;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'CURRENT BALANCE',
                amount: _money(ledger?.currentBalance),
                color: _blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'TOTAL CREDIT',
                amount: _money(ledger?.totalCredit),
                color: const Color(0xFF2DBE58),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _summaryCard(
          title: 'TOTAL DEBIT',
          amount: _money(ledger?.totalDebit),
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
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard() {
    final provider = context.watch<ViewledgerProvider>();
    if (provider.isLoading && provider.ledger == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (provider.errorMessage != null && provider.ledger == null) {
      return Column(
        children: [
          Text(
            provider.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: provider.loadLedger,
            child: const Text('Retry'),
          ),
        ],
      );
    }
    final transactions =
        provider.ledger?.transactions ?? const <WalletTransaction>[];
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }
    return Column(children: transactions.map(_transactionItem).toList());
  }

  Widget _transactionItem(WalletTransaction transaction) {
    final isCredit = transaction.type.toLowerCase() == 'credit';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      margin: const EdgeInsets.only(bottom: 10),
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
              Text(
                transaction.transactionId,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                '${isCredit ? '+' : '-'} ${isCredit ? 'Credit' : 'Debit'}',
                style: TextStyle(
                  color: isCredit
                      ? const Color(0xFF27943D)
                      : const Color(0xFFD13A2E),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.transaction,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Description: ${transaction.description}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      transaction.createdAt,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}${_money(transaction.amount)}',
                    style: TextStyle(
                      color: isCredit
                          ? const Color(0xFF27943D)
                          : const Color(0xFFD13A2E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Balance: ${_money(transaction.runningBalance)}',
                    style: const TextStyle(
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

  String _money(double? amount) => '₹${(amount ?? 0).toStringAsFixed(2)}';

  Widget _transactionCardStatic() {
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
