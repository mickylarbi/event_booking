import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/auth_service.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/models/event.dart';
import 'package:event_booking/screens/event_screen.dart/edit_event_screen.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirestoreService db = FirestoreService();
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 50,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showConfirmationDialog(
                context,
                message: 'Sign out?',
                confirmFunction: () {
                  auth.signOut(context);
                },
              );
            },
            child: const Icon(Icons.logout),
          ),
          const SizedBox(width: 20)
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db.myEvents.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Could not retrieve events'),
                  TextButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reload'))
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            List<Event> eventsList = snapshot.data!.docs
                .map((e) => Event.fromFirestore(e.data(), e.id))
                .toList();

            return eventsList.isEmpty
                ? const Center(
                    child: Text(
                    'Click the "+ Add event" icon to add an event',
                    style: TextStyle(color: Colors.grey),
                  ))
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(24),
                    itemCount: eventsList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) =>
                        EventCard(event: eventsList[index]),
                  );
          }),
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        onPressed: () {
          navigate(
              context,
              EditEventScreen(
                event: Event(),
              ));
        },
        label: const Text('Add event'),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(context, EditEventScreen(event: event));
      },
      child: Container(
        alignment: Alignment.center,
        height: 140,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.d().format(event.dateTime!),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    DateFormat.MMM().format(event.dateTime!),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(event.title!),
                Text(
                  DateFormat.jm().format(event.dateTime!),
                ),
                Text(event.venueString!),
              ],
            )
          ],
        ),
      ),
    );
  }
}
