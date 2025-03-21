import 'dart:convert';
import 'dart:io';
import 'package:database/drawer.dart';
import 'package:database/index/ororamalist.dart';
import 'package:database/index/products/all.dart';
import 'package:database/index/products/biscuit.dart';
import 'package:database/index/products/can.dart';
import 'package:database/index/products/chocolate.dart';
import 'package:database/index/products/cofee.dart';
import 'package:database/index/products/diswashing.dart';
import 'package:database/index/products/frozen.dart';
import 'package:database/index/products/hair.dart';
import 'package:database/index/products/noodles.dart';
import 'package:database/index/products/oil.dart';
import 'package:database/index/products/rice.dart';
import 'package:database/index/products/wine.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class OroramaAll extends StatefulWidget {
  const OroramaAll({super.key});

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<OroramaAll> {
  final Box _shoppingBox = Hive.box('shoppingL');
  final Box _budgetBox = Hive.box('budgetB');
  final Box _priceBox = Hive.box('priceB');
  final Box productsBox = Hive.box('productB'); // Overall products box

  final Box productsBox1 = Hive.box('canneds');
  final Box productsBox2 = Hive.box('noodless');
  final Box productsBox3 = Hive.box('sauces');
  final Box productsBox4 = Hive.box('coffees');
  final Box productsBox5 = Hive.box('Chocolatess');
  final Box productsBox6 = Hive.box('biscuits');
  final Box productsBox7 = Hive.box('winess');
  final Box productsBox8 = Hive.box('diswashings');
  final Box productsBox9 = Hive.box('rices');
  final Box productsBox10 = Hive.box('meats');
  final Box productsBox11 = Hive.box('hairs');

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  bool _isSearchVisible = false;
  double _budget = 0.0;

  late stt.SpeechToText _speech;
  bool _isListening = false;

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

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
    _searchController.addListener(_filterProducts);
    _budgetController.addListener(_updateBudget);

    _budget = _budgetBox.get('budget', defaultValue: 0.0);
    _budgetController.text = _budget.toString();

    _loadPricesFromHive();

    _speech = stt.SpeechToText();
  }

  void _loadAllProducts() {
    List<Map<String, dynamic>> combinedProducts = List.from(all_ororama ?? []);
    combinedProducts.addAll(
      productsBox.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox1.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox2.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox3.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox4.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox5.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox6.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox7.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox8.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox9.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox10.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
    combinedProducts.addAll(
      productsBox11.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );

    Map<String, Map<String, dynamic>> uniqueProducts = {};
    for (var product in combinedProducts) {
      String key = '${product["name"]}-${product["flavor"] ?? ""}';
      if (!uniqueProducts.containsKey(key)) {
        uniqueProducts[key] = Map<String, dynamic>.from(product);
        uniqueProducts[key]?['quantity'] = 0; // Initialize quantity
      }
    }

    setState(() {
      _filteredProducts = uniqueProducts.values.toList();
    });
    _loadPricesFromHive();
  }

  void _loadPricesFromHive() {
    for (var product in _filteredProducts) {
      double? savedPrice = _priceBox.get(product["name"]);
      if (savedPrice != null) {
        product["price"] = savedPrice;
      }
      // Ensure quantity is initialized
      product['quantity'] = product['quantity'] ?? 0;
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _loadAllProducts();
      _filteredProducts =
          _filteredProducts.where((product) {
            return product["name"].toLowerCase().contains(query);
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
      product['quantity'] = (product['quantity'] as int) + 1;
    });
  }

  void _resetQuantity(Map<String, dynamic> product) {
    setState(() {
      product['quantity'] = 0;
    });
  }

  void _addToShoppingList(Map<String, dynamic> product) {
    int quantity = product['quantity'] as int;
    if (quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          duration: Duration(seconds: 2),
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
        duration: Duration(seconds: 2),
      ),
    );

    _resetQuantity(product);
  }

  void _decrementQuantity(Map<String, dynamic> product) {
    setState(() {
      int currentQuantity = product['quantity'] as int;
      if (currentQuantity > 0) {
        product['quantity'] = currentQuantity - 1;
      }
    });
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _editPrice(Map<String, dynamic> product) async {
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
          title: Text('Edit Price', style: TextStyle(color: Colors.blueAccent)),
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
              child: Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text);
                if (newPrice != null) Navigator.of(context).pop(newPrice);
              },
              child: Text('Save', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );

    if (newPrice != null) {
      setState(() {
        product["price"] = newPrice;
        _priceBox.put(product["name"], newPrice);
        _updateProductInHive(product);
      });
    }
  }

  void _editProductDetails(Map<String, dynamic> product) async {
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
          title: Text(
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
              SizedBox(height: 10),
              TextField(
                controller: flavorController,
                decoration: InputDecoration(
                  labelText: 'Flavor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
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
              child: Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
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
              child: Text('Save', style: TextStyle(color: Colors.blueAccent)),
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
        _updateProductInHive(product, originalName: originalName);

        // Reload products to reflect changes
        _loadAllProducts();
        _filterProducts();
      });
    }
  }

  void _updateProductInHive(
    Map<String, dynamic> product, {
    String? originalName,
  }) {
    Box targetBox = _getBoxForCategory(product["category"] ?? 'All');
    int index = targetBox.values.toList().indexWhere(
      (item) => item["name"] == (originalName ?? product["name"]),
    );
    if (index != -1) {
      // Update the product at the found index
      targetBox.putAt(index, product);
    }
  }

  Box _getBoxForCategory(String category) {
    switch (category) {
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
        return productsBox;
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
                      if (_selectedCategories == 'All') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OroramaAll()),
                        );
                      } else if (_selectedCategories == 'Canned') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Can()),
                        );
                      } else if (_selectedCategories ==
                          'Instant Noodles / Pasta') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Noodles()),
                        );
                      } else if (_selectedCategories == 'Cooking oil / Sauce') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Oil()),
                        );
                      } else if (_selectedCategories ==
                          'Coffee / Powdered milk') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Coffe()),
                        );
                      } else if (_selectedCategories ==
                          'Chocolates / Candies') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Chocolate()),
                        );
                      } else if (_selectedCategories == 'Biscuit / JunkFoods') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Biscuit()),
                        );
                      } else if (_selectedCategories == 'Wines') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Wine()),
                        );
                      } else if (_selectedCategories == 'Dishwashing') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Diswashing()),
                        );
                      } else if (_selectedCategories == 'Rice / Sugar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Rice()),
                        );
                      } else if (_selectedCategories ==
                          'Fresh meat / Frozen Goods') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Frozen()),
                        );
                      } else if (_selectedCategories == 'Hair care / Soaps') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Hair()),
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
                valueListenable: Hive.box('productsBox').listenable(),
                builder: (context, Box box, _) {
                  return _filteredProducts.isEmpty
                      ? Center(
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
                              'No products available!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.60,
                            ),
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white,
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child:
                                        product['image'].startsWith(
                                              'data:image',
                                            )
                                            ? Image.memory(
                                              base64Decode(
                                                product['image']
                                                    .split(',')
                                                    .last,
                                              ),
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.file(
                                              File(product['image']),
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    product["image"],
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                            ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["name"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (product["flavor"] != null &&
                                          product["flavor"].isNotEmpty)
                                        Text(
                                          product["flavor"],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      Text(
                                        "₱${product["price"].toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Qty: ${product['quantity']}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed:
                                                    () => _decrementQuantity(
                                                      product,
                                                    ),
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed:
                                                    () => _incrementQuantity(
                                                      product,
                                                    ),
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed:
                                                () =>
                                                    _addToShoppingList(product),
                                            icon: const Icon(
                                              Icons.shopping_cart,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              "Add",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed:
                                                () => _editProductDetails(
                                                  product,
                                                ),
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                },
              ),
            ),
            const SizedBox(height: 20),
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
          const SizedBox(height: 30),
          FloatingActionButton(
            backgroundColor: Colors.white,
            heroTag: "addButton",
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Ororamalist()),
                ),
            elevation: 4,
            child: const Icon(
              Icons.list_alt,
              color: Colors.blueAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
