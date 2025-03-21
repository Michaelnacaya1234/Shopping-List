import 'dart:convert';
import 'dart:io';
import 'package:database/index/ororama_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class OroramaArchive extends StatefulWidget {
  const OroramaArchive({super.key});

  @override
  _ArchiveState createState() => _ArchiveState();
}

class _ArchiveState extends State<OroramaArchive> {
  final Box _shoppingBox = Hive.box('shoppingL');
  final Box _priceBox = Hive.box('priceB');
  final Box _masterBox = Hive.box('masterL');

  @override
  Widget build(BuildContext context) {
    List<dynamic> archiveList = _shoppingBox.get('archive', defaultValue: []);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Archive List",
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
            child: Icon(Icons.archive, color: Colors.white, size: 30),
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
                  "Products Name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  "Restore",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  "Delete",
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
                  archiveList.isEmpty
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
                              "No items in the archive!",
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
                        itemCount: archiveList.length,
                        itemBuilder: (context, index) {
                          final item =
                              archiveList[index] is Map
                                  ? Map<String, dynamic>.from(
                                    archiveList[index],
                                  )
                                  : {};
                          double? latestPrice = _priceBox.get(item["name"]);
                          double price =
                              latestPrice ??
                              (item["price"] as num?)?.toDouble() ??
                              0.0;

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
                                    "Archived on: $dateTime",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.restore,
                                      color: Colors.green,
                                      size: 28,
                                    ),
                                    onPressed: () => _restoreFromArchive(index),
                                  ),
                                  SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 28,
                                    ),
                                    onPressed: () => _deleteFromArchive(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            if (archiveList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Items: ${archiveList.length}",
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                    ElevatedButton(
                      onPressed: _deleteAllArchiveItems,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Delete All",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
        imageWidget = Image.memory(
          base64Decode(imagePath.split(',').last),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          frameBuilder: (_, child, frame, __) {
            return frame == null
                ? CircularProgressIndicator()
                : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
          },
        );
      } else if (imagePath.startsWith('assets/')) {
        imageWidget = Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          frameBuilder: (_, child, frame, __) {
            return frame == null
                ? CircularProgressIndicator()
                : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
          },
        );
      } else {
        imageWidget = Image.file(
          File(imagePath),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          frameBuilder: (_, child, frame, __) {
            return frame == null
                ? CircularProgressIndicator()
                : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: child,
                );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            );
          },
        );
      }
      return imageWidget;
    } catch (e) {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }
  }

  void _restoreFromArchive(int index) {
    setState(() {
      List<dynamic> archiveList = List.from(
        _shoppingBox.get('archive', defaultValue: []),
      );
      if (index >= 0 && index < archiveList.length) {
        Map<String, dynamic> restoredItem = Map<String, dynamic>.from(
          archiveList.removeAt(index),
        );
        _shoppingBox.put('archive', archiveList);

        List<dynamic> masterList = List.from(
          _masterBox.get('list', defaultValue: []),
        );
        masterList.add(restoredItem);
        _masterBox.put('list', masterList);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Item ${restoredItem["name"] ?? ''} restored!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _deleteFromArchive(int index) {
    setState(() {
      List<dynamic> archiveList = List.from(
        _shoppingBox.get('archive', defaultValue: []),
      );
      if (index >= 0 && index < archiveList.length) {
        final deletedItem = archiveList.removeAt(index);
        _shoppingBox.put('archive', archiveList);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Item ${deletedItem["name"] ?? ''} deleted!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _deleteAllArchiveItems() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Delete All Archive Items",
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: Text(
            "Are you sure you want to delete all items from the archive?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _shoppingBox.put('archive', []);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("All archive items removed!"),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
