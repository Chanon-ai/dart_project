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
    print('Welcome, $username');
    print('1. Show all');
    print('2. Today expense');
    print('3. Search expense');
    print('4. Add new expense');
    print('5. Delete an expense');
    print('6. Exit');
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

      // dev 1 search expense
      case '3':
        stdout.write('Item to search: ');
        String? keyword = stdin.readLineSync()?.trim();

        if (keyword == null || keyword.isEmpty) {
          print('Invalid input!');
          break;
        }

        try {
          final expenseRespSearch = await http.get(
            Uri.parse(
              'http://localhost:3000/expensess/$userId/search?keyword=$keyword',
            ),
          );

          if (expenseRespSearch.statusCode == 200) {
            List<Expense> results = (jsonDecode(expenseRespSearch.body) as List)
                .map((e) => Expense.fromJson(e))
                .toList();

            if (results.isEmpty) {
              print('No Item: $keyword');
            } else {
              for (int i = 0; i < results.length; i++) {
                var e = results[i];
                print('${i + 1}. ${e.item} : ${e.paid}à¸¿ : ${e.date}');
              }
            }
          } else {
            print('Cannot fetch search results: ${expenseRespSearch.body}');
          }
        } catch (e) {
          print('Error: $e');
        }
        break;

      // dev 2 Add new expense
      case '4':
        // code
        break;

      // dev 2 Delete an expense
      case '5':
        // code
        break;

      case '6':
        running = false;
        print('--------- Bye --------');
        break;

      default:
        print('Invalid choice!');
    }
  }
}
