import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:polar/polar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HeartRateScreen(),
    );
  }
}

class HeartRateScreen extends StatefulWidget {
  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  int heartRate = 0;
  static const identifier = '4D614220';
  Polar polar = Polar();

  bool start = false;

  void connect() async {
    await polar.connectToDevice(identifier);

    // polar.sdkFeatureReady.listen((e) {
    //   log(e.feature.toString());
    // });
    // await polar.sdkFeatureReady.firstWhere(
    //   (e) =>
    //       e.identifier == identifier &&
    //       e.feature == PolarSdkFeature.onlineStreaming,
    // );
    // final availabletypes =
    //     await polar.getAvailableOnlineStreamDataTypes(identifier);

    // log(availabletypes.toString());
  }

  void disconnect() async {
    polar.disconnectFromDevice(identifier);
  }

  void getHeart() async {
    await polar.sdkFeatureReady.firstWhere(
      (e) =>
          e.identifier == identifier &&
          e.feature == PolarSdkFeature.onlineStreaming,
    );
    final availabletypes =
        await polar.getAvailableOnlineStreamDataTypes(identifier);

    debugPrint(availabletypes.toString());
  }

  late StreamSubscription polarHr;

  @override
  void initState() {
    super.initState();

    polarHr = polar.startHrStreaming(identifier).listen((e) => setState(() {
          log(e.samples[0].hr.toString());
        }));

    polarHr.onData((data) => log(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Rate Monitor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Heart Rate: $heartRate',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: connect,
              child: Text('connect'),
            ),
            ElevatedButton(
              onPressed: disconnect,
              child: Text('disconnect'),
            ),
            StreamBuilder(
              stream: polar.startHrStreaming(identifier),
              builder: (context, snapshot) {
                return Text(snapshot.data.toString());
              },
            ),
            ElevatedButton(
              onPressed: getHeart,
              child: Text('get'),
            ),
          ],
        ),
      ),
    );
  }
}
