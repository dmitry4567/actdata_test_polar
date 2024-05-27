import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:polar/polar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String identifier = '4D614220';
  Polar polar = Polar();

  List<String> listDevice = [];

  bool firstStart = true;

  void scanner() {
    polar.requestPermissions();

    polar.searchForDevice().listen((value) {
      listDevice.add(value.deviceId);
      log(value.deviceId.toString());
      setState(() {});
    });
  }

  void connect(String identifier) async {
    // polar.connectToDevice(identifier).then((_) {
    //   setState(() {
    //     firstStart = false;
    //   });
    // });

    polar.connectToDevice(identifier);

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

  void disconnect(identifier) async {
    polar.disconnectFromDevice(identifier);
  }

  void getHeart() async {
    final hrData = await polar.startHrStreaming(identifier).first;
    log(hrData.samples.first.contactStatus.toString());

    // final availabletypes =
    // await polar.getAvailableOnlineStreamDataTypes(identifier);

    // log(availabletypes.toString());
    // await polar.requestStreamSettings(identifier, PolarDataType.hr);
  }

  late StreamSubscription polarHr;

  void streamWhenReady() async {
    polar.requestRecordingStatus(identifier).then((onValue) {
      log(onValue.entryId.toString());
    });

    await polar.sdkFeatureReady.firstWhere(
      (e) =>
          e.identifier == identifier &&
          e.feature == PolarSdkFeature.onlineStreaming,
    );

    final availabletypes =
        await polar.getAvailableOnlineStreamDataTypes(identifier);

    debugPrint('available types: $availabletypes');

    if (availabletypes.contains(PolarDataType.hr)) {
      polar
          .startHrStreaming(identifier)
          .listen((e) => debugPrint('HR data received'));
    }
    if (availabletypes.contains(PolarDataType.ecg)) {
      polar
          .startEcgStreaming(identifier)
          .listen((e) => debugPrint('ECG data received'));
    }
    if (availabletypes.contains(PolarDataType.acc)) {
      polar
          .startAccStreaming(identifier)
          .listen((e) => debugPrint('ACC data received'));
    }
  }

  // void getPrefs() async {
  // final SharedPreferences prefs = await SharedPreferences.getInstance();

  // prefs.clear();

  // String? identifier = prefs.getString("identifier");

  // log(identifier.toString());

  // if (identifier == null) {
  // log("true");
  // firstStart = true;
  // } else {
  // log("false");
  // firstStart = false;

  // prefs.setString("identifier", identifier);
  // disconnect(identifier);
  // connect(identifier);
  // }
  // setState(() {});
  // }

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
            firstStart
                ? Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listDevice.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  connect(listDevice[index]);
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      listDevice[index].toString(),
                                      style: const TextStyle(
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      ElevatedButton(
                        onPressed: scanner,
                        child: Text('scanner'),
                      ),
                    ],
                  )
                : Container(),
            // ElevatedButton(
            //   onPressed: getHeart,
            //   child: Text('getHeart'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await polar.connectToDevice(identifier);
                // streamWhenReady();
              },
              child: Text('connect'),
            ),
            ElevatedButton(
              onPressed: () async {
                await polar.disconnectFromDevice(identifier);
              },
              child: Text('disconnect'),
            ),
            ElevatedButton(
              onPressed: () async {
                getHeart();
              },
              child: Text('get'),
            ),
            // StreamBuilder(
            //   stream: polar.startHrStreaming(identifier),
            //   builder: (context, snapshot) {
            //     return Text(snapshot.data.toString());
            //   },
            // ),
            // ElevatedButton(
            //   onPressed: getHeart,
            //   child: Text('get'),
            // ),
          ],
        ),
      ),
    );
  }
}
