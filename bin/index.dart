import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Expense {
  String item;
  int paid;
  DateTime date;

  Expense(this.item, this.paid, this.date);


  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(json['item'], json['paid'], DateTime.parse(json['date']));
  }
}


void main() async {
  print('=========== login ==========');
  stdout.write('Username: ');
  String? username = stdin.readLineSync()?.trim();
  stdout.write('Password: ');
  String? password = stdin.readLineSync()?.trim();


  if (username == null || password == null) {
    print('Incomplete input');
    return;
  }


  final loginResp = await http.post(
    Uri.parse('http://localhost:3000/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );


  if (loginResp.statusCode != 200) {
    print('Login failed: ${loginResp.body}');
    return;
  }


  final userId = jsonDecode(loginResp.body)['userId'];


  bool running = true;
  List<Expense> expenses = [];


  while (running) {
    print('========== Expense Tracking App ==========');
    print('1. Show all');
    print('2. Today expense');
    print('3. Exit');
    stdout.write('Choose... ');
    String? choice = stdin.readLineSync();


    switch (choice) {
      case '1':
        final expenseResp = await http.get(
          Uri.parse('http://localhost:3000/expense/$userId'),
        );
        if (expenseResp.statusCode == 200) {
          expenses = (jsonDecode(expenseResp.body) as List)
              .map((e) => Expense.fromJson(e))
              .toList();
          int total = 0;
          print('----------- All expenses -----------');
          for (int i = 0; i < expenses.length; i++) {
            var e = expenses[i];
            print('${i + 1}. ${e.item} : ${e.paid}฿ : ${e.date}');
            total += e.paid;
          }
          print('Total expenses = ${total}฿');
        } else {
          print('Cannot fetch expenses: ${expenseResp.body}');
        }
        break;


      case '2':
        final expenseRespToday = await http.get(
          Uri.parse('http://localhost:3000/expense/$userId'),
        );
        if (expenseRespToday.statusCode == 200) {
          expenses = (jsonDecode(expenseRespToday.body) as List)
              .map((e) => Expense.fromJson(e))
              .toList();
          int totalToday = 0;
          DateTime today = DateTime.now();
          int count = 1;
          print('----------- Today expenses -----------');
          for (var e in expenses) {
            if (e.date.year == today.year &&
                e.date.month == today.month &&
                e.date.day == today.day) {
              print('${count}. ${e.item} : ${e.paid}฿ : ${e.date}');
              totalToday += e.paid;
              count++;
            }
          }
          print('Total today = ${totalToday}฿');
        }
        break;


      case '3':
        running = false;
        print('--------- Bye --------');
        break;


      default:
        print('Invalid choice!');
    }
  }
}
