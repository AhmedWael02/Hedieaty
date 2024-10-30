import 'package:flutter/material.dart';
import '../views/home_page.dart';
import '../views/event_list_page.dart';

void main() {
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/eventList': (context) => EventListPage(),
      },
    );
  }
}
