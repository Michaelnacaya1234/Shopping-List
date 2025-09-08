import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:database/drawer.dart';
import 'package:database/gaisano_p2.dart';
import 'package:database/products.dart';
import 'package:database/masterlist.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final Box _shoppingBox = Hive.box('shoppingList');
  final Box _priceBox = Hive.box('priceBox');
  final Box _masterBox = Hive.box('masterList');

  @override
  Widget build(BuildContext context) {
    List<dynamic> shoppingList = _shoppingBox.get('list', defaultValue: []);
    double totalAmount = _calculateTotalAmount(shoppingList);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shopping Lists",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.list_alt, color: Colors.white, size: 30),
          ),
        ],
      ),
      drawer: createDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue[700],
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GaisanoP2()),
                  ),
              icon: const Icon(Icons.store_mall_directory, size: 25),
            ),
            label: "Mall",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Products()),
                  ),
              icon: const Icon(Icons.search_rounded, size: 25),
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.list_alt,
                color: Color.fromARGB(255, 96, 97, 96),
                size: 40,
              ),
            ),
            label: "List",
          ),
        ],
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Product Name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  "Purchase",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            Expanded(
              child:
                  shoppingList.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No items in your Shopping List!",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: shoppingList.length,
                        itemBuilder: (context, index) {
                          final item = Map<String, dynamic>.from(
                            shoppingList[index],
                          );
                          double? latestPrice = _priceBox.get(item["name"]);
                          double price =
                              latestPrice ?? (item["price"] as num).toDouble();

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: _buildImageWidget(item["image"]),
                              title: Text(
                                item["name"] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item["flavor"] != null &&
                                      item["flavor"].isNotEmpty)
                                    Text(
                                      "${item["flavor"]}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  Text(
                                    "₱${price.toStringAsFixed(2)} x ${item["quantity"] ?? 0}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _decrementQuantity(index),
                                  ),
                                  Text(
                                    "${item["quantity"]}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => _incrementQuantity(index),
                                  ),
                                  SizedBox(width: 10),
                                  Checkbox(
                                    value: false,
                                    onChanged: (bool? value) {
                                      if (value == true) {
                                        _moveToPurchaseList(index);
                                      }
                                    },
                                    activeColor: Colors.blueAccent,
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Card(
              color: Colors.blueAccent,
              elevation: 6,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "₱${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _showClearShoppingListDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Clear",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 6,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MasterList()),
            ),
        child: Icon(Icons.shopping_cart, size: 40, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }
    try {
      if (imagePath.startsWith('data:image')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(imagePath.split(',').last),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      } else if (imagePath.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              );
            },
          ),
        );
      }
    } catch (e) {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }
  }

  double _calculateTotalAmount(List<dynamic> shoppingList) {
    double total = 0.0;
    for (var item in shoppingList) {
      double? latestPrice = _priceBox.get(item["name"]);
      double price = latestPrice ?? (item["price"] as num).toDouble();
      total += price * (item["quantity"] as num);
    }
    return total;
  }

  void _incrementQuantity(int index) {
    List<dynamic> shoppingList = _shoppingBox.get('list', defaultValue: []);
    if (index >= 0 && index < shoppingList.length) {
      setState(() {
        shoppingList[index]["quantity"] =
            (shoppingList[index]["quantity"] as num) + 1;
        _shoppingBox.put('list', shoppingList);
      });
    }
  }

  void _decrementQuantity(int index) {
    List<dynamic> shoppingList = _shoppingBox.get('list', defaultValue: []);
    if (index >= 0 && index < shoppingList.length) {
      setState(() {
        int currentQuantity = shoppingList[index]["quantity"] as int;
        if (currentQuantity > 0) {
          shoppingList[index]["quantity"] = currentQuantity - 1;
          if (currentQuantity == 1) {
            String itemName = shoppingList[index]["name"];
            shoppingList.removeAt(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$itemName has been removed from shopping list"),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 2),
              ),
            );
          }
          _shoppingBox.put('list', shoppingList);
        }
      });
    }
  }

  void _moveToPurchaseList(int index) {
    List<dynamic> shoppingList = _shoppingBox.get('list', defaultValue: []);
    if (index >= 0 && index < shoppingList.length) {
      setState(() {
        Map<String, dynamic> itemToMove = Map.from(shoppingList[index]);
        String itemName = itemToMove["name"];
        String itemFlavor =
            itemToMove["flavor"] ?? ""; // Default to empty string if no flavor
        itemToMove["dateTime"] = DateTime.now().toIso8601String();
        shoppingList.removeAt(index);
        _shoppingBox.put('list', shoppingList);

        List<dynamic> masterList = _masterBox.get('list', defaultValue: []);
        // Check for duplicates based on both name and flavor
        bool exists = masterList.any(
          (item) =>
              item["name"] == itemName && (item["flavor"] ?? "") == itemFlavor,
        );
        if (!exists) {
          masterList.add(itemToMove);
          _masterBox.put('list', masterList);
        } else {
          // If the item exists, update its quantity instead of adding a duplicate
          int existingIndex = masterList.indexWhere(
            (item) =>
                item["name"] == itemName &&
                (item["flavor"] ?? "") == itemFlavor,
          );
          masterList[existingIndex]["quantity"] =
              (masterList[existingIndex]["quantity"] as num) +
              (itemToMove["quantity"] as num);
          _masterBox.put('list', masterList);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$itemName${itemFlavor.isNotEmpty ? " ($itemFlavor)" : ""} has been moved to purchase list",
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _showClearShoppingListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Clear Shopping List",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: Text(
            "Are you sure you want to remove all items from the shopping list?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _clearShoppingList();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  void _clearShoppingList() {
    setState(() {
      _shoppingBox.put('list', []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All items have been removed from the shopping list."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
