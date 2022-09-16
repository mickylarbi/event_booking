import 'package:event_booking/models/review.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/screens/event_screen.dart/service_provider_details_screen.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';

class ServiceProvidersListScreen extends StatefulWidget {
  final int pagesToPop;
  const ServiceProvidersListScreen({Key? key, required this.pagesToPop})
      : super(key: key);

  @override
  State<ServiceProvidersListScreen> createState() =>
      _ServiceProvidersListScreenState();
}

class _ServiceProvidersListScreenState
    extends State<ServiceProvidersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 20,
        itemBuilder: (context, index) => ServiceProviderCard(
          serviceProvider: ServiceProvider(
            name: 'Heavenly Logistics',
            motto: 'Events like heaven!',
            bio:
                'We provide the best designs and best quality equipment for your events. We look forward to working with you',
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 30),
      ),
    );
  }
}

class ServiceProviderCard extends StatelessWidget {
  final ServiceProvider serviceProvider;
  const ServiceProviderCard({Key? key, required this.serviceProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/rob-simmons-Qfsgxw-ZWR0-unsplash.jpg',
              fit: BoxFit.cover,
              height: 96,
              width: 96,
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
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    // color: Color.fromARGB(80, 252, 228, 6),
                    color: Colors.yellow, size: 18,
                  ),
                  Text(calculateRating(serviceProvider.reviews)
                      .toStringAsFixed(2)),
                  const SizedBox(width: 10),
                  Text(
                    serviceProvider.reviews == null
                        ? 'No reviews yet'
                        : '(${serviceProvider.reviews!.length} reviews)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
