import '../models/bank.dart';

abstract final class MockData {
  static List<Bank> banks() => [
        Bank('GCash', 'E-Wallet', '₱12,450', connected: true),
        Bank('Maya', 'E-Wallet', '₱8,230', connected: true),
        Bank('MariBank', 'Savings Account', '₱25,000', connected: true),
        Bank('BPI', 'Bank', '₋'),
        Bank('BDO', 'Bank', '₋'),
      ];

  static List<Tx> transactions() => [
        Tx('Grab', 'GCash • Food & Dining', '-₱250.00'),
        Tx('Coffee Bean', 'Maya • Food & Dining', '-₱180.00'),
        Tx('Salary', 'MariBank • Income', '+₱30,000.00'),
      ];
}
