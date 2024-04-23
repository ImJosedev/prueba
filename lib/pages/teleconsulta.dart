import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prueba/services/consulta_service.dart';
/*
class OpenTokConfig {

  static String API_KEY = "46923724";
  static String SESSION_ID = "1_MX40NjkyMzcyNH5-MTYzODk3MTYwMTY1N35ReGZwSVZFNjRBOVp1Q1g1NTc0Qy9CVzV-fg";
  static String TOKEN = "T1==cGFydG5lcl9pZD00NjkyMzcyNCZzaWc9MDIzNDQ3YzA4YmY2ZWQ5MGNiMzZjMjg2OWQ5MzE4ZDBjOTkzNDE5ODpzZXNzaW9uX2lkPTFfTVg0ME5qa3lNemN5Tkg1LU1UWXpPRGszTVRZd01UWTFOMzVSZUdad1NWWkZOalJCT1ZwMVExZzFOVGMwUXk5Q1Z6Vi1mZyZjcmVhdGVfdGltZT0xNjM4OTcxNjAxJnJvbGU9cHVibGlzaGVyJm5vbmNlPTE2Mzg5NzE2MDEuNzg0MTY1NzU1NzE3JmNvbm5lY3Rpb25fZGF0YT1uYW1lJTNEUHJ1ZWJhK1BhY2llbnRlJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9Zm9jdXM=";
  static void message(){
    print('You are Calling Static Method');
  }

}
*/
class Teleconsulta extends StatefulWidget {
  final int id;
  const Teleconsulta({Key? key, required int this.id}) : super(key: key);

  @override
  _TeleconsultaState createState() => _TeleconsultaState(id);
}

class _TeleconsultaState extends State<Teleconsulta> {
  SdkState _sdkState = SdkState.LOGGED_OUT;
  bool _publishAudio = true;
  bool _publishVideo = true;
  String _apiKey = '';
  String _sessionId = '';
  String _token = '';
  int id;


  static const platformMethodChannel = const MethodChannel('com.vonage');

  _TeleconsultaState(this.id) {
    platformMethodChannel.setMethodCallHandler(methodCallHandler);
    _getCredentials(this.id);
    //_initSession();
  }

  Future<dynamic> methodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'updateState':
        {
          setState(() {
            var arguments = 'SdkState.${methodCall.arguments}';
            _sdkState = SdkState.values.firstWhere((v) {
              return v.toString() == arguments;
            });
          });
        }
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  Future<void> _initSession() async {
    await requestPermissions();

    //String token = "ALICE_TOKEN";
    log('y hizo');
    dynamic params = {
      /*
      'apiKey': OpenTokConfig.API_KEY,
      'sessionId': OpenTokConfig.SESSION_ID,
      'token': OpenTokConfig.TOKEN
       */
      'apiKey': _apiKey,
      'sessionId': _sessionId,
      'token': _token
    };

    try {
      await platformMethodChannel.invokeMethod('initSession', params);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _makeCall() async {
    try {
      await requestPermissions();

      await platformMethodChannel.invokeMethod('makeCall');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> _swapCamera() async {
    try {
      await platformMethodChannel.invokeMethod('swapCamera');
    } on PlatformException catch (e) {}
  }

  Future<void> _toggleAudio() async {
    //setState(() {
      //_publishAudio = !_publishAudio;
    //});

    dynamic params = {'publishAudio': _publishAudio};

    try {
      await platformMethodChannel.invokeMethod('toggleAudio', params);
    } on PlatformException catch (e) {}
  }

  Future<void> _toggleVideo() async {
    _updateView();

    dynamic params = {'publishVideo': _publishVideo};

    try {
      await platformMethodChannel.invokeMethod('toggleVideo', params);
    } on PlatformException catch (e) {}
  }

  Future<bool> _toggleDisconnect() async {
    try {
      await platformMethodChannel.invokeMethod('toggleDisconnect');
      return Future.value(true);
    } on PlatformException catch (e) {
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _toggleDisconnect,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teleconsulta"),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[SizedBox(height: 64), _updateView()],
          ),
        ),
      ),
    );
  }

  Widget _updateView() {
    bool toggleVideoPressed = false;

    if (_sdkState == SdkState.LOGGED_OUT) {
      return ElevatedButton(
          onPressed: () {
            _publishAudio = true;
            _publishVideo = true;
            _initSession();
          },
          child: Text("Volver a conectar"));
    } else if (_sdkState == SdkState.WAIT) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_sdkState == SdkState.LOGGED_IN) {
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: PlatformViewLink(
              viewType: 'opentok-video-container', // custom platform-view-type
              surfaceFactory:
                  (BuildContext context, PlatformViewController controller) {
                return AndroidViewSurface(
                  controller: controller as AndroidViewController,
                  gestureRecognizers: const <
                      Factory<OneSequenceGestureRecognizer>>{},
                  hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                );
              },
              onCreatePlatformView: (PlatformViewCreationParams params) {
                return PlatformViewsService.initSurfaceAndroidView(
                  id: params.id,
                  viewType: 'opentok-video-container',
                  // custom platform-view-type,
                  layoutDirection: TextDirection.ltr,
                  creationParams: {},
                  creationParamsCodec: StandardMessageCodec(),
                )
                  ..addOnPlatformViewCreatedListener(
                      params.onPlatformViewCreated)
                  ..create();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.flip_camera_android),
                iconSize: 40.0,
                color: Colors.grey,
                onPressed: () {
                  _swapCamera();
                },
              ),
              IconButton(
                icon: _publishAudio ? Icon(Icons.mic) : Icon(Icons.mic_off),
                iconSize: 40.0,
                color: Colors.grey,
                onPressed: () {
                  setState(() {
                  _publishAudio = !_publishAudio;
                  });
                  _toggleAudio();
                },
              ),
              IconButton(
                icon: _publishVideo ? Icon(Icons.videocam_rounded) : Icon(Icons.videocam_off_rounded),
                iconSize: 40.0,
                color: Colors.grey,
                onPressed: () {
                  setState(() {
                  _publishVideo = !_publishVideo;
                  });
                  _toggleVideo();
                },
              ),
              IconButton(
                icon: Icon(Icons.call_end),
                iconSize: 40.0,
                color: Colors.red,
                onPressed: () {
                  _toggleDisconnect();
                },
              ),
            ],
          ),
        ],
      );
    } else {
      return Center(child: Text("ERROR"));
    }
  }

  void _getCredentials(int id) async{
    ConsultaService consultaService = ConsultaService();
    var data = await consultaService.credentialsConsulta(id);
    if(data['status'] == true) {
      setState(() {
        _apiKey = data['apiKey'];
        _sessionId = data['sessionId'];
        _token = data['token'];
      });
      _initSession();
    }else{
      if(data['code'] == 500){
        _alertDialog(data['message']);
      }else{
        _alertDialog(data['message']);
      }
    }
  }

  Future<void> _alertDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atención'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}

enum SdkState { LOGGED_OUT, LOGGED_IN, WAIT, ON_CALL, ERROR }