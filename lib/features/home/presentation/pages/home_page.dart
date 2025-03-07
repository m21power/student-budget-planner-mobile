import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hackathon_mobile/core/constants/categories.dart';
import 'package:hackathon_mobile/core/constants/global_constant.dart';
import 'package:hackathon_mobile/dependency_injection.dart';
import 'package:hackathon_mobile/features/db/db_query.dart';
import 'package:hackathon_mobile/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> expense = [];
  double totalSpent = 0;
  double totalBudget = 0;

  // Use this to fetch the expenses asynchronously and set the state
  void getAllExpense() async {
    expense = await getAllExpenses();
    totalSpent = await getTotalSpent();
    totalBudget = await getTotalBudget();

    setState(() {
      // Trigger the UI to rebuild with the updated expense list
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch the expenses when the widget is initialized
    getAllExpense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Remaining Budget",
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${(totalBudget - totalSpent).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "/\$${totalBudget.toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: totalBudget > 0 ? totalSpent / totalBudget : 0,
                    valueColor: AlwaysStoppedAnimation(Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Spent: \$${totalSpent.toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Transactions List
            Text("Transactions list",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: expense.length,
                itemBuilder: (context, index) {
                  return transactionItem(
                      expense[index]['categoryName'],
                      formatDate(
                        expense[index]['date'],
                      ),
                      expense[index]['amount']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionItem(String title, String date, double amount) {
    IconData icon = Icons.star;
    for (var cat in categories) {
      if (cat['name'] == title) {
        icon = cat['icon'];
      }
    }
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Text(
          "\$$amount",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
