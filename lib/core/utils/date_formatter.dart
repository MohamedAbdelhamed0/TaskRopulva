import 'package:intl/intl.dart';

String formatTaskDate(DateTime date) {
  String dayName = DateFormat('E').format(date); // Gets abbreviated day name
  String formattedDate = '$dayName. ${date.day}/${date.month}/${date.year}';
  return formattedDate;
}
