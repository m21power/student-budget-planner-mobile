import 'dart:convert';

import 'package:hackathon_mobile/core/constants/global_constant.dart';
import 'package:hackathon_mobile/core/constants/show_notifications.dart';
import 'package:hackathon_mobile/dependency_injection.dart';
import 'package:hackathon_mobile/features/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

Future<int> insertCategory(String categoryName) async {
  final db = await DatabaseHelper.instance.database;
  print('Inserting category: $categoryName');
  return await db.insert(
    'categories',
    {'name': categoryName},
    conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicate entries
  );
}

Future<void> addExpenseByCategoryName(
    String categoryName, double amount, String date) async {
  final db = await DatabaseHelper.instance.database;

  // Get the category ID
  final List<Map<String, dynamic>> category = await db.query(
    'categories',
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [categoryName],
  );

  if (category.isNotEmpty) {
    int categoryId = category.first['id'];

    // Insert the expense
    await db.insert(
      'expenses',
      {'categoryId': categoryId, 'amount': amount, 'date': date},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    String email = jsonDecode(sl<SharedPreferences>()
        .getString(Constant.sharedPrefereceKey)!)['email'];
    // Update the user's budget after adding the expense
    await db.rawUpdate(
      'UPDATE users SET budget = budget - ? WHERE email = ?',
      [amount, email], // Assuming user ID is 1, adjust as necessary
    );
    print("done");
    await checkBudgetAndPlanAlert();
  } else {
    throw Exception('Category not found');
  }
}

Future<List<Map<String, dynamic>>> getDailyExpenses(String date) async {
  final db = await DatabaseHelper.instance.database;
  return await db.rawQuery('''
    SELECT e.amount AS cost, c.name AS categoryName 
    FROM expenses e 
    JOIN categories c ON e.categoryId = c.id 
    WHERE e.date = ?
  ''', [date]);
}

Future<List<Map<String, dynamic>>> getWeeklyExpenses(
    String startDate, String endDate) async {
  final db = await DatabaseHelper.instance.database;
  return await db.rawQuery('''
    SELECT SUM(e.amount) AS totalCost, c.name AS categoryName 
    FROM expenses e 
    JOIN categories c ON e.categoryId = c.id 
    WHERE e.date BETWEEN ? AND ? 
    GROUP BY c.name
  ''', [startDate, endDate]);
}

Future<List<Map<String, dynamic>>> getMonthlyExpenses(
    String monthStart, String monthEnd) async {
  final db = await DatabaseHelper.instance.database;
  return await db.rawQuery('''
    SELECT SUM(e.amount) AS totalCost, c.name AS categoryName 
    FROM expenses e 
    JOIN categories c ON e.categoryId = c.id 
    WHERE e.date BETWEEN ? AND ? 
    GROUP BY c.name
  ''', [monthStart, monthEnd]);
}

Future<List<Map<String, dynamic>>> getCategories() async {
  final db = await DatabaseHelper.instance.database;
  return await db.query('categories'); // Fetch all rows from categories
}

Future<void> upsertPlan(String categoryName, double amount, String date) async {
  final db = await DatabaseHelper.instance.database;
  print(categoryName + " " + date);
  // Get category ID
  final categoryResult = await db.query(
    'categories',
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [categoryName],
  );

  if (categoryResult.isEmpty) {
    throw Exception('Category not found');
  }

  final categoryId = categoryResult.first['id'] as int;

  // Check if a plan with the same date and category exists
  final existingPlan = await db.query(
    'plans',
    where: 'categoryId = ? AND date = ?',
    whereArgs: [categoryId, date],
  );

  if (existingPlan.isNotEmpty) {
    // Update existing plan
    await db.update(
      'plans',
      {'amount': amount},
      where: 'categoryId = ? AND date = ?',
      whereArgs: [categoryId, date],
    );
  } else {
    // Insert new plan
    await db.insert(
      'plans',
      {'categoryId': categoryId, 'amount': amount, 'date': date},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Future<List<Map<String, dynamic>>> getAllExpenses() async {
  final db = await DatabaseHelper.instance.database;

  final result = await db.rawQuery('''
    SELECT expenses.id, categories.name AS categoryName, expenses.amount, expenses.date 
    FROM expenses
    JOIN categories ON expenses.categoryId = categories.id
    ORDER BY expenses.date DESC;
  ''');

  return result;
}

Future<double> getTotalSpent() async {
  final db = await DatabaseHelper.instance.database;

  final result = await db.rawQuery('''
    SELECT SUM(amount) AS totalSpent 
    FROM expenses;
  ''');

  // If result is not empty, return the total spent, otherwise return 0
  return result.isNotEmpty
      ? (result.first['totalSpent'] as double? ?? 0.0)
      : 0.0;
}

Future<double> getTotalBudget() async {
  final db = await DatabaseHelper.instance.database;

  final result = await db.rawQuery('''
    SELECT budget FROM users LIMIT 1;
  ''');
  print(result);

  // If result is not empty, return the user's budget, otherwise return 0
  return result.isNotEmpty ? (result.first['budget'] as double? ?? 0.0) : 0.0;
}

Future<void> insertUser() async {
  final db = await DatabaseHelper.instance.database;
  var date =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString();
  var user = jsonDecode(
      sl<SharedPreferences>().getString(Constant.sharedPrefereceKey)!);
  await db.insert(
    'users',
    {
      'email': user['email'],
      'name': user['name'],
      'badges': user['badges'] ?? '', // Optional field
      'budget': user['budget'],
      'date': date,
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // Replace if exists
  );
}

Future<void> updateUserBudget({
  double? budget,
}) async {
  final db = await DatabaseHelper.instance.database;
  var user = jsonDecode(
      sl<SharedPreferences>().getString(Constant.sharedPrefereceKey)!);
  final updatedValues = <String, dynamic>{};

  if (budget != null) updatedValues['budget'] = budget;

  if (updatedValues.isNotEmpty) {
    await db.update(
      'users',
      updatedValues,
      where: 'email = ?',
      whereArgs: [user['email']],
    );
  }
  await checkBudgetAndPlanAlert();
}

// Method to retrieve daily expenses total
Future<Map<String, double>> getDailyExpensesTotal() async {
  // Query the database to sum the expenses by date
  final db = await DatabaseHelper.instance.database;

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT date, SUM(amount) as totalCost
    FROM expenses
    GROUP BY date
    ORDER BY date
  ''');

  // Initialize an empty map to store the results
  Map<String, double> dailyExpenses = {};

  // Iterate through the query results and add to the map
  for (var row in result) {
    String fullDate = row['date']; // Full date in 'yyyy-MM-dd' format
    String day = fullDate.split('-')[2]; // Extract just the day (dd) part
    double totalCost = row['totalCost']; // Total cost for that day
    dailyExpenses[day] = totalCost; // Store it in the map
  }

  return dailyExpenses;
}

Future<void> checkBudgetAndPlanAlert() async {
  final db = await DatabaseHelper.instance.database;

  // Get current date (for checking the day)
  final DateTime currentDate = DateTime.now();
  final int currentDay = currentDate.day;

  // 1. Get total budget for the user
  final userResult =
      await db.query('users', where: 'email = ?', whereArgs: ['userEmail']);
  final totalBudget =
      userResult.isNotEmpty ? (userResult[0]['budget'] as double? ?? 0.0) : 0.0;

  // 2. Get total expenses and total plan for each category
  final categoryResult = await db.query('categories');
  for (var category in categoryResult) {
    int categoryId = category['id'] as int;

    // Get expenses for this category
    final expensesResult = await db
        .query('expenses', where: 'categoryId = ?', whereArgs: [categoryId]);
    double totalExpensesForCategory = expensesResult.fold(
        0.0, (sum, expense) => sum + (expense['amount'] as double));

    // Get the plan for this category
    final planResult = await db
        .query('plans', where: 'categoryId = ?', whereArgs: [categoryId]);
    double totalPlanForCategory =
        planResult.isNotEmpty ? (planResult[0]['amount'] as double) : 0.0;

    // 3. Check if the category is approaching the budget
    if (totalExpensesForCategory >= totalPlanForCategory * 0.8) {
      // Send a warning notification about the category budget approaching
      showNotification("Warining‼️",
          'Warning: You are approaching your limit for the category "${category['name']}"');
    }
  }

  // 4. Check if total budget is close to being exceeded
  final totalExpensesResult = await db.query('expenses');
  double totalExpenses = totalExpensesResult.fold(
      0.0, (sum, expense) => sum + (expense['amount'] as double));

  if (totalExpenses >= totalBudget * 0.8) {
    // Send a warning notification about total budget approaching
    showNotification(
        "Warning‼️", 'Warning: You are approaching your total budget limit.');
  }

  // 5. Check if the current day is near the end of the month (e.g., day >= 20)
  if (currentDay >= 20) {
    // Warn the user that they have to wait for the next month to reset the budget
    showNotification("Reminder⚠️",
        'Reminder: You may have to wait until next month for a budget reset.');
  }
}
