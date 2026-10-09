/// A completed simulated transfer. Saved in the `transfers` Hive box.
class Transfer {
  Transfer({
    required this.id,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.amount,
    required this.fee,
    required this.dateTime,
    required this.reference,
    this.note = '',
    this.status = 'Completed',
  });

  final String id;
  final String sourceAccountId;
  final String destinationAccountId;
  final double amount;
  final double fee;
  final String status;
  final DateTime dateTime;
  final String reference;
  final String note;

  double get total => amount + fee;

  Map<String, dynamic> toMap() => {
        'id': id,
        'sourceAccountId': sourceAccountId,
        'destinationAccountId': destinationAccountId,
        'amount': amount,
        'fee': fee,
        'status': status,
        'dateTime': dateTime.toIso8601String(),
        'reference': reference,
        'note': note,
      };

  factory Transfer.fromMap(Map<dynamic, dynamic> map) => Transfer(
        id: map['id'] as String,
        sourceAccountId: map['sourceAccountId'] as String,
        destinationAccountId: map['destinationAccountId'] as String,
        amount: (map['amount'] as num).toDouble(),
        fee: (map['fee'] as num).toDouble(),
        status: map['status'] as String? ?? 'Completed',
        dateTime: DateTime.parse(map['dateTime'] as String).toLocal(),
        reference: map['reference'] as String,
        note: map['note'] as String? ?? '',
      );
}
