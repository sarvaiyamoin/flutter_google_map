import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_map/search_location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _origin = TextEditingController();
  TextEditingController _destination = TextEditingController();

  Set<Marker> _marker = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _setMarker(LatLng(22.9872261, 72.5045954));
  }

  void _setPolyline(List<PointLatLng> points) {
    final polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()));
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: polygonLatLngs,
      strokeWidth: 2,
      fillColor: Colors.yellow,
    ));
  }

  _setMarker(LatLng point) {
    _marker.add(Marker(
        markerId: MarkerId('marker'),
        position: point,
        icon: BitmapDescriptor.defaultMarker));
  }
  // static final Polygon _kPolygon =
  //     Polygon(polygonId: PolygonId('_kPolygon'), points: [
  //   LatLng(22.9872261, 72.5045954),
  //   LatLng(22.9874261, 72.503472),
  //   LatLng(22.9772261, 72.5025954),
  //   LatLng(22.9674261, 72.501472)
  // ]);

  // static final Polyline _kPolyline = Polyline(
  //     polylineId: PolylineId('_kPolyline'),
  //     color: Colors.yellow,
  //     width: 3,
  //     points: [LatLng(22.9872261, 72.5045954), LatLng(22.9874261, 72.504472)]);

  // static final Marker _kinitmarker = Marker(
  //     markerId: MarkerId('_kinitmarker'),
  //     infoWindow: InfoWindow(title: 'Your location'),
  //     icon: BitmapDescriptor.defaultMarker,
  //     position: LatLng(22.9872261, 72.5045954));

  // static final Marker _kdestmarker = Marker(
  //     markerId: MarkerId('_kdestmarker'),
  //     infoWindow: InfoWindow(title: 'Destination'),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //     position: LatLng(22.9874261, 72.504472));

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.9872261, 72.5045954),
    zoom: 14.4746,
  );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 14.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              // cameraTargetBounds: CameraTargetBounds.unbounded,
              myLocationButtonEnabled: true,
              polygons: _polygons,
              // polylines: {_kPolyline},
              polylines: _polylines,
              mapType: MapType.normal,
              markers: _marker,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 20, left: 20),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _origin,
                            onChanged: (value) {
                              // _origin.text = value;
                              print(value);
                            },
                            // style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              hintText: '   Enter your  address',
                            ),
                          ),
                          Spacer(),
                          TextFormField(
                            controller: _destination,
                            onChanged: (value) {
                              // _origin.text = value;
                              print(value);
                            },
                            // style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              hintText: '   Enter destination address',
                              // suffixIcon:
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          // var place =
                          //     await SearchLocation().getPlace(_origin.text);
                          // _goToPlace(place);
                          var direction = await SearchLocation()
                              .getDirection(_origin.text, _destination.text);
                          _goToPlace(
                            direction['start_location']['lat'],
                            direction['start_location']['lng'],
                            direction['bounds_ne'],
                            direction['bounds_sw'],
                          );

                          _setPolyline(direction['polyline_decode']);
                        },
                        icon: Icon(Icons.search))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map boundsne,
    Map boundssw,
  ) async {
    // final lat = place['geometry']['location']['lat'];
    // final lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12)));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
          southwest: LatLng(boundssw['lat'], boundssw['lng']),
          northeast: LatLng(boundsne['lat'], boundsne['lng'])),
      25,
    ));

    _setMarker(LatLng(lat, lng));
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
