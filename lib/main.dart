import 'dart:async';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription =
        Connectivity().onConnectivityChanged.listen(_showInternetConnection);
  }

  void _showInternetConnection(ConnectivityResult result) {
    final hasConnection = result == ConnectivityResult.none;
    hasConnection
        ? StandartSnackBar.show(context, 'Cоединение восстановлено',
            SnackBarStatus.internetResultSuccess())
        : StandartSnackBar.show(
            context, 'Потеряно интернет соединение', SnackBarStatus.warning());
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
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
