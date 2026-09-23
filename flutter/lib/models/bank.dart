class Bank {
  final String name;
  final String type;
  final String balance;
  bool connected;

  Bank(this.name, this.type, this.balance, {this.connected = false});
}

class TransactionItem {
  final String name;
  final String detail;
  final String amount;

  TransactionItem(this.name, this.detail, this.amount);
}

// Backwards-compatible alias for the prototype screens.
typedef Tx = TransactionItem;

class BankTransaction {
  final String name;
  final String detail;
  final String amount;

  BankTransaction(this.name, this.detail, this.amount);
}
