import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/quote_model.dart';
import '../models/quote_detail_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'components/custom_text_field.dart';

class QuoteDetailView extends StatefulWidget {
  final QuoteModel quote;
  const QuoteDetailView({Key? key, required this.quote}) : super(key: key);

  @override
  State<QuoteDetailView> createState() => _QuoteDetailViewState();
}

class _QuoteDetailViewState extends State<QuoteDetailView> {
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedImages = [];
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteViewModel>(context, listen: false)
          .fetchQuoteDetail(widget.quote.designId);
    });

    // Listen for foreground notifications to refresh the quote details instantly
    _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('QuoteDetailView received foreground message: ${message.data}');
      final msgDesignId = message.data['design_id']?.toString() ??
                          message.data['quote_id']?.toString() ??
                          message.data['designId']?.toString() ??
                          message.data['quoteId']?.toString() ??
                          message.data['enquiry_id']?.toString() ??
                          message.data['enquiryId']?.toString() ??
                          message.data['id']?.toString();
      if (msgDesignId == widget.quote.designId || msgDesignId == null) {
        if (mounted) {
          Provider.of<QuoteViewModel>(context, listen: false)
              .fetchQuoteDetail(widget.quote.designId);
        }
      }
    });
  }

  late final AuthViewModel _authVM;
  late final QuoteViewModel _quoteVM;
  late final NotificationViewModel _notificationVM;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authVM = Provider.of<AuthViewModel>(context, listen: false);
    _quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
    _notificationVM = Provider.of<NotificationViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _replyController.dispose();
    _fcmSubscription?.cancel();
    
    // Instantly refresh dashboard counts and lists when leaving this detail screen
    try {
      if (_authVM.user != null) {
        _notificationVM.fetchNotifications(_authVM.user!.userId);
        if (_authVM.user!.userType == '1') {
          _quoteVM.fetchAdminDesigns(_authVM);
        } else {
          _quoteVM.fetchQuotes(_authVM);
          _quoteVM.fetchMyOrders(_authVM);
          _quoteVM.fetchCompletedOrders(_authVM);
        }
      }
    } catch (e) {
      debugPrint('Error re-fetching lists on leaving QuoteDetailView: $e');
    }
    
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (selectedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(selectedImages.map((e) => e.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitReply() async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply message.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    final success = await quoteVM.submitReply(authVM, widget.quote.designId, replyText, imagePaths: _selectedImages);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        _replyController.clear();
        setState(() {
          _selectedImages.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply submitted successfully')),
        );
        // Refresh details
        quoteVM.fetchQuoteDetail(widget.quote.designId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quoteVM.errorMessage ?? 'Failed to submit reply')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quote Details'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Consumer<QuoteViewModel>(
        builder: (context, quoteVM, child) {
          if (quoteVM.isDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryButton));
          }

          if (quoteVM.errorMessage != null && quoteVM.quoteDetail == null) {
            return Center(child: Text(quoteVM.errorMessage!));
          }

          final detailData = quoteVM.quoteDetail;
          final currentQuote = detailData?.detail ?? widget.quote;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (detailData != null && detailData.images.isNotEmpty) ...[
                    _buildImagesGrid(detailData.images),
                    const SizedBox(height: 24),
                  ],
                  _buildDetailsCard(currentQuote),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showSendEmailDialog(context, widget.quote.designId);
                    },
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: Text(
                      'Email Project Details',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (detailData != null && detailData.process.isNotEmpty) ...[
                    _buildProcessList(detailData.process, currentQuote),
                    const SizedBox(height: 32),
                  ],
                  _buildReplySection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagesGrid(List<QuoteDetailImageModel> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageDialog(context, images[index].imageUrl),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: images[index].imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[50],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[50],
                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildDetailRow(String label, String? value) {
    if (value == null) return null;
    final clean = value.trim();
    if (clean.isEmpty || 
        clean.toLowerCase() == 'n/a' || 
        clean.toLowerCase() == 'n / a' || 
        clean == '0000-00-00 00:00:00' || 
        clean == '/' || 
        clean == ' / ') {
      return null;
    }
    return _buildModernDetailRow(label, clean);
  }

  Widget? _buildStatusRowIfAvailable(String label, String? value, bool isApproval, {String? statusValue}) {
    if (value == null) return null;
    final clean = value.trim();
    if (clean.isEmpty || 
        clean.toLowerCase() == 'n/a' || 
        clean.toLowerCase() == 'n / a') {
      return null;
    }
    return _buildStatusRow(label, clean, isApproval, statusValue: statusValue);
  }

  List<Widget> _buildSectionItems(List<Widget?> items) {
    final validItems = items.whereType<Widget>().toList();
    final result = <Widget>[];
    for (int i = 0; i < validItems.length; i++) {
      result.add(validItems[i]);
      if (i < validItems.length - 1) {
        result.add(const SizedBox(height: 12));
      }
    }
    return result;
  }

  Widget? _buildSection({required String title, required List<Widget?> items}) {
    final children = _buildSectionItems(items);
    if (children.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  List<Widget> _buildAllSections(QuoteModel quote) {
    final clientInfo = _buildSection(
      title: 'Client Info',
      items: [
        _buildDetailRow('Company', quote.company),
        _buildDetailRow('Name', quote.name),
        _buildDetailRow('Email', quote.email),
        _buildDetailRow('Contact', quote.contact),
      ],
    );

    final designSpecs = _buildSection(
      title: 'Design Details',
      items: [
        if (quote.productTitle.isNotEmpty)
          _buildModernDetailRow('Product', quote.productTitle),
        if (quote.productId != null && quote.productId!.isNotEmpty)
          _buildModernDetailRow('Product ID', quote.productId!),
        if (quote.itemNo != null && quote.itemNo!.isNotEmpty)
          _buildModernDetailRow('Item No', quote.itemNo!),
        _buildDetailRow('Ref Number', quote.referenceNumber),
        _buildDetailRow('Objective', quote.cleanMsg),
        _buildDetailRow('Timeframe', quote.frame),
        _buildDetailRow('Price/Budget', quote.budget.isNotEmpty ? '\$${quote.budget}' : null),
        _buildDetailRow('Metal', quote.metal),
        if (quote.metalColor != null && quote.metalColor!.isNotEmpty)
          _buildModernDetailRow('Metal Color', quote.metalColor!),
        _buildDetailRow('Finger Size', quote.size),
        if (quote.nbLength != null && quote.nbLength!.isNotEmpty)
          _buildModernDetailRow('NB Length', quote.nbLength!),
        _buildDetailRow('Diamond Total Wt', quote.diamondWeight),
        if (quote.diamondClarity != null && quote.diamondClarity!.isNotEmpty)
          _buildModernDetailRow('Diamond Clarity', quote.diamondClarity!),
        _buildDetailRow('Color Total Wt', quote.colorDiamondWeight),
        _buildDetailRow('Center Diamond', quote.centerDiamond),
        _buildDetailRow('Engraving', quote.engraving),
        if (quote.displayMatchingPair.isNotEmpty)
          _buildModernDetailRow('Customer Supply Stone', quote.displayMatchingPair.toUpperCase()),
        if (quote.displayCustomerStoneDetails.isNotEmpty && quote.displayCustomerStoneDetails.toLowerCase() != 'no')
          _buildModernDetailRow('Supply Stone Details', quote.displayCustomerStoneDetails),
      ],
    );

    final status = _buildSection(
      title: 'Status & Tracking',
      items: [
        _buildStatusRowIfAvailable('Processing Status', quote.status, false),
        _buildStatusRowIfAvailable('Status', _getApprovalText(quote.isApproved, quote.processingStatus), true, statusValue: quote.isApproved),
        _buildDetailRow('Job Number', quote.jobNo),
        _buildDetailRow('Request Date', quote.createDate),
        _buildDetailRow('Modified Date', quote.editDate == '0000-00-00 00:00:00' ? null : quote.editDate),
        if (quote.reply.isNotEmpty)
          _buildModernDetailRow('Latest Reply', quote.reply),
      ],
    );

    final validSections = [clientInfo, designSpecs, status].whereType<Widget>().toList();
    final result = <Widget>[];
    for (int i = 0; i < validSections.length; i++) {
      result.add(validSections[i]);
      if (i < validSections.length - 1) {
        result.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
        );
      }
    }
    return result;
  }

  Widget _buildDetailsCard(QuoteModel quote) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune, size: 20, color: AppColors.primaryButton),
                ),
                const SizedBox(width: 12),
                Text(
                  'Specifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: _buildAllSections(quote),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryButton,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value) {
    final displayValue = value.isNotEmpty && value != ' / ' ? value : 'N/A';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            displayValue,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, bool isApproval, {String? statusValue}) {
    Color bgColor = Colors.grey[100]!;
    Color textColor = Colors.grey[800]!;
    
    if (isApproval) {
      if (statusValue == '2') {
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
      } else if (statusValue == '1') {
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
      } else {
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
      }
    } else {
      if (value.toLowerCase() == 'completed' || value.toLowerCase() == 'approved') {
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
      } else if (value.toLowerCase() == 'pending') {
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
      } else if (value.toLowerCase() == 'processing' || value.toLowerCase() == 'in progress') {
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.isNotEmpty ? value : 'N/A',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessList(List<QuoteProcessModel> process, QuoteModel currentQuote) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Section header ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryButton.withOpacity(0.08),
                AppColors.primaryButton.withOpacity(0.02),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryButton.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.forum_outlined, size: 20, color: AppColors.primaryButton),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Communication History',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${process.length} message${process.length == 1 ? '' : 's'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Message bubbles ──────────────────────────────────────────────
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: process.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final p = process[index];
            final isUser = p.createdBy != '1';
            final isFirst = index == 0;
            final isLast  = index == process.length - 1;

            return _buildMessageBubble(
              p: p,
              isUser: isUser,
              isFirst: isFirst,
              isLast: isLast,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required QuoteProcessModel p,
    required bool isUser,
    required bool isFirst,
    required bool isLast,
  }) {
    // Colour tokens
    final bubbleGradient = isUser
        ? const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final textColor         = isUser ? Colors.white        : Colors.black87;
    final subtextColor      = isUser ? Colors.white60      : Colors.grey[500]!;
    final labelColor        = isUser ? Colors.white70      : Colors.grey[600]!;
    final chipBg            = isUser
        ? Colors.white.withOpacity(0.12)
        : AppColors.primaryButton.withOpacity(0.06);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Admin avatar (left side)
        if (!isUser) ...[
          _buildAvatar(isUser: false),
          const SizedBox(width: 10),
        ],

        // Bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: bubbleGradient,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(18),
                topRight:    const Radius.circular(18),
                bottomLeft:  isUser ? const Radius.circular(18) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4)  : const Radius.circular(18),
              ),
              border: isUser
                  ? null
                  : Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? const Color(0xFF1A1A2E).withOpacity(0.18)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Sender label row ─────────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUser ? 'You' : 'Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isUser
                              ? AppColors.primaryButton.withOpacity(0.9)
                              : AppColors.primaryButton,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ── Message text ─────────────────────────────────────
                  Text(
                    p.message,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // ── Attached images ──────────────────────────────────
                  if (p.images.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildProcessImagesGallery(p.images, isUser: isUser),
                  ],

                  // ── Attached videos ──────────────────────────────────
                  if (p.videos.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildProcessVideosGallery(p.videos, isUser: isUser),
                  ],

                  // ── Status chips ─────────────────────────────────────
                  if (p.processingStatus.isNotEmpty ||
                      (p.status != null && p.status!.isNotEmpty)) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isUser
                              ? Colors.white.withOpacity(0.15)
                              : AppColors.primaryButton.withOpacity(0.12),
                        ),
                      ),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (p.status != null && p.status!.isNotEmpty)
                            _buildChip(
                              icon: Icons.label_outline_rounded,
                              label: p.status!,
                              textColor: labelColor,
                            ),
                          if (p.processingStatus.isNotEmpty)
                            _buildChip(
                              icon: Icons.bolt_rounded,
                              label: _getProcessingStatusText(p.processingStatus),
                              textColor: isUser
                                  ? Colors.white
                                  : AppColors.primaryButton,
                              bold: true,
                            ),
                        ],
                      ),
                    ),
                  ],

                  // ── Timestamp ────────────────────────────────────────
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.access_time_rounded, size: 11, color: subtextColor),
                      const SizedBox(width: 3),
                      Text(
                        p.createDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: subtextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // User avatar (right side)
        if (isUser) ...[
          const SizedBox(width: 10),
          _buildAvatar(isUser: true),
        ],
      ],
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.primaryButton.withOpacity(0.15),
                  AppColors.primaryButton.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isUser
              ? Colors.white.withOpacity(0.15)
              : AppColors.primaryButton.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? Colors.black : AppColors.primaryButton).withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_rounded : Icons.support_agent_rounded,
          size: 17,
          color: isUser ? Colors.white : AppColors.primaryButton,
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color textColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: textColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: textColor,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessImagesGallery(List<QuoteProcessImageModel> images, {bool isUser = false}) {
    if (images.isEmpty) return const SizedBox();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images.map((img) => GestureDetector(
        onTap: () => _showImageDialog(context, img.imageUrl),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: img.imageUrl,
                height: 84,
                width: 84,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 84, width: 84,
                  color: isUser ? Colors.white12 : Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isUser ? Colors.white54 : AppColors.primaryButton,
                    ),
                  ),
                ),
                errorWidget: (context, url, err) => Container(
                  height: 84, width: 84,
                  color: isUser ? Colors.white12 : Colors.grey[200],
                  child: Icon(Icons.broken_image_outlined, size: 22,
                      color: isUser ? Colors.white54 : Colors.grey),
                ),
              ),
            ),
            // Tap overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.zoom_in_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildProcessVideosGallery(List<QuoteProcessVideoModel> videos, {bool isUser = false}) {
    if (videos.isEmpty) return const SizedBox();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: videos.map((vid) => GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => VideoDialog(videoUrl: vid.videoUrl),
          );
        },
        child: Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white30, width: 1.5),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'VIDEO',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildReplySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.reply_outlined, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                'Leave a Reply',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _replyController,
            maxLines: 4,
            hintText: 'Type your message here...',
            fillColor: Colors.grey[50],
          ),
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12, top: 8),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImages[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryButton, size: 20),
                  label: Text(
                    'Add Images',
                    style: GoogleFonts.poppins(color: AppColors.primaryButton, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primaryButton),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Reply',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSendEmailDialog(BuildContext context, String designId) {
    final TextEditingController emailController = TextEditingController();
    bool isDialogSending = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              titlePadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Send Images in Email',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  )
                ],
              ),
              contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email Address*',
                    keyboardType: TextInputType.emailAddress,
                    fillColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDialogSending
                          ? null
                          : () async {
                              final email = emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(content: Text('Please enter an email address.')),
                                );
                                return;
                              }
                              
                              setState(() {
                                isDialogSending = true;
                              });

                              final authVM = Provider.of<AuthViewModel>(dialogContext, listen: false);
                              final quoteVM = Provider.of<QuoteViewModel>(dialogContext, listen: false);

                              final success = await quoteVM.sendImagesInEmail(authVM, designId, email);

                              if (mounted) {
                                setState(() {
                                  isDialogSending = false;
                                });
                                if (success) {
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text('Email Has Been Sent Successfully!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    SnackBar(content: Text(quoteVM.errorMessage ?? 'Failed to send email.')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 0,
                      ),
                      child: isDialogSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Send Your Project',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton, 
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getApprovalText(String isApproved, String processingStatus) {
    if (isApproved == '2') return 'Reject';
    if (isApproved == '1') {
      if (processingStatus == '6') {
        return 'Completed';
      }
      return 'Approved';
    }
    return 'Pending';
  }

  String _getProcessingStatusText(String status) {
    switch (status) {
      case '1': return 'New Quote';
      case '2': return 'Sent Quote';
      case '3': return 'Approved';
      case '4': return 'Sent CAD';
      case '5': return 'CAD Approved';
      case '6': return 'Finished';
      default: return status;
    }
  }
}

class VideoDialog extends StatefulWidget {
  final String videoUrl;
  const VideoDialog({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller.play();
        }
      }).catchError((error) {
        debugPrint("Error loading video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: _initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),
          if (_initialized)
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white.withOpacity(0.8),
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}


