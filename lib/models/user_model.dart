class UserModel {
  final String userId;
  final String userFullname;
  final String userFirstname;
  final String userLastname;
  final String userEmail;
  final String userMobile;
  final String userActive;
  final String userType;

  UserModel({
    required this.userId,
    required this.userFullname,
    required this.userFirstname,
    required this.userLastname,
    required this.userEmail,
    required this.userMobile,
    required this.userActive,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      userFullname: json['user_fullname']?.toString() ?? '',
      userFirstname: json['user_firstname']?.toString() ?? '',
      userLastname: json['user_lastname']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      userMobile: json['user_mobile']?.toString() ?? '',
      userActive: json['user_active']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_fullname': userFullname,
      'user_firstname': userFirstname,
      'user_lastname': userLastname,
      'user_email': userEmail,
      'user_mobile': userMobile,
      'user_active': userActive,
      'user_type': userType,
    };
  }
}
