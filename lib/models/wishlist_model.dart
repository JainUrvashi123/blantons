class WishlistItem {
  final String wishlistId;
  final String productId;
  final String sku;
  final String category;
  final String productPrice;
  final String? imageShow;
  final String type;

  WishlistItem({
    required this.wishlistId,
    required this.productId,
    required this.sku,
    required this.category,
    required this.productPrice,
    this.imageShow,
    required this.type,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json, String type) {
    return WishlistItem(
      wishlistId: json['wishlist_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? json['diamond_id']?.toString() ?? '',
      sku: json['stock_id']?.toString() ?? '',
      category: json['name']?.toString() ?? json['type']?.toString() ?? '',
      productPrice: json['price']?.toString() ?? json['product_price']?.toString() ?? '0.00',
      imageShow: json['image']?.toString() ?? json['image_show']?.toString(),
      type: type,
    );
  }
}

class WishlistData {
  final List<WishlistItem> jewelry;
  final List<WishlistItem> diamond;

  WishlistData({
    required this.jewelry,
    required this.diamond,
  });

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    final jewelryList = (json['jewelry'] as List?)
            ?.map((e) => WishlistItem.fromJson(e, 'jewelry'))
            .toList() ??
        [];
    final diamondList = (json['diamond'] as List?)
            ?.map((e) => WishlistItem.fromJson(e, 'diamond'))
            .toList() ??
        [];

    return WishlistData(
      jewelry: jewelryList,
      diamond: diamondList,
    );
  }
  
  List<WishlistItem> get allItems => [...jewelry, ...diamond];
}
