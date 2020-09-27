import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:lets_vote/ballot.dart';
import 'package:lets_vote/ballot_cache_manager.dart';
import 'package:lets_vote/measure.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'candidate.dart';
import 'election.dart';
import 'election_page.dart';
import 'home.dart';
import 'measure_page.dart';

// class Election {
//   String name;
//   int id;
//   String officeLevel;
//   List<Candidate> candidates;

//   Election(this.name, this.id, this.officeLevel, this.candidates);
// }

// class BallotCacheManager extends BaseCacheManager {
//   static const key = 'customCache';

//   static BallotCacheManager _instance;

//   factory BallotCacheManager() {
//     if (_instance == null) {
//       _instance = new BallotCacheManager();
//     }
//     return _instance;
//   }

//   BallotCacheManager._() : super(key, maxAgeCacheObject: Duration(days: 7));

//   @override
//   Future<String> getFilePath() async {
//     var directory = await getTemporaryDirectory();
//     return path.join(directory.path, key);
//   }
// }

class BallotPage extends StatefulWidget {
  @override
  _BallotPageState createState() => _BallotPageState();
}

class _BallotPageState extends State<BallotPage> {
  List<int> federal = [];
  List<int> state = [];
  List<int> local = [];
  bool electionsReady = false;
  String deviceId;
  String ballotName = 'n/a';
  Box<Election> electionsBox;
  Box<Ballot> ballotsBox;
  Box<Measure> measuresBox;

  Future<void> sendBallotRequest(String voterId) async {
    var response;
    try {
      String sendUrl =
          'https://api.wevoteusa.org/apis/v1/voterBallotItemsRetrieve/?&voter_device_id=' +
              voterId;

      print(sendUrl + 'url');
      var file = await DefaultCacheManager().getSingleFile(sendUrl);
      response = file;
      //var res = file.readAsString();
    } catch (error) {
      print(error);
    } finally {
      String res = await response.readAsString();
      organizeElections(res);
    }
  }

