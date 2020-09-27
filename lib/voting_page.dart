import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:url_launcher/url_launcher.dart';
import 'election.dart';
import 'home.dart';

//TODO finish using url launcher instead of in app webview

class VotingPage extends StatefulWidget {
  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  String stateCode;
  int status = -1;
  //-1 -> loading
  //0 -> YesOrNo
  //1 -> MailInOrInPerson
  //2 -> Webview Vote.org
  //3 -> Checklist View
  bool inPerson;
  Box<Election> electionsBox;

  Future<String> getStateCode() async {
    String keyName = 'stateCode';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = (prefs.getString(keyName));
    //print(address);
    print(code);
    code = code.toLowerCase();
    return code;
  }

  Future<bool> getInPerson() async {
    String keyName = 'inPerson';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool inPerson = (prefs.getBool(keyName));
    //print(address);
    return inPerson;
  }

  void setInPerson(bool value) async {
    String keyName = 'inPerson';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyName, value);
  }

  void getPreferences() async {
    String temp_code;
    bool inPerson_temp;
    try {
      temp_code = await getStateCode();
      inPerson_temp = await getInPerson();
    } catch (error) {
      print(error);
    } finally {
      stateCode = temp_code;
      if (inPerson_temp == null) {
        setState(() {
          status = 0;
        });
      } else {
        setState(() {
          status = 3;
          inPerson = inPerson_temp;
        });
      }
    }
  }

  _launchRegistrationUrl() async {
    var url = _url(stateCode);
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  TextStyle topStyle = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.bold,
  );
  TextStyle messageText = TextStyle(
    fontSize: 14,
    color: Colors.grey.shade800,
  );
  TextStyle headerStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  TextStyle internalFontStyle = TextStyle(
    fontSize: 20,
    color: Colors.orange.shade400,
    //fontWeight: FontWeight.bold,
  );

  TextStyle cardStyle = TextStyle(fontSize: 20.0, color: Colors.white);

  _url(stateCodeInput) {
    if (stateCodeInput != null) {
      return 'https://www.vote.gov/register/' + stateCodeInput;
    }
    return 'https://www.vote.gov/';
  }

  renderYesOrNo() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Text(
                        'Have you Registered to Vote?',
                        style: headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FlatButton(
                        child: Center(
                          child: Container(
                            width: double.maxFinite,
                            //height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.orange.shade400,
                                    spreadRadius: 3),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'Yes',
                                textAlign: TextAlign.center,
                                style: internalFontStyle,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            //_launchRegistrationUrl();
                            status = 1;
                          });
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //     'OR',
                    //     style: TextStyle(fontSize: 18),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FlatButton(
                        child: Container(
                          width: double.maxFinite,
                          //height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.orange.shade400,
                                  spreadRadius: 3),
                            ],
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No',
                                textAlign: TextAlign.center,
                                style: internalFontStyle,
                              )),
                        ),
                        onPressed: () {
                          setState(() {
                            _launchRegistrationUrl();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                          'If you are not sure, please press no to check your registration status'),
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

  renderInPersonorMailIn() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Text(
                        'How do you Plan on Voting?',
                        style: headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FlatButton(
                        child: Center(
                          child: Container(
                            width: double.maxFinite,
                            //height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.orange.shade400,
                                    spreadRadius: 3),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'In-Person',
                                textAlign: TextAlign.center,
                                style: internalFontStyle,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            //render Map-View
                            setInPerson(true);
                            status = 3;
                            inPerson = true;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FlatButton(
                        child: Container(
                          width: double.maxFinite,
                          //height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.orange.shade400,
                                  spreadRadius: 3),
                            ],
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Mail-In',
                                textAlign: TextAlign.center,
                                style: internalFontStyle,
                              )),
                        ),
                        onPressed: () {
                          setState(() {
                            setInPerson(false);
                            status = 3;
                            inPerson = false;
                            //render something
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  renderLoading() {
    print('loading');
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  _ballotComplete() {
    print(electionsBox.length);
    for (var x = 0; x < electionsBox.length; x++) {
      if (electionsBox.getAt(x).chosenIndex == null) {
        print(electionsBox.getAt(x).chosenIndex);
        return false;
      }
    }
    return true;
  }

  _ballotCompleteCard(bool complete) {
    if (!complete) {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(selectedIndex: 1),
              ));
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.remove_circle_outline,
                color: Colors.white,
              ),
              title: Text(
                'Complete Ballot',
                style: cardStyle,
              ),
            ),
          ),
          color: Colors.red,
        ),
      );
    } else {
      return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              title: Text(
                'Ballot Complete',
                style: cardStyle,
              ),
            ),
          ),
          color: Colors.green);
    }
  }

  _launchGTTPURL() async {
    const url = 'https://gttp.votinginfoproject.org/';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  _completionCards() {
    if (inPerson) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: InkWell(
              onTap: () {
                _launchGTTPURL();
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Find Your Polling Place',
                      style: cardStyle,
                    ),
                    trailing:
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ),
                color: Colors.purpleAccent.shade700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(
                    Icons.input,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Go Vote!',
                    style: cardStyle,
                  ),
                ),
              ),
              color: Colors.purpleAccent.shade700,
            ),
          )
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.mail,
                color: Colors.white,
              ),
              title: Text(
                'Mail In Your Ballot 7 Days prior to deadline',
                style: cardStyle,
              ),
            ),
          ),
          color: Colors.purpleAccent.shade700,
        ),
      );
    }
  }

  _fab(bool status) {
    if (status) {
      return null;
    }
    return null;
  }

  renderChecklistPage() {
    const TextStyle topStyle = TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
      floatingActionButton: _fab(inPerson),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: Text(
                          'Voting Checklist',
                          style: topStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: SizedBox(
                          height: 20.0,
                          width: 150.0,
                          child: Divider(
                            thickness: 3,
                            color: Colors.teal.shade100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              leading:
                                  Icon(Icons.check_circle, color: Colors.white),
                              title: Text(
                                'Registered to Vote',
                                style: cardStyle,
                              ),
                              subtitle: InkWell(
                                onTap: () {
                                  setState(() {
                                    _launchRegistrationUrl();
                                    // status = 2;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Update/Check Status',
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontSize: 16),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue.shade900,
                                      size: 18.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          color: Colors.green,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: _ballotCompleteCard(_ballotComplete()),
                      ),
                      _completionCards(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  render(int render_input) {
    if (render_input == -1) {
      return renderLoading();
    } else if (render_input == 0) {
      return renderYesOrNo();
    } else if (render_input == 1) {
      return renderInPersonorMailIn();
    } else if (render_input == 3) {
      return renderChecklistPage();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getPreferences();
    electionsBox = Hive.box('electionBox');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return render(status);
  }
}
