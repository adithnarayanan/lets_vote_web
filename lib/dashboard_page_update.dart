import 'dart:convert';

import 'package:lets_vote/help_page.dart';
import 'package:lets_vote/profile_page.dart';

import 'ballot_cache_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:lets_vote/ballot_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'ballot.dart';
import 'home.dart';
import 'introduction_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  CalendarController _controller;
  Box<Ballot> ballotsBox;
  String deviceId;
  String response;
  String stateCode;
  Map<DateTime, String> datesMap = {};
  List<DateTime> dates = [];
  int index = 0;
  bool status = false;
  DateTime firstDate = DateTime.now();

  Future<String> getDeviceId() async {
    String keyName = 'DeviceId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = (prefs.getString(keyName));
    //prefs.setElection('Election', new Election('hello', 12, 'Federal', new List<Candidate>() ));
    //print(address);
    print(id);
    return id;
  }

  Future<String> getStateCode() async {
    String keyName = 'stateCode';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = (prefs.getString(keyName));
    //print(address);
    print(code);
    code = code.toLowerCase();
    return code;
  }

  Future<String> _loadFromAsset() async {
    return await rootBundle.loadString("assets/state_deadlines.json");
  }

  sendBallotRequest(String deviceId) async {
    var res;
    try {
      String sendUrl =
          'https://api.wevoteusa.org/apis/v1/electionsRetrieve/voter_device_id=' +
              deviceId;

      var file = await DefaultCacheManager().getSingleFile(sendUrl);
      //var file = await BallotCacheManager().getSingleFile(sendUrl);
      res = await file.readAsString();
    } catch (error) {
      print(error);
    } finally {
      populateBallots(res);
    }
  }

  int getDeadline() {
    var state = jsonDecode(response)[stateCode.toUpperCase()];
    if (state['online'] != null) {
      return state['online'];
    } else {
      return state['by_mail'];
    }
  }

  populateBallots(String ballotResponse) {
    //print(ballotResponse);
    var jsonParsed = jsonDecode(ballotResponse);
    int election_length = jsonParsed['election_list'].length;
    print(election_length);
    for (var x = 0; x < election_length; x++) {
      var ballot = jsonParsed['election_list'][x];
      if (ballot['election_is_upcoming']) {
        // print(ballot['state_code_list']);
        // print(stateCode);
        if (ballot['state_code_list'].contains(stateCode.toUpperCase())) {
          print(ballot['state_code_list']);
          print(stateCode);
          DateTime ballotDate = DateTime.parse(ballot['election_day_text']);
          print(ballotDate);
          int difference = getDeadline();
          DateTime deadline =
              ballotDate.subtract(new Duration(days: difference));
          Ballot addBallot = new Ballot(ballot['election_name'],
              ballot['google_civic_election_id'], ballotDate, deadline);
          ballotsBox.add(addBallot);
        }
      } else {
        break;
      }
    }
    populateDates();
  }

  void getPreferences() async {
    String temp_id;
    String temp_code;
    String temp_response;
    try {
      temp_id = await getDeviceId();
      temp_code = await getStateCode();
      temp_response = await _loadFromAsset();
    } catch (error) {
      print(error);
    } finally {
      deviceId = temp_id;
      stateCode = temp_code;
      response = temp_response;
      sendBallotRequest(deviceId);
    }
  }

  void populateDates() {
    DateTime.now();
    datesMap[DateTime.now()] = 'Today';
    for (var x = 0; x < ballotsBox.length; x++) {
      var ballot = ballotsBox.getAt(x);
      if (ballot.date.isAfter(DateTime.now())) {
        datesMap[ballot.date] = ballot.name.toString() + ' Day';
      }
      if (ballot.deadline.isAfter(DateTime.now())) {
        datesMap[ballot.deadline] =
            "Registration Deadline for \n" + ballot.name.toString();
      }
    }

    datesMap = Map.fromEntries(
        datesMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    dates = datesMap.keys.toList();

    print(datesMap);

    setState(() {
      status = true;
      if (dates.length > 1) {
        firstDate = dates[1];
        index = 1;
      } else {
        firstDate = dates[0];
      }

      // _controller.setSelectedDay(dates[index]);
    });
  }

  @override
  void initState() {
    _controller = CalendarController();
    ballotsBox = Hive.box<Ballot>('ballotBox');
    // if (ballotsBox.length < 1) {
    //   getPreferences();
    // } else {
    populateDates();
    //}
    super.initState();
  }

  _colorLeftArrow() {
    if (index > 0) {
      return Colors.white;
    }
    return Colors.grey;
  }

  _colorRightArrow() {
    if (index < (dates.length - 1)) {
      return Colors.white;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle topStyle = TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );

    if (status) {
      return Scaffold(
        // floatingActionButton: FloatingActionButton(
        //     child: Icon(Icons.help_outline),
        //     onPressed: () {
        //       showDialog(
        //         context: context,
        //         builder: (_) => Dialog(
        //             insetPadding: EdgeInsets.all(10.0),
        //             child: Container(
        //               width: double.infinity,
        //               decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(15)),
        //               child: HelpPage(),
        //             )),
        //         barrierDismissible: true,
        //       );
        //     }),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: Text(
                      'Upcoming',
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
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      //width: double.maxFinite,
                      constraints: BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 242, 96),
                            Color.fromARGB(255, 5, 117, 230)
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          )
                        ],
                      ),
                      child: TableCalendar(
                        initialSelectedDay: firstDate,
                        availableGestures: AvailableGestures.none,
                        calendarStyle: CalendarStyle(
                          todayColor: Colors.red.shade300,
                          //highlightSelected: false,
                          //selectedColor: null,
                          weekdayStyle:
                              TextStyle(color: Colors.white, fontSize: 16.0),
                          weekendStyle:
                              TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        headerStyle: HeaderStyle(
                            centerHeaderTitle: true,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            )),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                          weekendStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                          // dowTextBuilder: (date, locale) =>
                          //     DateFormat.E(locale).format(date)[0],
                        ),
                        calendarController: _controller,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      //width: double.maxFinite,
                      constraints: BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 242, 96),
                            Color.fromARGB(255, 5, 117, 230)
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0, horizontal: 10.0),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: _colorLeftArrow(),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    if (index > 0) {
                                      index--;
                                      _controller.setSelectedDay(dates[index]);
                                      _controller.setFocusedDay(dates[index]);
                                      print('tapped');
                                    }
                                    // _controller
                                    //     .setSelectedDay(ballotsBox.getAt(0).date);
                                    // _controller.setFocusedDay(ballotsBox.getAt(0).date);
                                    // print('tapped');
                                    // print(ballotsBox.getAt(0).date);
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Text(
                                    datesMap[dates[index]],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    DateFormat.yMMMMd().format(dates[index]),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      //fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0, horizontal: 10.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: _colorRightArrow(),
                                  ),
                                ),
                                onTap: () {
                                  if (index < (dates.length - 1)) {
                                    setState(() {
                                      index++;
                                      _controller.setSelectedDay(dates[index]);
                                      _controller.setFocusedDay(dates[index]);
                                    });
                                  }
                                  // setState(() {
                                  //   _controller
                                  //       .setSelectedDay(ballotsBox.getAt(0).deadline);
                                  //   _controller
                                  //       .setFocusedDay(ballotsBox.getAt(0).deadline);
                                  //   print(ballotsBox.getAt(0).deadline);
                                  // });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return (Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      ));
    }
  }
}
