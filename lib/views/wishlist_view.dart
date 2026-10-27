import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/wishlist_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import '../core/network/dio_client.dart';
import 'jewelry_detail_view.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({Key? key}) : super(key: key);

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<WishlistViewModel>().fetchWishlist(user.userId);
      }
    });
  }

  void _removeAll(BuildContext context, AuthViewModel authVm, WishlistViewModel wishlistVm) async {
    final items = wishlistVm.wishlistData?.allItems ?? [];
    if (items.isEmpty) return;
    bool allSuccess = true;
    for (var item in items) {
      final success = await wishlistVm.removeItem(authVm.user!.userId, item.type, item.wishlistId);
      if (!success) allSuccess = false;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allSuccess ? 'All items removed' : 'Failed to remove some items', style: GoogleFonts.poppins()),
        backgroundColor: allSuccess ? Colors.black87 : Colors.red,
      ),
    );
  }

  void _addToCart(BuildContext context, WishlistItem item, AuthViewModel authVm) async {
    try {
      final jewelryVm = Provider.of<JewelryViewModel>(context, listen: false);
      final success = await jewelryVm.addToCart(item.productId, userId: authVm.user?.userId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.sku.isNotEmpty ? item.sku : item.category} added to cart', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.primaryButton,
          ),
        );
      } else {
        throw Exception("Failed to add");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add to cart.', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Wishlist')),
      body: Consumer2<AuthViewModel, WishlistViewModel>(
        builder: (context, authVm, wishlistVm, child) {
          if (authVm.user == null) return _buildEmptyState(context, 'Please login to view your wishlist');
          if (wishlistVm.isLoading && wishlistVm.wishlistData == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryButton));
          }
          if (wishlistVm.errorMessage != null && wishlistVm.wishlistData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(wishlistVm.errorMessage!, style: GoogleFonts.poppins(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
              ),
            );
          }
          final allItems = wishlistVm.wishlistData?.allItems ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (allItems.isEmpty)
                Expanded(child: _buildEmptyState(context, 'Your wishlist is currently empty.'))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 16),
                    itemCount: allItems.length,
                    itemBuilder: (context, index) => _buildWishlistItem(context, allItems[index], authVm.user!.userId, wishlistVm, authVm),
                  ),
                ),
              if (allItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppConstants.horizontalPadding, 0, AppConstants.horizontalPadding, 16),
                  child: ElevatedButton(
                    onPressed: () => _removeAll(context, authVm, wishlistVm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text('Clear Wishlist', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, WishlistItem item, String userId, WishlistViewModel vm, AuthViewModel authVm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 80,
                width: 80,
                child: item.imageShow != null && item.imageShow!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: DioClient.getFullImageUrl(item.imageShow),
                        fit: BoxFit.cover,
                        memCacheWidth: 200,
                        filterQuality: FilterQuality.low,
                        placeholder: (ctx, url) => Container(color: const Color(0xFFF5F5F5), child: const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryButton)))),
                        errorWidget: (ctx, url, err) => Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.image_not_supported, color: Colors.black26)),
                      )
                    : Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.image_not_supported, color: Colors.black26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item.sku.isNotEmpty ? item.sku : 'Unknown SKU', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('\$${item.productPrice}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryButton)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final success = await vm.removeItem(userId, item.type, item.wishlistId);
                      if (!context.mounted) return;
                      if (success) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed from wishlist', style: GoogleFonts.poppins())));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.redAccent, size: 14),
                        const SizedBox(width: 3),
                        Text('Remove', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconBtn(Icons.visibility_outlined, const Color(0xFFE0EEFE), const Color(0xFF6B8BBE), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => JewelryDetailView(jewelryId: item.productId)));
                }),
                const SizedBox(height: 8),
                _buildIconBtn(Icons.shopping_cart_outlined, const Color(0xFFFBEADB), AppColors.primaryButton, () => _addToCart(context, item, authVm)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color bg, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Color(0xFFFDE8F6), shape: BoxShape.circle), child: const Icon(Icons.favorite_border, size: 48, color: Color(0xFFB577A8))),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Items you save will appear here', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 24),
          if (context.read<AuthViewModel>().user == null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('LOGIN', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}



