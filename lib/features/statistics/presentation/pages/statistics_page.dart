import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pc;
import 'package:pie_chart/pie_chart.dart';

import '../../../db/db_query.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String timeRange = 'Daily'; // Default selection
  List<BarChartGroupData> barChartData = []; // Bar chart data
  Map<String, double> pieChartData = {}; // Pie chart data
  List<FlSpot> lineChartData = []; // Line chart data
  List<Map<String, dynamic>> expenses = [];
  Map<int, String> categoryMap = {};
  Map<String, double> dailyExpense = {};
  List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.yellow
  ];

  @override
  void initState() {
    super.initState();
    dailyForGraph();
    _updateChartData(); // Initialize chart data
  }

  void dailyForGraph() async {
    dailyExpense = await getDailyExpensesTotal();
    setState(() {});
  }

  // Function to update the chart data based on the selected time range
  void _updateChartData() async {
    String date =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();

    if (timeRange == 'Daily') {
      expenses = await getDailyExpenses(date);
    } else if (timeRange == 'Weekly') {
      expenses = await getWeeklyExpenses(
          DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day - 7)
              .toString(),
          date);
    } else if (timeRange == 'Monthly') {
      expenses = await getMonthlyExpenses(
          DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
          date);
    }

    if (expenses.isEmpty) {
      // Provide default dummy data to prevent crash
      pieChartData = {"No Data": 100.0};
      barChartData = [];
      setState(() {});
      return;
    }
    double totalExpense = expenses.fold(
        0, (sum, item) => sum + (item['totalCost'] ?? item['cost']));

    barChartData = List.generate(expenses.length, (index) {
      categoryMap[index] = expenses[index]['categoryName'];
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
          toY: (expenses[index]['totalCost'] ?? expenses[index]['cost'])
              .toDouble(),
          color: colors[index % colors.length],
        )
      ]);
    });

    pieChartData = {};
    for (var expense in expenses) {
      String categoryName = expense['categoryName'];
      double cost = (expense['totalCost'] ?? expense['cost']).toDouble();
      double percentage = (totalExpense > 0) ? (cost / totalExpense) * 100 : 0;
      pieChartData[categoryName] = percentage;
    }

    setState(() {});
  }

  // Widget for Category Bar Chart
  Widget buildCategoryBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          barGroups: barChartData,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // Keep numbers on the left
                reservedSize: 40, // Adjust space for labels
              ),
            ),
            rightTitles: AxisTitles(
                sideTitles:
                    SideTitles(showTitles: false)), // Remove right titles
            topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)), // Remove top titles
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, // Keep bottom titles
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${categoryMap[groupIndex]}', // Show text instead of value
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Widget for Pie Chart
  Widget buildCategoryPieChart() {
    if (pieChartData.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return pc.PieChart(
      dataMap: pieChartData,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3,
      colorList: colors,
      legendOptions: LegendOptions(showLegends: true),
      chartValuesOptions: ChartValuesOptions(showChartValuesInPercentage: true),
    );
  }

  // Widget for Cost Over Time Line Chart

  Widget buildCategoryExpenseChart(Map<String, double> monthlyExpenses) {
    List<FlSpot> lineChartData = monthlyExpenses.entries.map((entry) {
      // Ensure we only use the day part as a double, not the entire timestamp
      double day = double.tryParse(entry.key) ?? 0.0;
      return FlSpot(
        day, // Use the day number as x (converted to double)
        entry.value, // Cost as y
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: TextStyle(fontSize: 12),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Format the day based on the x-axis value
                  String day = value.toInt().toString();
                  return Text(
                    day,
                    style: TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  );
                },
                reservedSize: 50,
                interval: 3,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: lineChartData,
              isCurved: true,
              barWidth: 2.5,
              color: Colors.blueAccent,
              dotData: FlDotData(show: true),
              belowBarData:
                  BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  String day = spot.x.toInt().toString().padLeft(2, '0');
                  return LineTooltipItem(
                    "Day $day\n\$${spot.y.toInt()}",
                    TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // First, always show the Cost Over Time chart
          Text("Cost Over Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          buildCategoryExpenseChart(dailyExpense),
          SizedBox(height: 20),

          // Dropdown for selecting time range (affects only bar and pie charts)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Time Range:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: timeRange,
                items: ['Daily', 'Weekly', 'Monthly']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    timeRange = newValue!;
                    _updateChartData();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text("Expense Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          buildCategoryPieChart(),
          SizedBox(height: 20),
          Text("Category Expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          buildCategoryBarChart(),
        ],
      ),
    );
  }
}
