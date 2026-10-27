import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'cart_view.dart';
import 'components/custom_jewelry_item_card.dart';

class CustomJewelryView extends StatefulWidget {
  final bool showAppBar;
  const CustomJewelryView({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<CustomJewelryView> createState() => _CustomJewelryViewState();
}

class _CustomJewelryViewState extends State<CustomJewelryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<JewelryViewModel>(context, listen: false);
      if (vm.customCategories.isEmpty) {
        vm.fetchCustomCategories();
      }
      if (vm.customJewelryList.isEmpty && !vm.isLoadingCustomJewelry) {
        vm.fetchCustomJewelry(reset: true);
      }

      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      if (authVm.user != null) {
        final wishlistVm = Provider.of<WishlistViewModel>(context, listen: false);
        wishlistVm.fetchWishlist(authVm.user!.userId);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      final vm = Provider.of<JewelryViewModel>(context, listen: false);
      if (vm.hasMoreCustom && !vm.isLoadingMoreCustom && !vm.isLoadingCustomJewelry) {
        vm.fetchCustomJewelry();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'Custom Jewelry',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.5,
              iconTheme: const IconThemeData(color: Colors.black87),
              actions: [
                Consumer<CartViewModel>(
                  builder: (context, cartVm, child) {
                    final cartCount = cartVm.cartItems.length;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          tooltip: 'View Bag',
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
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Consumer<JewelryViewModel>(
        builder: (context, vm, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Tabs Header
              if (vm.customCategories.isNotEmpty) _buildCategoryHeader(vm),

              // Page Title Section
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
                child: Text(
                  'Custom Jewelry List',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: _buildGridContent(vm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(JewelryViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: vm.customCategories.length,
        itemBuilder: (context, index) {
          final cat = vm.customCategories[index];
          final bool isSelected = vm.selectedCustomCategory == cat.categoryName;

          return GestureDetector(
            onTap: () => vm.selectCustomCategory(cat.categoryName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF1B3B8B) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                cat.categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1B3B8B) : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridContent(JewelryViewModel vm) {
    if (vm.isLoadingCustomJewelry && vm.customJewelryList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryButton),
      );
    }

    if (vm.customError != null && vm.customJewelryList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vm.customError!,
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
              ),
              onPressed: () => vm.fetchCustomJewelry(reset: true),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (vm.customJewelryList.isEmpty) {
      return Center(
        child: Text(
          "No custom jewelry items found.",
          style: GoogleFonts.poppins(color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchCustomJewelry(reset: true),
      color: AppColors.primaryButton,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
          vertical: 12,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.60,
        ),
        itemCount: vm.customJewelryList.length + (vm.hasMoreCustom ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vm.customJewelryList.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryButton,
                ),
              ),
            );
          }

          final item = vm.customJewelryList[index];
          return CustomJewelryItemCard(item: item);
        },
      ),
    );
  }
}
