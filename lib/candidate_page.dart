import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lets_vote/election.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'candidate.dart';
import 'election_page.dart';

//TODO replace webview with url launcher

class CandidatePage extends StatefulWidget {
  Candidate candidate;
  int electionIndex;
  int candidateIndex;
  CandidatePage(
      {Key key, this.candidate, this.electionIndex, this.candidateIndex})
      : super(key: key);

  @override
  _CandidatePageState createState() =>
      _CandidatePageState(candidate, electionIndex, candidateIndex);
}

class _CandidatePageState extends State<CandidatePage> {
  Candidate candidate;
  int electionIndex;
  int candidateIndex;
  _CandidatePageState(this.candidate, this.electionIndex, this.candidateIndex);

  Box<Election> electionsBox;
  Election election;
  String party;

  _photoUrlExists(photoUrl) {
    if (photoUrl != null || photoUrl != "") {
      return CachedNetworkImageProvider(photoUrl);
    }
    return AssetImage('assets/AmericanFlagStar.png');
  }

  _descriptionExists(input) {
    if (input != null) {
      return input;
    }
    return '';
  }

  _trailingButton() {
    if (candidateIndex == election.chosenIndex) {
      return InkWell(
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.remove_circle_outline)),
        onTap: () {
          setState(() {
            election.chosenIndex = null;
            election.save();
          });
        },
      );
    }
    return InkWell(
      child: Padding(
          padding: EdgeInsets.all(5), child: Icon(Icons.add_circle_outline)),
      onTap: () {
        setState(() {
          election.chosenIndex = candidateIndex;
          election.save();
        });
      },
    );
  }

  _color(int index) {
    if (candidateIndex == election.chosenIndex) {
      return Colors.green;
    }
    return Colors.amber.shade700;
  }

  Future<String> getParty() async {
    String keyName = 'partyAffiliation';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String party = (prefs.getString(keyName));
    //print(address);
    party = party;
  }

  @override
  void initState() {
    super.initState();
    electionsBox = Hive.box('electionBox');
    election = electionsBox.getAt(electionIndex);
  }

  _candidateListTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
      child: Card(
        color: _color(candidateIndex),
        child: ListTile(
          // leading: CircleAvatar(
          //   radius: 20.0,
          //   backgroundImage: _photoUrlExists(candidate.photoUrl),
          // ),
          title: Text(
            candidate.name,
            //style: TextStyle(color: Colors.grey),
          ),
          // subtitle: Text('${candidate.party}'),
          // isThreeLine: true,
          trailing: _trailingButton(),
        ),
      ),
    );
  }

  _launchBallotpediaUrl() async {
    var url = candidate.ballotopediaUrl;
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.teal,
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              //alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _candidateListTile(),
                              CircleAvatar(
                                radius: 50.0,
                                backgroundImage:
                                    _photoUrlExists(candidate.photoUrl),
                              ),
                              Text(
                                candidate.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                candidate.party,
                                style: TextStyle(
                                  fontFamily: 'SourceSansPro',
                                  fontSize: 20.0,
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                                width: 150.0,
                                child: Divider(
                                  thickness: 3,
                                  color: Colors.teal.shade100,
                                ),
                              ),

                              Text(
                                _descriptionExists(candidate.description),
                                style: TextStyle(
                                  //color: Colors.teal.shade900,
                                  fontFamily: 'SourceSansPro',
                                  fontSize: 15.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 30.0, 0, 3),
                                child: InkWell(
                                  onTap: () {
                                    _launchBallotpediaUrl();
                                  },
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.public,
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          // color: Colors.white,
                                        ),
                                        title: Text(
                                          "Research Candidate on Ballotpedia.org",
                                          //style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    color: Colors.yellow.shade300,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  '*Let\'s Vote is in no way affiliated with Ballotpedia.org',
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                              // Expanded(
                              //   child: WebView(
                              //     initialUrl: candidate.ballotopediaUrl,
                              //     javascriptMode: JavascriptMode.disabled,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      child: Row(children: [
                        Icon(Icons.arrow_back_ios),
                        Text('Back to Election')
                      ]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ElectionPage(
                                    election: election,
                                    electionIndex: electionIndex,
                                  )),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
