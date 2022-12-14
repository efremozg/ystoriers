import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/bloc/story/story_bloc.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/services/network_service.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/main/check/check.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

late List<CameraDescription> cameras;
void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  var appData = await AppData.init();
  final PermissionState ps = await PhotoManager.requestPermissionExtend();
  Firebase.initializeApp();
  // appData.logOut();
  // appData.setUserNickname('maximum_charisma');
  // appData.setUser(User(
  //     userId: 68,
  //     userToken:
  //         'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuaWNrbmFtZSI6IlNhcmlrX0FuZHJlYXN5YW4iLCJ0aW1lc3RhbXAiOiIxNjU1OTExODAyLjM0OTQ3MjgifQ.gKP2NVOPxR78e-k1sIk38RZJmzetQFF1LHv3yC0ymw8',
  //     nickName: 'sarik_andreasyan'));
  print(appData.user.userToken);
  appData.openStories(false);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => appData,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ConnectivityResult _connectionStatus = ConnectivityResult.none;
  // final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  late var hasConnection;
  bool hasInternet = true;
  bool wasLost = false;

  @override
  void initState() {
    getConnectivity();
    // checkConnection();
    super.initState();
  }

  getConnectivity() => _subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) async {
        hasConnection = await InternetConnectionChecker().hasConnection;
        var finalResult = result;
        print(hasConnection);
        print(result);
        if (hasConnection == false && finalResult != ConnectivityResult.none) {
          setState(() => wasLost = true);
          StandartSnackBar.showAndDontRemoveUntil(
              context,
              '???????????????? ???????????????? ????????????????????',
              SnackBarStatus.warning(),
              Duration(seconds: 9));
        } else if (wasLost == true &&
            (result != ConnectivityResult.wifi ||
                result != ConnectivityResult.mobile)) {
          StandartSnackBar.show(context, 'C?????????????????? ??????????????????????????',
              SnackBarStatus.internetResultSuccess());
          setState(() => wasLost = false);
        } else if (hasConnection == false &&
            finalResult == ConnectivityResult.none) {
          StandartSnackBar.showAndDontRemoveUntil(
              context,
              '???????????????? ???????????????? ????????????????????',
              SnackBarStatus.warning(),
              Duration(seconds: 9));
        }
      });

  // checkConnection() {
  //   _subscription = Connectivity()
  //       .onConnectivityChanged
  //       .listen((ConnectivityResult result) async {
  //     hasConnection = await InternetConnectionChecker().hasConnection;
  //     hasConnection == false && result != ConnectivityResult.none
  //         ? showDialogBox()
  //         : null;
  //   });
  // }

  // void showDialogBox() {
  //   if (Platform.isIOS) {
  //     showCupertinoDialog<String>(
  //         context: context,
  //         builder: (BuildContext context) => CupertinoAlertDialog(
  //               title: Text('???????????? ??????????????????????'),
  //               content: Text('?????????????????? ???????????????? ??????????????????????'),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {},
  //                   child: Text('OK'),
  //                 )
  //               ],
  //             ));
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (context) {
          return UserBloc();
        }),
        BlocProvider<StoryBloc>(create: (context) {
          return StoryBloc();
        }),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Check(),
        ),
      ),
    );
  }
}
