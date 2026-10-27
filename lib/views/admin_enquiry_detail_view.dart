import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/quote_model.dart';
import '../models/quote_detail_model.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'components/custom_text_field.dart';

class AdminEnquiryDetailView extends StatefulWidget {
  final QuoteModel quote;
  const AdminEnquiryDetailView({Key? key, required this.quote}) : super(key: key);

  @override
  State<AdminEnquiryDetailView> createState() => _AdminEnquiryDetailViewState();
}

class _AdminEnquiryDetailViewState extends State<AdminEnquiryDetailView> {
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedImages = [];
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  // Controllers and values for editing
  late String _isApproved;
  late String _processingStatus;
  late TextEditingController _dtwController;
  late TextEditingController _ctwController;
  late TextEditingController _metalController;
  late TextEditingController _centerDiamondController;
  late TextEditingController _referenceNumberController;
  late TextEditingController _poController;
  late TextEditingController _budgetController;

  bool _isInitializedWithDetail = false;

  @override
  void initState() {
    super.initState();
    _isApproved = widget.quote.isApproved.isEmpty ? '0' : widget.quote.isApproved;
    _processingStatus = widget.quote.processingStatus.isEmpty ? '1' : widget.quote.processingStatus;
    _dtwController = TextEditingController(text: widget.quote.diamondWeight ?? '');
    _ctwController = TextEditingController(text: widget.quote.colorDiamondWeight ?? '');
    _metalController = TextEditingController(text: widget.quote.metal);
    _centerDiamondController = TextEditingController(text: widget.quote.centerDiamond);
    _referenceNumberController = TextEditingController(text: widget.quote.referenceNumber);
    _poController = TextEditingController(text: widget.quote.po ?? '');
    _budgetController = TextEditingController(text: widget.quote.budget);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
      await quoteVM.fetchQuoteDetail(widget.quote.designId);
      if (mounted) {
        final auth = Provider.of<AuthViewModel>(context, listen: false);
        final notificationVM = Provider.of<NotificationViewModel>(context, listen: false);
        if (auth.user != null) {
          notificationVM.fetchNotifications(auth.user!.userId);
        }
      }
    });

    // Listen for foreground notifications to refresh the enquiry details instantly
    _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('AdminEnquiryDetailView received foreground message: ${message.data}');
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

  @override
  void dispose() {
    _replyController.dispose();
    _dtwController.dispose();
    _ctwController.dispose();
    _metalController.dispose();
    _centerDiamondController.dispose();
    _referenceNumberController.dispose();
    _poController.dispose();
    _budgetController.dispose();
    _fcmSubscription?.cancel();
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



  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _showAttachmentTypeActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo (Camera)'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose Photos (Gallery)'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _calculateTotalSizeMB() async {
    int totalBytes = 0;
    for (var path in _selectedImages) {
      final file = File(path);
      if (await file.exists()) {
        totalBytes += await file.length();
      }
    }
    return totalBytes / (1024 * 1024);
  }

  void _submitEditForm() async {
    final replyText = _replyController.text.trim();

    final totalSizeMB = await _calculateTotalSizeMB();
    if (totalSizeMB > 8.0) {
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Large Attachment Warning'),
          content: Text(
            'The total size of your attachments is ${totalSizeMB.toStringAsFixed(1)} MB.\n\n'
            'Many servers (including CodeIgniter/PHP defaults) limit uploads to 8 MB. '
            'Exceeding this limit will cause the server to discard the request and return a "403 Forbidden" error.\n\n'
            'Do you want to attempt the upload anyway?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1C18D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Upload Anyway', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ) ?? false;

      if (!shouldProceed) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
    final auth = Provider.of<AuthViewModel>(context, listen: false);

    bool success = true;

    // 1. If there is a reply or selected images, submit them to submitReply (which calls /m_api/design-process-submit)
    if (replyText.isNotEmpty || _selectedImages.isNotEmpty) {
      final replySuccess = await quoteVM.submitReply(
        auth,
        widget.quote.designId,
        replyText.isNotEmpty ? replyText : "Updated specifications",
        imagePaths: _selectedImages,
      );
      if (!replySuccess) {
        success = false;
      }
    }

    // 2. Submit the design specifications to submitDesignEdit (but with reply and imagePaths set to empty/null!)
    if (success) {
      final editSuccess = await quoteVM.submitDesignEdit(
        designId: widget.quote.designId,
        isApproved: _isApproved,
        processingStatus: _processingStatus,
        diamondWeight: _dtwController.text.trim(),
        colorDiamondWeight: _ctwController.text.trim(),
        budget: _budgetController.text.trim(),
        metal: _metalController.text.trim(),
        centerDiamond: _centerDiamondController.text.trim(),
        referenceNumber: _referenceNumberController.text.trim(),
        po: _poController.text.trim(),
        reply: "", // empty reply, so /m_api/design-edit-submit doesn't try to insert another log or upload files
        imagePaths: null, // null images
        videoPaths: null,
        userId: auth.user?.userId ?? "1",
      );
      if (!editSuccess) {
        success = false;
      }
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        _replyController.clear();
        setState(() {
          _selectedImages.clear();
          _isInitializedWithDetail = false; // Allow re-initialization with new server values
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enquiry details and reply updated successfully')),
        );
        // Refresh details
        quoteVM.fetchQuoteDetail(widget.quote.designId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quoteVM.errorMessage ?? 'Failed to update enquiry')),
        );
      }
    }
  }

  void _confirmAndDelete() async {
    final quoteVM = Provider.of<QuoteViewModel>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Enquiry?'),
        content: const Text(
          'Are you sure you want to delete this enquiry? '
          'This action cannot be undone and the enquiry will be permanently removed.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm && mounted) {
      setState(() {
        _isSubmitting = true;
      });
      final success = await quoteVM.deleteDesign(widget.quote.designId);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enquiry deleted successfully')),
          );
          Navigator.of(context).pop(true); // Return true to indicate deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(quoteVM.errorMessage ?? 'Failed to delete enquiry')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5),
      appBar: AppBar(
        title: const Text('Enquiry Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _isSubmitting ? null : _confirmAndDelete,
            tooltip: 'Delete Enquiry',
          ),
          const SizedBox(width: 8),
        ],
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

          if (detailData != null && !_isInitializedWithDetail) {
            _isApproved = currentQuote.isApproved.isEmpty ? '0' : currentQuote.isApproved;
            _processingStatus = currentQuote.processingStatus.isEmpty ? '1' : currentQuote.processingStatus;
            _dtwController.text = currentQuote.diamondWeight ?? '';
            _ctwController.text = currentQuote.colorDiamondWeight ?? '';
            _metalController.text = currentQuote.metal;
            _centerDiamondController.text = currentQuote.centerDiamond;
            _referenceNumberController.text = currentQuote.referenceNumber;
            _poController.text = currentQuote.po ?? '';
            _budgetController.text = currentQuote.budget;
            _isInitializedWithDetail = true;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Gallery Section
                  if (detailData != null && detailData.images.isNotEmpty) ...[
                    _buildImagesGrid(detailData.images),
                    const SizedBox(height: 24),
                  ] else if (widget.quote.image.isNotEmpty) ...[
                    _buildSingleImageHeader(widget.quote.imageUrl),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildFallbackImageHeader(),
                    const SizedBox(height: 24),
                  ],
                  // Specifications
                  _buildDetailsCard(currentQuote),
                  const SizedBox(height: 32),
                  // Communication history
                  if (detailData != null && detailData.process.isNotEmpty) ...[
                    _buildProcessList(detailData.process, currentQuote),
                    const SizedBox(height: 32),
                  ],
                  // Edit & Reply form
                  _buildEditForm(currentQuote),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleImageHeader(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showImageDialog(context, imageUrl),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[50], child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[50],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text('Image not available', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackImageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 50),
              const SizedBox(height: 12),
              Text(
                'Image not available',
                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
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
        _buildDetailRow('Reference', quote.referenceNumber),
        if (quote.po != null && quote.po!.isNotEmpty)
          _buildModernDetailRow('PO', quote.po!),
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
        _buildStatusRowIfAvailable('Status', quote.isApproved == '1' ? 'Approved' : 'Pending', true, statusValue: quote.isApproved),
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
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryButton,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value) {
    final displayValue = value.isNotEmpty && value != ' / ' ? value.trim() : 'N/A';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 13,
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
              fontSize: 13,
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
      if (statusValue == '1') {
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
              fontSize: 13,
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
                  fontSize: 11,
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
                    'Process / Communication',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${process.length} log${process.length == 1 ? '' : 's'}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
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
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: process.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final p = process[index];
            final isUser = p.createdBy != '1';
            return _buildMessageBubble(
              p: p,
              isUser: isUser,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required QuoteProcessModel p,
    required bool isUser,
  }) {
    final isSenderAdmin = p.createdBy == '1';

    if (p.message.isEmpty && p.images.isEmpty && p.videos.isEmpty) {
      final statusText = p.status != null && p.status!.isNotEmpty ? 'Status updated to: ${p.status}' : 'Specifications updated';
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            isSenderAdmin ? 'Admin: $statusText' : 'Client: $statusText',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final bubbleGradient = LinearGradient(
      colors: [Colors.white, Colors.grey.shade50],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const textColor = Colors.black87;
    final subtextColor = Colors.grey[500]!;
    final chipBg = AppColors.primaryButton.withOpacity(0.06);

    final senderLabel = isSenderAdmin ? 'ADMIN' : 'USER';
    final labelColor = isSenderAdmin ? Colors.green.shade700 : Colors.red.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildAvatar(isUser: !isSenderAdmin),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              gradient: bubbleGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        senderLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.message,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (p.images.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildProcessImagesGallery(p.images, isUser: false),
                  ],

                  if (p.processingStatus.isNotEmpty || (p.status != null && p.status!.isNotEmpty)) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryButton.withOpacity(0.12),
                        ),
                      ),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (p.status != null && p.status!.isNotEmpty)
                            _buildChip(icon: Icons.label_outline_rounded, label: p.status!, textColor: AppColors.primaryButton),
                          if (p.processingStatus.isNotEmpty)
                            _buildChip(
                              icon: Icons.bolt_rounded,
                              label: p.processingStatus == '1' ? 'New Quote' : p.processingStatus,
                              textColor: AppColors.primaryButton,
                              bold: true,
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.access_time_rounded, size: 10, color: subtextColor),
                      const SizedBox(width: 3),
                      Text(
                        p.createDate,
                        style: GoogleFonts.poppins(fontSize: 10, color: subtextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
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
          color: isUser ? Colors.white.withOpacity(0.15) : AppColors.primaryButton.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_rounded : Icons.support_agent_rounded,
          size: 15,
          color: isUser ? Colors.white : AppColors.primaryButton,
        ),
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label, required Color textColor, bool bold = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: textColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: textColor, fontWeight: bold ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProcessImagesGallery(List<QuoteProcessImageModel> images, {bool isUser = false}) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: images.map((img) => GestureDetector(
        onTap: () => _showImageDialog(context, img.imageUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: img.imageUrl,
            height: 72, width: 72,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: isUser ? Colors.white12 : Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
            errorWidget: (context, url, err) => Container(color: isUser ? Colors.white12 : Colors.grey[200], child: const Icon(Icons.broken_image_outlined, size: 18, color: Colors.grey)),
          ),
        ),
      )).toList(),
    );
  }



  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black45),
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(QuoteModel currentQuote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              const Icon(Icons.rate_review_outlined, color: AppColors.primaryButton, size: 20),
              const SizedBox(width: 10),
              Text(
                'Edit Enquiry & Reply',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Dropdowns Row (Status & Processing Status)
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Status',
                  value: _isApproved,
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('Pending')),
                    DropdownMenuItem(value: '1', child: Text('Approved')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _isApproved = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Processing Status',
                  value: _processingStatus,
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('New Quote')),
                    DropdownMenuItem(value: '3', child: Text('Approved')),
                    DropdownMenuItem(value: '6', child: Text('Finished')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _processingStatus = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Specs Grid Row 1 (DTW & CTW)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Diamond Total Wt (DTW)'),
                    CustomTextField(
                      controller: _dtwController,
                      hintText: 'e.g. 1.50',
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Color Total Wt (CTW)'),
                    CustomTextField(
                      controller: _ctwController,
                      hintText: 'e.g. 0.85',
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Specs Grid Row 2 (Metal & Center Diamond)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Metal'),
                    CustomTextField(
                      controller: _metalController,
                      hintText: 'e.g. 14k White Gold',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Center Diamond'),
                    CustomTextField(
                      controller: _centerDiamondController,
                      hintText: 'e.g. 1.00ct Round',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Specs Grid Row 3 (Reference & PO)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Reference'),
                    CustomTextField(
                      controller: _referenceNumberController,
                      hintText: 'e.g. 10452',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('PO'),
                    CustomTextField(
                      controller: _poController,
                      hintText: 'e.g. PO-9876',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Specs Grid Row 4 (Price/Budget)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Price / Budget'),
                    CustomTextField(
                      controller: _budgetController,
                      hintText: 'e.g. 2500',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 20),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),

          // Reply Message Field
          _buildFieldLabel('Reply Message'),
          CustomTextField(
            controller: _replyController,
            hintText: 'Enter your reply or process log message here...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Attachments Section
          if (_selectedImages.isNotEmpty) ...[
            SizedBox(
              height: 85,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final path = _selectedImages[index];

                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Picker buttons and Submit row
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _showAttachmentTypeActionSheet,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text('Add Photo', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black54,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEditForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'SUBMIT',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, err) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
