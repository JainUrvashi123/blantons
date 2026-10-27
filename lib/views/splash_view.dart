import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../core/constants/app_assets.dart';
import '../services/update_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });
  }

  Future<void> _navigateToNext() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1000)),
      authViewModel.checkAutoLogin(),
    ]);

    if (mounted) {
      final proceed = await UpdateService().checkAndShowUpdateDialog(context);
      if (!proceed) return; // Blocked by forced update

      if (mounted) {
        if (authViewModel.user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            // child: Image.asset(
            //   'assets/images/idca-logo.svg', // We assume the user drops the PNG here
            //   width: 250,
            //   // errorBuilder: (context, error, stackTrace) {
            //   //   // Fallback if the logo file doesn't exist yet
            //   //   return Column(
            //   //     mainAxisSize: MainAxisSize.min,
            //   //     children: [
            //   //       Text('IDCA', style: AppTextStyles.heading1.copyWith(fontSize: 48, color: AppColors.primaryGold)),
            //   //       const SizedBox(height: 10),
            //   //       Text('INDIAN DIAMOND &\nCOLORSTONE ASSOCIATION',
            //   //         textAlign: TextAlign.center,
            //   //         style: AppTextStyles.labelText.copyWith(color: AppColors.textGrey, letterSpacing: 1.5),
            //   //       ),
            //   //       const SizedBox(height: 20),
            //   //
            //   //     ],
            //   //   );
            //   // },
            // ),
            child: Image.asset(AppAssets.logoEmail,  width: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(
              'BLANTONS',
              style: GoogleFonts.cormorantUpright(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
