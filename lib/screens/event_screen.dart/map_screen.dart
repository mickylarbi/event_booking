import 'dart:developer';

import 'package:event_booking/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng? initialSelectedPostion;
  const MapScreen({Key? key, this.initialSelectedPostion}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late AnimationController lifter;
  late LatLng selectedPosition;

  @override
  void initState() {
    super.initState();

    selectedPosition =
        widget.initialSelectedPostion ?? const LatLng(6.6745, -1.5716);

    lifter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    lifter.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: selectedPosition,
              zoom: 14.4746,
            ),
            onMapCreated: onMapCreated,
            onCameraIdle: onCameraIdle,
            onCameraMove: onCameraMove,
            onCameraMoveStarted: onCameraMoveStarted,
          ),
          Center(
            child: Transform.translate(
              offset: Offset(.0, -20 + (lifter.value * -15)),
              child: SizedBox(
                height: 40,
                width: 40,
                child: Image.asset('assets/images/location_pin.png'),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: lifter,
              child: const CircleAvatar(
                radius: 2,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      elevation: 10,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      onPressed: () {
                        getCurrentLocation();
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedPosition);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      fixedSize: Size(kScreenHeight(context) - 72, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Choose location'),
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                height: 54,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: Colors.white,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(16),
                  child: IconButton(
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (widget.initialSelectedPostion != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: widget.initialSelectedPostion!, zoom: 18)));
    } else {
      try {
        getCurrentLocation();
      } catch (e) {
        log(e.toString());
      }
    }
  }

  getCurrentLocation() async {
    bool? serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position pos = await Geolocator.getCurrentPosition();
    LatLng currentPos = LatLng(pos.latitude, pos.longitude);
    selectedPosition = currentPos;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedPosition, zoom: 18)));
  }

  onCameraIdle() {
    lifter.reverse();
  }

  onCameraMove(CameraPosition pos) {
    selectedPosition = pos.target;
  }

  onCameraMoveStarted() {
    lifter.forward();
  }

  @override
  void dispose() {
    mapController.dispose();
    lifter.dispose();

    super.dispose();
  }
}
