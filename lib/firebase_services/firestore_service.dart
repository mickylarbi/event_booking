import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';

class FirestoreService {
  FirebaseFirestore instance = FirebaseFirestore.instance;

  //SERVICE PROVIDER

  CollectionReference<Map<String, dynamic>> get serviceProviderCollection =>
      instance.collection('serviceProviders');

  DocumentReference<Map<String, dynamic>> getServiceProviderFromId(String id) =>
      serviceProviderCollection.doc(id);

  Future<DocumentReference<Map<String, dynamic>>> uploadServiceProvider(
          ServiceProvider serviceProvider) =>
      serviceProviderCollection.add(serviceProvider.toMap());

  Future<void> updateServiceProvider(ServiceProvider serviceProvider) =>
      serviceProviderCollection
          .doc(serviceProvider.id)
          .update(serviceProvider.toMap());

  //SERVICES

  CollectionReference<Map<String, dynamic>> get serviceCollection =>
      instance.collection('services');

       Query<Map<String, dynamic>>  serviceCollectionFromProvider(String providerId) =>
      instance.collection('services').where('providerId',isEqualTo: providerId);

  DocumentReference<Map<String, dynamic>> getServiceFromId(String id) =>
      serviceCollection.doc(id);

  Future<DocumentReference<Map<String, dynamic>>> uploadService(
          Service service) =>
      serviceCollection.add(service.toMap());

  Future<void> updateService(Service service) =>
      serviceCollection.doc(service.id).update(service.toMap());
}
