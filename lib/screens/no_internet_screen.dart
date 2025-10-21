import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 600;
          final iconSize = isSmallScreen ? 80.0 : 120.0;
          final titleFontSize = isSmallScreen ? 20.0 : 28.0;
          final messageFontSize = isSmallScreen ? 14.0 : 16.0;
          final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 20, vertical: 12) : EdgeInsets.symmetric(horizontal: 30, vertical: 15);
          final buttonTextStyle = isSmallScreen ? TextStyle(fontSize: 16) : TextStyle(fontSize: 18);

          return Center(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedWifi01,
                    size: iconSize,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: isSmallScreen ? 15 : 20),
                  Text(
                    'No Internet Connection',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontSize: titleFontSize),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  Text(
                    'Please check your network settings and try again.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700], fontSize: messageFontSize),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: buttonPadding,
                      textStyle: buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
