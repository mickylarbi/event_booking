import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/firebase_services/storage_service.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/screens/event_screen.dart/service_provider_details_screen.dart';
import 'package:event_booking/upload_company_screen/company_list_screen.dart';
import 'package:event_booking/utils/constants.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Service service;
  final bool showProvider;

  ServiceDetailsScreen(
      {Key? key, required this.service, this.showProvider = true})
      : super(key: key);

  StorageService storage = StorageService();
  FirestoreService db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.title!)),
      body: Stack(
        children: [
          ListView(
            children: [
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 20),
                  Center(
                      child: Text(
                    service.description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  )),
                  const SizedBox(height: 50),
                  const Text(
                    'Price:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(service.price),
                  const SizedBox(height: 70),
                ],
              ),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index) =>
                      StatefulBuilder(builder: (context, setState) {
                    return FutureBuilder<String>(
                        future: storage
                            .imageReference(service.imageUrls![index])
                            .getDownloadURL(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data!,
                                  height: 250,
                                  width: 250,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator.adaptive(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }

                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        });
                  }),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 30),
                  itemCount: service.imageUrls!.length,
                ),
              ),
              const SizedBox(height: 50),
              if (showProvider)
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future:
                        db.getServiceProviderFromId(service.providerId!).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        ServiceProvider serviceProvider =
                            ServiceProvider.fromFirestore(
                                snapshot.data!.data()!, snapshot.data!.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onTap: () async {
                              pagesToPop = pagesToPop + 1;
                              await navigate(
                                  context,
                                  ServiceProviderDetailsScreen(
                                      serviceProvider: serviceProvider));
                              pagesToPop = pagesToPop - 1;
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    CompanyImageWidget(
                                      serviceProviderId: serviceProvider.id!,
                                      height: 90,
                                      width: 90,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(serviceProvider.name!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
              const SizedBox(height: 100),
            ],
          ),
          // if (!hiredServices.contains(service.id))
          if (!hiredServices.contains(service.id))
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < pagesToPop; i++) {
                      Navigator.pop(context, service.id);
                    }
                  },
                  style: elevatedButtonStyle,
                  child: const Text('Hire'),
                ),
              ),
            )
        ],
      ),
    );
  }

  //  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: CustomScrollView(
  //       slivers: [
  //         SliverAppBar(title: Text(service.title!)),
  //         SliverList(delegate: SliverChildListDelegate([

  //         ]))
  //       ],
  //     ),
  //   );
  // }
}
