import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lets_vote/address_initialization_page.dart';
import 'animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InitializationPage extends StatefulWidget {
  @override
  _InitializationPageState createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation1;
  AnimationController controller;
  //TODO Change beginning TEXT

  Future<String> generateDeviceId() async {
    var response =
        await http.get('https://api.wevoteusa.org/apis/v1/deviceIdGenerate');

    String vid = jsonDecode(response.body)['voter_device_id'];
    print(vid);

    String createUrl =
        'https://api.wevoteusa.org/apis/v1/voterCreate/?voter_device_id=' + vid;

    var res = await http.get(createUrl);
    print(res.body);

    return vid;
  }

  setDeviceId(String value) async {
    if (value == null) {
      throw Exception('lmao');
    }
    String keyName = 'DeviceId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyName, value);
  }

  getAndSetDeviceId() async {
    print('working');
    String id;
    try {
      id = await generateDeviceId();
    } catch (error) {
      print(error);
    } finally {
      setDeviceId(id);
    }
  }

  @override
  void initState() {
    //TODO
    super.initState();
    getAndSetDeviceId();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation1 = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle mainStyle = TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.bold,
    );

    const TextStyle biggerMainStyle = TextStyle(
      fontSize: 80,
      fontWeight: FontWeight.bold,
    );

    const TextStyle smallText = TextStyle(
      fontSize: 20,
    );

    TextStyle buttonText = TextStyle(
      fontSize: 18,
      color: Colors.grey.shade800,
    );

    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              //alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      'Let\'s Get',
                      style: mainStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      'Started.',
                      style: biggerMainStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 16, 10),
                    child: Text(
                      'Begin Voting in Two Simple Steps',
                      style: smallText,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        NextAddressAnimation(
                          animation: animation1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
