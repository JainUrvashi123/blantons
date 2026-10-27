import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/dio_client.dart';
import '../models/custom_jewelry_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/jewelry_viewmodel.dart';
import 'cart_view.dart';

class CustomJewelryDetailView extends StatefulWidget {
  final String jewelryId;
  final CustomJewelryItem? initialItem;

  const CustomJewelryDetailView({
    Key? key,
    required this.jewelryId,
    this.initialItem,
  }) : super(key: key);

  // Helper constructor when passing CustomJewelryItem directly
  factory CustomJewelryDetailView.fromItem(CustomJewelryItem item) {
    return CustomJewelryDetailView(
      jewelryId: item.id,
      initialItem: item,
    );
  }

  @override
  State<CustomJewelryDetailView> createState() => _CustomJewelryDetailViewState();

}

class _CustomJewelryDetailViewState extends State<CustomJewelryDetailView> {
  bool _isLoading = true;
  String? _error;
  CustomJewelryDetailData? _detailData;
  CustomJewelryItem? _item;
  CustomJewelryVariant? _activeVariant;

  String _selectedColor = '';
  String _selectedCarat = '';
  String _selectedRingSize = '7';

  int _currentImageIndex = 0;
  bool _isAddingToCart = false;
  List<String> _images = [];

  final List<String> _ringSizes = ['5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11'];

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _item = widget.initialItem;
      _selectedRingSize = _item!.ringSize.isNotEmpty ? _item!.ringSize : '7';
      _buildImageList();
    }
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final vm = Provider.of<JewelryViewModel>(context, listen: false);
      final detailData = await vm.fetchCustomJewelryDetails(widget.jewelryId);

      if (mounted) {
        setState(() {
          _detailData = detailData;
          _item = detailData.product;

          if (_item!.ringSize.isNotEmpty) {
            _selectedRingSize = _item!.ringSize;
          }

          if (detailData.availableColors.isNotEmpty) {
            _selectedColor = detailData.availableColors.first;
          } else if (_item!.metalColor.isNotEmpty) {
            _selectedColor = _item!.metalColor;
          }

          if (detailData.availableCarats.isNotEmpty) {
            _selectedCarat = detailData.availableCarats.first;
          } else if (_item!.displayCarat.isNotEmpty) {
            _selectedCarat = _item!.displayCarat;
          }

          _updateActiveVariant();
          _buildImageList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // If details endpoint fails, fallback to initial item if available
          if (_item != null) {
            _isLoading = false;
          } else {
            _error = e.toString().replaceFirst("Exception: ", "");
            _isLoading = false;
          }
        });
      }
    }
  }

  void _updateActiveVariant() {
    if (_detailData == null || _detailData!.variantsMatrix.isEmpty) return;

    final matrix = _detailData!.variantsMatrix;
    CustomJewelryVariant? matched;

    for (var v in matrix) {
      final colorMatch = _selectedColor.isEmpty ||
          v.color.trim().toLowerCase() == _selectedColor.trim().toLowerCase();
      final caratMatch = _selectedCarat.isEmpty ||
          v.carat.trim().toLowerCase() == _selectedCarat.trim().toLowerCase();

      if (colorMatch && caratMatch) {
        matched = v;
        break;
      }
    }

    // Fallbacks if exact match isn't found
    matched ??= matrix.firstWhere(
      (v) => v.color.trim().toLowerCase() == _selectedColor.trim().toLowerCase(),
      orElse: () => matrix.first,
    );

    _activeVariant = matched;
  }

  void _buildImageList() {
    final List<String> rawList = [];

    if (_item != null) {
      if (_item!.gallery.isNotEmpty) {
        rawList.addAll(_item!.gallery);
      }
      rawList.addAll([
        _item!.defaultImage,
        _item!.wgImage,
        _item!.ygImage,
        _item!.rgImage,
        _item!.media1,
        _item!.media2,
        _item!.media3Front,
        _item!.media3Side,
        _item!.media5,
        _item!.media6,
        _item!.media7,
      ]);
    }

    final Set<String> uniqueImages = {};
    for (var url in rawList) {
      if (url.trim().isNotEmpty) {
        uniqueImages.add(url.trim());
      }
    }

    _images = uniqueImages.toList();
    if (_images.isEmpty && _item != null && _item!.primaryImage.isNotEmpty) {
      _images.add(_item!.primaryImage);
    }
  }

  void _handleAddToCart() async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final jewelryVm = Provider.of<JewelryViewModel>(context, listen: false);
      final cartVm = Provider.of<CartViewModel>(context, listen: false);

      final customerId = authVm.user?.userId ?? '91';
      final productId = _activeVariant?.id ?? _item?.id ?? widget.jewelryId;

      final success = await jewelryVm.addCustomJewelryToCart(
        customerId: customerId,
        productId: productId,
        quantity: '1',
        ringSize: _selectedRingSize,
      );

      if (success && mounted) {
        // Refresh global cart items
        if (authVm.user != null) {
          cartVm.fetchCart();
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Custom Jewelry Details'),
            content: Text(
              '${_item?.variantName.trim().isNotEmpty == true ? _item!.variantName.trim() : (_item?.indexName ?? 'Item')} added to cart successfully!',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CONTINUE SHOPPING', style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartView()),
                  );
                },
                child: Text('GO TO CART', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Failed to add to cart");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Widget _buildSpecRow(String label, String value) {
    if (value.trim().isEmpty || value == "null") return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          const Text(' :  ', style: TextStyle(color: Colors.grey)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          item?.mainProductDropDown.isNotEmpty == true ? item!.mainProductDropDown : 'Custom Jewelry',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading && item == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryButton))
          : _error != null && item == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: GoogleFonts.poppins(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryButton),
                        onPressed: _fetchDetails,
                        child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      if (_images.isNotEmpty)
                        Hero(
                          tag: 'custom_jewelry_${widget.jewelryId}',
                          child: Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 340,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) => setState(() => _currentImageIndex = index),
                                ),
                                items: _images.map((imgUrl) {
                                  return CachedNetworkImage(
                                    imageUrl: DioClient.getFullImageUrl(imgUrl),
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    filterQuality: FilterQuality.medium,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[50],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryButton,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  );
                                }).toList(),
                              ),
                              // Indicator Dots
                              if (_images.length > 1)
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _images.asMap().entries.map((entry) {
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == entry.key ? AppColors.primaryButton : Colors.grey.shade300,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Content Container
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              item?.variantName.trim().isNotEmpty == true ? item!.variantName.trim() : (item?.indexName ?? ''),
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            if (item?.variantStockNumber.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                'SKU: ${item!.variantStockNumber}',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // Price
                            Text(
                              '\$${_activeVariant?.price ?? item?.variantPrice ?? "0.00"} USD',
                              style: GoogleFonts.poppins(fontSize: 22, color: const Color(0xFFC62828), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Color Selector (from available_colors or item)
                            if (_detailData != null && _detailData!.availableColors.isNotEmpty) ...[
                              Text('Metal Color:', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _detailData!.availableColors.map((color) {
                                  final bool isSelected = _selectedColor.trim().toLowerCase() == color.trim().toLowerCase();
                                  return ChoiceChip(
                                    label: Text(
                                      color,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.primaryButton,
                                    backgroundColor: Colors.grey.shade100,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedColor = color;
                                          _updateActiveVariant();
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Carat Weight Selector (from available_carats or item)
                            if (_detailData != null && _detailData!.availableCarats.isNotEmpty) ...[
                              Text('Center Carat Weight:', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _detailData!.availableCarats.map((carat) {
                                  final bool isSelected = _selectedCarat.trim().toLowerCase() == carat.trim().toLowerCase();
                                  return ChoiceChip(
                                    label: Text(
                                      '$carat CT',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppColors.primaryButton,
                                    backgroundColor: Colors.grey.shade100,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedCarat = carat;
                                          _updateActiveVariant();
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Ring Size Selector
                            Text('Ring Size:', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 38,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _ringSizes.length,
                                itemBuilder: (context, index) {
                                  final size = _ringSizes[index];
                                  final isSelected = _selectedRingSize == size;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRingSize = size;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primaryButton : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primaryButton : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          size,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const Divider(height: 32),

                            // Specifications Header
                            Text("Product Specifications", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),

                            if (item != null) ...[
                              _buildSpecRow('Category', item.mainProductDropDown),
                              _buildSpecRow('Sub Type', item.mainSubTypes),
                              _buildSpecRow('Style', item.styles),
                              _buildSpecRow('Metal Type', item.metalType),
                              _buildSpecRow('Metal Color', _selectedColor.isNotEmpty ? _selectedColor : item.metalColor),
                              _buildSpecRow('Metal Weight', item.metalWeight.isNotEmpty ? '${item.metalWeight} g' : ''),
                              _buildSpecRow('Setting Type', item.settingType),
                              _buildSpecRow('Total Carat Weight', item.totalCaratWeight.isNotEmpty ? '${item.totalCaratWeight} CT' : ''),
                              _buildSpecRow('Primary Stone', item.stones1),
                              _buildSpecRow('Stone Shape', item.stones1StoneShape.isNotEmpty ? item.stones1StoneShape : item.stoneShape),
                              _buildSpecRow('Stone Carat Weight', _selectedCarat.isNotEmpty ? '$_selectedCarat CT' : item.stones1CaratWeight),
                              _buildSpecRow('Number of Stones', item.stones1NumberOfStones),
                              if (item.stones1DiamondClarity.isNotEmpty) _buildSpecRow('Diamond Clarity', item.stones1DiamondClarity),
                              if (item.stones1DiamondColor.isNotEmpty) _buildSpecRow('Diamond Color', item.stones1DiamondColor),
                              if (item.stones1DiamondCut.isNotEmpty) _buildSpecRow('Diamond Cut', item.stones1DiamondCut),
                              if (item.stones2.isNotEmpty) _buildSpecRow('Accent Stone', item.stones2),
                            ],

                            if (item?.variantDescription.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 20),
                              Text("Description", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              HtmlWidget(
                                item!.variantDescription,
                                textStyle: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87, height: 1.5),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryButton,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: _isAddingToCart ? null : _handleAddToCart,
                                child: _isAddingToCart
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_shopping_cart_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'ADD TO CART',
                                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
