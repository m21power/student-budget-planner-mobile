import 'package:flutter/material.dart';
import 'package:hackathon_mobile/core/constants/api_constant.dart';
import 'package:hackathon_mobile/features/db/db_query.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({"sender": "You", "message": text});
    });

    var uri = Uri.parse("${ApiConstant.BaseUrl}/ask-gemini");
    var date =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .toString();
    List<Map<String, dynamic>> daily = await getDailyExpenses(date);
    var mesay = 'Daily Expenses: $daily ';
    List<Map<String, dynamic>> monthly = await getMonthlyExpenses(
        DateTime(DateTime.now().year, DateTime.now().month, 0).toString(),
        date);
    List<Map<String, dynamic>> weekly = await getWeeklyExpenses(
        DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day - 7)
            .toString(),
        date);
    var totalSpent = await getTotalSpent();
    var totalBudget = await getTotalBudget();
    mesay = '${mesay}Weekly Expenses: $weekly';
    mesay = '${mesay}Monthly Expenses: $monthly ';
    mesay =
        "${mesay} always based on this user's data if he asks you anything related to his expenses answer him based on the given data and make it as simple as possible and $totalBudget is the total budget of the user and $totalSpent is the total spent by the user";

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text + mesay}),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        final String value = jsonDecode(response.body);
        String result = value == ""
            ? "No response from AI"
            : value; // Adjust based on API response
        setState(() {
          messages.add({"sender": "AI", "message": result});
        });
      } else {
        setState(() {
          messages.add({"sender": "AI", "message": "Error getting response"});
        });
      }
    } catch (e) {
      setState(() {
        messages
            .add({"sender": "AI", "message": "Failed to connect to server"});
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          if (messages.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "No messages yet. Start the conversation!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg["sender"] == "You";

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      padding: EdgeInsets.all(12.0),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft:
                              isUser ? Radius.circular(12) : Radius.zero,
                          bottomRight:
                              isUser ? Radius.zero : Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        msg["message"]!,
                        style: TextStyle(
                            color: isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Ask...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      prefixIcon: Icon(Icons.message),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
