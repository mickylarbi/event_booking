import 'package:event_booking/models/event.dart';
import 'package:event_booking/screens/event_screen.dart/edit_event_screen.dart';
import 'package:event_booking/screens/shared/custom_drawer.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyEventsListScreen extends StatefulWidget {
  const MyEventsListScreen({Key? key}) : super(key: key);

  @override
  State<MyEventsListScreen> createState() => _MyEventsListScreenState();
}

class _MyEventsListScreenState extends State<MyEventsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My events'),
        centerTitle: true,
      ),
      body: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(24),
        itemCount: 20,
        separatorBuilder: (context, index) => const SizedBox(height: 30),
        itemBuilder: (context, index) => EventCard(),
      ),
      drawer: CustomDrawer(),
      floatingActionButton: FloatingActionButton.extended(
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
  const EventCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(
          context,
          EditEventScreen(
            event: Event(
                id: 'asdf',
                title: 'Believers Conference',
                dateTime: DateTime.now().add(const Duration(days: 15)),
                venueString: 'Great Hall'),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        height: 140,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
          color: Colors.white,
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
                    DateFormat.d().format(DateTime.now()),
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    DateFormat.MMM().format(
                      DateTime.now(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Believers Conference'),
                Text(DateFormat.jm().format(DateTime.now())),
                const Text('Great Hall'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
