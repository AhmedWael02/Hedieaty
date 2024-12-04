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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/signIn',
      routes: {
        '/signIn': (context) => SignInPage(),
        '/signUp': (context) => SignUpPage(),
        // Home Page Route
        '/homePage': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return HomePage(userId: userId);
        },
        // Updated Event List Page Route
        '/eventList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EventListPage(
              userId: args['userId'] as String,
              pledgerId: args['pledgerId'] as String?,

          );
        },

        // Updated Event Details Page Route
        '/eventDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EventDetailsPage(
            userId: args['userId'] as String,
            event: args['event'] as Event?,
          );
        },
        '/giftList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GiftListPage(
            event: args['event'] as Event,
            userId: args['userId'] as String,
            pledgerId: args['pledgerId'] as String?,

          );
        },

        '/giftDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GiftDetailsPage(
            eventId: args['eventId'] as String,
            gift: args['gift'] as Gift?,
          );
        },
        // Profile Page Route
        '/profile': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return ProfilePage(userId: userId);
        },
        // Pledged Gifts Page Route
        '/pledgedGifts': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return PledgedGiftsPage(userId: userId); // Use userId dynamically
        },

      },

    );
  }
}
