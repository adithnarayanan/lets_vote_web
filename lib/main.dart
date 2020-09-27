import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:lets_vote/ballot.dart';
import 'package:lets_vote/candidate.dart';
import 'package:lets_vote/election.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lets_vote/home.dart';
import 'package:lets_vote/introduction_page.dart';
import 'package:lets_vote/measure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'initialization_page.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

const electionBoxName = 'electionBox';
const ballotBoxName = 'ballotBox';
const measureBoxName = 'measureBox';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<Election>(ElectionAdapter());
  Hive.registerAdapter<Candidate>(CandidateAdapter());
  Hive.registerAdapter<Measure>(MeasureAdapter());
  Hive.registerAdapter<Ballot>(BallotAdapter());
  await Hive.openBox<Election>(electionBoxName);
  await Hive.openBox<Ballot>(ballotBoxName);
  await Hive.openBox<Measure>(measureBoxName);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     new FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  bool introCompleted;
  bool setupCompleted;

  Future<bool> getIntroductionStatus() async {
    String keyName = 'introCompleted';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introCompleted = (prefs.getBool(keyName));
    return introCompleted;
  }

  Future<bool> getSetupStatus() async {
    String keyName = 'address';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = (prefs.getString(keyName));
    if (address != null) {
      return true;
    }
    return false;
  }

  void getStatus() async {
    //introCompleted = await getIntroductionStatus();
    bool isSetupCompleted;
    try {
      isSetupCompleted = await getSetupStatus();
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        setupCompleted = isSetupCompleted;
      });
    }
  }

  Widget returnPage(bool isSetupCompleted) {
    // if (!introCompleted) {
    //   //Load Introduction Page
    // } else
    if (isSetupCompleted == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  // child: Text(
                  //   'Let\s Vote',
                  //   style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  // ),
                  children: [
                    Expanded(
                      child: Image.asset('assets/LetsVoteText.png'),
                    )
                  ]),
            ),
          ),
        ),
      );
    } else if (isSetupCompleted) {
      return HomePage(
        selectedIndex: 2,
      );
    }
    return InitializationPage();
    // Container(
    //   alignment: Alignment.center,
    //   constraints: BoxConstraints(maxWidth: 600),
    //   child: InitializationPage(),
    // );
    //return IntroductionPage();
  }

  @override
  void initState() {
    //requestIOSPermissions(flutterLocalNotificationsPlugin);
    getStatus();
    // initializationSettingsAndroid =
    //     new AndroidInitializationSettings('@mipmap/ic_launcher');
    // initializationSettingsIOS = new IOSInitializationSettings(
    //     requestSoundPermission: false,
    //     requestBadgePermission: false,
    //     requestAlertPermission: false,
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    // initializationSettings = new InitializationSettings(
    //     initializationSettingsAndroid, initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: onSelectNotification);
    super.initState();
  }

  // Future onSelectNotification(String payload) async {
  //   if (payload != null) {
  //     debugPrint('Notification payload: $payload');
  //   }
  //   await Navigator.push(context,
  //       new MaterialPageRoute(builder: (context) => new SecondRoute()));
  // }

  // Future onDidReceiveLocalNotification(
  //     int id, String title, String body, String payload) async {
  //   await showDialog(
  //       context: context,
  //       builder: (BuildContext context) => CupertinoAlertDialog(
  //             title: Text(title),
  //             content: Text(body),
  //             actions: <Widget>[
  //               CupertinoDialogAction(
  //                 isDefaultAction: true,
  //                 child: Text('Ok'),
  //                 onPressed: () async {
  //                   Navigator.of(context, rootNavigator: true).pop();
  //                   await Navigator.push(context,
  //                       MaterialPageRoute(builder: (context) => SecondRoute()));
  //                 },
  //               )
  //             ],
  //           ));
  // }

  // void requestIOSPermissions(
  //     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           IOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Let\'s Vote',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //primarySwatch: Colors.blue,
      ),
      home: returnPage(setupCompleted),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AlertPage'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('go back...'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
