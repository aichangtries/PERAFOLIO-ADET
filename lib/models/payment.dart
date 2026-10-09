/// A completed simulated payment. Saved in the `payments` Hive box.
class Payment {
  Payment({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.sourceAccountId,
    required this.fee,
    required this.dateTime,
    required this.reference,
    this.status = 'Completed',
  });

  final String id;
  final String merchant;
  final double amount;
  final String sourceAccountId;
  final double fee;
  final String status;
  final DateTime dateTime;
  final String reference;

  double get total => amount + fee;

  Map<String, dynamic> toMap() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'sourceAccountId': sourceAccountId,
        'fee': fee,
        'status': status,
        'dateTime': dateTime.toIso8601String(),
        'reference': reference,
      };

  factory Payment.fromMap(Map<dynamic, dynamic> map) => Payment(
        id: map['id'] as String,
        merchant: map['merchant'] as String,
        amount: (map['amount'] as num).toDouble(),
        sourceAccountId: map['sourceAccountId'] as String,
        fee: (map['fee'] as num).toDouble(),
        status: map['status'] as String? ?? 'Completed',
        dateTime: DateTime.parse(map['dateTime'] as String).toLocal(),
        reference: map['reference'] as String,
      );
}

/// What the user is about to pay, before it becomes a [Payment].
class PaymentDraft {
  const PaymentDraft({
    required this.merchant,
    required this.merchantDetail,
    required this.amount,
    required this.sourceAccountId,
    this.category = 'Payments',
    this.fee = 0,
  });

  final String merchant;
  final String merchantDetail;
  final double amount;
  final String sourceAccountId;
  final String category;
  final double fee;

  double get total => amount + fee;
}
