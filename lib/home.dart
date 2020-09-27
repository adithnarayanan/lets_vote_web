import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lets_vote/ballot_page.dart';
import 'package:lets_vote/measure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ballot.dart';
import 'dashboard_page_update.dart';
import 'package:lets_vote/profile_page.dart';
import 'package:lets_vote/voting_page.dart';
import 'current_candidates_page.dart';
import 'election.dart';
import 'candidate.dart';
import 'dart:convert';
import 'ballot_cache_manager.dart';

class HomePage extends StatefulWidget {
  int selectedIndex;
  HomePage({Key key, this.selectedIndex}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(selectedIndex);
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex;
  _HomePageState(this._selectedIndex);

  Box<Ballot> ballotsBox;
  Box<Election> electionsBox;
  Box<Measure> measuresBox;
  String stateCode;
  String id;
  String responseFromStateDeadlines;
  DateTime lastRefreshed;
  bool readyToRender = false;
  bool notificationsEnabled;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  checkBallotExists(int ballotId) {
    for (var x = 0; x < ballotsBox.length; x++) {
      if (ballotsBox.getAt(x).googleBallotId == ballotId) {
        return true;
      }
    }
    return false;
  }

  void organizeElections(String response, Map<int, String> electionIndicies,
      Map<int, bool> measureIndicies) {
    print('organizing elections');
    var jsonParsed = jsonDecode(response);

    if (jsonParsed['success'] == true) {
      int ballotItemLength = jsonParsed['ballot_item_list'].length;

      // List<Election> returnElections = [];

      for (var x = 0; x < ballotItemLength; x++) {
        var election = jsonParsed['ballot_item_list'][x];
        if (election['kind_of_ballot_item'] == 'OFFICE') {
          print(x);
          print(election['id']);
          int candidateListLength = election['candidate_list'].length;
          if (candidateListLength > 20) {
            candidateListLength = 20;
          }
          List<Candidate> electionCandidates = [];

          List<int> nonRepeatIndexes = [];
          List<String> stringNames = [];

          for (var y = 0; y < candidateListLength; y++) {
            var candidate = election['candidate_list'][y];
            var candidateName = candidate['ballot_item_display_name'];

            if (!stringNames.contains(candidateName)) {
              nonRepeatIndexes.add(y);
              stringNames.add(candidateName);
              // print(stringNames);
            }
          }

          for (var y = 0; y < nonRepeatIndexes.length; y++) {
            var index = nonRepeatIndexes[y];

            var candidate = election['candidate_list'][index];

            if (candidate['withdrawn_from_election'] == false) {
              Candidate addCandidate = new Candidate(
                  candidate['ballot_item_display_name'],
                  candidate['ballotpedia_candidate_summary'],
                  candidate['party'],
                  candidate['candidate_photo_url_large'],
                  candidate['ballotpedia_candidate_url'],
                  candidate['candidate_url'],
                  candidate['facebook_url'],
                  candidate['twitter_url']);

              electionCandidates.add(addCandidate);
            }
          }

          electionCandidates = electionCandidates.toSet().toList();

          Election addElection = new Election(
              election['ballot_item_display_name'],
              int.parse(election['id'].toString()),
              int.parse(election['google_civic_election_id'].toString()),
              election['race_office_level'],
              electionCandidates,
              null);

          print('checkpoint 1');

          if (electionIndicies.containsKey(addElection.id)) {
            print('found election with prexisting person');
            print(electionIndicies[addElection.id]);
            for (var x = 0; x < addElection.candidates.length; x++) {
              if (addElection.candidates[x].name ==
                  electionIndicies[addElection.id]) {
                addElection.chosenIndex = x;
                break;
              }
            }
          }

          print('checkpoint 2');

          electionsBox.add(addElection);
          print('election added');
          print(electionsBox.length);

          //  returnElections.add(addElection);
        }
        if (election['kind_of_ballot_item'] == 'MEASURE') {
          Measure addMeasure = new Measure(
              election['ballot_item_display_name'],
              int.parse(election['id'].toString()),
              int.parse(election['google_civic_election_id'].toString()),
              election['measure_text'],
              election['no_vote_description'],
              election['yes_vote_description'],
              election['measure_url'],
              null);

          if (measureIndicies.containsKey(addMeasure.id)) {
            print(electionIndicies[addMeasure.id]);
            addMeasure.isYes = measureIndicies[addMeasure.id];
          }

          measuresBox.add(addMeasure);
        }
      }

      //TODO if this google_civic ID is not in current Ballots, then check delete all ballots and recreate.
      print(int.parse(jsonParsed['google_civic_election_id'].toString()));

      if (!checkBallotExists(
          int.parse(jsonParsed['google_civic_election_id'].toString()))) {
        sendBallotRequest(id, true);
      } else {
        setState(() {
          readyToRender = true;
        });
      }
      setState(() {});
    }
  }

  static List<Widget> _renderPage = <Widget>[
    CurrentCandidatesPage(),
    BallotPage(),
    DashboardPage(),
    VotingPage(),
    ProfilePage(),
  ];

  Future<String> getDeviceId() async {
    String keyName = 'DeviceId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = (prefs.getString(keyName));
    return id;
  }

  Future<DateTime> getRefreshDate() async {
    String keyName = 'refreshDate';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateTimeString = prefs.getString(keyName);
    if (dateTimeString != null) {
      return DateTime.parse(dateTimeString);
    }
    return null;
  }

  void setRefreshDate() async {
    String keyName = 'refreshDate';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(keyName, DateTime.now().toIso8601String());
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

  Future<bool> getNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  void setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
    if (Platform.isIOS) {
      if (!value) {
        // cancelAllNotifications();
      }
    }
  }

  void setIOSNotificationsEnabled(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('iOSNotificationsEnabled', value);
  }

  Future<String> _loadFromAsset() async {
    return await rootBundle.loadString("assets/state_deadlines.json");
  }

  void setVoterId(bool status) async {
    String voterId;
    String temp_code;
    String temp_response;
    DateTime temp_date;
    bool notification;
    try {
      voterId = await getDeviceId();
      temp_code = await getStateCode();
      temp_response = await _loadFromAsset();
      temp_date = await getRefreshDate();
      notification = await getNotificationsEnabled();
    } catch (error) {
      print(error);
    } finally {
      print('OI MATE IM WORKING LMAO');
      stateCode = temp_code;
      responseFromStateDeadlines = temp_response;
      lastRefreshed = temp_date;
      id = voterId;
      print(id);
      notificationsEnabled = notification;
      if (ballotsBox.length == 0) {
        sendBallotRequest(voterId, false);
      }
      populate(voterId, status);
    }
  }

  void populate(String id, status) async {
    String sendUrl =
        'https://api.wevoteusa.org/apis/v1/voterBallotItemsRetrieve/?&voter_device_id=' +
            id;
    var file = await BallotCacheManager()
        .getFileFromCache(sendUrl, ignoreMemCache: true);
    //var file = await DefaultCacheManager().getFileFromCache(sendUrl);
    print(file);
    print(status);
    bool mustRefresh = false;
    if (lastRefreshed == null ||
        lastRefreshed.difference(DateTime.now()).inHours.abs() > 72) {
      mustRefresh = true;
    }
    if (status == true || mustRefresh == true) {
      //crudBallots(id);
      crudElectionsAndMeasures(id);
    } else {
      setState(() {
        //cancelAllNotifications();
        //createBallotNotifications(notificationsEnabled);
        readyToRender = true;
      });
    }
//do nothing
  }

  crudElectionsAndMeasures(String id) async {
    String response;
    try {
      String sendUrl =
          'https://api.wevoteusa.org/apis/v1/voterBallotItemsRetrieve/?&voter_device_id=' +
              id;
      var file = await BallotCacheManager().getSingleFile(sendUrl);
      // var file = await DefaultCacheManager().getSingleFile(sendUrl);
      response = await file.readAsString();
    } catch (error) {
      print(error);
    } finally {
      var jsonParsed = jsonDecode(response);

      if (jsonParsed['success'] == true && jsonParsed['ballot_found'] == true) {
        setRefreshDate();
        print(response);
        Map<int, String> currentElections = {};
        Map<int, bool> currentMeasures = {};
        if (electionsBox.length == 0) {
          print('going zero');
          organizeElections(response, currentElections, currentMeasures);
        } else {
          print('populating with Map');
          for (var x = 0; x < electionsBox.length; x++) {
            Election election = electionsBox.getAt(x);
            if (election.chosenIndex != null) {
              currentElections[election.id] =
                  election.candidates[election.chosenIndex].name;
            }
          }
          for (var x = 0; x < measuresBox.length; x++) {
            Measure measure = measuresBox.getAt(x);
            if (measure.isYes != null) {
              currentMeasures[measure.id] = measure.isYes;
            }
          }
          try {
            await electionsBox.clear();
            await measuresBox.clear();
          } catch (error) {
            print(error);
          } finally {
            print(electionsBox.length);
            organizeElections(response, currentElections, currentMeasures);
          }
        }
      } else {
        setState(() {
          // cancelAllNotifications();
          // createBallotNotifications(notificationsEnabled);
          readyToRender = true;
        });
        //readyToRender = true
      }
    }
  }

  bool checkIfBallotsPassed() {
    bool status = false;
    for (var x = ballotsBox.length - 1; x > -1; x--) {
      if (ballotsBox.getAt(x).date.isBefore(DateTime.now())) {
        print('checking');
        ballotsBox.deleteAt(x);
        status = true;
      }
    }
    return status;
  }

  int getDeadline() {
    var state = jsonDecode(responseFromStateDeadlines)[stateCode.toUpperCase()];
    if (state['online'] != null) {
      return state['online'];
    } else {
      return state['by_mail'];
    }
  }

  sendBallotRequest(String deviceId, bool status) async {
    var res;
    try {
      print('lol');
      print(deviceId.toString());
      String sendUrl =
          'https://api.wevoteusa.org/apis/v1/electionsRetrieve/voter_device_id=' +
              deviceId;

      //var file = await DefaultCacheManager().getSingleFile(sendUrl);
      //print('lol');
      var file = await BallotCacheManager().getSingleFile(sendUrl);

      print(file);
      res = await file.readAsString();
      print('DeviceId: $deviceId');
      print('res is $res');
    } catch (error) {
      print('Error is $error');
    } finally {
      populateBallots(res, status);
    }
  }

  populateBallots(String ballotResponse, status) {
    print(ballotResponse);
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
        if (status) {
          setState(() {
            // cancelAllNotifications();
            // createBallotNotifications(notificationsEnabled);
            readyToRender = true;
          });
        }
        break;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // setIOSandNotificationsEnabled();
    ballotsBox = Hive.box('ballotBox');
    electionsBox = Hive.box('electionBox');
    measuresBox = Hive.box('measureBox');
    //function to see if one of ballots has passed;
    bool runAgain = checkIfBallotsPassed();
    setVoterId(runAgain);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const bottomNavColor = Colors.black;

    if (readyToRender) {
      return Scaffold(
        // backgroundColor: Colors.black,
        body: _renderPage.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.red,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              title: Text('Reps'),
              backgroundColor: bottomNavColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in),
              title: Text('Ballot'),
              backgroundColor: bottomNavColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
              backgroundColor: bottomNavColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.thumbs_up_down),
              title: Text('Voting'),
              backgroundColor: bottomNavColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
              backgroundColor: bottomNavColor,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue.shade700,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/LetsVoteText.png'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
