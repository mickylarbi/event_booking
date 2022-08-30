import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/firebase_services/storage_service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/upload_company_screen/company_details_screen.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  FirestoreService db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.serviceProviderCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text('Something went wrong'),
                  IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh))
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          List<ServiceProvider>? serviceProviders = snapshot.data!.docs
              .map((e) => ServiceProvider.fromFirestore(e.data(), e.id))
              .toList();

          return serviceProviders.isEmpty
              ? const Center(
                  child: Text('Nothing to show here'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: serviceProviders.length,
                  itemBuilder: (context, index) {
                    ServiceProvider serviceProvider = serviceProviders[index];

                    return Company(
                      serviceProvider: serviceProvider,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 30),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigate(
              context,
              CompanyDetailsScreen(
                serviceProvider: ServiceProvider(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Company extends StatelessWidget {
  final ServiceProvider serviceProvider;
  Company({Key? key, required this.serviceProvider}) : super(key: key);

  StorageService storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(
            context, CompanyDetailsScreen(serviceProvider: serviceProvider));
      },
      child: SizedBox(
        height: 140,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Colors.grey[200],
                    height: 96,
                    width: 96,
                    child: CompanyImageWidget(
                        serviceProviderId: serviceProvider.id!),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      serviceProvider.name!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(serviceProvider.motto!),
                    // Row(
                    //   children: [
                    //     const Icon(
                    //       Icons.star,
                    //       // color: Color.fromARGB(80, 252, 228, 6),
                    //       color: Colors.yellow, size: 18,
                    //     ),
                    //     Text(calculateRating(serviceProvider.reviews)
                    //         .toStringAsFixed(2)),
                    //     const SizedBox(width: 10),
                    //     Text(
                    //       serviceProvider.reviews == null
                    //           ? 'No reviews yet'
                    //           : '(${serviceProvider.reviews!.length} reviews)',
                    //       style: const TextStyle(color: Colors.grey),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyImageWidget extends StatelessWidget {
  final String serviceProviderId;
  CompanyImageWidget({
    Key? key,
    required this.serviceProviderId,
  }) : super(key: key);

  StorageService storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return FutureBuilder<String>(
        //TODO:
        future: storage
            .serviceProviderImageReference(serviceProviderId)
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

          if (snapshot.connectionState == ConnectionState.done) {
            return CachedNetworkImage(
              imageUrl: snapshot.data!,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator.adaptive(
                      value: downloadProgress.progress),
              errorWidget: (context, url, error) => Center(
                child: IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      );
    });
  }
}
