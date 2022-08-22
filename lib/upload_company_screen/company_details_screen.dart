import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/firebase_services/storage_service.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/upload_company_screen/service_details_screen.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final ServiceProvider serviceProvider;
  const CompanyDetailsScreen({
    Key? key,
    required this.serviceProvider,
  }) : super(key: key);

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  ValueNotifier<XFile?> pictureNotifier = ValueNotifier<XFile?>(null);
  TextEditingController nameController = TextEditingController();
  TextEditingController mottoController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  FirestoreService db = FirestoreService();
  StorageService storage = StorageService();

  @override
  void initState() {
    super.initState();

    if (widget.serviceProvider.id != null) {
      nameController.text = widget.serviceProvider.name!;
      mottoController.text = widget.serviceProvider.motto!;
      bioController.text = widget.serviceProvider.bio!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Company'),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 88),
              children: [
                ValueListenableBuilder<XFile?>(
                  valueListenable: pictureNotifier,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (value != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(value.path),
                                height: 250,
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (value == null && widget.serviceProvider.id != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                color: Colors.grey[200],
                                height: 250,
                                width: 250,
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return FutureBuilder<String>(
                                      future: storage
                                          .serviceProviderImageReference(
                                              widget.serviceProvider.id!)
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
                                          return Image.network(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        }

                                        return const Center(
                                            child: CircularProgressIndicator
                                                .adaptive());
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              final ImagePicker picker = ImagePicker();

                              showCustomBottomSheet(
                                context,
                                [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Take a photo'),
                                    onTap: () async {
                                      picker
                                          .pickImage(source: ImageSource.camera)
                                          .then((value) {
                                        Navigator.pop(context);
                                        if (value != null) {
                                          pictureNotifier.value = value;
                                        }
                                      }).onError((error, stackTrace) {
                                        Navigator.pop(context);
                                        showAlertDialog(context);
                                      });
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo),
                                    title: const Text('Choose from gallery'),
                                    onTap: () async {
                                      picker
                                          .pickImage(
                                              source: ImageSource.gallery)
                                          .then((value) {
                                        Navigator.pop(context);
                                        if (value != null) {
                                          pictureNotifier.value = value;
                                        }
                                      }).onError((error, stackTrace) {
                                        showAlertDialog(context);
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              backgroundColor: Colors.blueGrey.withOpacity(.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(value == null
                                ? 'Choose photo'
                                : 'Change photo'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: mottoController,
                  decoration: const InputDecoration(labelText: 'Motto'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  maxLines: 10,
                  minLines: 1,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    ServiceProvider newServiceProvider = ServiceProvider(
                      id: widget.serviceProvider.id,
                      name: nameController.text.trim(),
                      motto: mottoController.text.trim(),
                      bio: bioController.text.trim(),
                    );

                    if (pictureNotifier.value == null &&
                        newServiceProvider.id == null) {
                      showAlertDialog(context, message: 'Choose an image');
                    } else if (newServiceProvider.name!.isNotEmpty &&
                        newServiceProvider.motto!.isNotEmpty &&
                        newServiceProvider.bio!.isNotEmpty) {
                      if (widget.serviceProvider.id == null) {
                        showLoadingDialog(context);

                        db
                            .uploadServiceProvider(newServiceProvider)
                            .then((val) {
                          storage
                              .uploadServiceProviderImage(
                                  File(pictureNotifier.value!.path), val.id)
                              .then((p0) {
                            val.get().then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                  context,
                                  CompanyDetailsScreen(
                                      serviceProvider:
                                          ServiceProvider.fromFirestore(
                                              valVal.data()!, valVal.id)));
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching company');
                            }).timeout(const Duration(minutes: 1));
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error while uploading image');
                          }).timeout(const Duration(minutes: 1));
                        }).onError((error, stackTrace) {
                          Navigator.pop(context);
                          showAlertDialog(context,
                              message: 'Error while uploading company');
                        }).timeout(const Duration(minutes: 1));
                      } else {
                        if (widget.serviceProvider != newServiceProvider &&
                            pictureNotifier.value != null) {
                          showLoadingDialog(context);

                          db
                              .updateServiceProvider(newServiceProvider)
                              .then((val) {
                            storage
                                .uploadServiceProviderImage(
                                    File(pictureNotifier.value!.path),
                                    newServiceProvider.id!)
                                .then((p0) {
                              db
                                  .getServiceProviderFromId(
                                      newServiceProvider.id!)
                                  .get()
                                  .then((valVal) {
                                Navigator.pop(context);
                                Navigator.pop(context);

                                navigate(
                                    context,
                                    CompanyDetailsScreen(
                                        serviceProvider:
                                            ServiceProvider.fromFirestore(
                                                valVal.data()!, valVal.id)));
                              }).onError((error, stackTrace) {
                                Navigator.pop(context);
                                showAlertDialog(context,
                                    message: 'Error while fetching company');
                              }).timeout(const Duration(minutes: 1));
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while uploading image');
                            }).timeout(const Duration(minutes: 1));
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error while updating company');
                          }).timeout(const Duration(minutes: 1));
                        } else if (pictureNotifier.value != null) {
                          showLoadingDialog(context);

                          storage
                              .uploadServiceProviderImage(
                                  File(pictureNotifier.value!.path),
                                  newServiceProvider.id!)
                              .then((p0) {
                            db
                                .getServiceProviderFromId(
                                    newServiceProvider.id!)
                                .get()
                                .then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                  context,
                                  CompanyDetailsScreen(
                                      serviceProvider:
                                          ServiceProvider.fromFirestore(
                                              valVal.data()!, valVal.id)));
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching company');
                            }).timeout(const Duration(minutes: 1));
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error while uploading image');
                          }).timeout(const Duration(minutes: 1));
                        } else if (widget.serviceProvider !=
                            newServiceProvider) {
                          showLoadingDialog(context);

                          db
                              .updateServiceProvider(newServiceProvider)
                              .then((value) {
                            db
                                .getServiceProviderFromId(
                                    newServiceProvider.id!)
                                .get()
                                .then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                  context,
                                  CompanyDetailsScreen(
                                      serviceProvider:
                                          ServiceProvider.fromFirestore(
                                              valVal.data()!, valVal.id)));
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching company');
                            }).timeout(const Duration(minutes: 1));
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error while updating company');
                          }).timeout(const Duration(minutes: 1));
                        }
                      }
                    } else {
                      showAlertDialog(context,
                          message: 'Textfields cannot be empty');
                    }
                  },
                  style: TextButton.styleFrom(
                    fixedSize: const Size(250, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(widget.serviceProvider.id == null
                      ? 'Add company'
                      : 'Edit company'),
                ),
                const SizedBox(height: 100),
                if (widget.serviceProvider.id != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Services',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            navigate(
                                context,
                                ServiceDetailsScreen(
                                  service: Service(),
                                  providerId: widget.serviceProvider.id!,
                                ));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            backgroundColor: Colors.blueGrey.withOpacity(.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Add service'),
                        ),
                      ),
                    ],
                  ),
                if (widget.serviceProvider.id != null)
                  const SizedBox(height: 20),
                if (widget.serviceProvider.id != null)
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: db
                        .serviceCollectionFromProvider(
                            widget.serviceProvider.id!)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Couldn't load services"),
                              IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      List<Service> servicesList = snapshot.data!.docs
                          .map((e) => Service.fromFirestore(e.data(), e.id))
                          .toList();

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        primary: false,
                        itemBuilder: (context, index) {
                          Service service = servicesList[index];

                          return InkWell(
                            onTap: () {
                              navigate(
                                  context,
                                  ServiceDetailsScreen(
                                    service: service,
                                    providerId: widget.serviceProvider.id!,
                                  ));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service.title!),
                                    const SizedBox(height: 10),
                                    Text(
                                      service.description!,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                        'GH₵ ${service.leastPrice!.toStringAsFixed(2)} - ${service.highestPrice!.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemCount: servicesList.length,
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    pictureNotifier.dispose();

    nameController.dispose();
    mottoController.dispose();
    bioController.dispose();

    super.dispose();
  }
}
