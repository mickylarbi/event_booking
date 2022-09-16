import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/screens/event_screen.dart/edit_event_screen.dart';
import 'package:event_booking/screens/service_details_screen.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  FirestoreService db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: db.serviceCollection.get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Could not retrieve services'),
                  TextButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reload'))
                ],
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              List<Service> servicesList = snapshot.data!.docs
                  .map((e) => Service.fromFirestore(e.data(), e.id))
                  .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () async {
                      pagesToPop = pagesToPop + 1;
                      await navigate(context,
                          ServiceDetailsScreen(service: servicesList[index]));
                      pagesToPop = pagesToPop - 1;
                    },
                    child: ServicesCard(
                      service: servicesList[index],
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: servicesList.length,
                ),
              );
            }

            return const Center(child: CircularProgressIndicator.adaptive());
          },
        ),
      ),
    );
  }
}
