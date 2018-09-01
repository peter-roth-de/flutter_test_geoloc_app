import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Example',
      theme: ThemeData.dark() ,
      home: Home(),
    ); // MaterialApp
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}
class HomeState extends State<Home> {
  MapController controller = new MapController();
  final TextEditingController textFieldController = new TextEditingController();
  LocationResult locations;
  StreamSubscription<LocationResult> streamSubscription;
  //Stream<LocationResult> streamSubscription;
  bool trackLocation = false;
  String sGoogleApiKey = "";

  @override initState() {
    super.initState();
    checkGps();

    trackLocation = false;
    locations = null;
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    textFieldController.dispose();
    super.dispose();
  }
  getPermission() async {
    final GeolocationResult result =
    await Geolocation.requestLocationPermission(const LocationPermission(
        android: LocationPermissionAndroid.fine,
        ios: LocationPermissionIOS.always));
    return result;
  }

  getLocation() {
    return getPermission().then((result) async {
      if (result.isSuccessful) {
        final coords =
          await Geolocation.currentLocation(accuracy: LocationAccuracy.best);
        /* coords.listen((result) {
          locations = result;
        });
        // locations = coords as LocationResult;
        */
        return coords;
      }
    });
  }

  getLocResult() {
    getLocation().then((response) {
      response.listen((value) {
        if (value.isSuccessful) {
          setState(() {
            locations=value;
          });

          //controller.move(
          //    new LatLng(value.location.latitude, value.location.longitude),
          //    8.0);
        }
      });
    });
  }

  getLocations() {
    if(trackLocation) {
      setState(() => trackLocation = false);
      streamSubscription.cancel();
      streamSubscription = null;
      locations = null;
    } else {
      setState(() => trackLocation = true );
      streamSubscription = Geolocation
          .locationUpdates(
            accuracy: LocationAccuracy.best,
            displacementFilter: 0.0,
            inBackground: false,
          )
      .listen((result) {
        final location = result;
        setState(() {
          // locations.add(location);
          locations = location;
          print("Location: Longitude=${locations.location.longitude} Latitude=${locations.location.latitude}");
        });
      });

      streamSubscription.onDone(() => setState(() {
        trackLocation = false;
        } ));
    }
  }

  checkGps() async {
    final GeolocationResult result = await Geolocation.isLocationOperational();
    if (result.isSuccessful) {
      print("Check GPS - Success");
    } else {
      print("Check GPS - Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GeoLocation example'),
        actions: <Widget>[
          FlatButton(
              onPressed: getLocResult, // buildMap, //getLocation,
              child: Text("Get Location")
          )
        ],
      ),
      body: Center(
        child: Container(
          child: ListView(
            children: [ /*locations
              .map((loc) => ListTile(
                title: Text(
                    "You are here: ${loc.location.longitude} : ${loc.location.latitude}"),
                subtitle:
                  Text("Your Altitude is: ${loc.location.altitude}"),
                ))
              .toList(),*/
              Image.network(locations == null
                  ? "https://heise.cloudimg.io/width/336/q50.png-lossy-50.webp-lossy-50.foil1/_www-heise-de_/imgs/18/2/4/8/8/6/8/5/dji_mavic_2_pro-d585e304494c7d70.jpeg"
                  : "https://maps.googleapis.com/maps/api/staticmap?center=${locations.location.latitude},${locations.location.longitude}&zoom=12&size=400x400&key=${textFieldController.text}"),
              TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: "Google API Key:",
                    hintText: 'Please enter the key!'
                ),
              ),
              Text(
                (locations == null ? 'no location determined' : "You are here: ${locations.location.longitude} : ${locations.location.latitude}")),
              ],
          ),
        ),
      ),
    );
  }
}
