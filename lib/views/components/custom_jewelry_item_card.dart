import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/dio_client.dart';
import '../../models/custom_jewelry_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/wishlist_viewmodel.dart';
import '../custom_jewelry_detail_view.dart';

class CustomJewelryItemCard extends StatefulWidget {
  final CustomJewelryItem item;
  const CustomJewelryItemCard({Key? key, required this.item}) : super(key: key);

  @override
  State<CustomJewelryItemCard> createState() => _CustomJewelryItemCardState();
}

class _CustomJewelryItemCardState extends State<CustomJewelryItemCard> {
  String _selectedMetalColor = 'WG';
  bool _isWishlistLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to first available image color
    if (widget.item.wgImage.isNotEmpty) {
      _selectedMetalColor = 'WG';
    } else if (widget.item.ygImage.isNotEmpty) {
      _selectedMetalColor = 'YG';
    } else if (widget.item.rgImage.isNotEmpty) {
      _selectedMetalColor = 'RG';
    } else {
      _selectedMetalColor = 'DEFAULT';
    }
  }

  String _getActiveImageUrl() {
    if (_selectedMetalColor == 'WG' && widget.item.wgImage.isNotEmpty) {
      return widget.item.wgImage;
    }
    if (_selectedMetalColor == 'YG' && widget.item.ygImage.isNotEmpty) {
      return widget.item.ygImage;
    }
    if (_selectedMetalColor == 'RG' && widget.item.rgImage.isNotEmpty) {
      return widget.item.rgImage;
    }
    return widget.item.primaryImage;
  }

  @override
  Widget build(BuildContext context) {
    final activeImage = _getActiveImageUrl();
    final categoryTag = widget.item.mainProductDropDown.isNotEmpty
        ? widget.item.mainProductDropDown.toUpperCase()
        : 'BRIDAL';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomJewelryDetailView.fromItem(widget.item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Wishlist Heart & Category Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeartIcon(context),
                if (categoryTag.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      categoryTag,
                      style: GoogleFonts.poppins(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Product Image Area
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'custom_jewelry_${widget.item.id}',
                  child: activeImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: DioClient.getFullImageUrl(activeImage),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          filterQuality: FilterQuality.medium,
                          placeholder: (context, url) => Container(
                            color: Colors.white,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryButton,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 36,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 36,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Variant Name / Title
            Text(
              widget.item.variantName.trim().isNotEmpty
                  ? widget.item.variantName.trim()
                  : widget.item.indexName,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Price in bold red
            Text(
              '\$${widget.item.variantPrice} USD',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC62828),
              ),
            ),
            const SizedBox(height: 2),

            // Carat weight subtext
            if (widget.item.displayCarat.isNotEmpty)
              Text(
                'Carat : ${widget.item.displayCarat}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(height: 6),

            // Metal color pills (WG, YG, RG)
            Row(
              children: [
                if (widget.item.wgImage.isNotEmpty)
                  _buildMetalPill('WG', const Color(0xFFE0E0E0), Colors.black87),
                if (widget.item.ygImage.isNotEmpty)
                  _buildMetalPill('YG', const Color(0xFFE5C158), Colors.black87),
                if (widget.item.rgImage.isNotEmpty)
                  _buildMetalPill('RG', const Color(0xFFE0A99A), Colors.black87),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetalPill(String code, Color bg, Color textCol) {
    final bool isSelected = _selectedMetalColor == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetalColor = code;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF1B3B8B) : Colors.transparent,
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            code,
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartIcon(BuildContext context) {
    final wishlistVm = Provider.of<WishlistViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    var wishlistItem;
    if (wishlistVm.wishlistData != null) {
      for (var w in wishlistVm.wishlistData!.jewelry) {
        if (w.productId == widget.item.id) {
          wishlistItem = w;
          break;
        }
      }
    }

    final bool isInWishlist = wishlistItem != null;

    return GestureDetector(
      onTap: () async {
        if (authVm.user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to add to wishlist'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (_isWishlistLoading) return;

        setState(() {
          _isWishlistLoading = true;
        });

        try {
          if (isInWishlist) {
            final success = await wishlistVm.removeItem(
              authVm.user!.userId,
              'jewelry',
              wishlistItem.wishlistId,
            );
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removed from wishlist'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            final success = await wishlistVm.addItem(
              authVm.user!.userId,
              'jewelry',
              widget.item.id,
            );
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to wishlist'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    wishlistVm.errorMessage ?? 'Failed to add to wishlist',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (_) {
        } finally {
          if (mounted) {
            setState(() {
              _isWishlistLoading = false;
            });
          }
        }
      },
      child: _isWishlistLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primaryButton,
              ),
            )
          : Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey.shade600,
              size: 18,
            ),
    );
  }
}
