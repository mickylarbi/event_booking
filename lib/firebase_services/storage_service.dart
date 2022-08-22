import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  FirebaseStorage instance = FirebaseStorage.instance;

  //SERVICE PROVIDER

  Reference serviceProviderImageReference(String id) =>
      instance.ref('serviceProviderImages/$id');

  UploadTask uploadServiceProviderImage(File file, String id) =>
      instance.ref('serviceProviderImages/$id').putFile(file);

  //SERVICE

  Reference imageReference(String imageUrl) => instance.ref(imageUrl);

  UploadTask uploadServiceImage(XFile xFile, String serviceId) => instance
      .ref('serviceImages/$serviceId/${xFile.name}')
      .putFile(File(xFile.path));
}
