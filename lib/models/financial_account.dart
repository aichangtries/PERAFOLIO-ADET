enum ConnectionStatus { connected, available }

/// A simulated bank or e-wallet. Saved in the `financial_accounts` Hive box.
class FinancialAccount {
  FinancialAccount({
    required this.id,
    required this.provider,
    required this.accountType,
    required this.balance,
    required this.connectionStatus,
    this.lastSync,
  });

  final String id;
  final String provider;
  final String accountType;
  double balance;
  ConnectionStatus connectionStatus;
  DateTime? lastSync;

  bool get isConnected => connectionStatus == ConnectionStatus.connected;
  String get initial => provider.isEmpty ? '?' : provider[0].toUpperCase();

  Map<String, dynamic> toMap() => {
        'id': id,
        'provider': provider,
        'accountType': accountType,
        'balance': balance,
        'connectionStatus': connectionStatus.name,
        'lastSync': lastSync?.toIso8601String(),
      };

  factory FinancialAccount.fromMap(Map<dynamic, dynamic> map) =>
      FinancialAccount(
        id: map['id'] as String,
        provider: map['provider'] as String,
        accountType: map['accountType'] as String,
        balance: (map['balance'] as num).toDouble(),
        connectionStatus: ConnectionStatus.values.byName(
          map['connectionStatus'] as String,
        ),
        lastSync: map['lastSync'] == null
            ? null
            : DateTime.parse(map['lastSync'] as String).toLocal(),
      );
}
