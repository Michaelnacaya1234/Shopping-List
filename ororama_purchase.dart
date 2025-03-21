import 'dart:convert';
import 'dart:io';
import 'package:database/index/ororama_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class OroramaPurchase extends StatefulWidget {
  const OroramaPurchase({super.key});

  @override
  _MasterListState createState() => _MasterListState();
}

class _MasterListState extends State<OroramaPurchase> {
  final Box _masterBox = Hive.box('masterL');
  final Box _priceBox = Hive.box('priceB');
  final Box _shoppingBox = Hive.box('shoppingL');

  void _archiveItem(int index) {
    try {
      setState(() {
        List<dynamic> masterList = _masterBox.get('list', defaultValue: []);
        if (index >= 0 && index < masterList.length) {
          Map<String, dynamic> archivedItem = Map.from(masterList[index]);
          masterList.removeAt(index);
          _masterBox.put('list', masterList);

          List<dynamic> archiveList = List.from(
            _shoppingBox.get('archive', defaultValue: []),
          );
          archiveList.add(archivedItem);
          _shoppingBox.put('archive', archiveList);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'The item ${archivedItem["name"]} has been archived.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to archive item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showArchiveAllConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Archive All Items",
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: Text(
            "Are you sure you want to archive all items from the master list?",
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              onPressed: () {
                _archiveAllItems();
                Navigator.of(context).pop();
              },
              child: Text("Archive"),
            ),
          ],
        );
      },
    );
  }

  void _archiveAllItems() {
    setState(() {
      List<dynamic> masterList = _masterBox.get('list', defaultValue: []);
      if (masterList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No items to archive'),
            backgroundColor: Colors.grey,
          ),
        );
        return;
      }

      List<dynamic> archiveList = List.from(
        _shoppingBox.get('archive', defaultValue: []),
      );
      archiveList.addAll(masterList.map((item) => Map.from(item)));
      _shoppingBox.put('archive', archiveList);

      _masterBox.put('list', []);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All items have been archived.'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  double _calculateTotalAmount(List<dynamic> masterList) {
    double total = 0.0;
    for (var item in masterList) {
      double? latestPrice = _priceBox.get(item["name"]);
      double price = latestPrice ?? (item["price"] as num).toDouble();
      total += price * (item["quantity"] as num);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> masterList = _masterBox.get('list', defaultValue: []);
    double totalAmount = _calculateTotalAmount(masterList);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Purchase List",
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
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.shopping_cart, color: Colors.white, size: 30),
          ),
        ],
      ),
      drawer: darwerOrorama(context),
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
                  "Archive",
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
                  masterList.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.archive_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No items in the Purchase list!",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: masterList.length,
                        itemBuilder: (context, index) {
                          final item = Map<String, dynamic>.from(
                            masterList[index],
                          );
                          double? latestPrice = _priceBox.get(item["name"]);
                          double price =
                              latestPrice ?? (item["price"] as num).toDouble();

                          String dateTime =
                              item["dateTime"] != null
                                  ? DateFormat(
                                    'MMM d, hh:mm a',
                                  ).format(DateTime.parse(item["dateTime"]))
                                  : 'No Date';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: _buildImageWidget(item["image"]),
                              title: Text(
                                item["name"] ?? 'Unknown',
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
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Added on: $dateTime",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.archive,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                onPressed: () => _archiveItem(index),
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
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _showArchiveAllConfirmationDialog,
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
                  "Archive All",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }

    try {
      Widget imageWidget;

      if (imagePath.startsWith('data:image')) {
        // Handle base64 encoded images
        imageWidget = Image.memory(
          base64Decode(imagePath.split(',').last),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      } else if (imagePath.startsWith('assets/')) {
        // Handle asset images
        imageWidget = Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      } else {
        // Handle file-based images
        imageWidget = Image.file(
          File(imagePath),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      );
    } catch (e) {
      // Fallback for any errors
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }
  }
}
