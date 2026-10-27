import 'quote_model.dart'; // Reusing QuoteModel since 'details' array items match QuoteModel structure

class QuoteDetailResponse {
  final QuoteModel? detail; // From data['details'][0]
  final List<QuoteDetailImageModel> images;
  final List<QuoteProcessModel> process;

  QuoteDetailResponse({
    this.detail,
    required this.images,
    required this.process,
  });

  factory QuoteDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return QuoteDetailResponse(images: [], process: []);
    }

    final data = json['data'];

    QuoteModel? detail;
    if (data['details'] != null && (data['details'] as List).isNotEmpty) {
      detail = QuoteModel.fromJson(data['details'][0]);
    }

    final imagesList = (data['images'] as List?)
            ?.map((e) => QuoteDetailImageModel.fromJson(e))
            .toList() ??
        [];

    final processList = (data['process'] as List?)
            ?.map((e) => QuoteProcessModel.fromJson(e))
            .toList() ??
        [];

    return QuoteDetailResponse(
      detail: detail,
      images: imagesList,
      process: processList,
    );
  }
}

class QuoteDetailImageModel {
  final String imageId;
  final String designId;
  final String image;

  QuoteDetailImageModel({
    required this.imageId,
    required this.designId,
    required this.image,
  });

  factory QuoteDetailImageModel.fromJson(Map<String, dynamic> json) {
    return QuoteDetailImageModel(
      imageId: json['image_id']?.toString() ?? '',
      designId: json['design_id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
  
  String get imageUrl {
    if (image.isEmpty) return '';
    final url = image.startsWith('http') ? image : 'https://blantonslab.com/uploads/design/$image';
    return Uri.encodeFull(url);
  }
}

class QuoteProcessModel {
  final String processId;
  final String designId;
  final String message;
  final String? status;
  final String flag;
  final String processingStatus;
  final String createDate;
  final String createdBy;
  final List<QuoteProcessImageModel> images;
  final List<QuoteProcessVideoModel> videos;

  QuoteProcessModel({
    required this.processId,
    required this.designId,
    required this.message,
    this.status,
    required this.flag,
    required this.processingStatus,
    required this.createDate,
    required this.createdBy,
    required this.images,
    required this.videos,
  });

  factory QuoteProcessModel.fromJson(Map<String, dynamic> json) {
    var imagesList = (json['images'] as List?)
            ?.map((e) => QuoteProcessImageModel.fromJson(e))
            .toList() ??
        [];

    var videosList = (json['videos'] as List?)
            ?.map((e) => QuoteProcessVideoModel.fromJson(e))
            .toList() ??
        [];

    return QuoteProcessModel(
      processId: json['process_id']?.toString() ?? '',
      designId: json['design_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString(),
      flag: json['flag']?.toString() ?? '',
      processingStatus: json['processing_status']?.toString() ?? '',
      createDate: json['create_date']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      images: imagesList,
      videos: videosList,
    );
  }
}

class QuoteProcessVideoModel {
  final String imageId;
  final String processId;
  final String image;
  final String type;

  QuoteProcessVideoModel({
    required this.imageId,
    required this.processId,
    required this.image,
    required this.type,
  });

  factory QuoteProcessVideoModel.fromJson(Map<String, dynamic> json) {
    return QuoteProcessVideoModel(
      imageId: json['image_id']?.toString() ?? '',
      processId: json['process_id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  String get videoUrl {
    if (image.isEmpty) return '';
    final url = image.startsWith('http') ? image : 'https://blantonslab.com/uploads/design/$image';
    return Uri.encodeFull(url);
  }
}

class QuoteProcessImageModel {
  final String imageId;
  final String processId;
  final String image;
  final String type;

  QuoteProcessImageModel({
    required this.imageId,
    required this.processId,
    required this.image,
    required this.type,
  });

  factory QuoteProcessImageModel.fromJson(Map<String, dynamic> json) {
    return QuoteProcessImageModel(
      imageId: json['image_id']?.toString() ?? '',
      processId: json['process_id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  String get imageUrl {
    if (image.isEmpty) return '';
    final url = image.startsWith('http') ? image : 'https://blantonslab.com/uploads/design/$image';
    return Uri.encodeFull(url);
  }
}
