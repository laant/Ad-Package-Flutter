import 'dart:async';

import 'package:ad/ad.dart' as hn_ad;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  late hn_ad.Ad _ad;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();
    _ad = hn_ad.Ad();
    initADHandler();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _ad.todayBannerLoadAD(
        'ca-app-pub-3940256099942544/9214589741',
        AdManagerBannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              adLoaded = true;
            });
            print('Ad loaded: $ad');
          },
          onAdFailedToLoad: (ad, error) {
            print('Ad failed to load: $error');
            ad.dispose();
          },
        ),
      );
    });
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
            adLoaded
                ? FullWidthBannerAd(
                    bannerAd: _ad.todayTopBannerAd, sidePadding: 10.0)
                : Container(),
          ],
        )),
      ),
    );
  }
}

class FullWidthBannerAd extends StatelessWidget {
  final AdManagerBannerAd? bannerAd;
  final double sidePadding;

  const FullWidthBannerAd(
      {super.key, required this.bannerAd, this.sidePadding = 0});

  @override
  Widget build(BuildContext context) {
    if (bannerAd != null) {
      return SizedBox(
          width: MediaQuery.of(context).size.width - sidePadding * 2,
          height: bannerAd!.sizes.first.height.toDouble(),
          child: AdWidget(ad: bannerAd!));
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }
}
