enum TransactionType { moneyIn, moneyOut }

/// One activity record. Saved in the `transactions` Hive box.
class Transaction {
  Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.merchantOrDescription,
    required this.category,
    required this.dateTime,
    this.status = 'Completed',
  });

  final String id;
  final String accountId;
  final TransactionType type;

  /// Always positive; [type] decides the sign shown in the UI.
  final double amount;
  final String merchantOrDescription;
  final String category;
  final DateTime dateTime;
  final String status;

  bool get isIncome => type == TransactionType.moneyIn;

  /// Transfers between the user's own accounts are not income or spending.
  bool get isInternalTransfer => category == 'Transfer';

  Map<String, dynamic> toMap() => {
        'id': id,
        'accountId': accountId,
        'type': type.name,
        'amount': amount,
        'merchantOrDescription': merchantOrDescription,
        'category': category,
        'dateTime': dateTime.toIso8601String(),
        'status': status,
      };

  factory Transaction.fromMap(Map<dynamic, dynamic> map) => Transaction(
        id: map['id'] as String,
        accountId: map['accountId'] as String,
        type: TransactionType.values.byName(map['type'] as String),
        amount: (map['amount'] as num).toDouble(),
        merchantOrDescription: map['merchantOrDescription'] as String,
        category: map['category'] as String,
        dateTime: DateTime.parse(map['dateTime'] as String).toLocal(),
        status: map['status'] as String? ?? 'Completed',
      );
}
