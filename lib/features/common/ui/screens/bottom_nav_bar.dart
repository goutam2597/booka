import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/account/ui/screens/account_screen.dart';
import 'package:bookapp_customer/features/appointments/ui/screens/appointments_screen.dart';
import 'package:bookapp_customer/features/common/providers/nav_provider.dart';
import 'package:bookapp_customer/features/services/ui/screens/services_screen.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../home/ui/screens/home_screen.dart';

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
// --------------------------------------------

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final List<Widget> _navBarScreens;
  late final PageController _pageController;

  late final NavProvider _nav;
  VoidCallback? _navListener;

  @override
  void initState() {
    super.initState();

    _nav = context.read<NavProvider>();
    _pageController = PageController(initialPage: widget.initialIndex);

    _navBarScreens = const [
      KeepAliveWrapper(child: HomeScreen()),
      KeepAliveWrapper(child: ServicesScreen()),
      KeepAliveWrapper(child: AppointmentsScreen()),
      KeepAliveWrapper(child: AccountScreen()),
    ];

    _navListener = () {
      final idx = _nav.index;
      if (!_pageController.hasClients) return;
      final current =
          _pageController.page?.round() ?? _pageController.initialPage;
      if (current != idx) {
        _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
        );
      }
    };
    _nav.addListener(_navListener!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nav.setIndex(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    if (_navListener != null) {
      _nav.removeListener(_navListener!);
      _navListener = null;
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onTappedItem(BuildContext context, int index) async {
    final nav = _nav;

    // Home and Services do NOT force login
    if (index == 0 || index == 1) {
      nav.setIndex(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
        );
      }
      return;
    }

    // Appointments and Account require login
    if (!AuthAndNetworkService.isLoggedIn.value) {
      final loggedIn = await Get.toNamed(AppRoutes.login) as bool?;

      if (loggedIn == true && AuthAndNetworkService.isLoggedIn.value) {
        nav.setIndex(index);
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    } else {
      nav.setIndex(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavProvider>().index;

    return ValueListenableBuilder<bool>(
      valueListenable: AuthAndNetworkService.isLoggedIn,
      builder: (context, loggedIn, _) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            allowImplicitScrolling: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _navBarScreens,
            onPageChanged: (i) => _nav.setIndex(i),
          ),
          bottomNavigationBar: _buildBottomBar(context, currentIndex),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex) {
    final width = MediaQuery.sizeOf(context).width;
    final appointmentsLabel = width < 370 ? 'Appt' : 'Appointments';
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          _buildNavItem(0, 'Home', AssetsPath.homeSvg, currentIndex),
          _buildNavItem(1, 'Services', AssetsPath.serviceSvg, currentIndex),
          _buildNavItem(
            2,
            appointmentsLabel,
            AssetsPath.appointmentSvg,
            currentIndex,
          ),
          _buildNavItem(3, 'Account', AssetsPath.accountSvg, currentIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    String iconPath,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryColor : Colors.grey.shade800;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTappedItem(context, index),
          borderRadius: BorderRadius.circular(99),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  iconPath,
                  height: 32,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                Text(
                  label.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
