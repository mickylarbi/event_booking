import 'package:event_booking/models/review.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:flutter/material.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  final ServiceProvider serviceProvider;
  const ServiceProviderDetailsScreen({Key? key, required this.serviceProvider})
      : super(key: key);

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
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
                  title: Text(widget.serviceProvider.name!),
                  background: Image.asset(
                    'assets/images/rob-simmons-Qfsgxw-ZWR0-unsplash.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                actions: const [
                  CircleAvatar(
                    child: Text('1'),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            widget.serviceProvider.motto!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.serviceProvider.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                // color: Color.fromARGB(80, 252, 228, 6),
                                color: Colors.yellow, size: 18,
                              ),
                              Text(
                                calculateRating(widget.serviceProvider.reviews)
                                    .toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.serviceProvider.reviews == null
                                    ? 'No reviews yet'
                                    : '(${widget.serviceProvider.reviews!.length} reviews)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Divider(height: 70),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Services'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    // ListView.separated(
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   primary: false,
                    //   padding: const EdgeInsets.only(bottom: 100),
                    //   itemBuilder: (BuildContext context, int index) {
                    //     Service service =
                    //         widget.serviceProvider.services![index];

                    //     return Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Padding(
                    //           padding:
                    //               const EdgeInsets.symmetric(horizontal: 24),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(service.title!),
                    //               const SizedBox(height: 5),
                    //               Text(service.description!),
                    //             ],
                    //           ),
                    //         ),
                    //         const SizedBox(height: 5),
                    //         SizedBox(
                    //           height: 100,
                    //           child: ListView.separated(
                    //             padding: const EdgeInsets.symmetric(
                    //                 horizontal: 24, vertical: 5),
                    //             scrollDirection: Axis.horizontal,
                    //             shrinkWrap: true,
                    //             itemBuilder: (context, index) => ClipRRect(
                    //               borderRadius: BorderRadius.circular(14),
                    //               child: Container(
                    //                 color: Colors.grey,
                    //                 height: 90,
                    //                 width: 90,
                    //               ),
                    //             ),
                    //             separatorBuilder: (context, index) =>
                    //                 const SizedBox(width: 5),
                    //             itemCount: 10,
                    //           ),
                    //         ),
                    //         Center(
                    //           child: TextButton(
                    //             onPressed: () {},
                    //             child: const Text(
                    //               'Add service',
                    //               style: TextStyle(
                    //                 decoration: TextDecoration.underline,
                    //               ),
                    //             ),
                    //           ),
                    //         )
                    //       ],
                    //     );
                    //   },
                    //   itemCount: widget.serviceProvider.services!.length,
                    //   separatorBuilder: (BuildContext context, int index) =>
                    //       const SizedBox(height: 30),
                    // ),
             
             
                  ],
                ),
              )
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  fixedSize: const Size(200, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Hire'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
