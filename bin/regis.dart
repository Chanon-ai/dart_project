import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';


void main() async {
  print("===== Register =====");


  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();


  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }
  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/register');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );


  if (response.statusCode == 201) {
    print("Insert done");
  } else if (response.statusCode == 400) {
    print("Username already exists or bad request");
  } else if (response.statusCode == 500) {
    print("Server error");
  } else {
    print("Unknown error: ${response.statusCode}");
  }
}
