import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

/// 1 second mein lat/lng Firebase pe push karta hai
class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  StreamSubscription<Position>? _posSub;
  bool _isTracking = false;

  Future<void> startTracking() async {
    if (_isTracking) return;

    // Permission check
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;

    _isTracking = true;

    // 1 second interval, HIGH accuracy (GPS)
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,          // Har update bhejo chahe hile ya na hile
      timeLimit: Duration(seconds: 1),
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position pos) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;

        // Firestore pe atomic update — 1 write per second
        await FirebaseFirestore.instance
            .collection('delivery_boys')
            .doc(uid)
            .set({
          'lat': pos.latitude,
          'lng': pos.longitude,
          'accuracy': pos.accuracy,
          'heading': pos.heading,   // Bike direction ke liye
          'speed': pos.speed,
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Active orders mein bhi update karo (customer tracking ke liye)
        final orders = await FirebaseFirestore.instance
            .collection('orders')
            .where('deliveryBoyId', isEqualTo: uid)
            .where('statusIndex', isEqualTo: 3) // sirf "on the way" wale
            .get();

        for (final doc in orders.docs) {
          doc.reference.update({
            'deliveryBoyLat': pos.latitude,
            'deliveryBoyLng': pos.longitude,
          });
        }
      },
      onError: (_) => _isTracking = false,
    );
  }

  Future<void> stopTracking() async {
    await _posSub?.cancel();
    _posSub = null;
    _isTracking = false;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('delivery_boys')
          .doc(uid)
          .set({'isOnline': false, 'lastSeen': FieldValue.serverTimestamp()},
              SetOptions(merge: true));
    }
  }

  bool get isTracking => _isTracking;
}
