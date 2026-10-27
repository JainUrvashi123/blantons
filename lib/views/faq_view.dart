import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';


class FaqView extends StatelessWidget {
  const FaqView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FAQ'),
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
                      color: Color(0xFFE0EEFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline_rounded, color: Color(0xFF6B8BBE), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return & Refund Policy',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Everything you need to know',
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

            // Intro paragraph card
            _buildInfoCard(
              icon: Icons.assignment_return_outlined,
              iconBg: const Color(0xFFFBEADB),
              iconColor: const Color(0xFFC78B6C),
              content: "We have a 15-day return policy, which means you have 15 days after receiving your item to request a return.\n\n"
                  "To be eligible for a return, your item must be in the same condition that you received it, unworn or unused, with tags, and in its original packaging. You'll also need the receipt or proof of purchase.\n\n"
                  "To start a return, you can contact us at Info@blantonslab.com. If your return is accepted, we'll send you a return shipping label, as well as instructions on how and where to send your package. Items sent back to us without first requesting a return will not be accepted.\n\n"
                  "You can always contact us for any return question at Info@blantonslab.com.",
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: 'Damages and issues',
              content: 'Please inspect your order upon reception and contact us immediately if the item is defective, damaged or if you receive the wrong item, so that we can evaluate the issue and make it right.',
              icon: Icons.shield_outlined,
              iconBg: const Color(0xFFDCF3E8),
              iconColor: const Color(0xFF67B08B),
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: 'Exceptions / non-returnable items',
              content: 'Certain types of items cannot be returned, like custom products (such as special orders or personalized items). Please get in touch if you have questions or concerns about your specific item.\n\nUnfortunately, we cannot accept returns on sale items or gift cards.',
              icon: Icons.block_outlined,
              iconBg: const Color(0xFFFDE8F6),
              iconColor: const Color(0xFFB577A8),
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: 'Exchanges',
              content: 'The fastest way to ensure you get what you want is to return the item you have, and once the return is accepted, make a separate purchase for the new item.',
              icon: Icons.swap_horiz_outlined,
              iconBg: const Color(0xFFEFDFFF),
              iconColor: const Color(0xFF8B6CB2),
            ),
            const SizedBox(height: 12),

            _buildSection(
              title: 'Refunds',
              content: "We will notify you once we've received and inspected your return, and let you know if the refund was approved or not. If approved, you'll be automatically refunded on your original payment method. Please remember it can take some time for your bank or credit card company to process and post the refund too.",
              icon: Icons.account_balance_wallet_outlined,
              iconBg: const Color(0xFFF7E9DA),
              iconColor: const Color(0xFFA58564),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String content,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 12,
                height: 1.7,
              ),
            ),
          ),
        ],
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


