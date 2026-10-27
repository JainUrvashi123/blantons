class CustomJewelryItem {
  final String id;
  final String stockNumberMaster;
  final String variantStockNumber;
  final String mainProductDropDown;
  final String mainSubTypes;
  final String styles;
  final String stoneShape;
  final String indexName;
  final String variantName;
  final String variantDescription;
  final String option1Name;
  final String option1Value;
  final String option2Name;
  final String option2Value;
  final String option3Name;
  final String option3Value;
  final String variantOrder;
  final String variantPrice;
  final String variantPrice2;
  final String variantPrice1Blue;
  final String media1;
  final String media2;
  final String media3Front;
  final String media3Side;
  final String media5;
  final String media6;
  final String media7;
  final String ringSize;
  final String settingType;
  final String metalType;
  final String metalColor;
  final String metalWeight;
  final String totalCaratWeight;
  final String stones1;
  final String stones1StoneShape;
  final String stones1CaratWeight;
  final String stones1DiamondClarity;
  final String stones1DiamondColor;
  final String stones1DiamondCut;
  final String stones1DiamondPolish;
  final String stones1NumberOfStones;
  final String stones2;
  final String stones2StoneShape;
  final String stones2CaratWeight;
  final String stones2NumberOfStones;
  final String wholesalePrice1;
  final String wholesalePrice2;
  final String wholesalePrice3Blue;
  final String createdAt;
  final String wgImage;
  final String ygImage;
  final String rgImage;
  final String defaultImage;
  final String calculatedRegularPrice;
  final String calculatedSalePrice;
  final List<String> gallery;

  CustomJewelryItem({
    required this.id,
    required this.stockNumberMaster,
    required this.variantStockNumber,
    required this.mainProductDropDown,
    required this.mainSubTypes,
    required this.styles,
    required this.stoneShape,
    required this.indexName,
    required this.variantName,
    required this.variantDescription,
    required this.option1Name,
    required this.option1Value,
    required this.option2Name,
    required this.option2Value,
    required this.option3Name,
    required this.option3Value,
    required this.variantOrder,
    required this.variantPrice,
    required this.variantPrice2,
    required this.variantPrice1Blue,
    required this.media1,
    required this.media2,
    required this.media3Front,
    required this.media3Side,
    required this.media5,
    required this.media6,
    required this.media7,
    required this.ringSize,
    required this.settingType,
    required this.metalType,
    required this.metalColor,
    required this.metalWeight,
    required this.totalCaratWeight,
    required this.stones1,
    required this.stones1StoneShape,
    required this.stones1CaratWeight,
    required this.stones1DiamondClarity,
    required this.stones1DiamondColor,
    required this.stones1DiamondCut,
    required this.stones1DiamondPolish,
    required this.stones1NumberOfStones,
    required this.stones2,
    required this.stones2StoneShape,
    required this.stones2CaratWeight,
    required this.stones2NumberOfStones,
    required this.wholesalePrice1,
    required this.wholesalePrice2,
    required this.wholesalePrice3Blue,
    required this.createdAt,
    required this.wgImage,
    required this.ygImage,
    required this.rgImage,
    required this.defaultImage,
    required this.calculatedRegularPrice,
    required this.calculatedSalePrice,
    this.gallery = const [],
  });

  factory CustomJewelryItem.fromJson(Map<String, dynamic> json) {
    return CustomJewelryItem(
      id: json['id']?.toString() ?? '',
      stockNumberMaster: json['stock_number_master'] ?? '',
      variantStockNumber: json['variant_stock_number'] ?? '',
      mainProductDropDown: json['main_product_drop_down'] ?? '',
      mainSubTypes: json['main_sub_types'] ?? '',
      styles: json['styles'] ?? '',
      stoneShape: json['stone_shape'] ?? '',
      indexName: json['index_name'] ?? '',
      variantName: json['variant_name'] ?? '',
      variantDescription: json['variant_description'] ?? '',
      option1Name: json['option_1_name'] ?? '',
      option1Value: json['option_1_value'] ?? '',
      option2Name: json['option_2_name'] ?? '',
      option2Value: json['option_2_value'] ?? '',
      option3Name: json['option_3_name'] ?? '',
      option3Value: json['option_3_value'] ?? '',
      variantOrder: json['variant_order']?.toString() ?? '0',
      variantPrice: (json['variant_price_1_blue'] != null && json['variant_price_1_blue'].toString().isNotEmpty)
          ? json['variant_price_1_blue'].toString()
          : (json['variant_price']?.toString() ?? '0.00'),
      variantPrice2: json['variant_price_2']?.toString() ?? '',
      variantPrice1Blue: json['variant_price_1_blue']?.toString() ?? '',
      media1: json['media_1'] ?? '',
      media2: json['media_2'] ?? '',
      media3Front: json['media_3_front'] ?? '',
      media3Side: json['media_3_side'] ?? '',
      media5: json['media_5'] ?? '',
      media6: json['media_6'] ?? '',
      media7: json['media_7'] ?? '',
      ringSize: json['ring_size']?.toString() ?? '',
      settingType: json['setting_type'] ?? '',
      metalType: json['metal_type'] ?? '',
      metalColor: json['metal_color'] ?? '',
      metalWeight: json['metal_weight']?.toString() ?? '',
      totalCaratWeight: json['total_carat_weight']?.toString() ?? '',
      stones1: json['stones_1'] ?? '',
      stones1StoneShape: json['stones_1_stone_shape'] ?? '',
      stones1CaratWeight: json['stones_1_carat_weight']?.toString() ?? '',
      stones1DiamondClarity: json['stones_1_diamond_clarity'] ?? '',
      stones1DiamondColor: json['stones_1_diamond_color'] ?? '',
      stones1DiamondCut: json['stones_1_diamond_cut'] ?? '',
      stones1DiamondPolish: json['stones_1_diamond_polish'] ?? '',
      stones1NumberOfStones: json['stones_1_number_of_stones']?.toString() ?? '',
      stones2: json['stones_2'] ?? '',
      stones2StoneShape: json['stones_2_stone_shape'] ?? '',
      stones2CaratWeight: json['stones_2_carat_weight']?.toString() ?? '',
      stones2NumberOfStones: json['stones_2_number_of_stones']?.toString() ?? '',
      wholesalePrice1: json['wholesale_price_1']?.toString() ?? '',
      wholesalePrice2: json['wholesale_price_2']?.toString() ?? '',
      wholesalePrice3Blue: json['wholesale_price_3_blue']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      wgImage: json['wg_image'] ?? '',
      ygImage: json['yg_image'] ?? '',
      rgImage: json['rg_image'] ?? '',
      defaultImage: json['default_image'] ?? '',
      calculatedRegularPrice: json['calculated_regular_price']?.toString() ?? '',
      calculatedSalePrice: json['calculated_sale_price']?.toString() ?? '',
      gallery: (json['gallery'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  String get primaryImage {
    if (defaultImage.isNotEmpty) return defaultImage;
    if (wgImage.isNotEmpty) return wgImage;
    if (media1.isNotEmpty) return media1;
    if (ygImage.isNotEmpty) return ygImage;
    if (rgImage.isNotEmpty) return rgImage;
    if (gallery.isNotEmpty) return gallery.first;
    return '';
  }

  String get displayCarat {
    if (totalCaratWeight.isNotEmpty && totalCaratWeight != '0') return totalCaratWeight;
    if (option2Value.isNotEmpty && option2Value != '0') return option2Value;
    if (stones1CaratWeight.isNotEmpty && stones1CaratWeight != '0') return stones1CaratWeight;
    return '';
  }
}

class CustomJewelryCategory {
  final String categoryName;

  CustomJewelryCategory({required this.categoryName});

  factory CustomJewelryCategory.fromJson(Map<String, dynamic> json) {
    return CustomJewelryCategory(
      categoryName: json['category_name'] ?? '',
    );
  }
}

class CustomJewelryVariant {
  final String id;
  final String color;
  final String carat;
  final String price;

  CustomJewelryVariant({
    required this.id,
    required this.color,
    required this.carat,
    required this.price,
  });

  factory CustomJewelryVariant.fromJson(Map<String, dynamic> json) {
    return CustomJewelryVariant(
      id: json['id']?.toString() ?? '',
      color: json['color'] ?? '',
      carat: json['carat']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
    );
  }
}

class CustomJewelryDetailData {
  final CustomJewelryItem product;
  final List<String> availableColors;
  final List<String> availableCarats;
  final List<CustomJewelryVariant> variantsMatrix;

  CustomJewelryDetailData({
    required this.product,
    required this.availableColors,
    required this.availableCarats,
    required this.variantsMatrix,
  });

  factory CustomJewelryDetailData.fromJson(Map<String, dynamic> json) {
    final prodMap = json['product'] as Map<String, dynamic>? ?? {};
    final colorsList = (json['available_colors'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final caratsList = (json['available_carats'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final matrixList = (json['variants_matrix'] as List?)
            ?.map((e) => CustomJewelryVariant.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CustomJewelryDetailData(
      product: CustomJewelryItem.fromJson(prodMap),
      availableColors: colorsList,
      availableCarats: caratsList,
      variantsMatrix: matrixList,
    );
  }
}
