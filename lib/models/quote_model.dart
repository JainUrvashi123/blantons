class QuoteModel {
  final String designId;
  final String company;
  final String name;
  final String email;
  final String contact;
  final String msg;
  final String frame;
  final String budget;
  final String referenceNumber;
  final String? jobNo;
  final String? po;
  final String centerDiamond;
  final String status;
  final String processingStatus;
  final String? type;
  final String? productId;
  final String? itemNo;
  final String productTitle;
  final String size;
  final String metal;
  final String? diamondWeight;
  final String? diamondClarity;
  final String? colorDiamondWeight;
  final String? engraving;
  final String createDate;
  final String createBy;
  final String editDate;
  final String editBy;
  final String isApproved;
  final String? approvedDate;
  final String image;
  final String reply;
  final String isApprovedText;
  final String? metalColor;
  final String? nbLength;
  final String? matchingPair;
  final String? customerStoneDetails;

  QuoteModel({
    required this.designId,
    required this.company,
    required this.name,
    required this.email,
    required this.contact,
    required this.msg,
    required this.frame,
    required this.budget,
    required this.referenceNumber,
    this.jobNo,
    this.po,
    required this.centerDiamond,
    required this.status,
    required this.processingStatus,
    this.type,
    this.productId,
    this.itemNo,
    required this.productTitle,
    required this.size,
    required this.metal,
    this.diamondWeight,
    this.diamondClarity,
    this.colorDiamondWeight,
    this.engraving,
    required this.createDate,
    required this.createBy,
    required this.editDate,
    required this.editBy,
    required this.isApproved,
    this.approvedDate,
    required this.image,
    required this.reply,
    required this.isApprovedText,
    this.metalColor,
    this.nbLength,
    this.matchingPair,
    this.customerStoneDetails,
  });

  factory QuoteModel.dummy(String designId) {
    return QuoteModel(
      designId: designId,
      company: '',
      name: '',
      email: '',
      contact: '',
      msg: '',
      frame: '',
      budget: '',
      referenceNumber: '',
      po: '',
      centerDiamond: '',
      status: '',
      processingStatus: '',
      productTitle: '',
      size: '',
      metal: '',
      createDate: '',
      createBy: '',
      editDate: '',
      editBy: '',
      isApproved: '',
      image: '',
      reply: '',
      isApprovedText: '',
      metalColor: '',
      nbLength: '',
      matchingPair: '',
      customerStoneDetails: '',
    );
  }

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      designId: json['design_id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      frame: json['frame']?.toString() ?? '',
      budget: json['budget']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString() ?? '',
      jobNo: json['job_no']?.toString(),
      po: json['po']?.toString(),
      centerDiamond: json['center_diamond']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      processingStatus: json['processing_status']?.toString() ?? '',
      type: json['type']?.toString(),
      productId: json['product_id']?.toString(),
      itemNo: json['item_no']?.toString(),
      productTitle: json['product_title']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      metal: json['metal']?.toString() ?? '',
      diamondWeight: json['diamond_weight']?.toString(),
      diamondClarity: json['diamond_clarity']?.toString(),
      colorDiamondWeight: json['color_diamond_weight']?.toString(),
      engraving: json['engraving']?.toString(),
      createDate: json['create_date']?.toString() ?? '',
      createBy: json['create_by']?.toString() ?? '',
      editDate: json['edit_date']?.toString() ?? '',
      editBy: json['edit_by']?.toString() ?? '',
      isApproved: json['is_approved']?.toString() ?? '',
      approvedDate: json['approved_date']?.toString(),
      image: json['image']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      isApprovedText: json['is_approved_text']?.toString() ?? '',
      metalColor: json['metal_color']?.toString(),
      nbLength: json['nb_length']?.toString(),
      matchingPair: json['matching_pair']?.toString(),
      customerStoneDetails: json['customer_stone_details']?.toString(),
    );
  }

  String get imageUrl {
    if (image.isEmpty) return '';
    final url = image.startsWith('http') ? image : 'https://blantonslab.com/uploads/design/$image';
    return Uri.encodeFull(url);
  }

  String get cleanMsg {
    if (msg.contains('Customer Supply Stone:')) {
      return msg.split('Customer Supply Stone:')[0].trim();
    }
    if (msg.contains('Supply Stone Details:')) {
      return msg.split('Supply Stone Details:')[0].trim();
    }
    return msg.trim();
  }

  String get displayMatchingPair {
    if (matchingPair != null && matchingPair!.isNotEmpty) {
      return matchingPair!;
    }
    // Fallback parsing from msg
    if (msg.contains('Customer Supply Stone:')) {
      final lines = msg.split('\n');
      for (var line in lines) {
        if (line.contains('Customer Supply Stone:')) {
          return line.split('Customer Supply Stone:')[1].trim();
        }
      }
    }
    return '';
  }

  String get displayCustomerStoneDetails {
    if (customerStoneDetails != null && customerStoneDetails!.isNotEmpty) {
      return customerStoneDetails!;
    }
    // Fallback parsing from msg
    if (msg.contains('Supply Stone Details:')) {
      final lines = msg.split('\n');
      for (var line in lines) {
        if (line.contains('Supply Stone Details:')) {
          return line.split('Supply Stone Details:')[1].trim();
        }
      }
    }
    return '';
  }
}

class QuoteResponse {
  final int recordsCount;
  final String pageLink;
  final List<QuoteModel> records;
  final int? userNotificationCount;
  final int? adminNotificationCount;

  QuoteResponse({
    required this.recordsCount,
    required this.pageLink,
    required this.records,
    this.userNotificationCount,
    this.adminNotificationCount,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    final recordsList = (json['records'] as List?)
            ?.map((e) => QuoteModel.fromJson(e))
            .toList() ??
        [];

    final int count = int.tryParse(json['records_count']?.toString() ?? '0') ?? 0;
    final int? userCount = json['user_notification_count'] != null 
        ? int.tryParse(json['user_notification_count'].toString()) 
        : null;
    final int? adminCount = json['admin_notification_count'] != null 
        ? int.tryParse(json['admin_notification_count'].toString()) 
        : null;

    return QuoteResponse(
      recordsCount: count,
      pageLink: json['page_link']?.toString() ?? '',
      records: recordsList,
      userNotificationCount: userCount,
      adminNotificationCount: adminCount,
    );
  }
}

class AdminDesignsResponse {
  final List<QuoteModel> records;
  final int? adminNotificationCount;
  final int? userNotificationCount;

  AdminDesignsResponse({
    required this.records,
    this.adminNotificationCount,
    this.userNotificationCount,
  });
}
