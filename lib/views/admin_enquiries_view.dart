import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../models/quote_model.dart';
import 'admin_enquiry_detail_view.dart';

class AdminEnquiriesView extends StatefulWidget {
  final String initialStatus;
  const AdminEnquiriesView({Key? key, this.initialStatus = 'All'}) : super(key: key);

  @override
  State<AdminEnquiriesView> createState() => _AdminEnquiriesViewState();
}

class _AdminEnquiriesViewState extends State<AdminEnquiriesView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    Provider.of<QuoteViewModel>(context, listen: false).fetchAdminDesigns(authViewModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Consumer<QuoteViewModel>(
          builder: (context, quoteVM, _) {
            final unreadCount = quoteVM.unreadAdminEnquiriesCount;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Design Enquiries'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<QuoteViewModel>(
              builder: (context, quoteVM, child) {
                if (quoteVM.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryButton),
                  );
                }

                if (quoteVM.errorMessage != null && quoteVM.errorMessage!.isNotEmpty) {
                  return _buildErrorWidget(quoteVM.errorMessage!);
                }

                final allRecords = quoteVM.adminDesigns;
                final filteredRecords = allRecords.where((item) {
                  // Apply Status Filter
                  if (_selectedStatus != 'All' && item.status.toLowerCase() != _selectedStatus.toLowerCase()) {
                    return false;
                  }

                  // Apply Search query
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    final nameMatch = item.name.toLowerCase().contains(query);
                    final companyMatch = item.company.toLowerCase().contains(query);
                    final refMatch = item.referenceNumber.toLowerCase().contains(query);
                    final emailMatch = item.email.toLowerCase().contains(query);
                    return nameMatch || companyMatch || refMatch || emailMatch;
                  }

                  return true;
                }).toList();

                if (filteredRecords.isEmpty) {
                  return _buildEmptyWidget();
                }

                return RefreshIndicator(
                  color: AppColors.primaryButton,
                  onRefresh: () async => _fetchData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 8),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final item = filteredRecords[index];
                      return _buildEnquiryCard(item, quoteVM);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Search box
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, company, ref...',
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Filter Row
          SizedBox(
            height: 34,
            child: Consumer<QuoteViewModel>(
              builder: (context, quoteVM, _) {
                final records = quoteVM.adminDesigns;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', _getUnreadCountForStatus(records, 'All', quoteVM)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Quote', _getUnreadCountForStatus(records, 'Quote', quoteVM)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Order', _getUnreadCountForStatus(records, 'Order', quoteVM)),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completed', _getUnreadCountForStatus(records, 'Completed', quoteVM)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getUnreadCountForStatus(List<QuoteModel> records, String status, QuoteViewModel quoteVM) {
    if (status == 'All') {
      return records.where((item) => quoteVM.isQuoteUnread(item)).length;
    }
    return records.where((item) => item.status.toLowerCase() == status.toLowerCase() && quoteVM.isQuoteUnread(item)).length;
  }

  Widget _buildFilterChip(String status, int unreadCount) {
    final isSelected = _selectedStatus == status;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.primaryButton : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = status;
          });
        }
      },
      selectedColor: AppColors.primaryButton,
      backgroundColor: const Color(0xFFF7F8FA),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? AppColors.primaryButton : Colors.transparent,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(QuoteModel item, QuoteViewModel quoteVM) {
    String dateStr = item.createDate;
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
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          quoteVM.markQuoteAsRead(item.designId, item.editDate);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminEnquiryDetailView(quote: item),
            ),
          );
          if (mounted) {
            final authVM = Provider.of<AuthViewModel>(context, listen: false);
            Provider.of<QuoteViewModel>(context, listen: false).fetchAdminDesigns(authVM);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.referenceNumber.isNotEmpty ? 'Ref: ${item.referenceNumber}' : 'Ref: N/A',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            if (quoteVM.isQuoteUnread(item)) ...[
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
                        if (item.company.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.company,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status.isNotEmpty ? item.status : 'Pending',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(item.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Customer info details
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: Colors.black38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.name.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 14, color: Colors.black38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.contact.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.phone_android_outlined, size: 14, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      item.contact,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ]
                ],
              ),
              if (item.msg.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  child: Text(
                    item.msg,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Specific chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (item.metal.isNotEmpty) _buildInfoChip(Icons.circle_outlined, item.metal, const Color(0xFFFBEADB), const Color(0xFFC78B6C)),
                  if (item.size.isNotEmpty) _buildInfoChip(Icons.straighten, 'Size: ${item.size}', const Color(0xFFE0EEFE), const Color(0xFF6B8BBE)),
                  if (item.budget.isNotEmpty && item.budget != '0') _buildInfoChip(Icons.attach_money, 'Budget: \$${item.budget}', const Color(0xFFDCF3E8), const Color(0xFF67B08B)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black38),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                  ),
                  const Spacer(),
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primaryButton, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryButton),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('completed')) return Colors.green;
    if (status.contains('order')) return Colors.blue;
    if (status.contains('quote')) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFBEADB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_outlined, size: 48, color: Color(0xFFC78B6C)),
          ),
          const SizedBox(height: 16),
          Text(
            'No matching enquiries found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search query or filters',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _fetchData,
                child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


