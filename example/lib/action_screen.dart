import 'dart:async';

import 'package:ad/ad.dart';
import 'package:flutter/material.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  late Ad _ad;

  @override
  void initState() {
    super.initState();
    _ad = Ad();
    initADHandler();
  }

  Future<void> initADHandler() async {
    try {
      await _ad.initGoogleAdMob();
    } on Exception {}

    if (!mounted) return;
  }

  Future<void> showGoogleAdMobVideo(String userId, String adUnitId) async {
    try {
      await _ad.showGoogleAdMobVideo(userId, adUnitId,
          rewardedAdLoadResponseCallback: (value) {
        print('showGoogleAdMobVideo ad: $value');
      });
    } on Exception {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: [
            OutlinedButton(
              onPressed: () async {
                await showGoogleAdMobVideo(
                    'usw', 'ca-app-pub-3940256099942544/5224354917');
              },
              child: const Text('Google Ad 테스트'),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: () async {
                await showGoogleAdMobVideo(
                    'usw', 'ca-app-pub-3940256099942544/5224354917');
              },
              child: const Text('[iOS] Google Ad 테스트'),
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        )),
      ),
    );
  }
}
