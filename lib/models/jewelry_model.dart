class JewelryItem {
  final String productId;
  final String productName;
  final String productSku;
  final String productPrice;
  final String? imageShow;
  final String? categoryName;
  final String? metalType;
  final String? stoneName;
  final String? stoneShape;

  JewelryItem({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productPrice,
    this.imageShow,
    this.categoryName,
    this.metalType,
    this.stoneName,
    this.stoneShape,
  });

  factory JewelryItem.fromJson(Map<String, dynamic> json) {
    return JewelryItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      productPrice: json['product_price']?.toString() ?? '0.00',
      imageShow: json['image_show'] ?? json['product_image'],
      categoryName: json['category_name'],
      metalType: json['metal_type'],
      stoneName: json['stone_name'],
      stoneShape: json['stone_shape'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_price': productPrice,
      'image_show': imageShow,
      'category_name': categoryName,
      'metal_type': metalType,
      'stone_name': stoneName,
      'stone_shape': stoneShape,
    };
  }
}
