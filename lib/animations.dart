import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_vote/current_candidates_page.dart';
import 'package:lets_vote/dislaimer_page.dart';
import 'package:lets_vote/main.dart';
import 'package:lets_vote/party_initialization_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'address_initialization_page.dart';
import 'home.dart';

class NextAddressAnimation extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.2, end: 1);

  NextAddressAnimation({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Text('Next', style: TextStyle(fontSize: 18)),
              Icon(Icons.arrow_forward_ios)
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddressIntitializationPage()),
            );
          },
        ),
      ),
    );
  }
}

class NextPartyAnimation extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.2, end: 1);

  NextPartyAnimation({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Text('Next', style: TextStyle(fontSize: 18)),
              Icon(Icons.arrow_forward_ios)
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PartyInitializationPage()));
          },
        ),
      ),
    );
  }
}

class NextDisclaimerAnimation extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.2, end: 1);

  NextDisclaimerAnimation({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Text('Next', style: TextStyle(fontSize: 18)),
              Icon(Icons.arrow_forward_ios)
            ],
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DisclaimerPage()));
          },
        ),
      ),
    );
  }
}

class NextHomeAnimation extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.2, end: 1);

  NextHomeAnimation({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Text('Finish', style: TextStyle(fontSize: 18)),
              Icon(Icons.arrow_forward_ios)
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(selectedIndex: 2)),
            );
          },
        ),
      ),
    );
  }
}
