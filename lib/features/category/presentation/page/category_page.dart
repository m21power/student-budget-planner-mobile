import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'dart:math';

import 'package:hackathon_mobile/core/constants/show_notifications.dart';
import 'package:hackathon_mobile/features/db/db_query.dart';

import '../../../../core/constants/dummy_data.dart';

class CategoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Monthly Budget', 'icon': Icons.attach_money_rounded},
    {'name': 'Food & Drink', 'icon': Icons.fastfood},
    {'name': 'Clothes', 'icon': Icons.shopping_bag},
    {'name': 'Medicine', 'icon': Icons.medical_services},
    {'name': 'Gifts', 'icon': Icons.card_giftcard},
    {'name': 'Books & Supplies', 'icon': Icons.book},
    {'name': 'Tuition Fees', 'icon': Icons.school},
    {'name': 'Accommodation', 'icon': Icons.home},
    {'name': 'Transportation', 'icon': Icons.directions_bus},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Utilities', 'icon': Icons.lightbulb},
    {'name': 'Health & Fitness', 'icon': Icons.fitness_center},
    {'name': 'Others', 'icon': Icons.star},
  ];

  final Random random = Random();
  final Map<DateTime, int> heatmapData = {
    for (int i = 0; i < 30; i++)
      DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day - i): Random().nextInt(5),
  };
  void init() async {
    // for (var category in categories) {
    //   await insertCategory(category['name']);
    // }
    // List<Map<String, dynamic>> categories = await getCategories();
    // for (var category in categories) {
    //   print('ID: ${category['id']}, Name: ${category['name']}');
    // }
    // for (var expense in dummyExpenses) {
    //   await addExpenseByCategoryName(
    //       expense['category'], expense['amount'], expense['date']);
    // }
    // List<Map<String, dynamic>> expenses = await getAllExpenses();
    // for (var expense in expenses) {
    //   print(
    //       'ID: ${expense['id']}, Category: ${expense['categoryName']}, Amount: ${expense['amount']}, Date: ${expense['date']}');
    // }
    var date =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();
    List<Map<String, dynamic>> daily = await getDailyExpenses(date);
    print('Daily Expenses: $daily');
    List<Map<String, dynamic>> monthly = await getMonthlyExpenses(
        DateTime(DateTime.now().year, DateTime.now().month, 0).toString(),
        date);
    print('Monthly Expenses: $monthly');
    List<Map<String, dynamic>> weekly = await getWeeklyExpenses(
        DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day - 7)
            .toString(),
        date);
    print('Weekly Expenses: $weekly');
  }

  void upsertPl(String categoryName, double amount) async {
    var date =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();
    await upsertPlan(categoryName, amount, date);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Categories'),
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildHeatmap(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 2.5,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      _showAmountDialog(context, categories[index]['name']);
                    },
                    icon: Icon(categories[index]['icon']),
                    label: Text(categories[index]['name']),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // init();
          addBudget(context);
          // showNotification(
          //     "broo", "what the fuck dude, you have to spend less");
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void addBudget(BuildContext context) {
    List<TextEditingController> controllers = List.generate(
        categories.length, (_) => TextEditingController(text: ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Set Your Budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: controllers[index],
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: categories[index]['name'],
                          prefixIcon: Icon(categories[index]['icon']),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Map<String, double> budgetData = {};
                  for (int i = 0; i < categories.length; i++) {
                    budgetData[categories[i]['name']] =
                        double.tryParse(controllers[i].text) ?? 0.0;
                  }
                  print('Budget Submitted: $budgetData');
                  budgetData.forEach((category, amount) {
                    if (amount != 0.0) {
                      upsertPl(category, amount);
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text('Submit Budget'),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeatmap() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: HeatMap(
        datasets: heatmapData,
        colorMode: ColorMode.color,
        defaultColor: Colors.grey[200]!,
        textColor: Colors.black,
        scrollable: true,
        colorsets: {
          1: Colors.green[100]!,
          2: Colors.green[300]!,
          3: Colors.green[500]!,
          4: Colors.green[700]!,
          5: Colors.green[900]!,
        },
      ),
    );
  }

  void _showAmountDialog(BuildContext context, String category) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Amount for $category'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount != 0.0) {
                  var date = DateTime(DateTime.now().year, DateTime.now().month,
                          DateTime.now().day)
                      .toString();
                  await addExpenseByCategoryName(category, amount, date);
                }
                print('Added $amount for $category');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
