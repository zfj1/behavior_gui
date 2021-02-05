import 'package:flutter/material.dart';
import 'settings.dart';
import 'api.dart';
import 'videoSection.dart';
// Uncomment lines 7 and 10 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  RigStatusMap.live();
  runApp(MaterialApp(
      home: MyApp(),
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.white,
        primaryColor: Color.fromARGB(255, 50, 50, 50),
        accentColor: Colors.cyan,
        buttonColor: Colors.lightBlue,
        unselectedWidgetColor: Colors.grey,
      )));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        initialData: false,
        future: RigStatusMap.initialized.future,
        builder: (context, snapshot) {
          if (RigStatusMap.initialized.isCompleted) {
            return LoadedApp();
          } else {
            return Scaffold(
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Connecting to python engine...',
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 12))
                ])));
          }
        });
  }
}

class LoadedApp extends StatefulWidget {
  LoadedApp();

  @override
  _LoadedAppState createState() => _LoadedAppState();
}

class _LoadedAppState extends State<LoadedApp> {
  int _updateCount = 0;
  RigStatusMap _rigStatus = RigStatusMap.live();
  bool _isInitialized;
  final TextEditingController _text = TextEditingController();

  @override
  void initState() {
    _isInitialized = _rigStatus['initialization'].current == 'initialized';
    RigStatusMap.onChange.listen((event) => _handleStateChange());
    super.initState();
  }

  void _handleStateChange() {
    setState(() {
      _updateCount += 1;
      _isInitialized = _rigStatus['initialization'].current == 'initialized';
    });
  }

  void _toggleRecord(String rootfilename) {
    //we want to update the state of the status list and the notes when the record button is pushed

    RigStatusMap rigStatus = RigStatusMap();
    rigStatus['recording'].current = (!_rigStatus['recording'].current);
    rigStatus['notes'].current = _text.text;
    rigStatus['rootfilename'].current = rootfilename;
    RigStatusMap.apply(rigStatus);
    _text.text = '';
  }

  void _toggleVideo(bool visible, int index) {
    debugPrint(
        'Attempting to make camera $index ${visible ? "visible" : "invisible"}');
    RigStatusMap rigStatus = RigStatusMap();
    if (index == 4) {
      //TODO: don't love this
      rigStatus['spectrogram'].current['displaying'].current = visible;
    } else {
      rigStatus['camera $index'].current['displaying'].current = visible;
    }
    RigStatusMap.apply(rigStatus);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQueryData _queryData = MediaQuery.of(context);
    Size mediaSize = MediaQuery.of(context).size;
    // double height = mediaSize.height;
    double mainWidth = mediaSize.width * 0.4;
    double mainHeight = mainWidth / 1280 * 1024;
    double padding = 30;
    // double subWidth = mediaSize.width - mainWidth - padding;
    double subHeight = mainHeight / 2;
    double audioHeight = mainHeight - subHeight;

    double textWidth = mediaSize.width * .6;
    double settingsWidth = mediaSize.width - textWidth - padding;

    Color color = Theme.of(context).buttonColor;

    // Widget buttonSection = ButtonSection(color, mainWidth);

    Widget textSection = ListView(
      reverse: true,
      children: [
        TextField(
          controller: _text,
          autofocus: true,
          maxLines: null,
          style: TextStyle(color: color),
        )
      ],
    );

    List<bool> displaying = List<int>.generate(4, (i) => i)
        .map<bool>((index) =>
            _rigStatus['camera $index'].current['displaying'].current)
        .toList();
    displaying.add(_rigStatus['spectrogram'].current['displaying'].current);

    return MaterialApp(
      title: 'Behavior App',
      theme: Theme.of(context),
      home: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: [
            StatusBar(mainWidth, recordCallback: _toggleRecord),
            VideoSection(_isInitialized, mediaSize.width, mainHeight, padding,
                subHeight, audioHeight, _toggleVideo, displaying),
            SizedBox(
                height: 30,
                width: mediaSize.width - 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SESSION NOTES', style: TextStyle(color: color)),
                    Text('SETTINGS PANEL', style: TextStyle(color: color)),
                  ],
                )),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: textWidth,
                  child: textSection,
                ),
                SizedBox(
                  width: settingsWidth,
                  child: SettingsList(),
                ),
              ],
            )),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
