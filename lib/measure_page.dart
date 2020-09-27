import 'package:flutter/material.dart';

import 'home.dart';
import 'measure.dart';

class MeasurePage extends StatefulWidget {
  Measure measure;
  String ballotName;
  MeasurePage({Key key, this.measure, this.ballotName});

  @override
  _MeasurePageState createState() => _MeasurePageState(measure, ballotName);
}

class _MeasurePageState extends State<MeasurePage> {
  Measure measure;
  String ballotName;
  _MeasurePageState(this.measure, this.ballotName);

  Color _yesColor = Colors.white;
  Color _noColor = Colors.white;

  _yesOrNo() {
    if (measure.isYes == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.yellow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: Text('None'),
        ),
      );
    }
    if (measure.isYes) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.green,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: Text('YES'),
        ),
      );
    } else if (!measure.isYes) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.red,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: Text('NO'),
        ),
      );
    }
  }

  @override
  void initState() {
    if (measure.isYes != null) {
      if (measure.isYes) {
        _yesColor = Colors.green;
      } else if (!measure.isYes) {
        _noColor = Colors.red.shade300;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //alignment: Alignment.center,
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: Container(
                        //height: 50,
                        //margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 241, 39, 17),
                              Color.fromARGB(255, 245, 175, 25)
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 10.0),
                          child: Column(
                            children: [
                              Text(
                                measure.name,
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(50, 0, 50, 5),
                                child: SizedBox(
                                  height: 20.0,
                                  //width: 300.0,
                                  child: Divider(
                                    thickness: 3,
                                    color: Colors.teal.shade100,
                                  ),
                                ),
                              ),
                              Text(
                                measure.measureText,
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(0),
                    //   child: Text(measure.measureText),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Vote: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _yesOrNo()
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.fastOutSlowIn,
                          //height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _yesColor, //democratFill(selected),
                            boxShadow: [
                              BoxShadow(color: Colors.green, spreadRadius: 3),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'YES',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    measure.yesVoteDescription,
                                    //style: internalFontStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _yesColor = Colors.green;
                            _noColor = Colors.white;
                            measure.isYes = true;
                            measure.save();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.fastOutSlowIn,
                          //height: 60,
                          //color: Colors.red.shade200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _noColor,
                            boxShadow: [
                              BoxShadow(color: Colors.red, spreadRadius: 3),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'NO',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    measure.noVoteDescription,
                                    // style: internalFontStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _yesColor = Colors.white;
                            _noColor = Colors.red.shade300;
                            measure.isYes = false;
                            measure.save();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Container(
                          width: double.maxFinite,
                          //height: 60,
                          // color: Colors.white,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.grey, spreadRadius: 3),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: Text(
                              'Clear Selection',
                              // style: internalFontStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _yesColor = Colors.white;
                            _noColor = Colors.white;
                            measure.isYes = null;
                            measure.save();
                          });
                        },
                      ),
                    ),
                    FlatButton(
                      child: Row(children: [
                        Icon(Icons.arrow_back_ios),
                        Text('Back to Ballot')
                      ]),
                      onPressed: () {
                        //go back to ballot page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              selectedIndex: 1,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
