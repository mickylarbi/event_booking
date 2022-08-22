import 'package:event_booking/models/event.dart';
import 'package:event_booking/screens/event_screen.dart/service_providers_list_screen.dart';
import 'package:event_booking/screens/shared/custom_textformfield.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
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
  TextEditingController venueController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.event.id != null) {
      titleController.text = widget.event.title!;
      dateTimeNotifier.value = widget.event.dateTime;
      venueController.text = widget.event.venue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit event'),
          actions: [
            if (widget.event.id != null)
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
          ],
        ),
        body: ListView(
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
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                showCustomBottomSheet(
                  context,
                  [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: const Text('Change date'),
                      onTap: () async {
                        Navigator.pop(context);

                        DateTime? result = await showDatePicker(
                            context: context,
                            initialDate:
                                widget.event.dateTime ?? DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100));

                        if (result != null) {
                          DateTime temp =
                              dateTimeNotifier.value ?? DateTime.now();
                          dateTimeNotifier.value = DateTime(result.year,
                              result.month, result.day, temp.hour, temp.minute);
                        }
                      },
                    ),
                    const Divider(height: 10),
                    ListTile(
                      leading: const Icon(Icons.timer_outlined),
                      title: const Text('Change time'),
                      onTap: () async {
                        Navigator.pop(context);

                        TimeOfDay? result = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                widget.event.dateTime ?? DateTime.now()));

                        if (result != null) {
                          DateTime temp =
                              dateTimeNotifier.value ?? DateTime.now();
                          dateTimeNotifier.value = DateTime(temp.year,
                              temp.month, temp.day, result.hour, result.minute);
                        }
                      },
                    ),
                  ],
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.withOpacity(.2)),
                child: ValueListenableBuilder<DateTime?>(
                    valueListenable: dateTimeNotifier,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(value ?? DateTime.now()),
                            style: const TextStyle(color: Colors.blue),
                          ),
                          Text(
                            DateFormat.jm().format(value ?? DateTime.now()),
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      );
                    }),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.pink.withOpacity(.1),
              child: const Text('some google maps things go go on for here'),
            ),
            const Divider(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Logistics',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      navigate(context, ServiceProvidersListScreen());
                    },
                    child: const Text(
                      'View service providers',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    dateTimeNotifier.dispose();
    venueController.dispose();

    super.dispose();
  }
}
