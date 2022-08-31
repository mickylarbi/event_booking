import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/firebase_services/firestore_service.dart';
import 'package:event_booking/firebase_services/storage_service.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:event_booking/upload_company_screen/company_list_screen.dart';
import 'package:event_booking/upload_company_screen/service_details_screen.dart';
import 'package:event_booking/utils/constants.dart';
import 'package:event_booking/utils/dialogs.dart';
import 'package:event_booking/utils/functions.dart';
import 'package:firebase_core/firebase_core.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Company'),
          actions: [
            if (widget.serviceProvider.id != null)
              IconButton(
                onPressed: () {
                  showConfirmationDialog(
                    context,
                    message: 'Delete company?',
                    confirmFunction: () {
                      showLoadingDialog(context);

                      db
                          .deleteServiceProvider(widget.serviceProvider.id!)
                          .timeout(ktimeout)
                          .then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context);

                        db
                            .serviceCollectionFromProvider(
                                widget.serviceProvider.id!)
                            .get()
                            .then((value) {
                          for (QueryDocumentSnapshot<
                              Map<String, dynamic>> element in value.docs) {
                            Service service = Service.fromFirestore(
                                element.data(), element.id);
                            for (String element in service.imageUrls!) {
                              storage.instance.ref(element).delete();
                            }
                            db.deleteService(service.id!);
                          }
                        }).onError((error, stackTrace) => null);
                      }).onError((error, stackTrace) {
                        Navigator.pop(context);
                        showAlertDialog(context,
                            message: 'Error deleting company');
                      });
                    },
                  );
                },
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 88),
              children: [
                if (widget.serviceProvider.id == null)
                  ValueListenableBuilder<XFile?>(
                    valueListenable: pictureNotifier,
                    builder: (context, value, _) {
                      return Column(
                        children: [
                          if (value == null)
                            const SizedBox()
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                File(value.path),
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
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
                                            .pickImage(
                                                source: ImageSource.camera)
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
                                backgroundColor:
                                    Colors.blueGrey.withOpacity(.2),
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
                if (widget.serviceProvider.id != null) changePhotoWidget(),
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

                        showConfirmationDialog(
                          context,
                          message: 'Add company?',
                          confirmFunction: () {
                            db
                                .addServiceProvider(newServiceProvider)
                                .timeout(const Duration(minutes: 1))
                                .then((val) {
                              storage
                                  .uploadServiceProviderImage(
                                      File(pictureNotifier.value!.path), val.id)
                                  .timeout(const Duration(minutes: 1))
                                  .then((p0) {
                                val
                                    .get()
                                    .timeout(const Duration(minutes: 1))
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
                                });
                              }).onError((error, stackTrace) {
                                Navigator.pop(context);
                                showAlertDialog(context,
                                    message: 'Error while uploading image');
                              });
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error while uploading company');
                            });
                          },
                        );
                      } else {
                        showConfirmationDialog(
                          context,
                          message: 'Save changes to company?',
                          confirmFunction: () {
                            db
                                .updateServiceProvider(newServiceProvider)
                                .timeout(const Duration(minutes: 1))
                                .then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }).onError((error, stackTrace) {
                              Navigator.pop(context);
                              showAlertDialog(context,
                                  message: 'Error aadding company');
                            });
                          },
                        );
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
                                    Text(service.description!,
                                        style: const TextStyle(
                                            color: Colors.grey)),
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

  changePhotoWidget() {
    return StatefulBuilder(builder: (context, setState) {
      return FutureBuilder<String>(
        future: storage
            .serviceProviderImageReference(widget.serviceProvider.id!)
            .getDownloadURL(),
        builder: (BuildContext context, snapshot) {
          FirebaseException? storageException;
          if (snapshot.hasError && snapshot.error is FirebaseException) {
            storageException = snapshot.error as FirebaseException;
          }

          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: snapshot.hasError ||
                        snapshot.connectionState != ConnectionState.done
                    ? GestureDetector(
                        onTap: () {
                          setState(() {});
                        },
                        child: Container(
                          height: 250,
                          width: 250,
                          color: Colors.grey[200],
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator.adaptive(
                              value: downloadProgress.progress),
                        ),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.person)),
                      ),
              ),
              const SizedBox(height: 20),
              if (snapshot.connectionState == ConnectionState.done ||
                  (storageException != null &&
                      storageException.code == 'object-not-found'))
                Center(
                  child: TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      final ImagePicker picker = ImagePicker();

                      showCustomBottomSheet(
                        context,
                        [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take a photo'),
                            onTap: () {
                              picker
                                  .pickImage(source: ImageSource.camera)
                                  .then((pickedImage) {
                                Navigator.pop(context);
                                if (pickedImage != null) {
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
                                              File(pickedImage.path),
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
                                                .uploadServiceProviderImage(
                                                    File(pickedImage.path),
                                                    widget.serviceProvider.id!)
                                                .timeout(
                                                    const Duration(minutes: 2))
                                                .then((p0) {
                                              Navigator.pop(
                                                  _scaffoldKey.currentContext!);

                                              ScaffoldMessenger.of(_scaffoldKey
                                                      .currentContext!)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Photo updated!')));

                                              setState(() {});
                                            }).onError((error, stackTrace) {
                                              Navigator.pop(context);
                                              showAlertDialog(context,
                                                  message:
                                                      'Error updating image');
                                            });
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
                                showAlertDialog(context);
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Choose from gallery'),
                            onTap: () {
                              picker
                                  .pickImage(source: ImageSource.gallery)
                                  .then((pickedImage) {
                                Navigator.pop(context);
                                if (pickedImage != null) {
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
                                              File(pickedImage.path),
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
                                                .uploadServiceProviderImage(
                                                    File(pickedImage.path),
                                                    widget.serviceProvider.id!)
                                                .timeout(
                                                    const Duration(minutes: 2))
                                                .then((p0) {
                                              Navigator.pop(context);
                                              setState(() {});
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Photo updated!')));
                                            }).onError((error, stackTrace) {
                                              Navigator.pop(context);
                                              showAlertDialog(context,
                                                  message:
                                                      'Error updating image');
                                            });
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
                                showAlertDialog(context);
                              });
                            },
                          ),
                        ],
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Change photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
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
