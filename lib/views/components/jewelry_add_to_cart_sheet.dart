import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class JewelryAddToCartSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic> selectedOptions) onAddToCart;
  final bool isAdding;

  const JewelryAddToCartSheet({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.isAdding = false,
  });

  static void show(
    BuildContext context, {
    required Map<String, dynamic> product,
    required Function(Map<String, dynamic> selectedOptions) onAddToCart,
    bool isAdding = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JewelryAddToCartSheet(
        product: product,
        onAddToCart: onAddToCart,
        isAdding: isAdding,
      ),
    );
  }

  @override
  State<JewelryAddToCartSheet> createState() => _JewelryAddToCartSheetState();
}

class _JewelryAddToCartSheetState extends State<JewelryAddToCartSheet> {
  String _selectedMetal = '18K Yellow Gold';
  String _selectedSize = '6.0';
  final TextEditingController _engravingController = TextEditingController();
  bool _includeGiftBox = false;
  int _quantity = 1;

  final List<Map<String, dynamic>> _metals = [
    {'name': '18K Yellow Gold', 'color': Color(0xFFE5C158)},
    {'name': '18K White Gold', 'color': Color(0xFFE2E8F0)},
    {'name': '18K Rose Gold', 'color': Color(0xFFF4A261)},
    {'name': 'Platinum', 'color': Color(0xFFCBD5E1)},
  ];

  final List<String> _sizes = ['5.0', '5.5', '6.0', '6.5', '7.0', '7.5', '8.0'];

  @override
  void initState() {
    super.initState();
    // Default metal from product if available
    if (widget.product['metal'] != null && widget.product['metal'].toString().isNotEmpty) {
      _selectedMetal = widget.product['metal'].toString();
    }
  }

  @override
  void dispose() {
    _engravingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product['product_sku'] ?? widget.product['product_name'] ?? 'Jewelry Item';
    final priceStr = widget.product['product_price_show'] ?? '\$${widget.product['product_price'] ?? '0'}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceStr,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryButton,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),

          const Divider(height: 24),

          // Flexible scroll content for customization options
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Metal Selection
                  Text(
                    'SELECT METAL',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _metals.map((metal) {
                        final isSelected = _selectedMetal == metal['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMetal = metal['name']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryButton.withValues(alpha: 0.08) : Colors.grey[50],
                              border: Border.all(
                                color: isSelected ? AppColors.primaryButton : Colors.grey[300]!,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: metal['color'] as Color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  metal['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? AppColors.primaryButton : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Ring Size Selection & Guide
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RING SIZE (US)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showSizeGuide(context),
                        child: Text(
                          'Size Guide',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryButton,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return ChoiceChip(
                        label: Text('US $size'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSize = size);
                        },
                        selectedColor: AppColors.primaryButton,
                        backgroundColor: Colors.grey[100],
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryButton : Colors.grey[300]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // 3. Custom Engraving (Optional)
                  Text(
                    'COMPLIMENTARY ENGRAVING (OPTIONAL)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _engravingController,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: 'e.g. Forever & Always ♡',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryButton),
                      ),
                      counterStyle: GoogleFonts.poppins(fontSize: 10),
                    ),
                  ),

                  // 4. Gift Packaging Checkbox
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _includeGiftBox,
                          activeColor: AppColors.primaryButton,
                          onChanged: (val) => setState(() => _includeGiftBox = val ?? false),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complimentary Gift Packaging',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Includes velvet ribbon box & personalized card',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Sticky Bottom Bar: Quantity & Add to Cart Button
          Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text(
                      '$_quantity',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Confirm Add to Cart CTA
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: widget.isAdding
                      ? null
                      : () {
                          widget.onAddToCart({
                            'metal': _selectedMetal,
                            'size': _selectedSize,
                            'engraving': _engravingController.text,
                            'giftBox': _includeGiftBox,
                            'quantity': _quantity,
                          });
                          Navigator.pop(context);
                        },
                  child: widget.isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'CONFIRM ADD TO CART',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSizeGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ring Size Guide', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Measure the inner diameter of an existing ring or wrap a strip of paper around your finger.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!, width: 0.5),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text('US Size', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: const EdgeInsets.all(8), child: Text('Inside Dia.', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: const EdgeInsets.all(8), child: Text('Circumference', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
                TableRow(children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text('5.0', style: GoogleFonts.poppins(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('15.7 mm', style: GoogleFonts.poppins(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('49.3 mm', style: GoogleFonts.poppins(fontSize: 11))),
                ]),
                TableRow(children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text('6.0', style: GoogleFonts.poppins(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('16.5 mm', style: GoogleFonts.poppins(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('51.8 mm', style: GoogleFonts.poppins(fontSize: 11))),
                ]),
                TableRow(children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text('7.0', style: GoogleFonts.poppins(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('17.3 mm', style: GoogleFonts.poppins(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('54.4 mm', style: GoogleFonts.poppins(fontSize: 11))),
                ]),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE', style: GoogleFonts.poppins(color: AppColors.primaryButton, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
