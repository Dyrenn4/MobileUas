enum TransactionType { income, expense }

class FinancialTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final String category;
  final DateTime createdAt;
  final String? productId; // null jika manual input

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.createdAt,
    this.productId,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'productId': productId,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: map['amount'].toDouble(),
      description: map['description'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      productId: map['productId'],
    );
  }
}
