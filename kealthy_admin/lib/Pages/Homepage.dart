import 'package:flutter/material.dart';
import 'package:kealthy_admin/Pages/Delivered_Orders.dart';
import 'Deliverying.dart'; // Ensure correct import for DeliveryPortal

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DeliveryPortal(),
    const DeliveredOrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    // Set a responsive width for the sidebar
    final double sidebarWidth = screenWidth > 600 ? 250 : screenWidth * 0.5;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: sidebarWidth,
            color: Colors.black,
            child: Column(
              children: [
                const SizedBox(height: 25),
                Image.asset(
                  "assets/Logo-removebg-preview.png",
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 50),
                Container(
                  color: _selectedIndex == 0 ? Colors.green[800] : Colors.black,
                  child: ListTile(
                    leading:
                        const Icon(Icons.local_shipping, color: Colors.white),
                    title: const Text(
                      'Delivering Now',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _onItemTapped(0),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: _selectedIndex == 1 ? Colors.green[800] : Colors.black,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outlined,
                        color: Colors.white),
                    title: const Text(
                      'Delivered',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _onItemTapped(1),
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
