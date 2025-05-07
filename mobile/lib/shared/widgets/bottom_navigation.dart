import 'package:flutter/material.dart';
import '../state/app_state.dart' as appState;
import '../config/navigation_config.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int)? onTap;

  const BottomNavigation({super.key, this.onTap});

  PageRouteBuilder<dynamic> _createPageRoute(
      BuildContext context, String route, bool isRight) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return NavigationConfig.getDestinationScreen(route);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var slideTween = Tween(
          begin: Offset(isRight ? 0.1 : -0.1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.2, end: 1.0);
        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isConstructionMode = appState.isConstructionContext;
    final List<Map<String, dynamic>> navItems = NavigationConfig.getNavItems(isConstructionMode);

    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            thickness: 1,
            color: Colors.white,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final bool isCurrentPage = appState.currentPage == item['route'].replaceAll('/', '');

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isCurrentPage) {
                      bool isRight = index > navItems.indexWhere((navItem) =>
                          navItem['route'].replaceAll('/', '') == appState.currentPage);

                      appState.currentPage = item['route'].replaceAll('/', '');

                      if (isConstructionMode && item['route'] == '/home') {
                        appState.isConstructionContext = false;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => NavigationConfig.getDestinationScreen('/home')),
                        );
                      } else {
                        Navigator.of(context).push(
                          _createPageRoute(context, item['route'], isRight),
                        );
                      }
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'],
                        size: 20,
                        color: isCurrentPage ? Colors.white : Colors.black,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentPage ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}