class NewArrivalResponse {
  final bool status;
  final String message;
  final List<ProductRecord> records;

  NewArrivalResponse({required this.status, required this.message, required this.records});

  factory NewArrivalResponse.fromJson(Map<String, dynamic> json) {
    return NewArrivalResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      records: (json['records'] as List? ?? [])
          .map((i) => ProductRecord.fromJson(i))
          .toList(),
    );
  }
}

class ProductRecord {
  final String productId;
  final String productName;
  final String imageShow;
  final String priceShow;
  final String shortDescription;

  ProductRecord({
    required this.productId,
    required this.productName,
    required this.imageShow,
    required this.priceShow,
    required this.shortDescription,
  });

  factory ProductRecord.fromJson(Map<String, dynamic> json) {
    return ProductRecord(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      imageShow: json['image_show'] ?? '',
      priceShow: json['product_price_show'] ?? '',
      shortDescription: json['product_short_description'] ?? '',
    );
  }
}