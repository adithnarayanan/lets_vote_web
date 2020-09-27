import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool readyToBuildVideo = false;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName.png', width: 250.0),
      alignment: Alignment.bottomCenter,
    );
  }

  final assetVideoNames = [
    'IntroductionVideo3.mp4',
    'IntroductionVotingVideo.mp4',
    'IntroductionRepVideo.mp4',
    'IntroNewProfile.mp4'
  ];

  @override
  void initState() {
    //_controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(() {
      print('listener removed');
    });
    _controller.dispose();
    super.dispose();
  }

  Widget _buildVideo(bool status) {
    if (status) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              _controller.play();
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                // Use the VideoPlayer widget to display the video.
                child: VideoPlayer(_controller),
              );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  _launchFeedbackURL() async {
    const url = 'https://letsvote.carrd.co/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = PageDecoration(
        pageColor: Colors.white,
        imageFlex: 3,
        bodyFlex: 2,
        imagePadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        bodyTextStyle: TextStyle());

    return IntroductionScreen(
      dotsFlex: 2,
      onChange: (value) async {
        print(value);
        if (value > 1 && value < 6) {
          if (_controller != null) {
            setState(() {
              readyToBuildVideo = false;
            });
            await _controller.dispose();
          }
          setState(() {
            _controller = VideoPlayerController.asset(
                'assets/${assetVideoNames[value - 2]}');
            _initializeVideoPlayerFuture = _controller.initialize();
            //_controller.setLooping(true);
            _controller.addListener(() {
              // print(_controller.value.isPlaying);
              if (!_controller.value.isPlaying) {
                // _controller.initialize();
                _controller.seekTo(new Duration(seconds: 0));
                _controller.play();
              }
            });
            readyToBuildVideo = true;
          });
        }
        // else {
        //   if (_controller != null) {
        //     _controller.dispose();
        //     readyToBuildVideo = false;
        //   }
        //   readyToBuildVideo = false;
        // }
      },
      pages: [
        PageViewModel(
          title: 'Let\'s Vote Help',
          body: 'Swipe to get started!',
          image: _buildImage('IntroductionPage1'),
          decoration: PageDecoration(),
        ),
        PageViewModel(
            title: 'Dates & Deadlines',
            bodyWidget: Text(
              'The Home Page will feature all the important upcoming dates and deadlines in a calendar format',
              style:
                  TextStyle(color: Colors.black, fontSize: 18.0, height: 1.5),
              textAlign: TextAlign.center,
            ),
            image: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/IntroductionPhoto2.jpeg'),
            ),
            decoration: pageDecoration
            //decoration: pageDecoration,
            ),
        PageViewModel(
            decoration: pageDecoration,
            title: "The Ballot Page",
            bodyWidget: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "• Elections, Candidates, and Measures\n• Use ",
                    style: TextStyle(
                        color: Colors.black, fontSize: 18.0, height: 1.5),
                  ),
                  WidgetSpan(
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(
                    text:
                        " to choose candidate.\n• All choices are saved automatically. \n• Use the ",
                    style: TextStyle(
                        color: Colors.black, fontSize: 18.0, height: 1.5),
                  ),
                  WidgetSpan(
                    child: Icon(
                      Icons.autorenew,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(
                    text:
                        " button to refresh your ballot, to account for any recent changes ",
                    style: TextStyle(
                        color: Colors.black, fontSize: 18.0, height: 1.5),
                  ),
                ],
              ),
            ),
            //bodyWidget: Text(
            //    '• Elections, Candidates, and Measures \n • Use ${Icon(Icons.add_circle_outline)} to choose candidate. \n • All your choices are saved automatically.'),
            image: _buildVideo(readyToBuildVideo)),
        PageViewModel(
            decoration: pageDecoration,
            title: "The Voting Page",
            bodyWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    '• Register to Vote (where applicable) \n • View Your Voting Checklist  \n • Find Your Polling Place \n • Check/Update Registration Status',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black, fontSize: 18.0, height: 1.5)),
              ],
            ),
            image: _buildVideo(readyToBuildVideo)),
        PageViewModel(
            decoration: pageDecoration,
            title: "Current Representatives",
            bodyWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '• View all your Current Representatives \n • Organized in order of Federal, State, and Local',
                  style: TextStyle(
                      color: Colors.black, fontSize: 18.0, height: 1.5),
                  // textAlign: TextAlign.center,
                ),
              ],
            ),
            image: _buildVideo(readyToBuildVideo)),
        PageViewModel(
            decoration: pageDecoration,
            title: "Profile & Notifications",
            bodyWidget: Text(
              '• Edit your Address and Party Affiliation  \n• Enable/Disable Notfication Reminders before Upcoming Elections and Deadlines\n• Customize number of days before which notification is showed',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
            image: _buildVideo(readyToBuildVideo)),
        // PageViewModel(
        //     title: 'Help & Feedback',
        //     bodyWidget: RichText(
        //       textAlign: TextAlign.center,
        //       text: TextSpan(
        //         children: [
        //           TextSpan(
        //             text: 'To revist this guide or submit feedback press the ',
        //             style: TextStyle(
        //               color: Colors.black,
        //               fontSize: 18.0,
        //               height: 1.5,
        //             ),
        //           ),
        //           WidgetSpan(
        //             child: Icon(
        //               Icons.help_outline,
        //               size: 24,
        //               color: Colors.blue,
        //             ),
        //           ),
        //           TextSpan(
        //             text: ' button located on the Home Page',
        //             style: TextStyle(
        //                 color: Colors.black, fontSize: 18.0, height: 1.5),
        //           ),
        //         ],
        //       ),
        //     ),
        //     image: Align(
        //       alignment: Alignment.bottomCenter,
        //       child: Image.asset('assets/IntroductionHelp.jpeg'),
        //     ),
        //     decoration: pageDecoration
        //     //decoration: pageDecoration,
        //     ),
        PageViewModel(
          title: 'Feedback or Questions?',
          bodyWidget: Column(
            children: [
              Text('Click the Button Below!'),
              RaisedButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    _launchFeedbackURL();
                  },
                  child: Text(
                    'Click Me',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          image: _buildImage('IntroductionPage1'),
          decoration: PageDecoration(),
        ),
      ],
      onDone: () {
        Navigator.of(context).pop();
      },
      onSkip: () {
        Navigator.of(context).pop();
      },
      skip: Row(
        children: [
          const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      done: Row(
        children: [
          const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      showSkipButton: true,
      showNextButton: false,
    );
  }
}
