import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/my_files_viewmodel.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MyFilesViewModel>().fetchGalleryFiles();
      context.read<MyFilesViewModel>().setGallerySearchQuery('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('My Gallery'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/Custom_Banner.jpeg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.65),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Premium jewelry showcase with modern responsive design.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                onChanged: (value) => context.read<MyFilesViewModel>().setGallerySearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search gallery...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          Consumer<MyFilesViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoadingGallery && viewModel.galleryFiles.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (viewModel.galleryError != null && viewModel.galleryFiles.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      viewModel.galleryError!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (viewModel.galleryFiles.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No data available',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = viewModel.galleryFiles[index];
                      return _buildGalleryCard(
                        context,
                        imageUrl: item.fileUrl,
                        fileName: item.fileName,
                      );
                    },
                    childCount: viewModel.galleryFiles.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(
    BuildContext context, {
    required String imageUrl,
    required String fileName,
  }) {
    String displayName = fileName;
    int extIndex = fileName.lastIndexOf('.');
    if (extIndex > 0) {
      displayName = fileName.substring(0, extIndex);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: const Color(0xFFE2E8F0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.toLowerCase().endsWith('.3dm'))
                      Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_in_ar, size: 48, color: Colors.grey.shade500),
                              const SizedBox(height: 8),
                              Text(
                                '3DM',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 600, // reduce memory usage
                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                            color: const Color(0xFF67B08B),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconButton(
                            iconWidget: const Icon(Icons.download, color: Colors.white, size: 18),
                            onTap: () => _launchUrl(imageUrl, context),
                          ),
                          const SizedBox(width: 8),
                          _buildIconButton(
                            iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                            onTap: () => _shareToWhatsApp(imageUrl, context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              displayName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required Widget iconWidget, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: iconWidget,
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not download file')),
        );
      }
    }
  }

  Future<void> _shareToWhatsApp(String url, BuildContext context) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(url)}');
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }
}


