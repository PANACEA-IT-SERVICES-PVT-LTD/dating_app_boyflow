class WalletTransaction {
  final String id;
  final String userId;
  final String action; // 'credit' or 'debit'
  final num amount;
  final String message;
  final String balanceAfter;
  final DateTime createdAt;
  final String? referenceId;
  final String? transactionType;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.action,
    required this.amount,
    required this.message,
    required this.balanceAfter,
    required this.createdAt,
    this.referenceId,
    this.transactionType,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      action: json['action']?.toString().toLowerCase() ?? 'unknown',
      amount: json['amount'] is num
          ? json['amount']
          : num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      balanceAfter: json['balanceAfter']?.toString() ?? '0',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      referenceId: json['referenceId']?.toString(),
      transactionType: json['transactionType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'action': action,
      'amount': amount,
      'message': message,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
      'referenceId': referenceId,
      'transactionType': transactionType,
    };
  }

  bool get isCredit => action.toLowerCase() == 'credit';
  bool get isDebit => action.toLowerCase() == 'debit';

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get amountString {
    return '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}';
  }
}
