import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/firebase_services/storage_service.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/utils/constants.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;
  final String providerId;
  const EditServiceScreen(
      {Key? key, required this.service, required this.providerId})
      : super(key: key);

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController leastPriceController = TextEditingController();
  TextEditingController highestPriceController = TextEditingController();

  FirestoreService db = FirestoreService();
  StorageService storage = StorageService();

  List<String>? imageUrls;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Service'),
          actions: [
            if (widget.service.id != null)
              IconButton(
                onPressed: () {
                  showConfirmationDialog(
                    context,
                    message: 'Delete service?',
                    confirmFunction: () {
                      showLoadingDialog(context);
                      db
                          .deleteService(widget.service.id!)
                          .timeout(ktimeout)
                          .then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        for (String element in widget.service.imageUrls!) {
                          storage.instance.ref(element).delete();
                        }
                      }).onError((error, stackTrace) {
                        Navigator.pop(context);
                        showAlertDialog(context,
                            message: 'Error deleting service');
                      });
                    },
                  );
                },
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: ListView(
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
                    decoration:
                        const InputDecoration(labelText: 'Least price (GH₵)'),
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: TextField(
                    controller: highestPriceController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Highest price (GH₵)'),
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
                  leastPrice: double.tryParse(leastPriceController.text.trim()),
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
                      showConfirmationDialog(
                        context,
                        message: 'Add service?',
                        confirmFunction: () {
                          db
                              .addService(newService)
                              .timeout(const Duration(minutes: 1))
                              .then((val) async {
                            val
                                .get()
                                .timeout(const Duration(minutes: 1))
                                .then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                context,
                                EditServiceScreen(
                                  service: Service.fromFirestore(
                                      valVal.data()!, valVal.id),
                                  providerId: widget.providerId,
                                ),
                              );
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching service');
                            });
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error uploading service');
                          });
                        },
                      );
                    } else {
                      showConfirmationDialog(
                        context,
                        message: 'Save changes to service?',
                        confirmFunction: () {
                          db
                              .updateService(newService)
                              .timeout(const Duration(minutes: 1))
                              .then((value) {
                            db
                                .getServiceFromId(newService.id!)
                                .get()
                                .timeout(const Duration(minutes: 1))
                                .then((valVal) {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              navigate(
                                  context,
                                  EditServiceScreen(
                                    service: Service.fromFirestore(
                                        valVal.data()!, valVal.id),
                                    providerId: widget.providerId,
                                  ));
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while fetching service');
                            });
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                            showAlertDialog(context,
                                message: 'Error uploading service');
                          });
                        },
                      );
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
              child: Text(
                  widget.service.id == null ? 'Add service' : 'Edit service'),
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      alignment: Alignment.center,
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: Image.file(
                                              File(xFile.path),
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: 100,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey[200]),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                          child: const Text(
                                            'CANCEL',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: .5),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);

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
                                                leastPrice:
                                                    widget.service.leastPrice,
                                                highestPrice:
                                                    widget.service.highestPrice,
                                                imageUrls: [
                                                  ...imageUrls!,
                                                  'serviceImages/${widget.service.id}/${xFile.name}'
                                                ],
                                              ))
                                                  .then((value) {
                                                Navigator.pop(_scaffoldKey
                                                    .currentContext!);
                                              }).onError((error, stackTrace) {
                                                Navigator.pop(_scaffoldKey
                                                    .currentContext!);
                                                showAlertDialog(
                                                    _scaffoldKey
                                                        .currentContext!,
                                                    message:
                                                        'Error adding image');
                                              }).timeout(const Duration(
                                                      minutes: 1));
                                            }).onError((error, stackTrace) {
                                              Navigator.pop(context);
                                              showAlertDialog(context,
                                                  message:
                                                      'Error uploading image');
                                            }).timeout(
                                                    const Duration(minutes: 1));
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Theme.of(context)
                                                        .primaryColor),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                          child: const Text(
                                            'UPLOAD PHOTO',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: .5),
                                          ),
                                        ),
                                      ],
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      actionsPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14),
                                    ),
                                  );
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      alignment: Alignment.center,
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: Image.file(
                                              File(xFile.path),
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: 100,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey[200]),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                          child: const Text(
                                            'CANCEL',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: .5),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);

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
                                                leastPrice:
                                                    widget.service.leastPrice,
                                                highestPrice:
                                                    widget.service.highestPrice,
                                                imageUrls: [
                                                  ...imageUrls!,
                                                  'serviceImages/${widget.service.id}/${xFile.name}'
                                                ],
                                              ))
                                                  .then((value) {
                                                Navigator.pop(_scaffoldKey
                                                    .currentContext!);
                                              }).onError((error, stackTrace) {
                                                Navigator.pop(_scaffoldKey
                                                    .currentContext!);
                                                showAlertDialog(
                                                    _scaffoldKey
                                                        .currentContext!,
                                                    message:
                                                        'Error adding image');
                                              }).timeout(const Duration(
                                                      minutes: 1));
                                            }).onError((error, stackTrace) {
                                              Navigator.pop(context);
                                              showAlertDialog(context,
                                                  message:
                                                      'Error uploading image');
                                            }).timeout(
                                                    const Duration(minutes: 1));
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Theme.of(context)
                                                        .primaryColor),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                          child: const Text(
                                            'UPLOAD PHOTO',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: .5),
                                          ),
                                        ),
                                      ],
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      actionsPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14),
                                    ),
                                  );
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
                  stream: db.getServiceFromId(widget.service.id!).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                                              child: CachedNetworkImage(
                                                imageUrl: snapshot.data!,
                                                height: 250,
                                                width: 250,
                                                progressIndicatorBuilder: (context,
                                                        url,
                                                        downloadProgress) =>
                                                    CircularProgressIndicator
                                                        .adaptive(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showConfirmationDialog(
                                                context,
                                                message: 'Delete image?',
                                                confirmFunction: () {
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
                                                      Navigator.pop(_scaffoldKey
                                                          .currentContext!);
                                                    }).onError((error,
                                                            stackTrace) {
                                                      Navigator.pop(_scaffoldKey
                                                          .currentContext!);
                                                      showAlertDialog(
                                                          _scaffoldKey
                                                              .currentContext!,
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
                                              );
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
