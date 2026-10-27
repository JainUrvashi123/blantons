class JewelryFilterData {
  final List<String> categories;
  final List<String> metalTypes;
  final List<String> stoneShapes;
  final List<String> stoneNames;

  JewelryFilterData({
    required this.categories,
    required this.metalTypes,
    required this.stoneShapes,
    required this.stoneNames,
  });

  factory JewelryFilterData.fromJson(Map<String, dynamic> json) {
    return JewelryFilterData(
      categories: (json['categories'] as List?)
              ?.map((e) => e['category_name'].toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      metalTypes: (json['metal_type'] as List?)
              ?.map((e) => e['metal'].toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      stoneShapes: (json['stone_shape'] as List?)
              ?.map((e) => e['stone_shape'].toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      stoneNames: (json['stone_name'] as List?)
              ?.map((e) => e['stone_name'].toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
    );
  }
}
