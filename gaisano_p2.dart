import 'package:database/Shoppinglist.dart';
import 'package:database/drawer.dart';
import 'package:database/index/ororama_home.dart';
import 'package:database/products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GaisanoP2 extends StatefulWidget {
  const GaisanoP2({super.key});

  @override
  State<GaisanoP2> createState() => _GaisanoP2State();
}

class _GaisanoP2State extends State<GaisanoP2>
    with SingleTickerProviderStateMixin {
  final List<String> _mallList = ['Gaisano', 'Ororama'];
  String? _selectedMall;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMallDialog(String mall) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Mall Selection',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          content: Text(
            mall == 'Gaisano'
                ? "You're now in Gaisano Mall!"
                : "Are you going to change Ororama Mall?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            if (mall == 'Ororama')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OroramaHome(),
                    ),
                  );
                },
                child: const Text('Go', style: TextStyle(color: Colors.blue)),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back', style: TextStyle(color: Colors.blue)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gaisano",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),

        actions: const [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.store_mall_directory,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: createDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        backgroundColor: Colors.blue[700],
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.store_mall_directory,
                color: Color.fromARGB(255, 96, 97, 96),
                size: 40,
              ),
            ),
            label: "Mall",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Products()),
                );
              },
              icon: const Icon(Icons.search_rounded, size: 25),
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingList()),
                );
              },
              icon: const Icon(Icons.list_alt, size: 25),
            ),
            label: "List",
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Welcome to Your Shopping List",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Select a mall to view available products and start shopping!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 1000))
                      .slideY(
                        begin: 0.5,
                        end: 0.0,
                        duration: const Duration(milliseconds: 1000),
                      ),
                  const SizedBox(height: 30),
                  Container(
                        width: 350.0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue[300]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: _selectedMall,
                          hint: const Text(
                            "Select Mall",
                            style: TextStyle(color: Colors.grey),
                          ),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue,
                          ),
                          items:
                              _mallList.map((mall) {
                                return DropdownMenuItem<String>(
                                  value: mall,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.storefront,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(mall),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMall = value;
                              if (value != null) {
                                _showMallDialog(value);
                              }
                            });
                          },
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 200),
                      )
                      .scale(duration: const Duration(milliseconds: 1000)),
                  const SizedBox(height: 50),
                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[100],
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          size: 100,
                          color: Colors.blue,
                        ),
                      )
                      .animate()
                      .scale(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                      )
                      .then()
                      .rotate(duration: const Duration(milliseconds: 600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
