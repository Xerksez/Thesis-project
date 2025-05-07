import 'package:flutter/material.dart';
import 'package:mobile/features/construction_home/views/widgets/construction_details.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/themes/styles.dart';
import '../../../shared/state/app_state.dart' as appState;

class ConstructionHomeScreen extends StatefulWidget {
  const ConstructionHomeScreen({super.key});

  @override
  _ConstructionHomeScreenState createState() => _ConstructionHomeScreenState();
}

class _ConstructionHomeScreenState extends State<ConstructionHomeScreen> {
  @override
  void initState() {
    super.initState();
    appState.currentPage = 'construction_home';
    appState.isConstructionContext = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło strony
          Container(decoration: AppStyles.backgroundDecoration),
          Container(color: AppStyles.filterColor.withOpacity(0.75)),
          Column(
            children: [
              // Nagłówek z nazwą budowy
              Container(
                width: double.infinity,
                color: AppStyles.transparentWhite,
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                child: Text(
                  appState.selectedConstructionName,
                  style: AppStyles.headerStyle.copyWith(color: Colors.black, fontSize: 22),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Szczegóły budowy
                    Expanded(
                      child: ConstructionDetails(),
                    ),   
                    ],
                ),
              ),
              BottomNavigation(onTap: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}
