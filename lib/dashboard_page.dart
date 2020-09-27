import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'ballot.dart';

const _newsApiKey = '90b7903befeb481ea444373cfbca02f1';

class NewsCacheManager extends BaseCacheManager {
  static const key = 'customCache';

  static NewsCacheManager _instance;

  factory NewsCacheManager() {
    if (_instance == null) {
      _instance = new NewsCacheManager();
    }
    return _instance;
  }

  NewsCacheManager._() : super(key, maxAgeCacheObject: Duration(minutes: 10));

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }
}

class NewsArticle {
  String title;
  String url;
  String photoUrl;
  String source;
  String author;

  NewsArticle(this.title, this.url, this.photoUrl, this.source, this.author);
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<NewsArticle> newsArticles = [];
  Box<Ballot> ballotsBox;
  String deviceId;
  String response;
  String stateCode;

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

  getNews() async {
    String res;
    try {
      String url =
          'http://newsapi.org/v2/top-headlines?country=us&category=politics&apiKey=' +
              _newsApiKey;
      var file = await NewsCacheManager._().getSingleFile(url);
      //var file = await DefaultCacheManager().getSingleFile(url);
      res = await file.readAsString();
    } catch (error) {
      print('error: $error');
    } finally {
      setState(() {
        response = res;
      });
    }
  }

  _buildNewsListView(String response) {
    if (response != null) {
      //var numItems = jsonDecode(response)['totalResults'];
      var articles = jsonDecode(response)['articles'];

      for (var x = 0; x < articles.length; x++) {
        var article = articles[x];
        newsArticles.add(new NewsArticle(
            article['title'],
            article['url'],
            article['urlToImage'],
            article['source']['name'],
            article['author']));
      }

      return new ListView.builder(
        shrinkWrap: true,
        itemCount: newsArticles.length,
        itemBuilder: (BuildContext context, int index) {
          NewsArticle article = newsArticles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.lightBlue,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(article.photoUrl),
                ),
                title: Text(article.title),
                subtitle: Text('${article.author} - ${article.source}'),
              ),
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

  sendBallotRequest(String deviceId) async {
    var res;
    try {
      String sendUrl =
          'https://api.wevoteusa.org/apis/v1/electionsRetrieve/voter_device_id=' +
              deviceId;

      var file = await DefaultCacheManager().getSingleFile(sendUrl);
      res = await file.readAsString();
    } catch (error) {
      print(error);
    } finally {
      populateBallots(res);
    }
  }

  populateBallots(String ballotResponse) {
    var jsonParsed = jsonDecode(ballotResponse);
    int election_length = jsonParsed['election_list'].length;
    for (var x = 0; x < election_length; x++) {
      var ballot = jsonParsed[x];
      if (ballot['election_is_upcoming']) {
        if (ballot['state_code_list'].contains(stateCode)) {
          DateTime ballotDate = DateTime.parse(ballot['election_day_text']);
          // Ballot addBallot = new Ballot(ballot['electionName'],
          //     ballot['google_civic_election_id'], ballotDate);
          // ballotsBox.add(addBallot);
        }
      } else {
        break;
      }
    }
  }

  void getPreferences() async {
    String temp_id;
    String temp_code;
    try {
      temp_id = await getDeviceId();
      temp_code = await getStateCode();
    } catch (error) {
      print(error);
    } finally {
      deviceId = temp_id;
      stateCode = temp_code;
      sendBallotRequest(deviceId);
    }
  }

  @override
  void initState() {
    getNews();
    ballotsBox = Hive.box<Ballot>('ballotBox');
    if (ballotsBox.length < 1) {
      getPreferences();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle topStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
      //fontWeight: FontWeight.bold,
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

    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                //color: Colors.cyan.shade900,
                color: Color.fromARGB(255, 5, 34, 82),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: const ListTile(
                          title: Text(
                            'Upcoming Elections',
                            style: topStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.amberAccent.shade100,
                        child: ListTile(
                          title: Text(
                            'Primary Election',
                            style: internalFontStyle,
                            textAlign: TextAlign.start,
                          ),
                          subtitle: Text('August 3, 2020'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.amberAccent.shade100,
                        child: ListTile(
                          title: Text(
                            'General Election',
                            style: internalFontStyle,
                            textAlign: TextAlign.start,
                          ),
                          subtitle: Text('Novemeber 3, 2020'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            // flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                //color: Colors.cyan.shade900,
                color: Color.fromARGB(255, 5, 34, 82),
                child: _buildNewsListView(response),
              ),
            ),
          )
        ],
      ),
    );
  }
}
