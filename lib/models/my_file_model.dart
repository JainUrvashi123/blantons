class MyFileModel {
  final String id;
  final String customerId;
  final String folderType;
  final String fileName;
  final String fileKey;
  final String fileUrl;
  final String createdAt;

  MyFileModel({
    required this.id,
    required this.customerId,
    required this.folderType,
    required this.fileName,
    required this.fileKey,
    required this.fileUrl,
    required this.createdAt,
  });

  factory MyFileModel.fromJson(Map<String, dynamic> json) {
    return MyFileModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      folderType: json['folder_type']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileKey: json['file_key']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
