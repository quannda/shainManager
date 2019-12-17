import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
// import 'package:the_gorgeous_login/sqllite/fetchdata.dart';
import 'package:the_gorgeous_login/sqllite/database_helper.dart';
import 'package:the_gorgeous_login/sqllite/model/fetchdata.dart';
import 'listtaikin.dart';

import 'dart:math' as math show sin, pi;

class manageEmp extends StatefulWidget {
  @override
  State createState() => manageEmpState();
}

class Data {
  String ymdworkData;
  String enterwork;
  String outwork;
  Data({this.ymdworkData,this.enterwork,this.outwork});
    
  }

class manageEmpState extends State<manageEmp> {

var db = new DatabaseHelper();
  String _connectionStatus = 'Unknown';
  String idwifi = '';
  String imgdirenter = 'assets/img/enter.gif';
  String imgdirout = 'assets/img/out.gif';
  var enterbutton = false;
  var outbutton = false;
  var datetimenow;
  var nowhourenter = '';
  var nowminuenter = '';
  var nowhourout = '';
  var nowminuout = '';
  var nowWorkenter = '';
  var nowWorkout = '';
  String nowyear = '';
  String nowmonth = '';
  String nowday = '';
  String ymdWork = '';
  String stringalldatetimeSavedEnter = '';
  String stringalldatetimeNowEnter = '';
  String stringalldatetimeSavedOut = '';
  String stringalldatetimeNowOut = '';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // model.createDB();
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('勤怠'),
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red)),
            color: Colors.yellowAccent,
            child: Text('勤怠一覧'),
            onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => listtaikin()));
              
            },
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height >= 775.0
                    ? MediaQuery.of(context).size.height
                    : 775.0,
        child: _goingtoWork(context)),
    );
  }



  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
          idwifi = wifiIP;
        });

        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
          idwifi = result.toString();
        });
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  Widget showimg(imgdir) {
    return Container(
      height: 350.0,
      width: 350.0,
      child: Image.asset(imgdir),
    );
  }

  Widget _workingcheck(sldata) {
    if(sldata !=null){
      var todaydatetime = nowyear + nowmonth + nowday;
      print('this is confirm compare datetime ' + sldata.length.toString());
      for(var data in sldata){
        if (data.ymdWork == todaydatetime && data.nowWorkout != '') {
          setState(() {
                      enterbutton = true;
          outbutton = true;
          imgdirout = data.imgdirout;
          nowWorkenter = data.nowWorkenter;
          nowWorkout = data.nowWorkout;
            
          });
        }
      }
    }

  }
  Widget _goingtoWork(BuildContext context) {
    datetimenow = new DateTime.now();
    nowyear = datetimenow.year.toString();
    nowmonth = (datetimenow.month < 10 ? '0' + datetimenow.month.toString() : datetimenow.month.toString());
    nowday = (datetimenow.day < 10 ? '0' + datetimenow.day.toString() : datetimenow.day.toString());

    ymdWork = nowyear + nowmonth + nowday;
    // _getsharedPreEnterbutton();
    // _getsharedPreOutbutton(); 
    // scenes wifi ip android : 192.168.8.82
    // scenes wifi ip ios : 192.168.8.113
    // home my wifi ip : 172.20.10.11
    print('ip wifi day ne '  + idwifi.toString());
    if (idwifi == idwifi) {
      print('aaaa');
      if(outbutton != true){
        db.getManager().then((results){
        print(results);
          for(var result in results){
            if(ymdWork == result.ymdWork){
              _workingcheck(results);
            }
          }
      });
      }
      // _workingcheck(model.itemListing.length != 0 ? model.itemListing : null);
      return Container(
        child: Column(
        // mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          showimg(enterbutton == true
              ? (outbutton == true ? imgdirout : imgdirenter)
              : ''),
          Container(
            width: MediaQuery.of(context).size.width-120.0,
            padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ProgressButton(
                  color: Colors.greenAccent,
                  defaultWidget: const Text('出勤'),
                  progressWidget: ThreeSizeDot(
                    color_1: Colors.black54,
                    color_2: Colors.black54,
                    color_3: Colors.black54,
                  ),
                  width: 114,
                  height: 48,
                  borderRadius: 5,
                  animate: false,
                  onPressed: enterbutton
                      ? null
                      : () async {
                          int score = await Future.delayed(
                              const Duration(milliseconds: 1000), () => 42);
                          setState(() {
                            datetimenow = new DateTime.now();
                            enterbutton = !enterbutton;
                            
                            nowhourenter = (datetimenow.hour < 10
                                    ? '0' + datetimenow.hour.toString() + '時'
                                    : datetimenow.hour.toString()) +
                                '時';
                            nowminuenter = (datetimenow.minute < 10
                                ? '0' + datetimenow.minute.toString() + '分'
                                : datetimenow.minute.toString() + '分');
                            nowWorkenter = nowhourenter + nowminuenter;
                            // _setSharedPreEnterbutton();
                          });
                        },
                ),
                // SizedBox(width: 20.0,),
                ProgressButton(
                  color: Colors.greenAccent,
                  defaultWidget: const Text('退勤'),
                  progressWidget: ThreeSizeDot(
                    color_1: Colors.black54,
                    color_2: Colors.black54,
                    color_3: Colors.black54,
                  ),
                  width: 114,
                  height: 48,
                  borderRadius: 5,
                  animate: false,
                  onPressed: outbutton
                      ? null
                      : () async {
                          int score = await Future.delayed(
                              const Duration(milliseconds: 1000), () => 42);
                          setState(() {
                            datetimenow = new DateTime.now();
                            outbutton = !outbutton;
                            
                            nowhourout = (datetimenow.hour < 10
                                    ? '0' + datetimenow.hour.toString() + '時'
                                    : datetimenow.hour.toString()) +
                                '時';
                            nowminuout = (datetimenow.minute < 10
                                ? '0' + datetimenow.minute.toString() + '分'
                                : datetimenow.minute.toString() + '分');
                            nowWorkout = nowhourout + nowminuout;
                            // _setSharedPreOutbutton();
                            var db = new DatabaseHelper();
                            var setdata = FetchDatafromSQLite(ymdWork,enterbutton,outbutton,imgdirenter,imgdirout, nowWorkenter, nowWorkout);
                            db.insertManager(setdata);                        
                          });
                        },
                ),
              ],
            ),
          ),
          timeToWork(nowWorkenter, nowWorkout)
        ],
      ),
      );
    } else {
      return Text('会社のネットに接続してください');
    }
  }

  Widget timeToWork(nowWorkenter, nowWorkout) {
    return Column(
      children: <Widget>[
        Container(
          decoration: myBoxDecoration(),
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width - 100.0,
            padding: EdgeInsets.only(top: 15.0),
            child: Text(
              '本日、$nowyear年$nowmonth月$nowday日',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  left: 80.0, top: 10.0, bottom: 10.0, right: 10.0),
              child: Text('出勤の時間　：    ' + nowWorkenter),
            ),
            Container()
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  left: 80.0, top: 10.0, bottom: 10.0, right: 10.0),
              child: Text('退勤の時間　：    ' + nowWorkout),
            ),
            Container()
          ],
        ),
      ],
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }

  // _setSharedPreEnterbutton() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   stringalldatetimeSavedEnter = nowyear + nowmonth + nowday;
  //   pref.setBool('enterbutton', enterbutton);
  //   pref.setString('imgdirenter', imgdirenter);
  //   pref.setString('nowhourenter', nowhourenter);
  //   pref.setString('nowminuenter', nowminuenter);
  //   pref.setString('stringalldatetimeSavedEnter', stringalldatetimeSavedEnter);
  // }

  // _getsharedPreEnterbutton() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   stringalldatetimeSavedEnter = pref.getString('stringalldatetimeSavedEnter');

  //   stringalldatetimeNowEnter = nowyear + nowmonth + nowday;
  //   if (stringalldatetimeNowEnter != stringalldatetimeSavedEnter) {
  //     pref.remove('enterbutton');
  //     pref.remove('imgdirenter');
  //     pref.remove('nowhourenter');
  //     pref.remove('nowminuenter');
  //   } else if (pref.getBool('enterbutton') == true) {
  //     enterbutton = pref.getBool('enterbutton');
  //     imgdirenter = pref.getString('imgdirenter');
  //     nowhourenter = pref.getString('nowhourenter');
  //     nowminuenter = pref.getString('nowminuenter');
  //   }
  // }

  // _setSharedPreOutbutton() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   stringalldatetimeSavedOut = nowyear + nowmonth + nowday;
  //   pref.setBool('outbutton', outbutton);
  //   pref.setString('imgdirout', imgdirout);
  //   pref.setString('nowhourout', nowhourout);
  //   pref.setString('nowminuout', nowminuout);
  //   pref.setString('stringalldatetimeSavedOut', stringalldatetimeSavedOut);
  // }

  // _getsharedPreOutbutton() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();

  //   stringalldatetimeSavedOut = pref.getString('stringalldatetimeSavedOut');

  //   stringalldatetimeNowOut = nowyear + nowmonth + nowday;
  //   if (stringalldatetimeNowOut != stringalldatetimeSavedOut) {
  //     pref.remove('outbutton');
  //     pref.remove('imgdirout');
  //     pref.remove('nowhourout');
  //     pref.remove('nowminuout');
  //   } else if (pref.getBool('outbutton') == true) {
  //     outbutton = pref.getBool('outbutton');
  //     imgdirout = pref.getString('imgdirout');
  //     nowhourout = pref.getString('nowhourout');
  //     nowminuout = pref.getString('nowminuout');
  //   }
  // }
}

