import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/providers/global_loader_provider.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';
import 'components/video_background.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final globalLoader = Provider.of<GlobalLoaderProvider>(context, listen: false);
    
    globalLoader.show();
    final successMessage = await viewModel.forgotPassword(email);
    globalLoader.hide();

    if (successMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Navigator.pop(context); // Go back to login
    } else if (mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
             children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const Spacer(),
                              Image.asset(
                                AppAssets.logoEmail,
                                height: 40,
                                width: 140,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Text(
                                  'BLANTONS',
                                  style: GoogleFonts.cormorantUpright(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // TextButton(
                              //   onPressed: () {
                              //      Navigator.pop(context);
                              //   },
                              //   child: const Text('Sign In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                              // ),
                              const SizedBox(width: 48), // To balance the back button on the left
                            ],
                          ),
                        ),
                        // Space before card
                        const SizedBox(height: 20),
                        // Centered Card
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 400),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Forgot Password',
                                          style: GoogleFonts.cormorantUpright(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Enter your email to get password',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        CustomTextField(
                                          controller: _emailController,
                                          hintText: 'Enter Your Email',
                                          prefixIcon: Icons.person_outline,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 24),
                                        Consumer<AuthViewModel>(
                                          builder: (context, viewModel, child) {
                                            return CustomButton(
                                              text: 'SUBMIT',
                                              isLoading: viewModel.isLoading,
                                              onPressed: _onSubmit,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
             ],
            );
          },
        ),
      ),
    );
  }
}
