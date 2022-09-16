import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/models/event.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/screens/event_screen.dart/map_screen.dart';
import 'package:event_booking/screens/event_screen.dart/services_list_screen.dart';
import 'package:event_booking/screens/service_details_screen.dart';
import 'package:event_booking/utils/constants.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  TextEditingController titleController = TextEditingController();
  ValueNotifier<DateTime?> dateTimeNotifier = ValueNotifier<DateTime?>(null);
  TextEditingController venueStringController = TextEditingController();
  LatLng? venueGeo;
  ValueNotifier<List<String>> hiredServicesNotifier =
      ValueNotifier<List<String>>([]);

  FirestoreService db = FirestoreService();

  @override
  void initState() {
    super.initState();

    if (widget.event.id != null) {
      titleController.text = widget.event.title!;
      dateTimeNotifier.value = widget.event.dateTime;
      venueStringController.text = widget.event.venueString!;
      venueGeo = widget.event.venueGeo;
      hiredServicesNotifier.value = widget.event.hiredServices!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit event'),
          actions: [
            if (widget.event.id != null)
              IconButton(
                  onPressed: () {
                    showConfirmationDialog(context, message: 'Delete event?',
                        confirmFunction: () {
                      showLoadingDialog(context);

                      db.deleteEvent(widget.event.id!).then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }).onError((error, stackTrace) {
                        Navigator.pop(context);
                        showAlertDialog(context,
                            message: 'An error occurred while deleting event');
                      });
                    });
                  },
                  icon: const Icon(Icons.delete)),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 5),
                  child: Text(
                    'Date and time',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                DateTimePicker(dateTimeNotifier: dateTimeNotifier),
                const SizedBox(height: 20),
                TextField(
                  controller: venueStringController,
                  decoration: const InputDecoration(labelText: 'Venue'),
                ),
                const SizedBox(height: 20),
                StatefulBuilder(builder: (context, setState) {
                  return TextButton(
                    onPressed: () async {
                      LatLng? result = await navigate(
                          context,
                          MapScreen(
                            initialSelectedPostion: venueGeo,
                          ));

                      if (result != null) {
                        venueGeo = result;
                      }
                      setState(() {});
                    },
                    style: venueGeo != null
                        ? translucentButtonStyle.copyWith(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.yellow),
                            backgroundColor: MaterialStateProperty.all(
                                Colors.yellow.withOpacity(.12)))
                        : translucentButtonStyle,
                    child: Text(
                      venueGeo != null
                          ? 'Change location on map'
                          : 'Choose location on map',
                    ),
                  );
                }),
                const Divider(height: 70),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Logistics',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () async {
                          hiredServices = hiredServicesNotifier.value;
                          pagesToPop = 1;

                          String? result = await navigate(
                              context, const ServicesListScreen());
                          pagesToPop = 0;
                          hiredServices = [];

                          if (result != null) {
                            hiredServicesNotifier.value = [
                              ...hiredServicesNotifier.value,
                              result
                            ];
                          }
                        },
                        child: const Text(
                          'Add service',
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<List<String>>(
                  valueListenable: hiredServicesNotifier,
                  builder: (context, value, child) {
                    return ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: hiredServicesNotifier.value.length,
                      itemBuilder: (context, index) =>
                          StatefulBuilder(builder: (context, setState) {
                        return FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          future: db.getServiceFromId(value[index]).get(),
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
                              Service service = Service.fromFirestore(
                                  snapshot.data!.data()!, snapshot.data!.id);

                              return GestureDetector(
                                  onTap: () async {
                                    hiredServices = hiredServicesNotifier.value;
                                    pagesToPop = 1;

                                    String? result = await navigate(context,
                                        ServiceDetailsScreen(service: service));
                                    hiredServices = [];
                                    pagesToPop = 0;

                                    if (result != null) {
                                      hiredServicesNotifier.value = [
                                        ...hiredServicesNotifier.value,
                                        result
                                      ];
                                    }
                                  },
                                  onLongPress: () {
                                    showCustomBottomSheet(context, [
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('Remove service'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          List<String> temp =
                                              hiredServicesNotifier.value;
                                          temp.remove(service.id);
                                          hiredServicesNotifier.value = [
                                            ...temp
                                          ];
                                        },
                                      )
                                    ]);
                                  },
                                  child: ServicesCard(service: service));
                            }

                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          },
                        );
                      }),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Event newEvent = Event(
                          id: widget.event.id,
                          title: titleController.text.trim(),
                          dateTime: dateTimeNotifier.value,
                          venueString: venueStringController.text.trim(),
                          venueGeo: venueGeo,
                          hiredServices: hiredServicesNotifier.value);

                      if (newEvent.title!.isEmpty) {
                        showAlertDialog(context,
                            message: 'Title cannot be empty');
                      } else if (dateTimeNotifier.value == null) {
                        showAlertDialog(context,
                            message: 'Please choose a date and time');
                      } else if (newEvent.venueString!.isEmpty) {
                        showAlertDialog(context,
                            message: 'Please type in a venue');
                      } else if (venueGeo == null) {
                        showAlertDialog(context,
                            message: 'Please choose a location from map');
                      } else if (hiredServicesNotifier.value.isEmpty) {
                        showAlertDialog(context,
                            message: 'At least one service should be added');
                      } else {
                        showConfirmationDialog(context,
                            message: widget.event.id == null
                                ? 'Add event?'
                                : 'Save changes to event?',
                            confirmFunction: () {
                          showLoadingDialog(context);

                          if (widget.event.id == null) {
                            db
                                .addEvent(newEvent)
                                .timeout(ktimeout)
                                .then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message:
                                      'An error occurred while adding event');
                            });
                          } else {
                            db.updateEvent(newEvent).then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message:
                                      'An error occurred while updating event');
                            });
                          }
                        });
                      }
                    },
                    style: elevatedButtonStyle,
                    child: Text(
                        widget.event.id == null ? 'Add event' : 'Save changes'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    dateTimeNotifier.dispose();
    venueStringController.dispose();
    hiredServicesNotifier.dispose();

    super.dispose();
  }
}

