import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/hcmap.dart';
import 'package:here_sdk/consent.dart';

// here stuff
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';


void _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.
  // String accessKeyId = "CUTO1DZzOaVI2hNQihijyQ";
  String accessKeyId = "-kkW7pkaFEal4cSWq7eVxQ";

  // String accessKeySecret =
  //     "WS_itwdUlIZaLkPYjX4LikocEKo6jD3FHuDGkEWGO62hv9gjtHH4gOYCCz8JaSv8YgoLl7NqrAAd9KxhJ7jQEg";
  String accessKeySecret =
      "rvZGAYBu_D-yGNdGaLmdDo9_cvg18UtMng0nsKXckprhPBt7yJMtxtz6Ro4izsaalyIAbFsxCmiokc0SIee4Hw";
  SDKOptions sdkOptions =
      SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}

void main() {
  _initializeHERESDK();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: HereSdkConsentLocalizations.localizationsDelegates,
            // Add supported locales.
            supportedLocales: HereSdkConsentLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'ASAPHere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(resizeToAvoidBottomInset: false, body: CHereMap()),
    );
  }
}
