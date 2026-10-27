import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../viewmodels/custom_design_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'components/custom_text_field.dart';
import 'package:flutter/services.dart';
import 'components/custom_phone_field.dart';

class CustomDesignView extends StatefulWidget {
  final bool showAppBar;
  final Function(int)? onNavigate;
  const CustomDesignView({Key? key, this.showAppBar = true, this.onNavigate}) : super(key: key);

  @override
  State<CustomDesignView> createState() => _CustomDesignViewState();
}

class _CustomDesignViewState extends State<CustomDesignView> {
   bool _isSubmitted = false;
   bool _showContactInfo = false;
   final _companyController = TextEditingController();
   final _fullNameController = TextEditingController();
   final _emailController = TextEditingController();
   final _phoneController = TextEditingController();
   String _fullPhoneNumber = '';
   final _referenceController = TextEditingController();
 
   final _projectDescController = TextEditingController();
   final _timeframeController = TextEditingController();
   final _fingerSizeController = TextEditingController();
   final _nbLengthController = TextEditingController();
   final _centerShapeController = TextEditingController();
   final _supplyStoneDetailsController = TextEditingController();
 
   // State variables for dropdown selections and radio buttons
   String? _selectedMetal;
   String? _selectedMetalColor;
   String _supplyStone = 'no';
 
   // Dropdown options
   final List<String> _timeframeOptions = ['1 week', '2 week'];
   final List<String> _fingerSizeOptions = [
     '4', '4.5', '5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12'
   ];
   final List<String> _metalOptions = ['10k', '14k', '18k', 'Platinum'];
   final List<String> _metalColorOptions = ['White Gold', 'Yellow Gold', 'Rose Gold'];
   final List<String> _nbLengthOptions = [
     '6', '6.5', '7', '7.5', '8', '8.5',
     '14', '16', '18', '20', '22', '24', '30', '36'
   ];

  bool _isVerified = false;
  bool _isVerifyingCaptcha = false;
  
