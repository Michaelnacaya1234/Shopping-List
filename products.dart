import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:database/Classes/all_products.dart';
import 'package:database/Classes/product.dart';
import 'package:database/Classes/product8.dart';
import 'package:database/Classes/product9.dart';
import 'package:database/ShoppingList.dart';
import 'package:database/drawer.dart';
import 'package:database/gaisano_p2.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:database/Classes/canned.dart';
import 'package:database/Classes/product1.dart';
import 'package:database/Classes/product2.dart';
import 'package:database/Classes/product3.dart';
import 'package:database/Classes/product4.dart';
import 'package:database/Classes/product5.dart';
import 'package:database/Classes/product6.dart';
import 'package:database/Classes/product7.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CameraPreviewScreen extends StatefulWidget {
  final CameraController cameraController;

  const CameraPreviewScreen({super.key, required this.cameraController});

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    widget.cameraController
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        })
        .catchError((e) {
          print('Error initializing camera: $e');
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile image = await widget.cameraController.takePicture();
      if (mounted) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Product Image'),
        backgroundColor: Colors.blue[700],
      ),
      body:
          _isInitialized
              ? Stack(
                children: [
                  CameraPreview(widget.cameraController),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FloatingActionButton(
                        onPressed: _captureImage,
                        backgroundColor: Colors.blueAccent,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final Box _shoppingBox = Hive.box('shoppingList');
  final Box _budgetBox = Hive.box('budgetBox');
  final Box _priceBox = Hive.box('priceBox');
  final Box productsBox = Hive.box('productsBox'); // Overall products box

  // Category-specific Hive boxes
  final Box productsBox1 = Hive.box('canned'); // Canned
  final Box productsBox2 = Hive.box('noodles'); // Instant Noodles / Pasta
  final Box productsBox3 = Hive.box('sauce'); // Cooking oil / Sauce
  final Box productsBox4 = Hive.box('coffee'); // Coffee / Powdered milk
  final Box productsBox5 = Hive.box('Chocolates'); // Chocolates / Candies
  final Box productsBox6 = Hive.box('biscuit'); // Biscuit / JunkFoods
  final Box productsBox7 = Hive.box('wines'); // Wines
  final Box productsBox8 = Hive.box('diswashing'); // Dishwashing
  final Box productsBox9 = Hive.box('rice'); // Rice / Sugar
  final Box productsBox10 = Hive.box('meat'); // Fresh meat / Frozen Goods
  final Box productsBox11 = Hive.box('hair'); // Hair care / Soaps

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  bool _isSearchVisible = false;
  double _budget = 0.0;
  List<Map<String, dynamic>> _filteredProducts = [];
  List<Map<String, dynamic>> products = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;

  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  final List _listCategories = [
    'All',
    'Biscuit / JunkFoods',
    'Canned',
    'Chocolates / Candies',
    'Coffee / Powdered milk',
    'Cooking oil / Sauce',
    'Dishwashing',
    'Fresh meat / Frozen Goods',
    'Hair care / Soaps',
    'Instant Noodles / Pasta',
    'Rice / Sugar',
    'Wines',
  ];

  String? _selectedCategories;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
    _filteredProducts = List.from(products); // Initially show all products
    _searchController.addListener(_filterProducts);
    _budgetController.addListener(_updateBudget);

    _budget = _budgetBox.get('budget', defaultValue: 0.0);
    _budgetController.text = _budget.toString();

    _loadPricesFromHive();

    _speech = stt.SpeechToText();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      _initializeControllerFuture = _cameraController.initialize();
    }
  }

  void _loadAllProducts() {
    // Load products from all category-specific boxes to avoid duplication
    products = [];
    final allBoxes = [
      productsBox1,
      productsBox2,
      productsBox3,
      productsBox4,
      productsBox5,
      productsBox6,
      productsBox7,
      productsBox8,
      productsBox9,
      productsBox10,
      productsBox11,
    ];

    for (var box in allBoxes) {
      products.addAll(
        box.values.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
    }
    // Remove duplicates based on name and flavor
    products = products.fold<List<Map<String, dynamic>>>([], (
      uniqueList,
      product,
    ) {
      if (!uniqueList.any(
        (item) =>
            item["name"] == product["name"] &&
            item["flavor"] == product["flavor"],
      )) {
        uniqueList.add(product);
      }
      return uniqueList;
    });
  }

  void _loadPricesFromHive() {
    for (var product in products) {
      double? savedPrice = _priceBox.get(product["name"]);
      if (savedPrice != null) {
        product["price"] = savedPrice;
      }
    }
    setState(() {
      _filteredProducts = List.from(products);
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts =
          products.where((product) {
            final matchesQuery = product["name"].toLowerCase().contains(query);
            final matchesCategory =
                _selectedCategories == null ||
                _selectedCategories == 'All' ||
                product["category"] == _selectedCategories;
            return matchesQuery && matchesCategory;
          }).toList();
    });
  }

  void _updateBudget() {
    final budgetText = _budgetController.text;
    if (budgetText.isEmpty) {
      setState(() {
        _budget = 0.0;
      });
      return;
    }

    final budget = double.tryParse(budgetText);
    if (budget == null) {
      setState(() {
        _budget = 0.0;
      });
      return;
    }

    setState(() {
      _budget = budget;
      _budgetBox.put('budget', _budget);
    });
  }

  void _incrementQuantity(Map<String, dynamic> product) {
    setState(() {
      product['quantity'] = (product['quantity'] ?? 0) + 1;
    });
  }

  void _resetQuantity(Map<String, dynamic> product) {
    setState(() {
      product['quantity'] = 0;
    });
  }

  void _addToShoppingList(Map<String, dynamic> product) {
    int quantity = product['quantity'] ?? 0;
    if (quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add quantity before adding to Shopping List!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    List<Map<String, dynamic>> shoppingList =
        (_shoppingBox.get('list', defaultValue: []) as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    int existingIndex = shoppingList.indexWhere(
      (item) =>
          item["name"] == product["name"] &&
          item["flavor"] == product["flavor"],
    );

    double currentTotalPrice = shoppingList.fold(
      0.0,
      (sum, item) => sum + ((item["price"] as num) * (item["quantity"] as num)),
    );
    double potentialTotalPrice =
        currentTotalPrice + ((product["price"] as num) * quantity);

    if (potentialTotalPrice > _budget && _budget > 0) {
      double excessAmount = potentialTotalPrice - _budget;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adding this item exceeds your budget by ₱${excessAmount.toStringAsFixed(2)}!',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (existingIndex != -1) {
      shoppingList[existingIndex]["quantity"] =
          (shoppingList[existingIndex]["quantity"] as num) + quantity;
    } else {
      shoppingList.add({
        "name": product["name"],
        "flavor": product["flavor"] ?? "",
        "image": product["image"],
        "price": product["price"],
        "quantity": quantity,
      });
    }

    _shoppingBox.put('list', shoppingList);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product["name"]} added to Shopping List!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    _resetQuantity(product);
  }

  void _decrementQuantity(Map<String, dynamic> product) {
    setState(() {
      if ((product['quantity'] ?? 0) > 0) {
        product['quantity'] = (product['quantity'] as int) - 1;
      }
    });
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  Future<void> _editPrice(Map<String, dynamic> product) async {
    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) {
        final priceController = TextEditingController(
          text: product["price"].toString(),
        );
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Edit Price',
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'New Price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text);
                if (newPrice != null) Navigator.of(context).pop(newPrice);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );

    if (newPrice != null) {
      setState(() {
        product["price"] = newPrice;
        _priceBox.put(product["name"], newPrice);
        _updateProductInBoxes(product);
      });
    }
  }

  Future<void> _editProductDetails(Map<String, dynamic> product) async {
    // Store the original name to find the product in the box later
    final originalName = product["name"];

    final newDetails = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: product["name"]);
        final flavorController = TextEditingController(
          text: product["flavor"] ?? "",
        );
        final priceController = TextEditingController(
          text: product["price"].toString(),
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Edit Product Details',
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: flavorController,
                decoration: InputDecoration(
                  labelText: 'Flavor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text;
                final newFlavor = flavorController.text;
                final newPrice = double.tryParse(priceController.text);

                if (newName.isNotEmpty && newPrice != null) {
                  Navigator.of(context).pop({
                    "name": newName,
                    "flavor": newFlavor,
                    "image": product["image"],
                    "price": newPrice,
                    "category": product["category"],
                    "originalName":
                        originalName, // Pass the original name for reference
                  });
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );

    if (newDetails != null) {
      setState(() {
        // Update the in-memory product
        product["name"] = newDetails["name"];
        product["flavor"] = newDetails["flavor"];
        product["price"] = newDetails["price"];

        // Update the price in priceBox with the new name
        _priceBox.delete(originalName); // Remove old name entry
        _priceBox.put(
          newDetails["name"],
          newDetails["price"],
        ); // Add new name entry

        // Update the product in the appropriate Hive box
        _updateProductInBoxes(product, originalName: originalName);
      });
    }
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Delete Product',
              style: TextStyle(color: Colors.blueAccent),
            ),
            content: Text(
              'Are you sure you want to delete "${product["name"]}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete == true) {
      setState(() {
        _deleteProductFromBoxes(product);
        _loadAllProducts();
        _filterProducts();
        _priceBox.delete(product["name"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product["name"]} has been deleted'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult:
              (val) => setState(() {
                _searchController.text = val.recognizedWords;
                _filterProducts();
              }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _updateProductInBoxes(
    Map<String, dynamic> product, {
    String? originalName,
  }) {
    Box categoryBox = _getBoxForCategory(product["category"]);
    int categoryIndex = categoryBox.values.toList().indexWhere(
      (item) => item["name"] == (originalName ?? product["name"]),
    );
    if (categoryIndex != -1) {
      // Update the product at the found index using the key
      var key = categoryBox.keys.toList()[categoryIndex];
      categoryBox.put(key, product);
    }
    _loadAllProducts(); // Reload to ensure consistency
    _filterProducts();
  }

  void _deleteProductFromBoxes(Map<String, dynamic> product) {
    Box categoryBox = _getBoxForCategory(product["category"]);
    int categoryIndex = categoryBox.values.toList().indexWhere(
      (item) => item["name"] == product["name"],
    );
    if (categoryIndex != -1) {
      categoryBox.deleteAt(categoryIndex);
    }
  }

  Box _getBoxForCategory(String category) {
    switch (category) {
      case 'All':
        return productsBox;
      case 'Canned':
        return productsBox1;
      case 'Instant Noodles / Pasta':
        return productsBox2;
      case 'Cooking oil / Sauce':
        return productsBox3;
      case 'Coffee / Powdered milk':
        return productsBox4;
      case 'Chocolates / Candies':
        return productsBox5;
      case 'Biscuit / JunkFoods':
        return productsBox6;
      case 'Wines':
        return productsBox7;
      case 'Dishwashing':
        return productsBox8;
      case 'Rice / Sugar':
        return productsBox9;
      case 'Fresh meat / Frozen Goods':
        return productsBox10;
      case 'Hair care / Soaps':
        return productsBox11;
      default:
        return productsBox3; // Default to Cooking oil / Sauce if category not found
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _searchController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: AnimatedOpacity(
          opacity: _isSearchVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Visibility(
            visible: _isSearchVisible,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Discover deals and products...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.blueAccent,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.blueAccent,
                    ),
                    onPressed: _listen,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 30, color: Colors.white),
              onPressed: _toggleSearchVisibility,
            ),
          ),
        ],
        backgroundColor: Colors.blue[700],
      ),
      drawer: createDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        backgroundColor: Colors.blue[700],
        elevation: 8,

        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GaisanoP2()),
                  ),
              icon: const Icon(Icons.store_mall_directory, size: 25),
            ),
            label: "Mall",
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.search_rounded,
              size: 40,
              color: Color.fromARGB(255, 96, 97, 96),
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShoppingList(),
                    ),
                  ),
              icon: const Icon(Icons.list_alt, size: 25),
            ),
            label: "List",
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShoppingList()),
            );
          }
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Budget: ₱${_budget.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedCategories,
                  hint: const Text(
                    "Select Category",
                    style: TextStyle(color: Colors.grey),
                  ),
                  isExpanded: true,
                  underline: Container(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blueAccent,
                  ),
                  items:
                      _listCategories.map((mall) {
                        return DropdownMenuItem<String>(
                          value: mall,
                          child: Text(
                            mall,
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategories = value;
                      _filterProducts(); // Filter products based on selection
                      if (value == 'All') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllProducts(),
                          ),
                        );
                      } else if (value == 'Instant Noodles / Pasta') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product(),
                          ),
                        );
                      } else if (value == 'Canned') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Canned(),
                          ),
                        );
                      } else if (value == 'Cooking oil / Sauce') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product1(),
                          ),
                        );
                      } else if (value == 'Coffee / Powdered milk') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product2(),
                          ),
                        );
                      } else if (value == 'Chocolates / Candies') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product3(),
                          ),
                        );
                      } else if (value == 'Biscuit / JunkFoods') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product4(),
                          ),
                        );
                      } else if (value == 'Wines') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product5(),
                          ),
                        );
                      } else if (value == 'Dishwashing') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product6(),
                          ),
                        );
                      } else if (value == 'Rice / Sugar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product7(),
                          ),
                        );
                      } else if (value == 'Fresh meat / Frozen Goods') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product8(),
                          ),
                        );
                      } else if (value == 'Hair care / Soaps') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Product9(),
                          ),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Budget",
                  hintText: "e.g., 1000",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: Colors.blueAccent,
                  ),
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('sauce').listenable(),
                builder: (context, Box box, _) {
                  _loadAllProducts();
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No products added yet!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              0.5, // Adjusted to fit category text
                        ),
                    itemBuilder: (context, index) {
                      Map<String, dynamic> product = _filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            heroTag: "searchButton",
            onPressed: _toggleSearchVisibility,
            elevation: 4,
            child: const Icon(Icons.search, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.white,
            heroTag: "addButton",
            onPressed: _pickImage,
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child:
                product['image'].startsWith('data:image')
                    ? Image.memory(
                      base64Decode(product['image'].split(',').last),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      frameBuilder: (_, child, frame, __) {
                        return frame == null
                            ? const CircularProgressIndicator()
                            : child;
                      },
                    )
                    : Image.file(
                      File(product['image']),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      frameBuilder: (_, child, frame, __) {
                        return frame == null
                            ? const CircularProgressIndicator()
                            : child;
                      },
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 120,
                            color: Colors.grey,
                          ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['flavor'] ?? 'No Flavor',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${product['category'] ?? 'Uncategorized'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${(product['price'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Qty: ${product['quantity'] ?? '0'}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _decrementQuantity(product),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.blueAccent,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () => _incrementQuantity(product),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blueAccent,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _addToShoppingList(product),
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _editProductDetails(product),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blueAccent,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: () => _deleteProduct(product),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final newProduct = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          final nameController = TextEditingController();
          final flavorController = TextEditingController();
          final priceController = TextEditingController();
          File? imageFile;
          String? imageBase64;
          String? selectedCategory;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text(
                  'Add New Product',
                  style: TextStyle(color: Colors.blueAccent),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: flavorController,
                        decoration: InputDecoration(
                          labelText: 'Flavor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          hint: const Text(
                            "Select Category",
                            style: TextStyle(color: Colors.grey),
                          ),
                          isExpanded: true,
                          underline: Container(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blueAccent,
                          ),
                          items:
                              _listCategories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (kIsWeb) {
                                FilePickerResult? result = await FilePicker
                                    .platform
                                    .pickFiles(
                                      type: FileType.image,
                                      withData: true,
                                    );
                                if (result != null &&
                                    result.files.single.bytes != null) {
                                  imageBase64 = base64Encode(
                                    result.files.single.bytes!,
                                  );
                                  setState(() {});
                                }
                              } else {
                                final returnedImage = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (returnedImage != null) {
                                  imageFile = File(returnedImage.path);
                                  setState(() {});
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Gallery',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _initializeControllerFuture;
                              final capturedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CameraPreviewScreen(
                                        cameraController: _cameraController,
                                      ),
                                ),
                              );
                              if (capturedImage != null) {
                                imageFile = capturedImage;
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Camera',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            imageFile!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (imageBase64 != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(imageBase64!),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final price = double.tryParse(priceController.text);
                      if (nameController.text.isNotEmpty &&
                          priceController.text.isNotEmpty &&
                          price != null &&
                          selectedCategory != null &&
                          (imageFile != null || imageBase64 != null)) {
                        Navigator.of(context).pop({
                          'name': nameController.text,
                          'flavor': flavorController.text,
                          'price': price,
                          'image':
                              kIsWeb
                                  ? 'data:image/png;base64,$imageBase64'
                                  : imageFile!.path,
                          'quantity': 0,
                          'category': selectedCategory,
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill all required fields including category',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add Product',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (newProduct != null) {
        Box targetBox = _getBoxForCategory(newProduct["category"]);
        await targetBox.add(newProduct); // Add only to category-specific box
        setState(() {
          _loadAllProducts();
          _filterProducts();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${newProduct["name"]} has been added successfully to ${newProduct["category"]}!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
