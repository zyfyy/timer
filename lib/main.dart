import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock/wakelock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 保持常亮
    Wakelock.enable();
    return MaterialApp(
      title: 'Timmer For Yaaap',
      theme: ThemeData(
          primaryColor: Color.fromRGBO(62, 64, 61, 1.0),
          primarySwatch: Colors.deepOrange,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          primaryColor: Colors.black26,
          primarySwatch: Colors.deepOrange,
          brightness: Brightness.light),
      home: MyHomePage(title: 'Time is Money'),
      routes: {
        '/timer': (context) => MyTimer(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const d_timeout = const Duration(seconds: 30);
const d_duration = const Duration(seconds: 1);

void handleTimeout() {
  // callback function
}

class _MyHomePageState extends State<MyHomePage> {
  String timer = '0:0:0';
  Duration _timer = new Duration();

  Widget time() {
    return CupertinoTimerPicker(
      mode: CupertinoTimerPickerMode.hms,
      minuteInterval: 1,
      secondInterval: 1,
      initialTimerDuration: _timer,
      onTimerDurationChanged: (Duration ct) {
        setState(() {
          _timer = ct;
          timer = _timer.toString().split(".")[0];
        });
      },
    );
  }

  _selectTimer() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: time());
        });
  }

  _startTimer() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SecondRoute()));
    Navigator.pushNamed((context), '/timer',
        arguments: MyTimerArguments(_timer));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: _selectTimer,
              child: Text(
                '$timer',
                style: Theme.of(context).textTheme.display1,
              ),
            ),
            Padding(padding: EdgeInsets.all(16.0)),
            FloatingActionButton(
              onPressed: _startTimer,
              child: Icon(Icons.play_arrow),
            )
          ],
        ),
      ),
    );
  }
}

class MyTimerArguments {
  final Duration timer;

  MyTimerArguments(this.timer);
}

class MyTimer extends StatefulWidget {
  @override
  _MyTimer createState() => _MyTimer();
}

class _MyTimer extends State<MyTimer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    t.cancel();
    super.dispose();
  }

  Timer t;
  String txt = '';

  _setupTimer(du) {
    DateTime lastT = DateTime.now().add(du).add(Duration(seconds: 1));
    if (t != null) {
      return;
    }

    t = Timer.periodic(Duration(seconds: 1), (timer) {
      if (lastT.compareTo(DateTime.now()) < 0) {
        // print('cancel');
        t.cancel();
        return;
      }

      String res = lastT.difference(DateTime.now()).toString().split(".")[0];
      // print(res);
      setState(() {
        txt = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final MyTimerArguments args = ModalRoute.of(context).settings.arguments;
    _setupTimer(args.timer);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(60.0),
          child: AutoSizeText(
            '$txt',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 960,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            maxLines: 1,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
