import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../core/providers/global_loader_provider.dart';
import 'home_view.dart';
import 'custom_jewelry_view.dart';
import 'custom_design_view.dart';
import 'contact_view.dart';
import 'cart_view.dart';
import '../services/update_service.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

// class _MainLayoutViewState extends State<MainLayoutView> {
//   int _currentIndex = 0;
//
//   final List<Widget> _pages = [
//     const HomeView(),
//     const JewelryView(),
//     const Center(child: Text('Custom Design Coming Soon')),
//     const Center(child: Text('Contact Coming Soon')),
//     const Center(child: Text('Information Coming Soon')),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   void _showFilterBottomSheet(BuildContext context, JewelryViewModel vm) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSync) {
//             return DraggableScrollableSheet(
//               initialChildSize: 0.8,
//               minChildSize: 0.5,
//               maxChildSize: 0.95,
//               expand: false,
//               builder: (context, scrollController) {
//                 return Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Filters', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
//                           TextButton(
//                             onPressed: () {
//                               vm.clearFilters();
//                               Navigator.pop(context);
//                             },
//                             child: Text('CLEAR ALL', style: GoogleFonts.poppins(color: Colors.black)),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: vm.isLoadingFilters
//                           ? const Center(child: CircularProgressIndicator())
//                           : ListView(
//                               controller: scrollController,
//                               padding: const EdgeInsets.all(16),
//                               children: [
//                                 _buildFilterSection(
//                                   title: 'CATEGORIES',
//                                   items: vm.filterData?.categories ?? [],
//                                   selectedItems: vm.selectedCategories,
//                                   onToggle: (val) {
//                                     vm.toggleCategory(val);
//                                     setStateSync(() {});
//                                   },
//                                 ),
//                                 const Divider(),
//                                 _buildFilterSection(
//                                   title: 'METAL TYPE',
//                                   items: vm.filterData?.metalTypes ?? [],
//                                   selectedItems: vm.selectedMetals,
//                                   onToggle: (val) {
//                                     vm.toggleMetal(val);
//                                     setStateSync(() {});
//                                   },
//                                 ),
//                                 const Divider(),
//                                 _buildFilterSection(
//                                   title: 'STONE SHAPE',
//                                   items: vm.filterData?.stoneShapes ?? [],
//                                   selectedItems: vm.selectedShapes,
//                                   onToggle: (val) {
//                                     vm.toggleShape(val);
//                                     setStateSync(() {});
//                                   },
//                                 ),
//                                 const SizedBox(height: 80),
//                               ],
//                             ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
//                       ),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const AppColors.primaryButton,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: () {
//                             vm.applyFilters();
//                             Navigator.pop(context);
//                           },
//                           child: Text('APPLY FILTERS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildFilterSection({
//     required String title,
//     required List<String> items,
//     required List<String> selectedItems,
//     required Function(String) onToggle,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 0,
//           children: items.map((item) {
//             final isSelected = selectedItems.contains(item);
//             return FilterChip(
//               label: Text(item, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
//               selected: isSelected,
//               onSelected: (_) => onToggle(item),
//               selectedColor: const AppColors.primaryButton,
//               checkmarkColor: Colors.white,
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 2,
//         shadowColor: Colors.black12,
//         iconTheme: const IconThemeData(color: Colors.black),
//         title: Image.asset(AppAssets.logoEmail, height: 40, fit: BoxFit.contain),
//         centerTitle: true,
//         actions: [
//           if (_currentIndex == 1)
//             Consumer<JewelryViewModel>(
//               builder: (context, vm, _) {
//                 return IconButton(
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: () => _showFilterBottomSheet(context, vm),
//                 );
//               },
//             ),
//           Consumer<AuthViewModel>(
//             builder: (context, authViewModel, child) {
//               final user = authViewModel.user;
//               if (user != null) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8.0),
//                   child: PopupMenuButton<String>(
//                     offset: const Offset(0, 45),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     color: Colors.white,
//                     elevation: 4,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.person_outline, color: Colors.black87),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${user.userFirstname.isNotEmpty ? user.userFirstname[0].toUpperCase() : ''}${user.userLastname.isNotEmpty ? user.userLastname[0].toUpperCase() : ''}',
//                           style: GoogleFonts.poppins(
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const Icon(Icons.arrow_drop_down, color: Colors.black87),
//                       ],
//                     ),
//                     onSelected: (value) async {
//                       if (value == 'logout') {
//                         await authViewModel.logout();
//                       } else if (value == 'profile') {
//                         Navigator.pushNamed(context, '/profile');
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                       PopupMenuItem<String>(
//                         value: 'profile',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.person_outline, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text(
//                               user.userFullname.isNotEmpty ? user.userFullname : '${user.userFirstname} ${user.userLastname}'.trim(),
//                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       PopupMenuItem<String>(
//                         value: 'compare',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.compare_arrows_outlined, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text('Compare', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                       PopupMenuItem<String>(
//                         value: 'quotes',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.format_quote_outlined, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text('My Quotes', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuDivider(),
//                       PopupMenuItem<String>(
//                         value: 'logout',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.logout_outlined, size: 20, color: Colors.black54),
//                             const SizedBox(width: 12),
//                             Text('Logout', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return IconButton(
//                 icon: const Icon(Icons.person_outline),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/login');
//                 },
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.favorite_border_outlined),
//             onPressed: () {
//               Navigator.pushNamed(context, '/wishlist');
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.shopping_bag_outlined),
//             onPressed: () {
//               Navigator.pushNamed(context, '/cart');
//             },
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: const AppColors.primaryButton,
//         unselectedItemColor: Colors.black54,
//         selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
//         unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.diamond_outlined),
//             activeIcon: Icon(Icons.diamond),
//             label: 'Jewelry',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.design_services_outlined),
//             activeIcon: Icon(Icons.design_services),
//             label: 'Custom',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.contact_mail_outlined),
//             activeIcon: Icon(Icons.contact_mail),
//             label: 'Contact',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.info_outline),
//             activeIcon: Icon(Icons.info),
//             label: 'Info',
//           ),
//         ],
//       ),
//     );
//   }
class _MainLayoutViewState extends State<MainLayoutView> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _hasUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCounts();
      _startRefreshTimer();
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchCounts();
      _startRefreshTimer();
      _checkForUpdate();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchCounts();
    });
  }

  void _fetchCounts() {
    if (!mounted) return;
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
    if (auth.user != null) {
      Provider.of<NotificationViewModel>(context, listen: false).fetchNotifications(auth.user!.userId);
      if (auth.user!.userType == '1') {
        quoteVM.fetchAdminDesigns(auth);
      } else {
        quoteVM.fetchQuotes(auth);
        quoteVM.fetchMyOrders(auth);
        quoteVM.fetchCompletedOrders(auth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final user = auth.user;
    final isAdmin = user?.userType == '1';

    // Clamp _currentIndex to prevent index out of range when switching layout modes
    final int maxIndex = isAdmin ? 2 : 3;
    if (_currentIndex > maxIndex) {
      _currentIndex = maxIndex;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: _currentIndex == 0,
      appBar: AppBar(
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _currentIndex = 0);
                },
              )
            : null,
        backgroundColor: Colors.white,
        elevation: _currentIndex == 0 ? 0 : null,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: _currentIndex == 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?.userType == '1' ? 'admin' : 'DashBoard',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (user?.userType != '1') ...[
                    const SizedBox(height: 1),
                    Text(
                      '(Retailer side )',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              )
            : Image.asset(AppAssets.logoEmail, height: 35, fit: BoxFit.contain),
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cartVM, _) {
              final cartCount = cartVM.cartItems.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.black87),
                    tooltip: 'Shopping Cart',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartView()),
                      );
                    },
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryButton,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<NotificationViewModel>(
            builder: (context, notificationVM, _) {
                final totalUnread = notificationVM.unreadCount;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, size: 24, color: Colors.black87),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                    if (totalUnread > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$totalUnread',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          _buildProfileButton(context),
        ],
      ),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(onNavigate: (index) {
            setState(() => _currentIndex = index);
            _fetchCounts();
          }),
          const CustomJewelryView(showAppBar: false),
          if (!isAdmin)
            CustomDesignView(
              showAppBar: false,
              onNavigate: (index) {
                setState(() => _currentIndex = index);
                _fetchCounts();
              },
            ),
          ContactView(
            onNavigate: (index) {
              setState(() => _currentIndex = index);
              _fetchCounts();
            },
          ),
        ],
      ),
      bottomNavigationBar: isAdmin
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                _fetchCounts();
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primaryButton,
              unselectedItemColor: Colors.black45,
              showUnselectedLabels: true,
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), label: 'Jewelry'),
                BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'Custom'),
                BottomNavigationBarItem(icon: Icon(Icons.phone_in_talk_outlined), label: 'Contact'),
              ],
            ),
    );
  }


  Widget _buildProfileButton(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        final user = auth.user;
        if (user != null) {
          final firstLetter = user.userFirstname.isNotEmpty 
              ? user.userFirstname[0].toUpperCase() 
              : 'U';
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryButton.withOpacity(0.1),
                child: Text(
                  firstLetter,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryButton,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }


  void _showFilterBottomSheet(BuildContext context, JewelryViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSync) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              vm.clearFilters();
                              Navigator.pop(context);
                            },
                            child: Text('CLEAR ALL', style: GoogleFonts.poppins(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: vm.isLoadingFilters
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildFilterSection(
                            title: 'CATEGORIES',
                            items: vm.filterData?.categories ?? [],
                            selectedItems: vm.selectedCategories,
                            onToggle: (val) {
                              vm.toggleCategory(val);
                              setStateSync(() {});
                            },
                          ),
                          const Divider(),
                          _buildFilterSection(
                            title: 'METAL TYPE',
                            items: vm.filterData?.metalTypes ?? [],
                            selectedItems: vm.selectedMetals,
                            onToggle: (val) {
                              vm.toggleMetal(val);
                              setStateSync(() {});
                            },
                          ),
                          const Divider(),
                          _buildFilterSection(
                            title: 'STONE SHAPE',
                            items: vm.filterData?.stoneShapes ?? [],
                            selectedItems: vm.selectedShapes,
                            onToggle: (val) {
                              vm.toggleShape(val);
                              setStateSync(() {});
                            },
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  AppColors.primaryButton,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            vm.applyFilters();
                            Navigator.pop(context);
                          },
                          child: Text('APPLY FILTERS', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Account',
            style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'This action is permanent and cannot be undone. All your data will be permanently removed.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final success = await authViewModel.deleteAccount();
                if (success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deleted successfully')),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authViewModel.errorMessage ?? 'Failed to delete account')),
                    );
                  }
                }
              },
              child: Text(
                'DELETE',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'CANCEL',
                style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
                final wishlistViewModel = Provider.of<WishlistViewModel>(context, listen: false);
                final quoteViewModel = Provider.of<QuoteViewModel>(context, listen: false);
                final globalLoader = Provider.of<GlobalLoaderProvider>(context, listen: false);

                Navigator.pop(dialogContext);
                globalLoader.show();
                await authViewModel.logout();

                cartViewModel.clearCart();
                wishlistViewModel.clearWishlist();
                quoteViewModel.clearQuotes();
                globalLoader.hide();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              child: Text(
                'LOGOUT',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item, style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              onSelected: (_) => onToggle(item),
              selectedColor: AppColors.primaryButton,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Consumer<AuthViewModel>(
        builder: (authContext, auth, _) {
          final user = auth.user;
          final isAdmin = user?.userType == '1';

          final userName = user != null 
              ? (user.userFullname.isNotEmpty 
                  ? user.userFullname 
                  : '${user.userFirstname} ${user.userLastname}'.trim()) 
              : 'User';
              
          final firstLetter = user != null 
              ? (user.userFirstname.isNotEmpty ? user.userFirstname[0].toUpperCase() : 'U') 
              : 'U';

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryButton,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          firstLetter,
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryButton),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.userEmail ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              if (_hasUpdate) ...[
                const SizedBox(height: 12),
                _buildUpdateBanner(context),
              ],

              const SizedBox(height: 10),

              // Drawer Items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                      children: [
                        _drawerTile(Icons.person_outline_rounded, 'My Profile', () => Navigator.pushNamed(context, '/profile')),
                        Consumer<NotificationViewModel>(
                          builder: (context, notificationVM, _) {
                            final count = notificationVM.unreadCount;
                            return _drawerTile(
                              Icons.notifications_outlined,
                              'Notifications',
                              () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/notifications');
                              },
                              trailing: count > 0
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                        // _drawerTile(Icons.favorite_border_rounded, 'Wishlist', () => Navigator.pushNamed(context, '/wishlist')),
                        if (!isAdmin)
                          Consumer<QuoteViewModel>(
                            builder: (quoteContext, quoteVM, _) {
                              final count = quoteVM.unreadQuotesCount;
                              return _drawerTile(
                                Icons.format_quote_rounded,
                                'My Quotes',
                                () => Navigator.pushNamed(context, '/quotes'),
                                trailing: count > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        if (isAdmin)
                          Consumer<QuoteViewModel>(
                            builder: (quoteContext, quoteVM, _) {
                              final count = quoteVM.unreadAdminEnquiriesCount;
                              return _drawerTile(
                                Icons.admin_panel_settings_rounded,
                                'Design Enquiries',
                                () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/admin_enquiries');
                                },
                                trailing: count > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        _drawerTile(Icons.delete_forever_outlined, 'Delete Account', () {
                          Navigator.pop(context);
                          _showDeleteAccountDialog(context, auth);
                        }),

        
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Divider(color: Colors.grey[200], thickness: 1),
                      ),
                      
                      _drawerTile(Icons.help_outline_rounded, 'FAQ', () {
                        Navigator.pushNamed(context, '/faq');
                      }),
                      _drawerTile(Icons.policy_outlined, 'Terms & Conditions', () => Navigator.pushNamed(context, '/terms_conditions')),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),


              if (user != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context, auth);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Logout', 
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryButton.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryButton, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 20),
        onTap: onTap,
        dense: true,
        hoverColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildUpdateBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
