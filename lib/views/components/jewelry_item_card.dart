import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../core/network/dio_client.dart';
import '../jewelry_detail_view.dart';
import '../cart_view.dart';

class JewelryItemCard extends StatefulWidget {
  final dynamic item;
  const JewelryItemCard({Key? key, required this.item}) : super(key: key);

  @override
  State<JewelryItemCard> createState() => _JewelryItemCardState();
}

class _JewelryItemCardState extends State<JewelryItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _btnAnimController;
  late Animation<double> _btnScaleAnimation;
  bool _isAdded = false;
  bool _isLoading = false;
  bool _isWishlistLoading = false;

  @override
  void initState() {
    super.initState();
    _btnAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _btnAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnAnimController.dispose();
    super.dispose();
  }

  void _handleAddToCart() async {
    if (_isAdded || _isLoading) return;
    
    _btnAnimController.forward().then((_) {
      _btnAnimController.reverse();
    });
    
    setState(() {
      _isLoading = true;
    });

    try {
      final cartVm = Provider.of<CartViewModel>(context, listen: false);

      final success = await cartVm.addToCart(
        widget.item.productId.toString(),
        '1',
      );

      if (success && mounted) {
        setState(() {
          _isAdded = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.item.productSku.isNotEmpty ? widget.item.productSku : widget.item.productName} added to cart'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.primaryButton,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.amber[300],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartView()),
                );
              },
            ),
          ),
        );
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isAdded = false;
            });
          }
        });
      } else {
        throw Exception("Failed to add");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add item to cart. Try logging in.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleRemoveFromCart(String cartId) async {
    if (_isLoading) return;

    _btnAnimController.forward().then((_) {
      _btnAnimController.reverse();
    });

    setState(() {
      _isLoading = true;
    });

    try {
      final cartVm = Provider.of<CartViewModel>(context, listen: false);
      final success = await cartVm.removeFromCart(cartId, 'jewelry');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from cart'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception("Failed to remove");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not remove item from cart.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JewelryDetailView(jewelryId: widget.item.productId.toString()),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'jewelry_${widget.item.productId}',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.item.imageShow != null && widget.item.imageShow!.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: DioClient.getFullImageUrl(widget.item.imageShow),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      memCacheWidth: 400,
                      filterQuality: FilterQuality.low,
                      fadeInDuration: const Duration(milliseconds: 300), 
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100], 
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
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    )
                        : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                ),
                // Actions Overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      // _buildHeartIcon(context),
                      // const SizedBox(height: 8),
                      _buildActionButton(
                        icon: Icons.remove_red_eye_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JewelryDetailView(jewelryId: widget.item.productId.toString()),
                            ),
                          );
                        },
                        tooltip: 'Quick View',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              widget.item.productSku.isNotEmpty ? widget.item.productSku : widget.item.productName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '\$${widget.item.productPrice}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Consumer<CartViewModel>(
            builder: (context, cartVm, child) {
              // Find the cart item to get its cartId if it exists
              dynamic cartItem;
              try {
                cartItem = cartVm.cartItems.firstWhere(
                  (c) => c.productId == widget.item.productId.toString(),
                );
              } catch (_) {
                cartItem = null;
              }

              final bool isInCart = _isAdded || cartItem != null;

              return GestureDetector(
                onTap: _isLoading 
                    ? null 
                    : (isInCart && cartItem != null 
                        ? () => _handleRemoveFromCart(cartItem.cartId) 
                        : _handleAddToCart),
                child: ScaleTransition(
                  scale: _btnScaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isInCart ? Colors.green : AppColors.primaryButton,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ] else if (isInCart) ...[
                          const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                        ] else ...[
                          const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          _isLoading ? 'WORKING...' : isInCart ? 'REMOVE FROM CART' : 'ADD TO CART',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    ));
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primaryButton : Colors.grey,
          size: 18,
        ),
      ),
    );
  }

  /*
  Widget _buildHeartIcon(BuildContext context) {
    final wishlistVm = Provider.of<WishlistViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    var wishlistItem;
    if (wishlistVm.wishlistData != null) {
      for (var w in wishlistVm.wishlistData!.jewelry) {
        if (w.productId == widget.item.productId.toString()) {
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
            const SnackBar(content: Text('Please log in to add to wishlist'), backgroundColor: Colors.red),
          );
          return;
        }

        if (_isWishlistLoading) return;

        setState(() {
          _isWishlistLoading = true;
        });

        try {
          if (isInWishlist) {
            final success = await wishlistVm.removeItem(authVm.user!.userId, 'jewelry', wishlistItem.wishlistId);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from wishlist'), backgroundColor: Colors.green),
              );
            }
          } else {
            final success = await wishlistVm.addItem(authVm.user!.userId, 'jewelry', widget.item.productId.toString());
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to wishlist'), backgroundColor: Colors.green),
              );
            } else if (!success && mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(wishlistVm.errorMessage ?? 'Failed to add to wishlist'), backgroundColor: Colors.red),
              );
            }
          }
        } catch (e) {
          // ignore
        } finally {
          if (mounted) {
            setState(() {
              _isWishlistLoading = false;
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: _isWishlistLoading 
          ? const SizedBox(
              width: 18, 
              height: 18, 
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryButton)
            )
          : Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey,
              size: 18,
            ),
      ),
    );
  }
  */
}
