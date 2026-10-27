class ProfileModel {
  final String customerId;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String cadGalleryName;
  final String cadGalleryStatus;
  final String company;

  ProfileModel({
    required this.customerId,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.cadGalleryName,
    required this.cadGalleryStatus,
    required this.company,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      customerId: json['customer_id']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      cadGalleryName: json['cad_gallery_name']?.toString() ?? '',
      cadGalleryStatus: json['cad_gallery_status']?.toString() ?? '0',
      company: json['company']?.toString() ?? json['company_name']?.toString() ?? '',
    );
  }
}
