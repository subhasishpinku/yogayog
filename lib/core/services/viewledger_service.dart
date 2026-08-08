import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class ViewledgerService {
  ViewledgerService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<WalletLedger> getLedger() async {
    try {
      final response = await _dio.get(ApiEndpoints.customerWalletLedger);
      final data = response.data;

      if (data is! Map) {
        throw const ViewledgerException('Invalid response from the server');
      }

      return WalletLedger.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ViewledgerException(data['message'].toString());
      }
      throw ViewledgerException(
        error.message ?? 'Network error while loading wallet ledger',
      );
    }
  }
}

class WalletLedger {
  const WalletLedger({
    required this.currentBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.transactions,
  });

  final double currentBalance;
  final double totalCredit;
  final double totalDebit;
  final List<WalletTransaction> transactions;

  factory WalletLedger.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    return WalletLedger(
      currentBalance: _toDouble(json['current_balance']),
      totalCredit: _toDouble(json['total_credit']),
      totalDebit: _toDouble(json['total_debit']),
      transactions: rawTransactions is List
          ? rawTransactions
                .whereType<Map>()
                .map(
                  (item) => WalletTransaction.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.transactionId,
    required this.transaction,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.runningBalance,
    required this.status,
  });

  final String transactionId;
  final String transaction;
  final String type;
  final double amount;
  final String description;
  final String createdAt;
  final double runningBalance;
  final String status;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      transactionId: json['transaction_id']?.toString() ?? '',
      transaction: json['transaction']?.toString() ?? '',
      type: json['txn_direction']?.toString() ??
          json['transaction_type']?.toString() ?? '',
      amount: WalletLedger._toDouble(json['amount']),
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      runningBalance: WalletLedger._toDouble(json['running_balance']),
      status: json['status']?.toString() ?? '',
    );
  }
}

class ViewledgerException implements Exception {
  const ViewledgerException(this.message);

  final String message;

  @override
  String toString() => message;
}
