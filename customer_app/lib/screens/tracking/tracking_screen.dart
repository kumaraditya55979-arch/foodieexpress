import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  MapplsMapController? _mapCtrl;
  Symbol? _deliveryMarker;
  LatLng? _currentPos;

  // Smooth animation
  late AnimationController _markerAnim;
  late AnimationController _pulseAnim;
  Animation<double>? _latAnim, _lngAnim;
  LatLng? _animatedPos;

  StreamSubscription? _orderSub;
  StreamSubscription? _deliverySub;

  @override
  void initState() {
    super.initState();
    _markerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _listenOrder();
  }

  void _listenOrder() {
    _orderSub = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final data = snap.data()!;
      final uid = data['deliveryBoyId'] as String?;
      if (uid != null && uid.isNotEmpty) _listenDeliveryBoy(uid);
    });
  }

  void _listenDeliveryBoy(String uid) {
    _deliverySub?.cancel();
    _deliverySub = FirebaseFirestore.instance
        .collection('delivery_boys')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (!snap.exists || !mounted) return;
      final data = snap.data()!;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);
      if (_currentPos == null) {
        setState(() {
          _currentPos = newPos;
          _animatedPos = newPos;
        });
        _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 15));
        _addMarker(newPos);
      } else {
        _animateMarker(_currentPos!, newPos);
      }
      _currentPos = newPos;
    });
  }

  Future<void> _addMarker(LatLng pos) async {
    if (_mapCtrl == null) return;
    _deliveryMarker = await _mapCtrl!.addSymbol(SymbolOptions(
      geometry: pos,
      iconImage: 'assets/mappls/delivery_icon.png',
      iconSize: 1.5,
      textField: 'Delivery Partner',
      textOffset: const Offset(0, 2),
      textSize: 12,
    ));
  }

  void _animateMarker(LatLng from, LatLng to) {
    _markerAnim.reset();
    _latAnim = Tween<double>(begin: from.latitude, end: to.latitude)
        .animate(CurvedAnimation(parent: _markerAnim, curve: Curves.easeInOut));
    _lngAnim = Tween<double>(begin: from.longitude, end: to.longitude)
        .animate(CurvedAnimation(parent: _markerAnim, curve: Curves.easeInOut));

    _markerAnim.addListener(() {
      if (_latAnim == null || _lngAnim == null) return;
      final pos = LatLng(_latAnim!.value, _lngAnim!.value);
      setState(() => _animatedPos = pos);

      // Move marker on map
      if (_deliveryMarker != null) {
        _mapCtrl?.updateSymbol(_deliveryMarker!, SymbolOptions(geometry: pos));
      }
      // Camera follow
      _mapCtrl?.animateCamera(CameraUpdate.newLatLng(pos));
    });

    _markerAnim.forward();
  }

  @override
  void dispose() {
    _markerAnim.dispose();
    _pulseAnim.dispose();
    _orderSub?.cancel();
    _deliverySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );

        final data = snap.data!.data() as Map<String, dynamic>;
        final si = (data['statusIndex'] as int?) ?? 0;
        final statusLabels = ['Order Placed', 'Confirmed', 'Preparing', 'On the way 🛵', 'Delivered ✅'];
        final steps = ['Placed', 'Confirmed', 'Preparing', 'On way', 'Delivered'];

        return Scaffold(
          appBar: AppBar(
            title: Text('Track Order #${widget.orderId.substring(0, 6).toUpperCase()}'),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(children: [
            // Status bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.5 + 0.5 * _pulseAnim.value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    si < statusLabels.length ? statusLabels[si] : '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ]),
                const SizedBox(height: 14),
                // Step indicator
                Row(
                  children: List.generate(steps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      return Expanded(child: Container(
                        height: 2,
                        color: i ~/ 2 < si ? AppColors.primary : const Color(0xFFEEEEEE),
                      ));
                    }
                    final idx = i ~/ 2;
                    final done = idx <= si;
                    return Column(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: done ? AppColors.primary : const Color(0xFFEEEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(done ? Icons.check_rounded : Icons.circle, size: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(steps[idx], style: TextStyle(
                        fontSize: 8,
                        color: done ? AppColors.primary : AppColors.textHint,
                        fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                      )),
                    ]);
                  }),
                ),
              ]),
            ),

            // MapMyIndia Map
            Expanded(
              child: Stack(children: [
                MapplsMap(
                  initialCameraPosition: CameraPosition(
                    target: _animatedPos ?? const LatLng(28.6139, 77.2090),
                    zoom: 15,
                  ),
                  onMapCreated: (ctrl) {
                    _mapCtrl = ctrl;
                    if (_animatedPos != null) {
                      ctrl.animateCamera(CameraUpdate.newLatLngZoom(_animatedPos!, 15));
                      _addMarker(_animatedPos!);
                    }
                  },
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.None,
                ),
                // LIVE badge
                if (_animatedPos != null)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withOpacity(0.5 + 0.5 * _pulseAnim.value),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green)),
                        const SizedBox(width: 4),
                        const Text('· MapMyIndia', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                    ),
                  ),
              ]),
            ),

            // Delivery partner card
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              color: Colors.white,
              child: Row(children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.delivery_dining_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    data['deliveryBoyName'] ?? 'Delivery Partner',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const Text('Live location · 1 sec update',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ])),
                GestureDetector(
                  onTap: () {
                    final phone = data['deliveryBoyPhone'];
                    if (phone != null) launchUrl(Uri.parse('tel:$phone'));
                  },
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.call_rounded, color: AppColors.primary, size: 20),
                  ),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}
