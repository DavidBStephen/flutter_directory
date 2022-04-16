// Global locator
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:directory/services/contact_service.dart';
import 'package:directory/services/file_service.dart';
import 'package:directory/services/preference_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<GetIt> registerLocator() async {
  locator.reset(dispose: false);
  locator.registerFactory<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerFactory<FirebaseFirestore>(() => FirebaseFirestore.instance);
  locator.registerFactory<FirebaseAnalytics>(() => FirebaseAnalytics.instance);
  locator
      .registerFactory<FirebasePerformance>(() => FirebasePerformance.instance);
  locator.registerFactory<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
  locator.registerLazySingleton<ContactService>(() => ContactService());
  locator.registerLazySingleton<FileService>(() => FileService());
  locator.registerLazySingleton<PreferenceService>(() => PreferenceService());

  // initialization
  await locator.get<PreferenceService>().initialize();
  return locator;
}
