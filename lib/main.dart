import 'package:flutter/material.dart';
import '../views/home_page.dart';
import '../views/event_list_page.dart';
import '../views/event_details_page.dart';
import '../views/gift_list_page.dart';
import '../models/event.dart';
import '../views/gift_details_page.dart';
import '../models/gift.dart';

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
        '/eventDetails': (context) => EventDetailsPage(),
        '/giftList': (context) => GiftListPage(
          event: ModalRoute.of(context)!.settings.arguments as Event,
        ),
        '/giftDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GiftDetailsPage(
            eventId: args['eventId'] as String,
            gift: args['gift'] as Gift?,
          );
        },
      },

    );
  }
}
