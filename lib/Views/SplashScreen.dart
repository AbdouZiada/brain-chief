import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:get/get.dart';
import 'package:lms_flutter_app/Config/app_config.dart';
import 'package:lms_flutter_app/Model/Settings/Languages.dart';
import 'package:lms_flutter_app/Views/MainNavigationPage.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presentation_displays/display.dart';
import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../Service/firebase_remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  final FirebaseRemoteConfigService firebaseRemoteConfigService;

  final SharedPreferences sharedPref;

  const SplashScreen(
      {super.key,
      required this.sharedPref,
      required this.firebaseRemoteConfigService});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOpen = false;
  IosInsecureScreenDetector _insecureScreenDetector =
      IosInsecureScreenDetector();
  bool _isCaptured = false;
  void checkJailbreak() async {
    bool jailbroken = await FlutterJailbreakDetection.jailbroken;
    if (jailbroken) {
      !_isOpen
          ? Get.dialog(
              DialogContent(
                text: 'نعتذر لا يمكن استخدام التطبيق علي جهازك(جهاز غير امن)',
              ),
              barrierDismissible: false,
            ).then((value) => _isOpen = false)
          : null;
      _isOpen = true;
    }
    if (Platform.isAndroid) {
      bool developerMode = await FlutterJailbreakDetection.developerMode;
      if (developerMode) {
        !_isOpen
            ? Get.dialog(
                DialogContent(
                  text: 'يرجي ايقاف وضع المطور لاستخدام التطبيق',
                ),
                barrierDismissible: false,
              ).then((value) => _isOpen = false)
            : null;
        _isOpen = true;
      }
    }
  }

  void forceUpdate() async {
    int build = widget.firebaseRemoteConfigService.getintText();
    String update = widget.firebaseRemoteConfigService.getStringText();

    log(build.toString(), name: 'remote');
    log(update.toString(), name: 'remote');

    if (build < 5) {
      log('yes', name: 'remote');
      await Get.defaultDialog(
        title: "تنبيه",
        middleText: 'يرجي تحديث التطبيق',
        backgroundColor: Colors.teal,
        titleStyle: TextStyle(color: Colors.white),
        middleTextStyle: TextStyle(color: Colors.white),
        radius: 30,

        confirm: ElevatedButton(
            onPressed: () async {
              final _url = Platform.isIOS ? rateAppLinkiOS : rateAppLinkAndroid;
              // ignore: deprecated_member_use
              await canLaunch(_url)
                  // ignore: deprecated_member_use
                  ? await launch(_url)
                  : throw 'Could not launch $_url';
            },
            child: Text(
              'تحديث',
              style: TextStyle(color: Colors.white),
            )),
        onWillPop: () {
          return Future(() => false);
        },

        // barrierDismissible: false,
      );

      // !_isOpen
      //     ? Get.defaultDialog(
      //         title: "تحذير",
      //         middleText: 'يرجي تحديث التطبيق',
      //         backgroundColor: Colors.teal,
      //         titleStyle: TextStyle(color: Colors.white),
      //         middleTextStyle: TextStyle(color: Colors.white),
      //         radius: 30,
      //         onConfirm: () {
      //           log('confirm');
      //         },
      //         onWillPop: () {
      //           return Future(() => false);
      //         },

      //         // barrierDismissible: false,
      //       ).then((value) => _isOpen = false)
      //     : null;
      _isOpen = true;
    }
  }

  void getAllDisplaysPerdoic() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      getAllDisplays();
    });
  }

  void getAllDisplays() async {
    DisplayManager displayManager = DisplayManager();
    List<Display>? displays = await displayManager.getDisplays();

    if ((displays?.length ?? 1) > 1) {
      !_isOpen
          ? Get.dialog(
              DialogContent(
                text: 'لا يمكن استخدام اكتر من شاشة اثناء استخدام التطبيق',
              ),
              barrierDismissible: false,
            ).then((value) => _isOpen = false)
          : null;
      _isOpen = true;
    }
  }

  void screenShotCallBack() {
    !_isOpen
        ? Get.dialog(
            DialogContent(
              text: 'تصوير الشاشة ممنوع لانه يخالف قواعد استخدام \nالتطبيق ',
            ),
            barrierDismissible: false,
          ).then((value) => _isOpen = false)
        : null;
    _isOpen = true;
  }

  void videoRecordingCallBack(bool isrecorderd) {
    !_isOpen
        ? Get.dialog(
            DialogContent(
              text: '  تسجيل الشاشة ممنوع لانه يخالف قواعد استخدام \nالتطبيق',
            ),
            barrierDismissible: false,
          ).then((value) => _isOpen = false)
        : null;
    _isOpen = true;
  }

  String lang = "ar";
  @override
  void initState() {
    _insecureScreenDetector.initialize();
    _insecureScreenDetector.addListener(
        screenShotCallBack, videoRecordingCallBack);

    /// Check if current screen is captured.
    isCaptured();
    Future.delayed(Duration(seconds: 3), () {
      // Get.off(() => MainNavigationPage());
      // languageCode
      checkJailbreak();
      getAllDisplaysPerdoic();
      forceUpdate();

      if (widget.sharedPref.getBool('isSelectedLanguage') != true) {
        Get.off(() => ChooseLanguage());
      } else {
        lang = widget.sharedPref.getString('languageCode') ?? "ar";
        log(lang, name: 'lang');
        stctrl.selectedLanguage.value = Language(code: lang) ?? Language();
        log(stctrl.selectedLanguage.value.code.toString(), name: "lang");
        stctrl.getLanguageSplash(langCode: lang).then((value) async {
          log(Get.locale!.languageCode.toString(), name: "lang");
          await Get.updateLocale(Locale(lang)).then((value) async {
            setState(() {});
            await Get.off(() => MainNavigationPage());
          });
        });
      }
    });
    super.initState();
  }

  isCaptured() async {
    _isCaptured = await _insecureScreenDetector.isCaptured();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: [
            Image.asset(
              'images/$splashLogo',
              width: Get.width,
              height: Get.height,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(child: CupertinoActivityIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogContent extends StatelessWidget {
  final String text;
  const DialogContent({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: WillPopScope(
        onWillPop: () => Future(() => false),
        child: Container(
          width: Get.width,
          height: Get.height,
          color: Colors.teal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'تحذير',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'cairo',
                  fontSize: 24,
                ),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'cairo',
                  fontSize: 16,
                ),
              ),
              Text(
                'يرجي اعادة تشغيل التطبيق لتتمكن من مواصلة استخدامه',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'cairo',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChooseLanguage extends StatefulWidget {
  const ChooseLanguage({super.key});

  @override
  State<ChooseLanguage> createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  void saveselectedLanguage(String code) async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool('isSelectedLanguage', true);
    sharedPref.setString('languageCode', code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 190, 193, 255), Color(0xFFA8D789)],
              // begin: Alignment.topCenter,
              // end: Alignment.bottomCenter,

              begin: Alignment(0.0, 0.0), // Starts above the center
              end: Alignment(0.0, 0.6),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: Get.height * .35,
              ),
              Align(
                alignment: Alignment.center,
                child: Text('اختيار اللغة',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 60)),
              ),
              SizedBox(
                height: Get.height * .03,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        stctrl.selectedLanguage.value =
                            Language(code: 'ar') ?? Language();
                        // stctrl.setLanguage(
                        //     langCode: stctrl.selectedLanguage.value.code);
                        await stctrl.getLanguageSplash(langCode: 'ar');

                        await Get.updateLocale(Locale('ar'));

                        saveselectedLanguage('ar');
                        Get.off(() => MainNavigationPage());
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 226, 228),
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the radius as needed
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'العربية',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 135, 195, 85)),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        stctrl.selectedLanguage.value =
                            Language(code: 'en') ?? Language();
                        // stctrl.setLanguage(
                        //     langCode: stctrl.selectedLanguage.value.code);
                        await stctrl.getLanguageSplash(langCode: 'en');

                        await Get.updateLocale(Locale('en'));
                        saveselectedLanguage('en');
                        Get.off(() => MainNavigationPage());
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 226, 228),
                          borderRadius: BorderRadius.circular(
                              10), // Adjust the radius as needed
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'ENGLISH',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 72, 82, 238)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