class ThreeSizeDot extends StatefulWidget {
  ThreeSizeDot(
      {Key key,
      this.shape = BoxShape.circle,
      this.duration = const Duration(milliseconds: 1000),
      this.size = 8.0,
      this.color_1,
      this.color_2,
      this.color_3,
      this.padding = const EdgeInsets.all(2)})
      : super(key: key);

  final BoxShape shape;
  final Duration duration;
  final double size;
  final Color color_1;
  final Color color_2;
  final Color color_3;
  final EdgeInsetsGeometry padding;

  @override
  _ThreeSizeDotState createState() => _ThreeSizeDotState();
}

class _ThreeSizeDotState extends State<ThreeSizeDot>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation_1;
  Animation<double> animation_2;
  Animation<double> animation_3;


  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    animation_1 = DelayTween(begin: 0.0, end: 1.0, delay: 0.0)
        .animate(animationController);
    animation_2 = DelayTween(begin: 0.0, end: 1.0, delay: 0.2)
        .animate(animationController);
    animation_3 = DelayTween(begin: 0.0, end: 1.0, delay: 0.4)
        .animate(animationController);
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScaleTransition(
            scale: animation_1,
            child: Padding(
              padding: widget.padding,
              child: Dot(
                shape: widget.shape,
                size: widget.size,
                color:
                    widget.color_1 ?? Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          ScaleTransition(
            scale: animation_2,
            child: Padding(
              padding: widget.padding,
              child: Dot(
                shape: widget.shape,
                size: widget.size,
                color:
                    widget.color_2 ?? Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          ScaleTransition(
            scale: animation_3,
            child: Padding(
              padding: widget.padding,
              child: Dot(
                shape: widget.shape,
                size: widget.size,
                color:
                    widget.color_3 ?? Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final BoxShape shape;
  final double size;
  final Color color;

  Dot({
    Key key,
    this.shape,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: shape),
      ),
    );
  }
}

class DelayTween extends Tween<double> {
  DelayTween({
    double begin,
    double end,
    this.delay,
  }) : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
