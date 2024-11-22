import 'package:flutter/material.dart';
import '../views/home_page.dart';
import '../views/event_list_page.dart';
import '../views/event_details_page.dart';
import '../views/gift_list_page.dart';
import '../models/event.dart';
import '../views/gift_details_page.dart';
import '../models/gift.dart';
import '../views/profile_page.dart';
import '../views/pledged_gifts_page.dart';
import '../views/sign_in_page.dart';
import '../views/sign_up_page.dart';

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
        '/': (context) => SignInPage(),
        '/signIn': (context) => SignInPage(),
        '/signUp': (context) => SignUpPage(),
        '/homePage': (context) => HomePage(),
        // Updated Event List Page Route
        '/eventList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EventListPage(userId: args['userId'] as String);
        },

        // Updated Event Details Page Route
        '/eventDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EventDetailsPage(
            userId: args['userId'] as String,
            event: args['event'] as Event?,
          );
        },
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
        '/profile': (context) => ProfilePage(),
        '/pledgedGifts': (context) => PledgedGiftsPage(
          userName: "John Doe", // Replace with dynamic userName if available
        ),

      },

    );
  }
}
