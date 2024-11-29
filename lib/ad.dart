import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef RewardedAdLoadResponseCallback = Function(String adResponseData);
typedef GoogleAdLoadCallback = void Function(bool isAdLoaded);

class Ad {
  Ad._privateConstructor();
  static final Ad _instance = Ad._privateConstructor();

  factory Ad() {
    return _instance;
  }

  Future<void> initGoogleAdMob() async {
    final List<String> _testDevices = [
      "C7D2C570CD1BD5997B159AA62BD006C1",
      "420fbca823697fba5723f543792e0001",
      "F0F3DE456DA8EED6557343A80FCAA6F6",
      "6803B83B27010C7F517608BFD122E056",
      "9C773578446D3F52E99DCEEF66D524D5",
      "81c8fd26f9fee909769a3a197487b3f5",
    ];

    if (kReleaseMode) {
      MobileAds.instance.initialize();
    } else if (kDebugMode) {
      MobileAds.instance.initialize().then((value) {
        MobileAds.instance.updateRequestConfiguration(
            RequestConfiguration(testDeviceIds: _testDevices));
      });
    }
  }

  Future<void> showGoogleAdMobVideo(
    String userId,
    String adUnitId, {
    GoogleAdLoadCallback? googleAdLoadCallback,
    RewardedAdLoadResponseCallback? rewardedAdLoadResponseCallback,
  }) async {
    String code = '';
    int startAt = 0;
    int endAt = 0;
    DateTime startDateTime = DateTime.now();
    startAt = startDateTime.millisecondsSinceEpoch;
    try {
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ServerSideVerificationOptions options =
                ServerSideVerificationOptions(
                    userId: userId, customData: '$startAt');
            ad.setServerSideOptions(options);
            googleAdLoadCallback?.call(true);
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (code == 'SUCCESS') {
                  // 광고 reward 지급 됬을 경우
                  disposeGoogleAd(code, startAt, endAt,
                      rewardedAdLoadResponseCallback: (value) =>
                          rewardedAdLoadResponseCallback?.call(value));
                }
              },
              onAdFailedToShowFullScreenContent: (_, err) {
                googleAdLoadCallback?.call(false);
                code = parseErrorCode(err);
                DateTime endDateTime = DateTime.now();
                endAt = endDateTime.millisecondsSinceEpoch;
                disposeGoogleAd(code, startAt, endAt,
                    rewardedAdLoadResponseCallback: (value) =>
                        rewardedAdLoadResponseCallback?.call(value));
                print(
                    '[Ad] Failed to ShowFullScreenContent ad: ${err.message}');
              },
            );
            ad.show(onUserEarnedReward: (_, reward) async {
              code = 'SUCCESS';
              DateTime endDateTime = DateTime.now();
              endAt = endDateTime.millisecondsSinceEpoch;
              print('[Ad] reward : ${reward.amount}');
            });
          },
          onAdFailedToLoad: (err) {
            googleAdLoadCallback?.call(false);
            code = parseErrorCode(err);
            DateTime endDateTime = DateTime.now();
            endAt = endDateTime.millisecondsSinceEpoch;
            disposeGoogleAd(code, startAt, endAt,
                rewardedAdLoadResponseCallback: (value) =>
                    rewardedAdLoadResponseCallback?.call(value));
            print('[Ad] Failed to load a rewarded ad: ${err.message}');
          },
        ),
      );
    } catch (e) {
      print('[Ad] GoogleAdMobVideo: $e');
    }
  }

  Future<void> disposeGoogleAd(
    String code,
    int startAt,
    int endAt, {
    RewardedAdLoadResponseCallback? rewardedAdLoadResponseCallback,
  }) async {
    final jsonString = ADData.toJson(code, startAt, endAt);
    rewardedAdLoadResponseCallback?.call(jsonString);
  }

  String parseErrorCode(AdError error) {
    String errorCode = '';
    if (Platform.isAndroid) {
      switch (error.code) {
        case 0:
          // (광고) 서버 에러
          errorCode = 'SERVER_ERROR';
          break;
        case 2:
          // 네트워크 에러
          errorCode = 'NETWORK_ERROR';
          break;
        case 3:
        case 9:
          // 요청은 성공, 광고는 없음
          errorCode = 'NO_ADS';
          break;
        default:
          // (광고) 요청 에러
          errorCode = 'REQUEST_ERROR';
          break;
      }
    } else if (Platform.isIOS) {
      switch (error.code) {
        case 3:
        case 8:
        case 11:
          // (광고) 서버 에러
          errorCode = 'SERVER_ERROR';
          break;
        case 2:
          // 네트워크 에러
          errorCode = 'NETWORK_ERROR';
          break;
        case 1:
        case 9:
        case 13:
          // 요청은 성공, 광고는 없음
          errorCode = 'NO_ADS';
          break;
        default:
          // (광고) 요청 에러
          errorCode = 'REQUEST_ERROR';
          break;
      }
    }
    return errorCode;
  }
}

class ADData {
  ADData(this.code, this.startAt, this.endAt);

  final String code;
  final String startAt;
  final String endAt;

  static ADData fromDataList(List<dynamic> data) {
    print('AD_DATA -----------------------------------------------');
    print('AD_CODE' + data[0]!);
    print('AD_START_TIME' + data[1]!);
    print('AD_END_TIME' + data[2]!);
    print('AD_DATA -----------------------------------------------');
    return ADData(data[0]!, data[1]!, data[2]!);
  }

  static String toJson(String code, int startAt, int endAt) {
    Map<String, dynamic> adData = {
      'errorCode': code,
      'startAt': startAt,
      'endAt': endAt,
    };
    return json.encode(adData);
  }
}
