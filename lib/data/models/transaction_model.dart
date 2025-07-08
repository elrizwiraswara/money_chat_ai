class TransactionModel {
  String? id;
  String? categoryId;
  String? categoryName;
  String? createdById;
  String? createdByName;
  double? discount;
  double? amount;
  String? merchant;
  String? date;
  String? source;
  String? type;
  List<ItemModel>? items;
  String? createdAt;
  String? updatedAt;

  TransactionModel({
    this.id,
    this.categoryId,
    this.categoryName,
    this.createdById,
    this.createdByName,
    this.discount,
    this.amount,
    this.merchant,
    this.date,
    this.source,
    this.type,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      createdById: json['createdById'],
      createdByName: json['createdByName'],
      discount: json['discount'],
      amount: json['amount'],
      merchant: json['merchant'],
      date: json['date'],
      source: json['source'],
      type: json['type'],
      items: json['items'] == null
          ? null
          : List<ItemModel>.from(
              json['items']!.map((x) => ItemModel.fromJson(x)),
            ),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdById': createdById,
      'createdByName': createdByName,
      'discount': discount,
      'amount': amount,
      'merchant': merchant,
      'date': date,
      'source': source,
      'type': type,
      'items': items == null
          ? []
          : List<dynamic>.from(items!.map((x) => x.toJson())),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toDebugJson() {
    return {
      'categoryId': categoryId,
      'discount': discount,
      'amount': amount,
      'merchant': merchant,
      'date': date,
      'type': type,
      'items': items == null
          ? []
          : List<dynamic>.from(items!.map((x) => x.toDebugJson())),
    };
  }
}

class ItemModel {
  String? id;
  String? transactionId;
  String? name;
  int? qty;
  double? price;

  ItemModel({
    this.id,
    this.transactionId,
    this.name,
    this.qty,
    this.price,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      transactionId: json['transactionId'],
      name: json['name'],
      qty: json['qty'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'name': name,
      'qty': qty,
      'price': price,
    };
  }

  Map<String, dynamic> toDebugJson() {
    return {
      'name': name,
      'qty': qty,
      'price': price,
    };
  }
}
