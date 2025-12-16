enum StockChangeType { add, remove, adjustment }

class StockHistory {
  final String id;
  final String productId;
  final String productName;
  final StockChangeType type;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String? notes;
  final DateTime createdAt;

  StockHistory({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.name,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      type: StockChangeType.values.firstWhere((e) => e.name == map['type']),
      quantity: map['quantity'],
      previousStock: map['previousStock'],
      newStock: map['newStock'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
