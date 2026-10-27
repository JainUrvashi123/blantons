import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/profile_model.dart';
import 'components/custom_text_field.dart';
import 'components/custom_phone_field.dart';
import '../services/update_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _fullPhoneNumber = '';
  final _emailController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isChangePassword = false;
  ProfileModel? _profile;

  bool _hasUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    final hasUpdate = await UpdateService().isUpdateAvailable();
    if (mounted) {
      setState(() {
        _hasUpdate = hasUpdate;
      });
    }
  }

  Map<String, bool> _passwordVisibility = {
    'Current Password *': false,
    'New Password *': false,
    'Confirm Password *': false,
  };

  Future<void> _fetchProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profile = await authViewModel.fetchProfile();

    if (mounted) {
      if (profile != null) {
        setState(() {
          _profile = profile;
          _firstNameController.text = profile.firstname;
          _lastNameController.text = profile.lastname;
          _phoneController.text = profile.phone;
          _fullPhoneNumber = profile.phone;
          _emailController.text = profile.email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Failed to load profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryButton))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24.0),
                child: Column(
                  children: [
                    if (_hasUpdate) ...[
                      _buildUpdateBanner(context),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 32.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildToggle('PROFILE INFO', !_isChangePassword, () {
                        setState(() => _isChangePassword = false);
                      }),
                      const SizedBox(width: 10),
                      _buildToggle('CHANGE PASSWORD', _isChangePassword, () {
                        setState(() => _isChangePassword = true);
                      }),
                    ],
                  ),

                  // const SizedBox(height: 10),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF0A74F),
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   child: Text(
                  //     _isChangePassword ? 'CHANGE PASSWORD' : 'PROFILE INFO',
                  //     style: GoogleFonts.poppins(
                  //       color: Colors.white,
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w600,
                  //       letterSpacing: 1.2,
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 48),

                  _isChangePassword ? _buildPasswordFields() : _buildProfileFields(),

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton('UPDATE', _isChangePassword ? _handleChangePassword : _handleUpdateProfile),
                      const SizedBox(width: 24),
                      _buildActionButton('CANCEL', () {
                        if (_isChangePassword) {
                          setState(() => _isChangePassword = false);
                        } else {
                          Navigator.pop(context);
                        }
                      }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildProfileFields() {
    return Column(
      children: [
        _buildProfileField('First Name *', _firstNameController),
        const SizedBox(height: 24),
        _buildProfileField('Last Name', _lastNameController),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone No*',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            CustomPhoneField(
              controller: _phoneController,
              hintText: 'Phone No*',
              onChanged: (val) {
                _fullPhoneNumber = val;
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildProfileField('Email*', _emailController, enabled: false),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildProfileField('Current Password *', _currentPasswordController),
        const SizedBox(height: 24),
        _buildProfileField('New Password *', _newPasswordController),
        const SizedBox(height: 24),
        _buildProfileField('Confirm Password *', _confirmPasswordController),
      ],
    );
  }

  Widget _buildToggle(String title, bool isSelected, VoidCallback onTap) {
    return Expanded( // Added Expanded to fill available space
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center, // Center text within the expanded area
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryButton : Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, {bool enabled = true}) {
    final isPassword = label.toLowerCase().contains('password');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          readOnly: !enabled,
          obscureText: isPassword ? !_passwordVisibility[label]! : false,
          hintText: label,
          suffixIcon: isPassword
              ? (_passwordVisibility[label]! ? Icons.visibility : Icons.visibility_off)
              : null,
          onSuffixTap: isPassword
              ? () {
                  setState(() {
                    _passwordVisibility[label] = !_passwordVisibility[label]!;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 120,
        height: 45,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              left: 4,
              top: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 4,
              bottom: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryButton,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdateProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobile: _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : _phoneController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Profile updated successfully" : "Update failed"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Password changed successfully" : "Failed"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildUpdateBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            UpdateService().launchStore();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Available',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Enjoy a more seamless shopping experience',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'New',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFF05A7E),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


