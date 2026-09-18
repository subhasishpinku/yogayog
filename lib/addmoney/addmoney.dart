import 'package:flutter/material.dart';
import 'package:billdesk_sdk/sdk.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/Payment/provider/payment_provider.dart';
import 'package:yogayog/core/services/payment_service.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';
import 'package:provider/provider.dart';

class Addmoney extends StatefulWidget {
  const Addmoney({super.key});

  @override
  State<Addmoney> createState() => _AddmoneyState();
}

class _AddmoneyState extends State<Addmoney> {
  final amountController = TextEditingController(text: '1000');
  int selectedAmount = 1000;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _balance(),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Select',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final amount in [500, 1000, 2000, 5000]) ...[
                        Expanded(child: _quickAmount(amount)),
                        if (amount != 5000) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ENTER TOP-UP AMOUNT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    color: const Color(0xFFF0F1FF),
                    child: const Text(
                      '🔒  Payments via BillDesk — PCI DSS secured',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _proceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text(
                        'Proceed to Payment →',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    color: AppColors.primaryMain,
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              // style: IconButton.styleFrom(
              //   backgroundColor: const Color(0xFF4D59A7),
              // ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Wallet Top-up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Text(
          'Securely add funds to your wallet',
          style: TextStyle(color: Color(0xFFD2D5FF)),
        ),
      ],
    ),
  );

  Widget _balance() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: const Column(
      children: [
        Text(
          'CURRENT BALANCE',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '₹10,000.00',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _quickAmount(int amount) {
    final active = amount == selectedAmount;
    return OutlinedButton(
      onPressed: () => setState(() {
        selectedAmount = amount;
        amountController.text = '$amount';
      }),
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0xFFF0F1FF) : Colors.white,
        side: BorderSide(
          color: active ? AppColors.primaryBlue : Colors.transparent,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      child: Text(
        '₹${amount.toString()}',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _proceed() async {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final payload = <String, dynamic>{
      'payment_method': 'ONLINE',
      'amount': amount,
    };
    final payment = await context.read<PaymentProvider>().createBillDeskPayment(
      payload: payload,
    );
    if (!mounted) return;
    if (payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<PaymentProvider>().errorMessage ??
                'Unable to initialize BillDesk payment',
          ),
        ),
      );
      return;
    }

    _openBillDesk(payment, orderPayload: payload);
  }

  void _openBillDesk(
    BillDeskPaymentResponse payment, {
    required Map<String, dynamic> orderPayload,
  }) {
    final config = SdkConfig(
      sdkConfigJson: SdkConfiguration(
        {
          'authToken': payment.authToken,
          'merchantId': payment.merchantId,
          'bdOrderId': payment.billDeskOrderId,
          'childWindow': false,
        },
        FlowType.payments,
        '',
        null,
      ),
      responseHandler: _BillDeskResponseHandler(
        onSuccess: () => _createOrderAfterPayment(orderPayload),
        onFailure: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('BillDesk payment was cancelled')),
          );
        },
      ),
      isUATEnv: false,
    );
    SdkWebView.openSdkWebView(config, context);
  }

  Future<void> _createOrderAfterPayment(
    Map<String, dynamic> orderPayload,
  ) async {
    if (!mounted) return;
    final order = await context.read<PaymentProvider>().createOrder(
      payload: orderPayload,
    );
    if (!mounted) return;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<PaymentProvider>().errorMessage ??
                'Payment succeeded, but order creation failed',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Dashboard()),
      (route) => false,
    );
  }
}

class _BillDeskResponseHandler extends ResponseHandler {
  _BillDeskResponseHandler({required this.onSuccess, required this.onFailure});

  final Future<void> Function() onSuccess;
  final VoidCallback onFailure;

  @override
  void onTransactionResponse(TxnInfo txnInfo) {
    final cancelled =
        txnInfo.txnInfoMap['isCancelledByUser'] == true ||
        txnInfo.txnInfoMap['isCancelledByUser']?.toString().toLowerCase() ==
            'true';
    if (cancelled) {
      onFailure();
    } else {
      onSuccess();
    }
  }

  @override
  void onError(SdkError sdkError) => onFailure();
}
