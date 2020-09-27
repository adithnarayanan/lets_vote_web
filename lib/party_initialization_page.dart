import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'animations.dart';
import 'animations.dart';

class PartyInitializationPage extends StatefulWidget {
  @override
  _PartyInitializationPageState createState() =>
      _PartyInitializationPageState();
}

class _PartyInitializationPageState extends State<PartyInitializationPage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation1;
  AnimationController controller;
  bool moveToNextPage = false;
  int selected = 0;

  democratFill(int selectedNumber) {
    if (selectedNumber == 1) {
      return Colors.blue.shade100;
    }
    return Colors.white;
  }

  republicanFill(int selectedNumber) {
    if (selectedNumber == 2) {
      return Colors.red.shade100;
    }
    return Colors.white;
  }

  nonPartisanFill(int selectedNumber) {
    if (selectedNumber == 3) {
      return Colors.grey.shade300;
    }
    return Colors.white;
  }

  Color _democratColor = Colors.white;
  Color _republicanColor = Colors.white;
  Color _nonPartisanColor = Colors.white;

  setPartyAffiliation(String value) async {
    String keyName = 'partyAffiliation';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyName, value);
  }

  Widget renderNextButton(bool move) {
    if (move) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                onNextPressed();
              },
              child: NextDisclaimerAnimation(
                animation: animation1,
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  void onNextPressed() {
    //shared Preferences
    if (selected == 1) {
      setPartyAffiliation('Democrat');
    } else if (selected == 2) {
      setPartyAffiliation('Republican');
    } else if (selected == 3) {
      setPartyAffiliation('Non-Partisan');
    }
  }

  @override
  void initState() {
    super.initState();
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
    const TextStyle topStyle = TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.bold,
    );
    TextStyle messageText = TextStyle(
      fontSize: 14,
      color: Colors.grey.shade800,
    );
    const TextStyle headerStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    const TextStyle internalFontStyle = TextStyle(
      fontSize: 20,
      //fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
              child: Text(
                '2. Affiliation',
                style: topStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 15, 20),
              child: Text(
                'In order to give you the best tailored experience, we ask for your party affiliation.',
                style: messageText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 15, 10),
              child: Text(
                'Choose Your Party:',
                style: headerStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 15, 10),
              child: FlatButton(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _democratColor, //democratFill(selected),
                    boxShadow: [
                      BoxShadow(color: Colors.blue, spreadRadius: 3),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Image.asset('assets/Democrat.png'),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 30),
                          child: Text(
                            'Democratic',
                            style: internalFontStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _democratColor = Colors.blue.shade200;
                    _republicanColor = Colors.white;
                    _nonPartisanColor = Colors.white;
                    moveToNextPage = true;
                    selected = 1;
                    onNextPressed();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 15, 10),
              child: FlatButton(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  height: 60,
                  //color: Colors.red.shade200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _republicanColor,
                    boxShadow: [
                      BoxShadow(color: Colors.red, spreadRadius: 3),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Image.asset('assets/Republican.png'),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 30),
                          child: Text(
                            'Republican',
                            style: internalFontStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _democratColor = Colors.white;
                    _republicanColor = Colors.red.shade200;
                    _nonPartisanColor = Colors.white;
                    moveToNextPage = true;
                    selected = 2;
                    onNextPressed();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
              child: Text(
                'OR',
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 30, 15, 10),
              child: FlatButton(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _nonPartisanColor,
                    boxShadow: [
                      BoxShadow(color: Colors.yellow, spreadRadius: 3),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        //flex: 4,
                        child: Text(
                          'Non-Partisan',
                          style: internalFontStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  //do something
                  setState(() {
                    _democratColor = Colors.white;
                    _republicanColor = Colors.white;
                    _nonPartisanColor = Colors.yellow.shade300;
                    moveToNextPage = true;
                    selected = 3;
                    onNextPressed();
                  });
                },
              ),
            ),
            renderNextButton(moveToNextPage)
          ],
        ),
      ),
    );
  }
}