  final List<File> _pickedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
    });
    _fullNameController.addListener(_onContactFieldChanged);
    _phoneController.addListener(_onContactFieldChanged);
    _emailController.addListener(_onContactFieldChanged);
  }

  void _onContactFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _prefillUserData() async {
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVm.user;
    if (user != null) {
      setState(() {
        if (_fullNameController.text.isEmpty) {
          final fullName = user.userFullname.isNotEmpty
              ? user.userFullname
              : '${user.userFirstname} ${user.userLastname}'.trim();
          _fullNameController.text = fullName;
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = user.userEmail;
        }
        if (_phoneController.text.isEmpty) {
          _phoneController.text = user.userMobile;
          _fullPhoneNumber = user.userMobile;
        }
      });

      try {
        final profile = await authVm.fetchProfile();
        if (profile != null && mounted) {
          setState(() {
            if (_companyController.text.isEmpty && profile.company.isNotEmpty) {
              _companyController.text = profile.company;
            }
            if (profile.firstname.isNotEmpty || profile.lastname.isNotEmpty) {
              final fullName = '${profile.firstname} ${profile.lastname}'.trim();
              if (fullName.isNotEmpty) {
                _fullNameController.text = fullName;
              }
            }
            if (profile.email.isNotEmpty) {
              _emailController.text = profile.email;
            }
            if (profile.phone.isNotEmpty) {
              _phoneController.text = profile.phone;
              _fullPhoneNumber = profile.phone;
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading user profile: $e');
      }

      if (mounted) {
        final hasName = _fullNameController.text.trim().isNotEmpty;
        final hasEmail = _emailController.text.trim().isNotEmpty;
        final hasPhone = _phoneController.text.trim().isNotEmpty || _fullPhoneNumber.trim().isNotEmpty;
        final hasCompany = _companyController.text.trim().isNotEmpty;

        setState(() {
          _showContactInfo = !(hasName && hasEmail && hasPhone && hasCompany);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _showContactInfo = true;
        });
      }
    }
  }



  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload File(s)'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickCameraPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        if (!mounted) return;
        setState(() {
          _pickedFiles.addAll(result.paths.where((path) => path != null).map((path) => File(path!)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickCameraPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        if (!mounted) return;
        setState(() {
          _pickedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onContactFieldChanged);
    _phoneController.removeListener(_onContactFieldChanged);
    _emailController.removeListener(_onContactFieldChanged);
    _companyController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _referenceController.dispose();
    _projectDescController.dispose();
    _timeframeController.dispose();
    _fingerSizeController.dispose();
    _nbLengthController.dispose();
    _centerShapeController.dispose();
    _supplyStoneDetailsController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final company = _companyController.text.trim();
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : _phoneController.text.trim();
    final projectDesc = _projectDescController.text.trim();
    final reference = _referenceController.text.trim();

    if (company.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty || projectDesc.isEmpty || reference.isEmpty) {
      if (company.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty) {
        setState(() {
          _showContactInfo = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)'), backgroundColor: Colors.red),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _showContactInfo = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: Colors.red),
      );
      return;
    }

    final phoneRegex = RegExp(r'^[\+\(\)\s\-0-9]{10,}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _showContactInfo = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify that you are not a robot.'), backgroundColor: Colors.red),
      );
      return;
    }

    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    if (authVm.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit custom design request.'), backgroundColor: Colors.red),
      );
      return;
    }

    final customDesignVm = Provider.of<CustomDesignViewModel>(context, listen: false);

    // Format message to include Customer Supply Stone info
    final formattedMsg = [
      projectDesc,
      "",
      "Customer Supply Stone: ${_supplyStone.toUpperCase()}",
      if (_supplyStone == 'yes' && _supplyStoneDetailsController.text.trim().isNotEmpty)
        "Supply Stone Details: ${_supplyStoneDetailsController.text.trim()}",
    ].join("\n");

    final success = await customDesignVm.submitDesignForm(
      userId: authVm.user!.userId,
      name: name,
      company: company,
      email: email,
      contact: phone,
      msg: formattedMsg,
      frame: _timeframeController.text.trim(),
      budget: '', 
      referenceNumber: _referenceController.text.trim(),
      size: _fingerSizeController.text.trim(),
      metal: _selectedMetal ?? '',
      matchingPair: _supplyStone,
      nbLength: _nbLengthController.text.trim(),
      metalColor: _selectedMetal != null ? (_selectedMetalColor ?? '') : '',
      centerDiamond: _centerShapeController.text.trim(),
      customerStoneDetails: _supplyStone == 'yes' ? _supplyStoneDetailsController.text.trim() : 'No',
      imagePaths: _pickedFiles.map((e) => e.path).toList(),
    );

    if (!mounted) return;

    if (success) {
      // Instantly refresh dashboard counts and lists on successful submit
      try {
        final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
        quoteVM.fetchQuotes(authVm);
        quoteVM.fetchMyOrders(authVm);
        quoteVM.fetchCompletedOrders(authVm);
        Provider.of<NotificationViewModel>(context, listen: false).fetchNotifications(authVm.user!.userId);
      } catch (e) {
        debugPrint('Error re-fetching lists after custom design submit: $e');
      }

      _companyController.clear();
      _fullNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _fullPhoneNumber = '';
      _referenceController.clear();
      _projectDescController.clear();
      _timeframeController.clear();
      _fingerSizeController.clear();
      _nbLengthController.clear();
      _centerShapeController.clear();
      _supplyStoneDetailsController.clear();
      setState(() {
        _isSubmitted = true;
        _selectedMetal = null;
        _selectedMetalColor = null;
        _supplyStone = 'no';
        _pickedFiles.clear();
        _isVerified = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(customDesignVm.errorMessage ?? 'Failed to submit request.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar ? AppBar(
        title: Text(_isSubmitted ? 'Confirmation' : 'Custom Design'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSubmitted) {
              setState(() {
                _isSubmitted = false;
              });
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          },
        ),
      ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24.0),
        child: _isSubmitted
            ? _buildThankYouSection()
            : Column(
                children: [
                  // _buildHeaderSection(),
                  // const SizedBox(height: 24),
                  _buildContactInfoSection(),
                  const SizedBox(height: 24),
                  _buildProjectDetailsSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Design With Us',
            style: GoogleFonts.cormorantUpright(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 80,
            color: AppColors.primaryButton, // Small underline as in design
          ),
          const SizedBox(height: 20),
          Text(
            'Choosing Blantons means choosing a personalized experience where your ideas and values are at the forefront of our design process. Our expert team is here to guide you through every step, from the initial concept to the final creation. Design your dream engagement ring, pendant, earring or necklace with Blantons today. Explore our custom options, including CAD designs and reused diamonds to create a unique and meaningful piece that will last a lifetime. Your perfect jewelry piece awaits; contact us now to start your journey!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    final name = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    String summaryText = '';
    if (name.isNotEmpty) summaryText += name;
    if (phone.isNotEmpty) {
      if (summaryText.isNotEmpty) summaryText += '  •  ';
      summaryText += phone;
    } else if (email.isNotEmpty) {
      if (summaryText.isNotEmpty) summaryText += '  •  ';
      summaryText += email;
    }
    if (summaryText.isEmpty) {
      summaryText = 'Tap to enter contact details';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _showContactInfo = !_showContactInfo;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButton.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primaryButton,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Name & Contact Info',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!_showContactInfo && name.isNotEmpty && email.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Prefilled',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _showContactInfo ? 'Review or edit your details' : summaryText,
                              key: ValueKey<String>('${_showContactInfo}_$summaryText'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _showContactInfo ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryButton,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 20),
                    _buildLabeledTextField('Company/Organization*', _companyController),
                    _buildLabeledTextField('Full Name*', _fullNameController),
                    _buildLabeledTextField('Email Address*', _emailController, keyboardType: TextInputType.emailAddress),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number*',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomPhoneField(
                            controller: _phoneController,
                            hintText: '',
                            onChanged: (val) {
                              _fullPhoneNumber = val;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _showContactInfo ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptchaSection() {
    return GestureDetector(
      onTap: () async {
        if (_isVerified || _isVerifyingCaptcha) return;

        setState(() => _isVerifyingCaptcha = true);
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          setState(() {
            _isVerifyingCaptcha = false;
            _isVerified = true;
          });
        }
      },
      child: Container(
        height: 74,
        width: 300,
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
                        color: _isVerified ? Colors.transparent : const Color(0xFFC1C1C1),
                        width: 2
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: _isVerifyingCaptcha
                      ? const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )
                      : _isVerified ? const Center(child: Icon(Icons.check, size: 24, color: Colors.green)) : null,
                ),
                const SizedBox(width: 12),
                const Text(
                    "I'm not a robot",
                    style: TextStyle(fontSize: 14, color: Color(0xFF222222), fontWeight: FontWeight.w500)
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://www.gstatic.com/recaptcha/api2/logo_48.png',
                  width: 32,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.sync, color: Colors.blue.shade600, size: 28),
                ),
                const SizedBox(height: 4),
                const Text('reCAPTCHA', style: TextStyle(fontSize: 10, color: Color(0xFF555555))),
                const SizedBox(height: 2),
                const Text('Privacy - Terms', style: TextStyle(fontSize: 8, color: Color(0xFF555555))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us about your project',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildLabeledTextField(
            'Reference # or Job Name*',
            _referenceController,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]'))],
          ),
          _buildLabeledTextField('Please tell us about your project*', _projectDescController),
          // Timeframe editable dropdown
          _buildEditableDropdownField(
            label: 'What is your timeframe?',
            controller: _timeframeController,
            options: _timeframeOptions,
          ),

          // Finger Size editable dropdown
          _buildEditableDropdownField(
            label: 'Finger Size',
            controller: _fingerSizeController,
            options: _fingerSizeOptions,
          ),

          // Metal dropdown
          _buildLabeledDropdownField<String>(
            label: 'Metal',
            value: _selectedMetal,
            items: _metalOptions.map((opt) => DropdownMenuItem(
              value: opt,
              child: Text(opt),
            )).toList(),
            onChanged: (val) {
              setState(() {
                _selectedMetal = val;
                if (val == 'Platinum') {
                  _selectedMetalColor = null;
                }
              });
            },
          ),
          
          // Conditional Metal Color dropdown (only show for Gold options, not Platinum)
          if (_selectedMetal != null && _selectedMetal != 'Platinum')
            _buildLabeledDropdownField<String>(
              label: 'Metal Color',
              value: _selectedMetalColor,
              items: _metalColorOptions.map((opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMetalColor = val;
                });
              },
            ),

          // Bracelet/Necklace length editable dropdown
          _buildEditableDropdownField(
            label: 'Bracelet/Necklace length',
            controller: _nbLengthController,
            options: _nbLengthOptions,
          ),

          _buildLabeledTextField('Center shape/size', _centerShapeController),

          // Customer supply stone radio buttons
          _buildCustomerSupplyStoneRadioField(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<CustomDesignViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showImageSourceActionSheet,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  'Upload File',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (_pickedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _pickedFiles.map((file) {
                    final ext = file.path.split('.').last.toLowerCase();
                    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
                    
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: isImage
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.insert_drive_file, color: Colors.grey, size: 32),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(
                                        file.path.split(Platform.pathSeparator).last,
                                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedFiles.remove(file);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                            ),
                          ),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildCaptchaSection(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send Your Project',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: '',
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableDropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> options,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            controller: controller,
            requestFocusOnTap: true,
            expandedInsets: EdgeInsets.zero,
            menuHeight: 250,
            hintText: hintText,
            textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            trailingIcon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(4),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
              ),
            ),
            dropdownMenuEntries: options.map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry<String>(
                value: value,
                label: value,
                style: MenuItemButton.styleFrom(
                  textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<T>(
            initialSelection: value,
            expandedInsets: EdgeInsets.zero,
            menuHeight: 250,
            hintText: hintText,
            textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            trailingIcon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(4),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
              ),
            ),
            onSelected: onChanged,
            dropdownMenuEntries: items.map<DropdownMenuEntry<T>>((DropdownMenuItem<T> item) {
              String labelText = '';
              if (item.child is Text) {
                labelText = (item.child as Text).data ?? '';
              } else {
                labelText = item.value?.toString() ?? '';
              }
              return DropdownMenuEntry<T>(
                value: item.value as T,
                label: labelText,
                style: MenuItemButton.styleFrom(
                  textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSupplyStoneRadioField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Supply Stone?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'yes',
                    groupValue: _supplyStone,
                    activeColor: AppColors.primaryButton,
                    onChanged: (value) {
                      setState(() {
                        _supplyStone = value!;
                      });
                    },
                  ),
                  Text(
                    'Yes',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Radio<String>(
                    value: 'no',
                    groupValue: _supplyStone,
                    activeColor: AppColors.primaryButton,
                    onChanged: (value) {
                      setState(() {
                        _supplyStone = value!;
                      });
                    },
                  ),
                  Text(
                    'No',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          if (_supplyStone == 'yes') ...[
            const SizedBox(height: 12),
            _buildLabeledTextField(
              'Comment section (Measurement/Carat Weight)*',
              _supplyStoneDetailsController,
              maxLines: 3,
            ),
          ],
        ],
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
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryButton.withOpacity(0.05),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryButton.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryButton,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Thank You!',
                style: GoogleFonts.cormorantUpright(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryButton,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Request Submitted Successfully',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for giving us the opportunity to service your company for custom design needs. Our design team will review your project details and get back to you shortly with quotes or CAD files.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/quotes');
                  },
                  icon: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 20),
                  label: Text(
                    'View My Quotes',
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
                    _prefillUserData();
                    setState(() {
                      _isSubmitted = false;
                    });
                  },
                  icon: const Icon(Icons.add, color: AppColors.primaryButton, size: 20),
                  label: Text(
                    'Submit Another Request',
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
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  if (widget.onNavigate != null) {
                    widget.onNavigate!(0);
                  } else {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }
                },
                icon: const Icon(Icons.home_outlined, color: Colors.black54, size: 18),
                label: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


