import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'admin_enquiries_view.dart';
import 'quotes_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class HomeView extends StatefulWidget {

  final Function(int)? onNavigate;
  const HomeView({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoadingProfile = true;
  String? _cadGalleryName;
  String? _cadGalleryStatus;

  bool get _isAdmin {
    final auth = context.read<AuthViewModel>();
    return auth.user?.userType == '1';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfile();
      _fetchCounts();
    });
  }

  void _fetchCounts() {
    final auth = context.read<AuthViewModel>();
    final quoteVM = context.read<QuoteViewModel>();
    if (auth.user != null) {
      Provider.of<NotificationViewModel>(context, listen: false).fetchNotifications(auth.user!.userId);
      if (auth.user!.userType == '1') {
        quoteVM.fetchAdminDesigns(auth);
      } else {
        quoteVM.fetchQuotes(auth);
        quoteVM.fetchMyOrders(auth);
        quoteVM.fetchCompletedOrders(auth);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchProfile();
    _fetchCounts();
  }

  Future<void> _fetchProfile() async {
    final auth = context.read<AuthViewModel>();
    final profile = await auth.fetchProfile();
    if (mounted) {
      setState(() {
        _cadGalleryName = profile?.cadGalleryName;
        _cadGalleryStatus = profile?.cadGalleryStatus;
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF1B3B8B),
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingText(),
                SizedBox(height: _isAdmin ? 12 : 8),
                _buildWelcomeBanner(),
                SizedBox(height: _isAdmin ? 12 : 8),
                _buildDashboardGrid(context),
                if (!_isAdmin) ...[
                  const SizedBox(height: 10),
                  _buildContactCard(),
                  const SizedBox(height: 10),
                  _buildHighlightsRow(),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            children: [
              const TextSpan(text: "Let's create something "),
              TextSpan(
                text: 'beautiful',
                style: GoogleFonts.playball(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1B3B8B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: _isAdmin ? 1920 / 920 : 1920 / 800,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Custom_Banner.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return Consumer<QuoteViewModel>(
      builder: (context, quoteVM, _) {
        final List<Widget> items = [];

        if (_isAdmin) {
          // Admin Dashboard Items - Rendered as a vertical list
          items.add(
            _buildAdminListCard(
              context,
              title: 'New Quotes',
              subtitle: 'Review incoming design quotes',
              icon: Icons.chat_bubble_outline_outlined,
              badgeCount: quoteVM.unreadAdminQuotesCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminEnquiriesView(initialStatus: 'Quote')),
                );
              },
            ),
          );

          items.add(
            _buildAdminListCard(
              context,
              title: 'Active Orders',
              subtitle: 'Manage ongoing production orders',
              icon: Icons.shopping_bag_outlined,
              badgeCount: quoteVM.unreadAdminOrdersCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminEnquiriesView(initialStatus: 'Order')),
                );
              },
            ),
          );

          items.add(
            _buildAdminListCard(
              context,
              title: 'Completed Orders',
              subtitle: 'View finished client orders',
              icon: Icons.fact_check_outlined,
              badgeCount: quoteVM.unreadAdminCompletedOrdersCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminEnquiriesView(initialStatus: 'Completed')),
                );
              },
            ),
          );

          items.add(
            _buildAdminListCard(
              context,
              title: 'All Enquiries',
              subtitle: 'Browse all customer enquiries',
              icon: Icons.admin_panel_settings_outlined,
              badgeCount: quoteVM.unreadAdminEnquiriesCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminEnquiriesView(initialStatus: 'All')),
                );
              },
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
              //   child: Text(
              //     'Quick Actions',
              //     style: GoogleFonts.poppins(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black87,
              //       letterSpacing: 0.5,
              //     ),
              //   ),
              // ),
              ...items.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: card,
              )).toList(),
            ],
          );
        } else {
          // Standard User Dashboard Items - Rendered as Grid
          items.add(
            _buildDashboardItem(
              context,
              title: 'Jewelry',
              subtitle: 'Explore Custom\nJewelry Collection',
              icon: Icons.diamond_outlined,
              onTap: () {
                if (widget.onNavigate != null) {
                  widget.onNavigate!(1);
                }
              },
            ),
          );

          items.add(
            _buildDashboardItem(
              context,
              title: 'Custom',
              subtitle: 'Create Your Own\nDream Jewelry Design',
              icon: Icons.auto_awesome_outlined,
              onTap: () {
                if (widget.onNavigate != null) {
                  widget.onNavigate!(2);
                }
              },
            ),
          );

          items.add(
            _buildDashboardItem(
              context,
              title: 'My Orders',
              subtitle: 'Track and manage\nyour orders',
              icon: Icons.shopping_bag_outlined,
              badgeCount: quoteVM.myOrders.length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuotesView(type: 'my_orders')),
                );
              },
            ),
          );

          items.add(
            _buildDashboardItem(
              context,
              title: 'My Quotes',
              subtitle: 'View and manage\nyour quotes',
              icon: Icons.chat_bubble_outline_outlined,
              badgeCount: quoteVM.quotes.length,
              onTap: () => Navigator.pushNamed(context, '/quotes'),
            ),
          );

          items.add(
            _buildDashboardItem(
              context,
              title: 'Completed Orders',
              subtitle: 'View your completed\norders',
              icon: Icons.fact_check_outlined,
              badgeCount: quoteVM.completedOrders.length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuotesView(type: 'completed_orders')),
                );
              },
            ),
          );

          // Shared items for CAD Gallery if applicable
          if (!_isLoadingProfile &&
              _cadGalleryName != null &&
              _cadGalleryName!.isNotEmpty &&
              _cadGalleryStatus == '1') {
            items.add(
              _buildDashboardItem(
                context,
                title: 'My CAD',
                subtitle: 'View your\nCAD designs',
                icon: Icons.architecture_outlined,
                onTap: () => Navigator.pushNamed(context, '/my_cad'),
              ),
            );
            items.add(
              _buildDashboardItem(
                context,
                title: 'My Gallery',
                subtitle: 'View your\ngallery',
                icon: Icons.photo_library_outlined,
                onTap: () => Navigator.pushNamed(context, '/gallery'),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.40,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          );
        }
      },
    );
  }

  Widget _buildAdminListCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1.0),
        ),
        child: Row(
          children: [
            // Icon container with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F1FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFF4A7AD0),
                      size: 24,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron container
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF1B3B8B),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F1FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFF4A7AD0),
                      size: 20,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF1B3B8B),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF1B3B8B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Blanton',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Info@blantonslab.com',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('mailto:Info@blantonslab.com');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.email_outlined,
                      color: Color(0xFF4A7AD0),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://wa.me/15708405757');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Color(0xFF2CD483),
                      size: 18,
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

  Widget _buildHighlightsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildHighlightItem(
                Icons.verified_user_outlined,
                'Secure &\nReliable',
              ),
            ),
            _buildHighlightDivider(),
            Expanded(
              child: _buildHighlightItem(
                Icons.diamond_outlined,
                'Premium\nQuality',
              ),
            ),
            _buildHighlightDivider(),
            Expanded(
              child: _buildHighlightItem(
                Icons.headset_mic_outlined,
                '24/7\nSupport',
                onTap: _openPhone,
              ),
            ),
            _buildHighlightDivider(),
            Expanded(
              child: _buildHighlightItem(
                Icons.workspace_premium_outlined,
                '100% Client\nSatisfaction',
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _openPhone() async {
    final Uri phoneUrl = Uri.parse('tel:+15708405757');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer')),
        );
      }
    }
  }

  Widget _buildHighlightItem(IconData icon, String text, {VoidCallback? onTap}) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: const Color(0xFF1B3B8B),
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 7.5,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.2,
          ),
          maxLines: 3,
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }

  Widget _buildHighlightDivider() {
    return const VerticalDivider(
      color: Color(0xFFE2E8F0),
      thickness: 1,
      width: 8,
      indent: 4,
      endIndent: 4,
    );
  }
}