class ServicesCard extends StatelessWidget {
  ServicesCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  final Service service;

  FirestoreService db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.title!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: db.getServiceProviderFromId(service.providerId!).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    ServiceProvider serviceProvider =
                        ServiceProvider.fromFirestore(
                            snapshot.data!.data()!, snapshot.data!.id);

                    return Text(serviceProvider.name!);
                  }
                  return const SizedBox();
                }),
            const SizedBox(height: 10),
            Text(service.description!,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(service.price),
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    Key? key,
    required this.dateTimeNotifier,
  }) : super(key: key);

  final ValueNotifier<DateTime?> dateTimeNotifier;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate: dateTimeNotifier.value ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100))
            .then((date) {
          showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      dateTimeNotifier.value ?? DateTime.now()))
              .then((time) {
            dateTimeNotifier.value ??= DateTime.now();
            if (date != null && time != null) {
              dateTimeNotifier.value = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
            } else if (time != null) {
              dateTimeNotifier.value = DateTime(
                  dateTimeNotifier.value!.year,
                  dateTimeNotifier.value!.month,
                  dateTimeNotifier.value!.day,
                  time.hour,
                  time.minute);
            } else if (date != null) {
              dateTimeNotifier.value = DateTime(date.year, date.month, date.day,
                  dateTimeNotifier.value!.hour, dateTimeNotifier.value!.minute);
            }
          }).onError((error, stackTrace) {
            showAlertDialog(context);
          });
        }).onError((error, stackTrace) {
          showAlertDialog(context);
        });
      },
      style: translucentButtonStyle,
      child: ValueListenableBuilder<DateTime?>(
          valueListenable: dateTimeNotifier,
          builder: (context, value, child) {
            return value == null
                ? const Text('Choose date and time')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMMd().format(value),
                        style: const TextStyle(color: Colors.blue),
                      ),
                      Text(
                        DateFormat.jm().format(value),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  );
          }),
    );
  }
}
