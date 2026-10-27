import 'package:blantons/viewmodels/jewelry_viewmodel.dart';
import 'package:blantons/views/faq_view.dart';
import 'package:blantons/views/jewelry_view.dart';
import 'package:blantons/views/custom_jewelry_view.dart';
import 'package:blantons/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/global_loader_provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/wishlist_viewmodel.dart';
import 'views/login_view.dart';
import 'views/profile_view.dart';
import 'views/main_layout_view.dart';
import 'views/wishlist_view.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/custom_design_viewmodel.dart';
import 'views/cart_view.dart';
import 'viewmodels/quote_viewmodel.dart';
import 'views/quotes_view.dart';
import 'viewmodels/contact_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'views/search_view.dart';
import 'views/terms_conditions_view.dart';
import 'views/new_arrival_view.dart';
import 'views/gallery_view.dart';
import 'package:blantons/views/my_cad_view.dart';
import 'package:blantons/views/admin_enquiries_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/push_notification_service.dart';
import 'viewmodels/my_files_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'views/notification_list_view.dart';

import 'package:flutter/services.dart';
import 'core/navigation/navigator_service.dart';
import 'core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  await PushNotificationService().initialize();
  await DioClient.initCookies();


  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalLoaderProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => JewelryViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => CustomDesignViewModel()),
        ChangeNotifierProvider(create: (_) => QuoteViewModel()),
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, MyFilesViewModel>(
          create: (_) => MyFilesViewModel(),
          update: (_, auth, myFiles) {
            myFiles!.updateUserId(auth.user?.userId);
            return myFiles;
          },
        ),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorService.navigatorKey,
      title: 'Blantons',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryButton,
        scaffoldBackgroundColor: AppColors.background,
          fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primaryButton,
          secondary: AppColors.primaryButton,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryButton,
          selectionColor: AppColors.primaryButton.withOpacity(0.3),
          selectionHandleColor: AppColors.primaryButton,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black87),
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: '/',
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Consumer<GlobalLoaderProvider>(
              builder: (context, loader, _) {
                if (loader.isLoading) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            color: AppColors.primaryButton,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
      routes: {
        '/': (context) => const SplashView(),
        '/login': (context) => const LoginView(),
        '/home': (context) => const MainLayoutView(),
        '/profile': (context) => const ProfileView(),
        '/jewelry': (context) => const CustomJewelryView(),
        '/custom_jewelry': (context) => const CustomJewelryView(),
        '/wishlist': (context) => const WishlistView(),
        '/cart': (context) => const CartView(),
        '/quotes': (context) => const QuotesView(),
        '/search': (context) => const SearchView(),
        '/terms_conditions': (context) => const TermsConditionsView(),
        '/faq': (context) => const FaqView(),
        '/new_arrival': (context) => const NewArrivalView(),
        '/gallery': (context) => const GalleryView(),
        '/my_cad': (context) => const MyCadView(),
        '/admin_enquiries': (context) => const AdminEnquiriesView(),
        '/notifications': (context) => const NotificationListView(),
      },
      // home: const LoginView(),
    );
  }

}







