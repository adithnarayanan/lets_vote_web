import 'package:flutter/material.dart';

import 'animations.dart';

class DisclaimerPage extends StatefulWidget {
  @override
  _DisclaimerPageState createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation1;
  AnimationController controller;
  bool moveToNextPage = false;

  @override
  void initState() {
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
    super.initState();
  }

  Widget renderFinishButton(bool move) {
    if (move) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: NextHomeAnimation(
          animation: animation1,
        ),
      );
    }
    return Container();
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

    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 15, 0),
                      child: Text(
                        'Disclaimer:',
                        style: topStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                      child: Text(
                        '**Let\'s Vote is NOT affiliated with any government or governmental organization.' +
                            ' Let\'s Vote is also NOT affiliated with any politician, political party, or political entity. **',
                        style: headerStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 30, 15, 20),
                      child: Text(
                        '**DISCLAIMER: We, Let’s Vote, are not responsible if information made available on this application is not accurate, complete, or current. The material on this application is provided for general information only and should not be relied upon or used as the sole basis for making decisions without consulting primary, more accurate, more complete or more timely sources of information. Any reliance on the material on this application is at your own risk.\n\n' +
                            'This application may contain certain historical information. Historical information, necessarily, is not current and is provided for your reference only. We reserve the right to modify the contents of this application at any time, but we have no obligation to update any information on our application. You agree that it is your responsibility to monitor changes to our application.**',
                        style: messageText,
                      ),
                    ),
                  ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                        checkColor: Colors.green.shade100,
                        activeColor: Colors.green,
                        value: moveToNextPage,
                        onChanged: (bool value) {
                          setState(() {
                            if (value) {
                              moveToNextPage = true;
                            } else {
                              moveToNextPage = false;
                            }
                          });
                        }),
                    Text(
                      "I understand",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
                renderFinishButton(moveToNextPage)
              ],
            ),
          )
        ],
      ),
    ));
  }
}
