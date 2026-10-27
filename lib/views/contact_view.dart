import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/contact_viewmodel.dart';
import 'components/custom_text_field.dart';
import 'components/custom_phone_field.dart';

class ContactView extends StatefulWidget {
  final Function(int)? onNavigate;
  const ContactView({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  bool _isSubmitted = false;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();

  String _fullMobileNumber = '';

  bool _acceptTerms = false;
  bool _isNotRobot = false;
  bool _isVerifyingCaptcha = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept terms of use')),
        );
        return;
      }
      if (!_isNotRobot) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify you are not a robot')),
        );
        return;
      }

      final viewModel = Provider.of<ContactViewModel>(context, listen: false);
      
      final success = await viewModel.submitContactForm(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _fullMobileNumber.isNotEmpty ? _fullMobileNumber : _mobileController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Clear form
          _nameController.clear();
          _emailController.clear();
          _mobileController.clear();
          _messageController.clear();
          setState(() {
            _isSubmitted = true;
            _acceptTerms = false;
            _isNotRobot = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Failed to submit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isSubmitted ? _buildThankYouSection() : _buildFormContent(),
                const SizedBox(height: 24),
                _buildContactDetailsContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0EEFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF6B8BBE), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Get in Touch',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name Field
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),

            // Email Field
            CustomTextField(
              controller: _emailController,
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!value.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Mobile Field
            CustomPhoneField(
              controller: _mobileController,
              hintText: 'Mobile No.',
              onChanged: (val) {
                _fullMobileNumber = val;
              },
            ),
            const SizedBox(height: 14),

            // Message Field
            CustomTextField(
              controller: _messageController,
              hintText: 'Type message here...',
              prefixIcon: Icons.message_outlined,
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a message' : null,
            ),
            const SizedBox(height: 20),

            // Terms Checkbox
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() => _acceptTerms = value ?? false);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primaryButton,
                    side: const BorderSide(color: Colors.black26),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'I have read and accept ',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'terms of use',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.primaryButton,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/terms_conditions');
                            },
                        ),
                        TextSpan(
                          text: '.',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // reCAPTCHA
            GestureDetector(
              onTap: () async {
                if (_isNotRobot || _isVerifyingCaptcha) return;
                setState(() => _isVerifyingCaptcha = true);
                await Future.delayed(const Duration(milliseconds: 1000));
                if (mounted) {
                  setState(() {
                    _isVerifyingCaptcha = false;
                    _isNotRobot = true;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(3),
                  color: const Color(0xFFF9F9F9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isNotRobot ? Colors.transparent : const Color(0xFFC1C1C1),
                              width: 2,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: _isVerifyingCaptcha
                              ? const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : _isNotRobot
                                  ? const Center(child: Icon(Icons.check, size: 24, color: Colors.green))
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        const Text("I'm not a robot", style: TextStyle(fontSize: 14, color: Color(0xFF222222), fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.gstatic.com/recaptcha/api2/logo_48.png',
                          width: 32,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.sync, color: Colors.blue.shade600, size: 28),
                        ),
                        const SizedBox(height: 4),
                        const Text('reCAPTCHA', style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
                        const SizedBox(height: 2),
                        const Text('Privacy - Terms', style: TextStyle(fontSize: 8, color: Color(0xFF555555))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Send Button
            Consumer<ContactViewModel>(
              builder: (context, viewModel, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: viewModel.isLoading ? null : _submitForm,
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'SEND MESSAGE',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }




  Future<void> _openMap() async {
    const String address = '1460 John Brady Dr, Muncy, PA 17756';
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    final Uri appleMapsUrl = Uri.parse('https://maps.apple.com/?q=${Uri.encodeComponent(address)}');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map')),
        );
      }
    }
  }

  Future<void> _openEmail() async {
    final Uri emailUrl = Uri.parse('mailto:Info@blantonslab.com');
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  Future<void> _openPhone() async {
    final Uri phoneUrl = Uri.parse('tel:+15708405757');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer')),
        );
      }
    }
  }



  Widget _buildContactDetailsContent() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBEADB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headset_mic_outlined, color: Color(0xFFC78B6C), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Us',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Our team at Blantons is glad to help you out with your questions and feedback. To get in touch, fill the form above or reach us via the options below.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, height: 1.6),
          ),
          const SizedBox(height: 20),
          Text(
            'Blantons',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          _buildContactCard(
            Icons.location_on_outlined,
            '1460 JOHN BRADY DR MUNCY, PA 17756 United States',
            const Color(0xFFDCF3E8),
            const Color(0xFF67B08B),
            onTap: _openMap,
          ),
          _buildContactCard(
            Icons.access_time_rounded,
            'Monday through Friday, 10am - 6pm EST',
            const Color(0xFFE0EEFE),
            const Color(0xFF6B8BBE),
          ),
          _buildContactCard(
            Icons.email_outlined,
            'Info@blantonslab.com',
            const Color(0xFFFDE8F6),
            const Color(0xFFB577A8),
            onTap: _openEmail,
          ),
          _buildContactCard(
            Icons.phone_outlined,
            '+1 (570) 840-5757',
            const Color(0xFFEFDFFF),
            const Color(0xFF8B6CB2),
            onTap: _openPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String text, Color iconBg, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildThankYouSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButton.withOpacity(0.05),
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButton.withOpacity(0.1),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryButton,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Thank You!',
              style: GoogleFonts.cormorantUpright(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryButton,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Message Sent Successfully',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you for contacting us. We have received your inquiry and our support team will get back to you very soon!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(0);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                icon: const Icon(Icons.home_outlined, color: Colors.white, size: 20),
                label: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isSubmitted = false;
                  });
                },
                icon: const Icon(Icons.refresh, color: AppColors.primaryButton, size: 18),
                label: Text(
                  'Send Another Message',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryButton,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryButton, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
