import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/models/review.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/screens/event_screen.dart/edit_event_screen.dart';
import 'package:event_booking/screens/service_details_screen.dart';
import 'package:event_booking/upload_company_screen/company_list_screen.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ServiceProviderDetailsScreen extends StatelessWidget {
  final ServiceProvider serviceProvider;
  ServiceProviderDetailsScreen({Key? key, required this.serviceProvider})
      : super(key: key);

  FirestoreService db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    title: Text(serviceProvider.name!),
                    background: CompanyImageWidget(
                      serviceProviderId: serviceProvider.id!,
                    )),
                // actions: const [
                //   CircleAvatar(
                //     child: Text('1'),
                //   ),
                //   SizedBox(width: 10),
                // ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          serviceProvider.motto!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          serviceProvider.bio!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 20),
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     const Icon(
                        //       Icons.star,
                        //       // color: Color.fromARGB(80, 252, 228, 6),
                        //       color: Colors.yellow, size: 18,
                        //     ),
                        //     Text(
                        //       calculateRating(serviceProvider.reviews)
                        //           .toStringAsFixed(2),
                        //       style: const TextStyle(
                        //         color: Colors.grey,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 10),
                        //     Text(
                        //       serviceProvider.reviews == null
                        //           ? 'No reviews yet'
                        //           : '(${serviceProvider.reviews!.length} reviews)',
                        //       style: const TextStyle(color: Colors.grey),
                        //     ),
                        //   ],
                        // ),
                        const Divider(height: 70),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Services',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        StatefulBuilder(builder: (context, setState) {
                          return FutureBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                              future: db
                                  .serviceCollectionFromProvider(
                                      serviceProvider.id!)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {});
                                      },
                                    ),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  List<Service> servicesList = snapshot
                                      .data!.docs
                                      .map((e) =>
                                          Service.fromFirestore(e.data(), e.id))
                                      .toList();

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    primary: false,
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemBuilder:
                                        (BuildContext context, int index) =>
                                            GestureDetector(
                                      onTap: () async {
                                        pagesToPop = pagesToPop + 1;
                                        await navigate(
                                            context,
                                            ServiceDetailsScreen(
                                              showProvider: false,
                                                service: servicesList[index]));
                                        pagesToPop = pagesToPop - 1;
                                      },
                                      child: ServicesCard(
                                          service: servicesList[index]),
                                    ),
                                    itemCount: servicesList.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const SizedBox(height: 30),
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              });
                        }),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
