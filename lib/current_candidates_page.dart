import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

const _kGoogleApiKey = 'AIzaSyAoMEzR-M4-xZ2DyRWi8eYa-xMPlQVpHf8';

class RepresentativesCacheManager extends BaseCacheManager {
  static const key = 'customCache';

  static RepresentativesCacheManager _instance;

  factory RepresentativesCacheManager() {
    if (_instance == null) {
      _instance = new RepresentativesCacheManager();
    }
    return _instance;
  }

  RepresentativesCacheManager._()
      : super(key, maxAgeCacheObject: Duration(days: 7));

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }
}

class Representative {
  String name;
  String officeName;
  String photoUrl;
  String party;

  Representative(this.name, this.officeName, this.photoUrl, this.party);
}

class CurrentCandidatesPage extends StatefulWidget {
  @override
  _CurrentCandidatesPageState createState() => _CurrentCandidatesPageState();
}

class _CurrentCandidatesPageState extends State<CurrentCandidatesPage> {
  List<Representative> representatives = [];
  String response;
  String address;

  Future<String> getAddress() async {
    String keyName = 'address';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = (prefs.getString(keyName));
    return address;
  }

  sendGetRequest(String address_input) async {
    String formatted_address = address_input.replaceAll(new RegExp(' '), '%20');
    String url =
        'https://www.googleapis.com/civicinfo/v2/representatives?key=' +
            _kGoogleApiKey +
            '&address=' +
            formatted_address;
    print(url + 'url');
    var file = await RepresentativesCacheManager._().getSingleFile(url);
    var res = file.readAsString();
    return res;
  }

  _photoUrlExists(photoUrl) {
    if (photoUrl != null) {
      return CachedNetworkImageProvider(photoUrl);
    }
    return AssetImage('assets/AmericanFlagStar.png');
  }

  _buildListView(String response_input) {
    if (response_input != null) {
      var offices = jsonDecode(response_input)['offices'];
      var offices_length = offices.length;
      var officialsBody = jsonDecode(response_input)['officials'];
      int length = officialsBody.length;
      print(length.toString() + 'length');

      for (var i = 0; i < offices_length; i++) {
        String officeName = offices[i]['name'];
        var officials = offices[i]['officialIndices'];
        //int officials_length = officials.length;
        for (var x = 0; x < officials.length; x++) {
          int index = officials[x];
          String name = officialsBody[index]['name'];
          String party = officialsBody[index]['party'];
          if (party == 'Republican Party') {
            party = 'R';
          } else if (party == 'Democratic Party') {
            party = 'D';
          }
          String photoUrl = officialsBody[index]['photoUrl'];
          //print(officeName + ': ' + name + ' ' + ' ' + party + ' ');

          representatives
              .add(new Representative(name, officeName, photoUrl, party));
        }
      }

      return new ListView.builder(
        shrinkWrap: true,
        itemCount: representatives.length,
        itemBuilder: (BuildContext context, int index) {
          Representative representative = representatives[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.amber.shade700,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: _photoUrlExists(representative.photoUrl),
                ),
                title: Text(
                  representative.name,
                  //style: TextStyle(color: Colors.grey),
                ),
                subtitle: Text(
                    '${representative.officeName} - ${representative.party}'),
              ),
            ),
          );
        },
      );

      // return ListView(
      //   shrinkWrap: true,
      //   padding: const EdgeInsets.all(8),
      //   children: <Widget>[
      //     ...representativeCards,
      //   ],
      // );
    }
    return Center(
        child: CircularProgressIndicator(
      strokeWidth: 5,
    ));
  }

  void setAddress() async {
    address = await getAddress().then((value) {
      setResponse(value);
      return value;
    });
  }

  void setResponse(address_input) async {
    String httpResponse;
    try {
      httpResponse = await sendGetRequest(address_input);
      print(httpResponse);
    } catch (error) {
      print('error: + $error');
    } finally {
      print('exeucting finally');
      setState(() {
        response = httpResponse;
        print(response);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setAddress();

    //response = sendGetRequest();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle topStyle = TextStyle(
      fontSize: 35,
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
    const TextStyle locationStyle = TextStyle(
      fontSize: 16,
    );

    return SafeArea(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //alignment: Alignment.center,
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(00, 40, 0, 0),
                  child: Text(
                    'Your Representatives',
                    style: topStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    height: 20.0,
                    width: 150.0,
                    child: Divider(
                      thickness: 3,
                      color: Colors.teal.shade100,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildListView(response),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
