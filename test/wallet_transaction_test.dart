import 'package:flutter_test/flutter_test.dart';
import 'package:Boy_flow/models/wallet_transaction.dart';

void main() {
  group('WalletTransaction Model Tests', () {
    test('fromJson should create WalletTransaction from valid JSON', () {
      final json = {
        '_id': '123',
        'userId': 'user123',
        'action': 'credit',
        'amount': 100.50,
        'message': 'Wallet recharge',
        'balanceAfter': '1500.00',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'referenceId': 'ref123',
        'transactionType': 'recharge',
      };

      final transaction = WalletTransaction.fromJson(json);

      expect(transaction.id, '123');
      expect(transaction.userId, 'user123');
      expect(transaction.action, 'credit');
      expect(transaction.amount, 100.50);
      expect(transaction.message, 'Wallet recharge');
      expect(transaction.balanceAfter, '1500.00');
      expect(transaction.isCredit, true);
      expect(transaction.isDebit, false);
      expect(transaction.referenceId, 'ref123');
      expect(transaction.transactionType, 'recharge');
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        '_id': '123',
        'userId': 'user123',
        'action': 'debit',
        'amount': 50,
        'message': 'Call charge',
        'balanceAfter': '950.00',
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final transaction = WalletTransaction.fromJson(json);

      expect(transaction.id, '123');
      expect(transaction.referenceId, null);
      expect(transaction.transactionType, null);
      expect(transaction.isCredit, false);
      expect(transaction.isDebit, true);
    });

    test('toJson should convert WalletTransaction to JSON', () {
      final transaction = WalletTransaction(
        id: '123',
        userId: 'user123',
        action: 'credit',
        amount: 100.50,
        message: 'Wallet recharge',
        balanceAfter: '1500.00',
        createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
        referenceId: 'ref123',
        transactionType: 'recharge',
      );

      final json = transaction.toJson();

      expect(json['_id'], '123');
      expect(json['userId'], 'user123');
      expect(json['action'], 'credit');
      expect(json['amount'], 100.50);
      expect(json['message'], 'Wallet recharge');
      expect(json['balanceAfter'], '1500.00');
      expect(json['referenceId'], 'ref123');
      expect(json['transactionType'], 'recharge');
    });

    test('formattedDate should return properly formatted date', () {
      final transaction = WalletTransaction(
        id: '123',
        userId: 'user123',
        action: 'credit',
        amount: 100,
        message: 'Test',
        balanceAfter: '1000',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      expect(transaction.formattedDate, '15-01-2024 10:30');
    });

    test('amountString should return formatted amount with sign', () {
      final creditTransaction = WalletTransaction(
        id: '123',
        userId: 'user123',
        action: 'credit',
        amount: 100,
        message: 'Test',
        balanceAfter: '1000',
        createdAt: DateTime.now(),
      );

      final debitTransaction = WalletTransaction(
        id: '124',
        userId: 'user123',
        action: 'debit',
        amount: 50,
        message: 'Test',
        balanceAfter: '950',
        createdAt: DateTime.now(),
      );

      expect(creditTransaction.amountString, '+₹100.00');
      expect(debitTransaction.amountString, '-₹50.00');
    });
  });
}
