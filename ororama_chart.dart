import 'package:database/index/ororama_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

final Box _priceBox = Hive.box('priceBox');
final Box _masterBox = Hive.box('masterList');
final Box _historyBox = Hive.box('historyBox');
final Box _ororamaPriceBox = Hive.box('priceB');
final Box _ororamaMasterBox = Hive.box('masterL');
final Box _ororamaHistoryBox = Hive.box('historyB');

class OroramaChart extends StatefulWidget {
  const OroramaChart({super.key});

  @override
  _MallComparisonState createState() => _MallComparisonState();
}

class _MallComparisonState extends State<OroramaChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mall Comparison",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Ororama"), Tab(text: "Comparison")],
        ),
      ),
      drawer: darwerOrorama(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMallView(
            context,
            "Ororama",
            _ororamaMasterBox,
            _ororamaPriceBox,
            _ororamaHistoryBox,
          ),
          _buildComparisonView(context),
        ],
      ),
    );
  }

  Widget _buildMallView(
    BuildContext context,
    String mallName,
    Box masterBox,
    Box priceBox,
    Box historyBox,
  ) {
    final totalSpent = _calculateTotalSpent(masterBox, priceBox, historyBox);
    final totalAmount = totalSpent.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$mallName Mall",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  "Total: ₱${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Spending Breakdown by Item",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(flex: 2, child: _buildBarChart(totalSpent)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Purchase History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () => _clearHistory(context, historyBox),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Clear History",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(flex: 1, child: _buildPurchaseHistory(historyBox)),
        ],
      ),
    );
  }

  Widget _buildComparisonView(BuildContext context) {
    final ororamaSpent = _calculateTotalSpent(
      _ororamaMasterBox,
      _ororamaPriceBox,
      _ororamaHistoryBox,
    );
    final gaisanoSpent = _calculateTotalSpent(
      _masterBox,
      _priceBox,
      _historyBox,
    );
    final ororamaTotal = ororamaSpent.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    final gaisanoTotal = gaisanoSpent.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Comparison",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Ororama Total:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₱${ororamaTotal.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Gaisano Total:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₱${gaisanoTotal.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Difference:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₱${(ororamaTotal - gaisanoTotal).abs().toStringAsFixed(2)}",
                      style: TextStyle(
                        color:
                            ororamaTotal > gaisanoTotal
                                ? Colors.red
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Item-by-Item Comparison",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildComparisonTable(ororamaSpent, gaisanoSpent)),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
    Map<String, double> ororamaSpent,
    Map<String, double> gaisanoSpent,
  ) {
    Set<String> allItems = {...ororamaSpent.keys, ...gaisanoSpent.keys};
    List<DataRow> rows = [];
    int index = 0;

    for (var item in allItems) {
      final ororamaPrice = ororamaSpent[item] ?? 0.0;
      final gaisanoPrice = gaisanoSpent[item] ?? 0.0;
      final cheaperMall =
          ororamaPrice < gaisanoPrice
              ? "Ororama"
              : (ororamaPrice > gaisanoPrice ? "Gaisano" : "Equal");

      rows.add(
        DataRow(
          color: WidgetStateProperty.all(
            index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
          ),
          cells: [
            DataCell(
              Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataCell(
              Text(
                "₱${ororamaPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  color: cheaperMall == "Ororama" ? Colors.green : Colors.black,
                  fontWeight:
                      cheaperMall == "Ororama"
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
            DataCell(
              Text(
                "₱${gaisanoPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  color: cheaperMall == "Gaisano" ? Colors.green : Colors.black,
                  fontWeight:
                      cheaperMall == "Gaisano"
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
            DataCell(
              Text(
                cheaperMall,
                style: TextStyle(
                  color:
                      cheaperMall == "Ororama"
                          ? Colors.orange
                          : (cheaperMall == "Gaisano"
                              ? Colors.blue
                              : Colors.grey),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      index++;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          headingRowColor: WidgetStateProperty.all(
            Colors.blueAccent.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                "Item",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Ororama",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Gaisano",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Cheaper",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: rows,
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> totalSpent) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups:
                totalSpent.entries.map((entry) {
                  final index = totalSpent.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.blueAccent.withOpacity(0.8),
                        width: 20,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Colors.lightBlueAccent.withOpacity(0.6),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < totalSpent.keys.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            totalSpent.keys.elementAt(index),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval:
                      totalSpent.values.isNotEmpty
                          ? totalSpent.values.reduce((a, b) => a > b ? a : b) /
                              5
                          : 10,
                  reservedSize: 40,
                  getTitlesWidget:
                      (value, meta) => Text(
                        "₱${value.toInt()}",
                        style: const TextStyle(fontSize: 12),
                      ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: false,
              horizontalInterval:
                  totalSpent.values.isNotEmpty
                      ? totalSpent.values.reduce((a, b) => a > b ? a : b) / 5
                      : 10,
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey.shade800.withOpacity(0.9),
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 10,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final itemName = totalSpent.keys.elementAt(group.x.toInt());
                  return BarTooltipItem(
                    '$itemName\n₱${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseHistory(Box historyBox) {
    List<dynamic> historyList = historyBox.get('history', defaultValue: []);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child:
          historyList.isEmpty
              ? const Center(
                child: Text(
                  "No purchase history available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final item = Map<String, dynamic>.from(
                    historyList[index] as Map,
                  );
                  double price = (item["price"] as num).toDouble();
                  final totalPrice = price * (item["quantity"] as num);
                  final purchaseDate =
                      item["date"] != null
                          ? DateFormat(
                            'MMM dd, yyyy',
                          ).format(DateTime.parse(item["date"].toString()))
                          : DateFormat('MMM dd, yyyy').format(DateTime.now());

                  return ListTile(
                    title: Text(
                      item["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Qty: ${item["quantity"]} | Date: $purchaseDate",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      "₱${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Map<String, double> _calculateTotalSpent(
    Box masterBox,
    Box priceBox,
    Box historyBox,
  ) {
    Map<String, double> totals = {};
    List<dynamic> masterList = masterBox.get('list', defaultValue: []);

    for (var item in masterList) {
      Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
      double? latestPrice = priceBox.get(itemMap["name"]);
      double price = latestPrice ?? (itemMap["price"] as num).toDouble();
      totals[itemMap['name']] =
          (totals[itemMap['name']] ?? 0) + price * (itemMap["quantity"] as num);
      _saveToHistory(itemMap, price, historyBox);
    }
    return totals;
  }

  void _saveToHistory(Map<String, dynamic> item, double price, Box historyBox) {
    List<dynamic> historyList = historyBox.get('history', defaultValue: []);
    final historyEntry = {
      "name": item["name"],
      "price": price,
      "quantity": item["quantity"],
      "date": item["date"] ?? DateTime.now().toIso8601String(),
    };

    int existingIndex = historyList.indexWhere((entry) {
      final entryMap = Map<String, dynamic>.from(entry as Map);
      return entryMap["name"] == historyEntry["name"] &&
          DateTime.parse(entryMap["date"]).toDateString() ==
              DateTime.parse(historyEntry["date"]).toDateString();
    });

    if (existingIndex != -1) {
      final existingEntry = Map<String, dynamic>.from(
        historyList[existingIndex] as Map,
      );
      existingEntry["quantity"] =
          (existingEntry["quantity"] as num) + (item["quantity"] as num);
      historyList[existingIndex] = existingEntry;
    } else {
      historyList.add(historyEntry);
    }

    historyBox.put('history', historyList);
  }

  void _clearHistory(BuildContext context, Box historyBox) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Clear Purchase History"),
            content: const Text(
              "Are you sure you want to clear all purchase history? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    historyBox.put('history', []);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Purchase history cleared")),
                  );
                },
                child: const Text("Clear", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

extension DateOnly on DateTime {
  String toDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}
