import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Acceptance of Terms',
      'icon': Icons.verified_user_outlined,
      'iconBg': 0xFFDCF3E8,
      'iconColor': 0xFF67B08B,
      'content':
          'By accessing and using this website, you agree to comply with and be bound by these Terms and Conditions. If you do not agree with any part of these terms, please do not use this website.\n\nThese Terms and Conditions constitute a legally binding agreement between you and Blantons.',
    },
    {
      'title': 'Jewelry Products',
      'icon': Icons.diamond_outlined,
      'iconBg': 0xFFEFDFFF,
      'iconColor': 0xFF8B6CB2,
      'content':
          'Our website showcases and sells a variety of jewelry products. The descriptions, images, and prices of these products are subject to change without notice.\n\nWe make every effort to accurately display the colors and details of our products. However, we cannot guarantee that your device\'s display will accurately reflect the actual colors of the products.\n\nAll jewelry items are subject to availability. We reserve the right to discontinue or modify any product at any time without prior notice.',
    },
    {
      'title': 'Pricing and Payment',
      'icon': Icons.attach_money_rounded,
      'iconBg': 0xFFFBEADB,
      'iconColor': 0xFFC78B6C,
      'content':
          'When you place an order on our website, you are making an offer to purchase the products at the prices and terms indicated.\n\nWe reserve the right to refuse or cancel any orders for any reason, including but not limited to inaccuracies in product descriptions or pricing errors.\n\nPayment for orders is processed securely. By completing a purchase, you agree to the terms and conditions of the chosen payment method.',
    },
    {
      'title': 'Shipping and Returns',
      'icon': Icons.local_shipping_outlined,
      'iconBg': 0xFFE0EEFE,
      'iconColor': 0xFF6B8BBE,
      'content':
          'Shipping costs and estimated delivery times are provided during the checkout process. Please review our Shipping Policy for more details.\n\nWe accept returns within days of the purchase date. Please review our Return Policy for information on returns and exchanges.\n\nYou are responsible for all shipping costs associated with the return of products unless the return is due to our error or a defective product.',
    },
    {
      'title': 'Intellectual Property',
      'icon': Icons.copyright_outlined,
      'iconBg': 0xFFFDE8F6,
      'iconColor': 0xFFB577A8,
      'content':
          'All content on this website, including images, text, logos, and designs, is the property of Blantons and is protected by intellectual property laws.\n\nYou may not use, reproduce, distribute, or create derivative works based on the content of this website without our explicit written consent.',
    },
    {
      'title': 'Privacy and Data Protection',
      'icon': Icons.lock_outline_rounded,
      'iconBg': 0xFFF7E9DA,
      'iconColor': 0xFFA58564,
      'content':
          'Your use of this website is also governed by our Privacy Policy, which outlines how we collect, use, and protect your personal information.\n\nBy using our website, you consent to the processing of your personal information as described in our Privacy Policy.',
    },
    {
      'title': 'User Conduct',
      'icon': Icons.person_outline_rounded,
      'iconBg': 0xFFDCF3E8,
      'iconColor': 0xFF67B08B,
      'content':
          'You agree not to engage in any of the following prohibited activities:\n\nUse the website for any illegal purpose or in violation of any local, state, national, or international law.\n\nViolate or encourage others to violate any right of Blantons, including by infringing or misappropriating any intellectual property right.\n\nInterfere with security-related features of the website or attempt to gain unauthorized access.',
    },
    {
      'title': 'Limitation of Liability',
      'icon': Icons.gavel_outlined,
      'iconBg': 0xFFE0EEFE,
      'iconColor': 0xFF6B8BBE,
      'content':
          'To the fullest extent permitted by law, Blantons shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues arising out of or related to your use of this website.',
    },
    {
      'title': 'Governing Law',
      'icon': Icons.account_balance_outlined,
      'iconBg': 0xFFEFDFFF,
      'iconColor': 0xFF8B6CB2,
      'content':
          'These Terms and Conditions are governed by and construed in accordance with the laws, and any disputes will be subject to the exclusive jurisdiction of the courts.',
    },
    {
      'title': 'Contact Information',
      'icon': Icons.mail_outline_rounded,
      'iconBg': 0xFFFBEADB,
      'iconColor': 0xFFC78B6C,
      'content':
          'If you have any questions about these Terms and Conditions, please contact us at Info@blantonslab.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7E9DA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.description_outlined, color: Color(0xFFA58564), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms and Conditions',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last updated · Blantons',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ..._sections.asMap().entries.map((entry) {
              final s = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSection(
                  title: s['title'] as String,
                  content: s['content'] as String,
                  icon: s['icon'] as IconData,
                  iconBg: Color(s['iconBg'] as int),
                  iconColor: Color(s['iconColor'] as int),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}


