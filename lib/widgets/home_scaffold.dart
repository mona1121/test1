import 'package:flutter/material.dart';

class HomeScaffold extends StatelessWidget {
  final Widget? child;
  final List<PopupMenuEntry<String>>? menuItems; // Accepts menu items as a parameter
  final Function(String)? onMenuItemSelected; // Callback for menu item selection

  const HomeScaffold({
    super.key,
    this.child,
    this.menuItems,
    this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (menuItems != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: onMenuItemSelected,
              itemBuilder: (context) => menuItems!,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/start2.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: child ?? Container(),
          ),
        ],
      ),
    );
  }
}
