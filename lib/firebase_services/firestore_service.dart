import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/models/event.dart';
import 'package:event_booking/models/service.dart';
import 'package:event_booking/models/service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirebaseFirestore instance = FirebaseFirestore.instance;

  //SERVICE PROVIDER

  CollectionReference<Map<String, dynamic>> get serviceProviderCollection =>
      instance.collection('serviceProviders');

  DocumentReference<Map<String, dynamic>> getServiceProviderFromId(String id) =>
      serviceProviderCollection.doc(id);

  Future<DocumentReference<Map<String, dynamic>>> addServiceProvider(
          ServiceProvider serviceProvider) =>
      serviceProviderCollection.add(serviceProvider.toMap());

  Future<void> updateServiceProvider(ServiceProvider serviceProvider) =>
      serviceProviderCollection
          .doc(serviceProvider.id)
          .update(serviceProvider.toMap());

  Future<void> deleteServiceProvider(String serviceProviderId) =>
      serviceProviderCollection.doc(serviceProviderId).delete();

  //SERVICES

  CollectionReference<Map<String, dynamic>> get serviceCollection =>
      instance.collection('services');

  Query<Map<String, dynamic>> serviceCollectionFromProvider(
          String providerId) =>
      serviceCollection.where('providerId', isEqualTo: providerId);

  DocumentReference<Map<String, dynamic>> getServiceFromId(String id) =>
      serviceCollection.doc(id);

  Future<DocumentReference<Map<String, dynamic>>> addService(Service service) =>
      serviceCollection.add(service.toMap());

  Future<void> updateService(Service service) =>
      serviceCollection.doc(service.id).update(service.toMap());

  Future<void> deleteService(String serviceId) =>
      serviceCollection.doc(serviceId).delete();

  //EVENTS

  CollectionReference<Map<String, dynamic>> get eventsCollection =>
      instance.collection('events');

  Query<Map<String, dynamic>> get myEvents => eventsCollection
      .where('customerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  Future<DocumentReference<Map<String, dynamic>>> addEvent(Event event) =>
      eventsCollection.add(event.toMap());

  Future<void> updateEvent(Event event) =>
      eventsCollection.doc(event.id).update(event.toMap());

  Future<void> deleteEvent(String eventId) =>
      eventsCollection.doc(eventId).delete();
}
