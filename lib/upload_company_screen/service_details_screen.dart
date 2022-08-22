import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/firebase_services/storage_service.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Service service;
  final String providerId;
  const ServiceDetailsScreen(
      {Key? key, required this.service, required this.providerId})
      : super(key: key);

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController leastPriceController = TextEditingController();
  TextEditingController highestPriceController = TextEditingController();

  FirestoreService db = FirestoreService();
  StorageService storage = StorageService();

  List<String>? imageUrls;

  @override
  void initState() {
    super.initState();

    if (widget.service.id != null) {
      titleController.text = widget.service.title!;
      descriptionController.text = widget.service.description!;
      leastPriceController.text = widget.service.leastPrice!.toStringAsFixed(2);
      highestPriceController.text =
          widget.service.highestPrice!.toStringAsFixed(2);
      imageUrls = widget.service.imageUrls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Service')),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 88),
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  minLines: 1,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: leastPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Least price (GH₵)'),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: TextField(
                        controller: highestPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Highest price (GH₵)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Service newService = Service(
                      id: widget.service.id ?? '',
                      providerId: widget.service.providerId,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      leastPrice:
                          double.tryParse(leastPriceController.text.trim()),
                      highestPrice:
                          double.tryParse(highestPriceController.text.trim()),
                    );
                    if (widget.service != newService) {
                      if (newService.title!.isNotEmpty &&
                          newService.description!.isNotEmpty &&
                          newService.leastPrice != null &&
                          newService.highestPrice != null) {
                        showLoadingDialog(context);

                        if (widget.service.id == null) {
                          db.uploadService(newService).then((val) async {
                            val.get().then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                context,
                                ServiceDetailsScreen(
                                  service: Service.fromFirestore(
                                      valVal.data()!, valVal.id),
                                  providerId: widget.providerId,
                                ),
                              );
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching service');
                            }).timeout(const Duration(minutes: 1));
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error uploading service');
                          }).timeout(const Duration(minutes: 1));
                        } else {
                          db.updateService(newService).then((value) {
                            db
                                .getServiceFromId(newService.id!)
                                .get()
                                .then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                  context,
                                  ServiceDetailsScreen(
                                    service: Service.fromFirestore(
                                        valVal.data()!, valVal.id),
                                    providerId: widget.providerId,
                                  ));
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching service');
                            }).timeout(const Duration(minutes: 1));
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error uploading service');
                          }).timeout(const Duration(minutes: 1));
                        }
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    elevation: 0,
                    fixedSize: const Size(250, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(widget.service.id == null
                      ? 'Add service'
                      : 'Edit service'),
                ),
                const SizedBox(height: 100),
                if (widget.service.id != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Images',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      TextButton(
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
                                      .then((xFile) {
                                    Navigator.pop(context);

                                    if (xFile != null) {
                                      showLoadingDialog(context);

                                      storage
                                          .uploadServiceImage(
                                              xFile, widget.service.id!)
                                          .then((p0) {
                                        db
                                            .updateService(Service(
                                          id: widget.service.id,
                                          providerId: widget.providerId,
                                          title: widget.service.title,
                                          description:
                                              widget.service.description,
                                          leastPrice: widget.service.leastPrice,
                                          highestPrice:
                                              widget.service.highestPrice,
                                          imageUrls: [
                                            ...imageUrls!,
                                            'serviceImages/${widget.service.id}/${xFile.name}'
                                          ],
                                        ))
                                            .then((value) {
                                          Navigator.pop(context);
                                        }).onError((error, stackTrace) {
                                          Navigator.pop(context);
                                          showAlertDialog(context,
                                              message: 'Error adding image');
                                        }).timeout(const Duration(minutes: 1));
                                      }).onError((error, stackTrace) {
                                        Navigator.pop(context);
                                        showAlertDialog(context,
                                            message: 'Error uploading image');
                                      }).timeout(const Duration(minutes: 1));
                                    }
                                  }).onError((error, stackTrace) {
                                    Navigator.pop(context);
                                    showAlertDialog(context);
                                  }).timeout(const Duration(minutes: 1));
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Choose from gallery'),
                                onTap: () async {
                                  picker
                                      .pickImage(source: ImageSource.gallery)
                                      .then((xFile) {
                                    Navigator.pop(context);

                                    if (xFile != null) {
                                      showLoadingDialog(context);

                                      storage
                                          .uploadServiceImage(
                                              xFile, widget.service.id!)
                                          .then((p0) {
                                        db
                                            .updateService(Service(
                                          id: widget.service.id,
                                          providerId: widget.providerId,
                                          title: widget.service.title,
                                          description:
                                              widget.service.description,
                                          leastPrice: widget.service.leastPrice,
                                          highestPrice:
                                              widget.service.highestPrice,
                                          imageUrls: [
                                            ...imageUrls!,
                                            'serviceImages/${widget.service.id}/${xFile.name}'
                                          ],
                                        ))
                                            .then((value) {
                                          Navigator.pop(context);
                                        }).onError((error, stackTrace) {
                                          Navigator.pop(context);
                                          showAlertDialog(context,
                                              message: 'Error adding image');
                                        }).timeout(const Duration(minutes: 1));
                                      }).onError((error, stackTrace) {
                                        Navigator.pop(context);
                                        showAlertDialog(context,
                                            message: 'Error uploading image');
                                      }).timeout(const Duration(minutes: 1));
                                    }
                                  }).onError((error, stackTrace) {
                                    Navigator.pop(context);
                                    showAlertDialog(context);
                                  }).timeout(const Duration(minutes: 1));
                                },
                              ),
                            ],
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          backgroundColor: Colors.blueGrey.withOpacity(.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add image'),
                      ),
                    ],
                  ),
                if (widget.service.id != null) const SizedBox(height: 20),
                if (widget.service.id != null)
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream:
                          db.getServiceFromId(widget.service.id!).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong'),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        }

                        imageUrls = Service.fromFirestore(
                                snapshot.data!.data()!, snapshot.data!.id)
                            .imageUrls;

                        return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            primary: false,
                            itemBuilder: (context, index) =>
                                StatefulBuilder(builder: (context, setState) {
                                  return FutureBuilder<String>(
                                      future: storage
                                          .imageReference(imageUrls![index])
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
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: SizedBox(
                                                  height: 250,
                                                  width: 250,
                                                  child: Image.network(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  showLoadingDialog(context);

                                                  storage
                                                      .imageReference(
                                                          imageUrls![index])
                                                      .delete()
                                                      .then((value) {
                                                    List<String> temps = [
                                                      ...imageUrls!
                                                    ];
                                                    temps.removeAt(index);

                                                    db
                                                        .updateService(Service(
                                                      id: widget.service.id,
                                                      providerId:
                                                          widget.providerId,
                                                      title:
                                                          widget.service.title,
                                                      description: widget
                                                          .service.description,
                                                      leastPrice: widget
                                                          .service.leastPrice,
                                                      highestPrice: widget
                                                          .service.highestPrice,
                                                      imageUrls: [...temps],
                                                    ))
                                                        .then((value) {
                                                      Navigator.pop(context);
                                                    }).onError((error,
                                                            stackTrace) {
                                                      Navigator.pop(context);
                                                      showAlertDialog(context,
                                                          message:
                                                              'Error removing image');
                                                    }).timeout(const Duration(
                                                            minutes: 1));
                                                  }).onError(
                                                          (error, stackTrace) {
                                                    Navigator.pop(context);
                                                    showAlertDialog(context,
                                                        message:
                                                            'Error deleting image');
                                                  }).timeout(const Duration(
                                                          minutes: 1));
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        return const Center(
                                            child: CircularProgressIndicator
                                                .adaptive());
                                      });
                                }),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 20),
                            itemCount: imageUrls!.length);
                      })
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    leastPriceController.dispose();
    highestPriceController.dispose();

    super.dispose();
  }
}
