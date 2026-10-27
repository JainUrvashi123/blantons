class CartItem {
  final String cartId;
  final String productId;
  final String stockId;
  final String quantity;
  final String productType;
  final String price;
  final String totalPrice;
  final String name;
  final String description;
  final String attributes;
  final String? infoArray;
  final String image;
  final String? diamondVideo;
  final String? reportFilename;
  final String createdAt;
  final String customerId;
  final String isRingBuilder;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.stockId,
    required this.quantity,
    required this.productType,
    required this.price,
    required this.totalPrice,
    required this.name,
    required this.description,
    required this.attributes,
    this.infoArray,
    required this.image,
    this.diamondVideo,
    this.reportFilename,
    required this.createdAt,
    required this.customerId,
    required this.isRingBuilder,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      stockId: json['stock_id']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '1',
      productType: json['product_type']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      attributes: json['attributes']?.toString() ?? '',
      infoArray: json['info_array']?.toString(),
      image: json['image']?.toString() ?? '',
      diamondVideo: json['diamond_video']?.toString(),
      reportFilename: json['report_filename']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      isRingBuilder: json['is_ring_builder']?.toString() ?? '0',
    );
  }
}
