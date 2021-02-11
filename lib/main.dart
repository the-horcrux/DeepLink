import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:placesAPI/utils.dart';
import 'package:provider/provider.dart';

void main() => runApp(PocApp());

class PocApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = DeepLinkBloc();
    Utilities.getDeviceDetails();
    return MaterialApp(
        title: 'Gymnash',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: TextTheme(
              headline2: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.blue,
                fontSize: 25.0,
              ),
            )),
        home: Scaffold(
            body: Center(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Provider<DeepLinkBloc>(create: (context) => _bloc, dispose: (context, bloc) => bloc.dispose(), child: PocWidget()),
            ElevatedButton(
              child: Text('Get Location'),
              onPressed: () {
                Location().getLocation().then((location) {
                  var coordinates = new Coordinates(location.latitude, location.longitude);
                  coordinates = new Coordinates(21.2368966, 81.5983572);
                  Geocoder.local.findAddressesFromCoordinates(coordinates).then((address) {
                    print(address.first.toMap());
                  });
                });
              },
            ),
            ElevatedButton(
                child: Text('Get Permissions'),
                onPressed: () {
                  Location().requestPermission().then((permissionData) {
                    print(permissionData);
                  });
                }),
            // Row(
            //   children: [
            //   ],
            // )
          ],
        ))));
  }
}

class PocWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DeepLinkBloc _bloc = Provider.of<DeepLinkBloc>(context);
    return StreamBuilder<String>(
      stream: _bloc.state,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(child: Center(child: Text('No deep link was used  ', style: Theme.of(context).textTheme.headline2)));
        } else {
          return Container(
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Redirected: ${snapshot.data}', style: Theme.of(context).textTheme.headline2))));
        }
      },
    );
  }
}

abstract class Bloc {
  void dispose();
}

class DeepLinkBloc extends Bloc {
  //Event Channel creation
  static const stream = const EventChannel('https.www.gymnash.com/events');

  //Method channel creation
  static const platform = const MethodChannel('https.www.gymnash.com/channel');

  StreamController<String> _stateController = StreamController();

  Stream<String> get state => _stateController.stream;

  Sink<String> get stateSink => _stateController.sink;

  //Adding the listener into constructor
  DeepLinkBloc() {
    //Checking application start by deep link
    startUri().then(_onRedirected);
    //Checking broadcast stream, if deep link was clicked in opened application
    stream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  }

  _onRedirected(String uri) {
    // Here can be any uri analysis, checking tokens etc, if it’s necessary
    // Throw deep link URI into the BloC's stream
    stateSink.add(uri);
  }

  @override
  void dispose() {
    _stateController.close();
  }

  Future<String> startUri() async {
    try {
      return platform.invokeMethod('initialLink');
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }
}
