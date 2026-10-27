import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../models/quote_model.dart';
import 'quote_detail_view.dart';

class QuotesView extends StatefulWidget {
  final String type;

  const QuotesView({Key? key, this.type = 'quotes'}) : super(key: key);

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
      if (widget.type == 'my_orders') {
        quoteVM.fetchMyOrders(authViewModel);
      } else if (widget.type == 'completed_orders') {
        quoteVM.fetchCompletedOrders(authViewModel);
      } else {
        quoteVM.fetchQuotes(authViewModel);
      }
    });
  }

  String get _title => widget.type == 'my_orders'
      ? 'My Orders'
      : widget.type == 'completed_orders'
          ? 'Completed Orders'
          : 'My Quotes';

  IconData get _emptyIcon => widget.type == 'my_orders'
      ? Icons.shopping_bag_outlined
      : widget.type == 'completed_orders'
          ? Icons.assignment_turned_in_outlined
          : Icons.format_quote_outlined;

  Color get _emptyIconBg => widget.type == 'my_orders'
      ? const Color(0xFFFDE8F6)
      : widget.type == 'completed_orders'
          ? const Color(0xFFDCF3E8)
          : const Color(0xFFE0EEFE);

  Color get _emptyIconColor => widget.type == 'my_orders'
      ? const Color(0xFFB577A8)
      : widget.type == 'completed_orders'
          ? const Color(0xFF67B08B)
          : const Color(0xFF6B8BBE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Consumer<QuoteViewModel>(
          builder: (context, quoteVM, _) {
            int unreadCount = 0;
            if (widget.type == 'my_orders') {
              unreadCount = quoteVM.unreadMyOrdersCount;
            } else if (widget.type == 'completed_orders') {
              unreadCount = quoteVM.unreadCompletedOrdersCount;
            } else {
              unreadCount = quoteVM.unreadQuotesCount;
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_title),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Consumer<QuoteViewModel>(
        builder: (context, quoteVM, child) {
          if (quoteVM.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryButton),
            );
          }

          if (quoteVM.errorMessage != null && quoteVM.errorMessage!.isNotEmpty) {
            return Center(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBEADB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline, color: Color(0xFFC78B6C), size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        quoteVM.errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                          if (widget.type == 'my_orders') {
                            quoteVM.fetchMyOrders(authViewModel);
                          } else if (widget.type == 'completed_orders') {
                            quoteVM.fetchCompletedOrders(authViewModel);
                          } else {
                            quoteVM.fetchQuotes(authViewModel);
                          }
                        },
                        child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          List<QuoteModel> displayList;
          if (widget.type == 'my_orders') {
            displayList = quoteVM.myOrders;
          } else if (widget.type == 'completed_orders') {
            displayList = quoteVM.completedOrders;
          } else {
            displayList = quoteVM.quotes;
          }

          if (displayList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _emptyIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_emptyIcon, size: 48, color: _emptyIconColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.type == 'my_orders'
                        ? 'No orders found.'
                        : widget.type == 'completed_orders'
                            ? 'No completed orders found.'
                            : 'No quotes found.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your list will appear here once created',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 16),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final quote = displayList[index];
              return _buildQuoteCard(quote, quoteVM);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(QuoteModel quote, QuoteViewModel quoteVM) {
    String dateStr = quote.createDate;
    if (dateStr.length > 10) {
      dateStr = dateStr.substring(0, 10);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          quoteVM.markQuoteAsRead(quote.designId, quote.editDate);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuoteDetailView(quote: quote),
            ),
          );
          if (mounted) {
            final authVM = Provider.of<AuthViewModel>(context, listen: false);
            if (widget.type == 'my_orders') {
              quoteVM.fetchMyOrders(authVM);
            } else if (widget.type == 'completed_orders') {
              quoteVM.fetchCompletedOrders(authVM);
            } else {
              quoteVM.fetchQuotes(authVM);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryButton.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.type == 'my_orders'
                                ? Icons.shopping_bag_outlined
                                : widget.type == 'completed_orders'
                                    ? Icons.assignment_turned_in_outlined
                                    : Icons.format_quote_outlined,
                            size: 16,
                            color: AppColors.primaryButton,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Ref: ${quote.referenceNumber.isNotEmpty ? quote.referenceNumber : "N/A"}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (quoteVM.isQuoteUnread(quote)) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(quote.isApprovedText).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.type != 'quotes'
                          ? (quote.status.isNotEmpty ? quote.status : 'Processing')
                          : (quote.isApproved == '2'
                              ? 'Reject'
                              : (quote.isApproved == '1'
                                  ? (quote.processingStatus == '6' ? 'Completed' : 'Approved')
                                  : 'Pending')),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(widget.type != 'quotes'
                            ? quote.status
                            : (quote.isApproved == '2'
                                ? 'Reject'
                                : (quote.isApproved == '1'
                                    ? (quote.processingStatus == '6' ? 'Completed' : 'Approved')
                                    : 'Pending'))),
                      ),
                    ),
                  ),
                ],
              ),
              if (quote.name.isNotEmpty || quote.company.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  [if (quote.name.isNotEmpty) quote.name, if (quote.company.isNotEmpty) quote.company].join(' • '),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (quote.metal.isNotEmpty) _buildInfoChip(Icons.circle_outlined, quote.metal, const Color(0xFFFBEADB), const Color(0xFFC78B6C)),
                  if (quote.size.isNotEmpty) _buildInfoChip(Icons.straighten, quote.size, const Color(0xFFE0EEFE), const Color(0xFF6B8BBE)),
                  if (quote.centerDiamond.isNotEmpty) _buildInfoChip(Icons.diamond_outlined, quote.centerDiamond, const Color(0xFFEFDFFF), const Color(0xFF8B6CB2)),
                  if (quote.budget.isNotEmpty && quote.budget != '0') _buildInfoChip(Icons.attach_money, quote.budget, const Color(0xFFDCF3E8), const Color(0xFF67B08B)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.black38),
                  const SizedBox(width: 5),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('pending')) return Colors.orange;
    if (status.contains('approv') || status.contains('completed')) return Colors.green;
    if (status.contains('reject')) return Colors.red;
    return Colors.blue;
  }
}