  void organizeElections(String response) {
    var jsonParsed = jsonDecode(response);

    if (jsonParsed['success'] == true) {
      int ballotItemLength = jsonParsed['ballot_item_list'].length;

      // List<Election> returnElections = [];

      for (var x = 0; x < ballotItemLength; x++) {
        var election = jsonParsed['ballot_item_list'][x];
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
            election['id'],
            election['google_civic_election_id'],
            election['race_office_level'],
            electionCandidates,
            null);

        electionsBox.add(addElection);

        //  returnElections.add(addElection);
      }

      // DateTime parsedDateTime = DateTime.parse(jsonParsed['election_day_text']);

      // Ballot addBallot = new Ballot(jsonParsed['election_name'],
      //     int.parse(jsonParsed['google_civic_election_id']), parsedDateTime, parsedDateTime);
      // ballotsBox.add(addBallot);
      setState(() {
        filterElections();
        electionsReady = true;
        // elections = returnElections;
        //print(elections[0].id);
      });
    }
  }

  _electionColor(Election election) {
    if (election.chosenIndex != null) {
      return Colors.green;
    }
    return Colors.amber.shade600;
  }

  _measureColor(Measure measure) {
    if (measure.isYes != null) {
      return Colors.green;
    }
    return Colors.amber.shade600;
  }

  _buildMeasuresView(bool status) {
    if (status) {
      if (measuresBox.length == 0) {
        return Center(child: Text('Oops! No Measures to Display Here'));
      }
      return new ListView.builder(
        shrinkWrap: true,
        itemCount: measuresBox.length,
        itemBuilder: (BuildContext context, int index) {
          Measure measure = measuresBox.getAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FlatButton(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: _measureColor(measure),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    // leading: CircleAvatar(
                    //   radius: 20.0,
                    //   backgroundImage: _photoUrlExists(candidate.photoUrl),
                    // ),
                    title: Text(
                      measure.name,
                      //style: TextStyle(color: Colors.grey),
                    ),
                    //subtitle: Text('{$election.officeLevel} Office'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ),
              onPressed: () {
                //open Election Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeasurePage(
                      measure: measure,
                      ballotName: ballotName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return Center(
        child: CircularProgressIndicator(
      strokeWidth: 5,
    ));
  }

  _buildElectionsView(bool status, int fslIndex) {
    if (status) {
      // return Center(
      //   child: Text('ELECTIONS RETRIEVED'),
      // );
      List<int> chosenIndicies;
      if (fslIndex == 1) {
        chosenIndicies = federal;
      }
      if (fslIndex == 2) {
        chosenIndicies = state;
      }
      if (fslIndex == 3) {
        chosenIndicies = local;
      }
      if (chosenIndicies.length == 0) {
        return Center(child: Text('Oops! No Races to Display Here'));
      }
      return new ListView.builder(
        shrinkWrap: true,
        itemCount: chosenIndicies.length,
        itemBuilder: (BuildContext context, int index) {
          Election election = electionsBox.getAt(chosenIndicies[index]);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FlatButton(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: _electionColor(election),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    // leading: CircleAvatar(
                    //   radius: 20.0,
                    //   backgroundImage: _photoUrlExists(candidate.photoUrl),
                    // ),
                    title: Text(
                      election.name,
                      //style: TextStyle(color: Colors.grey),
                    ),
                    //subtitle: Text('{$election.officeLevel} Office'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ),
              onPressed: () {
                //open Election Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ElectionPage(
                            election: election,
                            electionIndex: chosenIndicies[index],
                          )),
                );
              },
            ),
          );
        },
      );
    }
    return Center(
        child: CircularProgressIndicator(
      strokeWidth: 5,
    ));
  }

  Future<String> getDeviceId() async {
    String keyName = 'DeviceId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = (prefs.getString(keyName));
    //prefs.setElection('Election', new Election('hello', 12, 'Federal', new List<Candidate>() ));
    //print(address);
    print(id);
    return id;
  }

  void getPreferences() async {
    String temp_id;
    try {
      temp_id = await getDeviceId();
    } catch (error) {
      print(error);
    } finally {
      deviceId = temp_id;
      sendBallotRequest(deviceId);
    }
  }

  void filterElections() {
    for (var i = 0; i < electionsBox.length; i++) {
      var officeLevel = electionsBox.getAt(i).officeLevel.toLowerCase();
      if (officeLevel == 'federal') {
        federal.add(i);
      } else if (officeLevel == 'state') {
        state.add(i);
      } else if (officeLevel == 'local') {
        local.add(i);
      }
    }
  }

  @override
  void initState() {
    //getPreferences();
    electionsBox = Hive.box<Election>('electionBox');
    measuresBox = Hive.box<Measure>('measureBox');
    print(electionsBox.length);
    ballotsBox = Hive.box<Ballot>('ballotBox');
    // if (electionsBox.length == 0) {
    //   getPreferences();
    // } else {
    if (ballotsBox.length > 0) {
      ballotName = ballotsBox.getAt(0).name;
    }
    if (electionsBox.length > 0) {
      for (var x = 0; x < ballotsBox.length; x++) {
        print(ballotsBox.getAt(x).googleBallotId);
        print(electionsBox.getAt(0).googleCivicId);
        if (ballotsBox.getAt(x).googleBallotId ==
            electionsBox.getAt(0).googleCivicId) {
          ballotName = ballotsBox.getAt(x).name;
        }
      }
    }
    filterElections();
    electionsReady = true;
    //}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.autorenew),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Refresh Ballot?'),
                content: Text(
                    'Refreshing your ballot will reflect any changes in elections (i.e. candidates dropping out).\n Let\'s Vote will keep your selected preferences, unless the candidate you have previously chosen has dropped out.\n Let\'s Vote automatically refreshes your ballots every 3 days'),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      //DefaultCacheManager().emptyCache();
                      BallotCacheManager().emptyCache();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(selectedIndex: 1)),
                      );
                    },
                  ),
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
              barrierDismissible: true,
            );
          }),
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              //alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: Text(
                      'Your Ballot',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(80, 0, 80, 20),
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
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                    child: Text(
                      'Upcoming Election:',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    child: Container(
                      //height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 241, 39, 17),
                            Color.fromARGB(255, 245, 175, 25)
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          ballotName,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              Tab(
                                text: 'Federal',
                              ),
                              Tab(
                                text: 'State',
                              ),
                              Tab(
                                text: 'Local',
                              ),
                              Tab(
                                text: 'Measures',
                              )
                            ],
                            labelColor: Colors.black,
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildElectionsView(electionsReady, 1),
                                _buildElectionsView(electionsReady, 2),
                                _buildElectionsView(electionsReady, 3),
                                _buildMeasuresView(electionsReady),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: _buildElectionsView(electionsReady),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
