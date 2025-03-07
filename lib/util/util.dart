import 'package:intl/intl.dart';

String formatDate(String input) {
  // Parse the input string into a DateTime object
  DateTime dateTime = DateTime.parse(input);

  // Format the DateTime into the desired format
  return DateFormat('dd MMM yyyy').format(dateTime);
}
