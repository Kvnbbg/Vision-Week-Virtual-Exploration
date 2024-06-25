/// The `WelcomeScreen` class in Dart is a Flutter widget that allows users to add and retrieve user
/// information using SOAP requests.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class WelcomeScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  Future<void> addUser(String name, int age) async {
    final soapEnvelope = '''<?xml version="1.0" encoding="UTF-8"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:spy="spyne.examples.hello.soap">
        <soapenv:Header/>
        <soapenv:Body>
            <spy:addUser>
                <spy:name>$name</spy:name>
                <spy:age>$age</spy:age>
            </spy:addUser>
        </soapenv:Body>
    </soapenv:Envelope>''';

    final response = await http.post(
      Uri.parse('http://127.0.0.1/soap_server.php'),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'spyne.examples.hello.soap/addUser',
      },
      body: soapEnvelope,
    );

    if (response.statusCode == 200) {
      print('User added successfully');
    } else {
      print('Failed to add user');
    }
  }

  Future<void> getUsers() async {
    final soapEnvelope = '''<?xml version="1.0" encoding="UTF-8"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:spy="spyne.examples.hello.soap">
        <soapenv:Header/>
        <soapenv:Body>
            <spy:getUsers/>
        </soapenv:Body>
    </soapenv:Envelope>''';

    final response = await http.post(
      Uri.parse('http://127.0.0.1/soap_server.php'),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'spyne.examples.hello.soap/getUsers',
      },
      body: soapEnvelope,
    );

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final result = document.findAllElements('getUsersResponse').single;
      print('Users: ${result.text}');
    } else {
      print('Failed to get users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Vision Week'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                addUser(_nameController.text, int.parse(_ageController.text));
              },
              child: Text('Add User'),
            ),
            ElevatedButton(
              onPressed: () {
                getUsers();
              },
              child: Text('Get Users'),
            ),
          ],
        ),
      ),
    );
  }
}
