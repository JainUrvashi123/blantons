import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/providers/global_loader_provider.dart';
import 'components/custom_button.dart';
import 'components/custom_text_field.dart';
import 'components/video_background.dart';
import 'create_account_view.dart';
import 'forgot_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    if (savedEmail != null && savedPassword != null) {
      if (mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final globalLoader = Provider.of<GlobalLoaderProvider>(context, listen: false);
    
    globalLoader.show();
    final success = await viewModel.login(_emailController.text, _passwordController.text);
    globalLoader.hide();

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text);
        await prefs.setString('saved_password', _passwordController.text);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }
      Navigator.pushReplacementNamed(context, '/home');
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
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(AppAssets.logoEmail, height: 40, width: 140, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(
                              'BLANTONS',
                              style: GoogleFonts.cormorantUpright(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            )),
                            // TextButton(
                            //   onPressed: () {
                            //      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountView()));
                            //   },
                            //   child: const Text('Sign Up', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                            // ),
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
                                    'Login',
                                    style: GoogleFonts.cormorantUpright(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Enter your account details to sign in',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                    ),
                                  ),
                                  const SpacerWidget(height: 32),
                                  CustomTextField(
                                    controller: _emailController,
                                    hintText: 'Enter Your Email',
                                    prefixIcon: Icons.person_outline,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SpacerWidget(height: 16),
                                  CustomTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    onSuffixTap: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  const SpacerWidget(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (val) {
                                                setState(() {
                                                  _rememberMe = val ?? false;
                                                });
                                              },
                                              activeColor: AppColors.primaryButton,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Remember me', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordView()));
                                        },
                                        child: const Text('Forgot Password?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, decoration: TextDecoration.underline)),
                                      ),
                                    ],
                                  ),
                                  const SpacerWidget(height: 24),
                                  Consumer<AuthViewModel>(
                                    builder: (context, viewModel, child) {
                                      return CustomButton(
                                        text: 'SIGN IN',
                                        isLoading: viewModel.isLoading,
                                        onPressed: _onLogin,
                                      );
                                    },
                                  ),
                                  const SpacerWidget(height: 24),


                                  // const SpacerWidget(height: 24),
                                  // Row(
                                  //   children: const [
                                  //     Expanded(child: Divider()),
                                  //     Padding(
                                  //       padding: EdgeInsets.symmetric(horizontal: 16),
                                  //       child: Text('or', style: TextStyle(color: AppColors.textSecondary)),
                                  //     ),
                                  //     Expanded(child: Divider()),
                                  //   ],
                                  // ),
                                  // const SpacerWidget(height: 24),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text('Don\'t have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                      GestureDetector(
                                        onTap: () {
                                           Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountView()));
                                        },
                                        child: const Text('Create Account', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                      ),
                                    ],
                                  )
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
            );
          },
        ),
      ),
    );
  }
}

class SpacerWidget extends StatelessWidget {
  final double height;
  const SpacerWidget({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
