import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lets_vote/candidate.dart';
import 'package:lets_vote/dashboard_page.dart';
import 'package:lets_vote/home.dart';

import 'ballot.dart';
import 'ballot_page.dart';
import 'candidate_page.dart';
import 'election.dart';

class ElectionPage extends StatefulWidget {
  Election election;
  int electionIndex;
  ElectionPage({Key key, this.election, this.electionIndex}) : super(key: key);

  @override
  _ElectionPageState createState() =>
      _ElectionPageState(election, electionIndex);
}

class _ElectionPageState extends State<ElectionPage> {
  Election election;
  int electionIndex;
  _ElectionPageState(this.election, this.electionIndex);

  String ballotName;
  bool isPrimary = false;

  _photoUrlExists(photoUrl) {
    if (photoUrl != null || photoUrl == '') {
      return CachedNetworkImageProvider(
        photoUrl,
        //scale: ,
        //placeholder: (context, url) => CircularProgressIndicator(),
        //errorWidget: (context, url, error) => Icon(Icons.error)
      );
    }
    return AssetImage('assets/AmericanFlagStar.png');
  }

  _color(int index) {
    if (index == election.chosenIndex) {
      return Colors.green;
    }
    return Colors.amber.shade700;
  }

  _buildCandidateListView() {
    return new ListView.builder(
      shrinkWrap: true,
      itemCount: election.candidates.length,
      itemBuilder: (BuildContext context, int index) {
        Candidate candidate = election.candidates[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FlatButton(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: _color(index),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: _photoUrlExists(candidate.photoUrl),
                ),
                title: Text(
                  candidate.name,
                  //style: TextStyle(color: Colors.grey),
                ),
                subtitle: Text(candidate.party),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CandidatePage(
                    candidate: candidate,
                    electionIndex: electionIndex,
                    candidateIndex: index,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    var ballotsBox = Hive.box<Ballot>('ballotBox');
    for (var x = 0; x < ballotsBox.length; x++) {
      print(ballotsBox.getAt(x).googleBallotId);
      print(election.id);
      if (ballotsBox.getAt(x).googleBallotId == election.googleCivicId) {
        ballotName = ballotsBox.getAt(x).name;
      }
    }
    //ballotName = ballotsBox.getAt(0).name;
    if (ballotName.toLowerCase().contains('primary')) {
      isPrimary = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                            vertical: 30, horizontal: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                election.name,
                                style: TextStyle(
                                    fontSize: 28, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              ballotName,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                    child: Text(
                      'Candidates: ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: _buildCandidateListView(),
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
                                )),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
