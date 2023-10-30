// import 'dart:io';

// // import 'package:flutter_html_iframe/flutter_html_iframe.dart';
// import 'package:fwfh_webview/fwfh_webview.dart' as view;
// import 'package:get/get.dart';
// import 'package:pod_player/pod_player.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// // import 'package:flutter_html/flutter_html.dart';

// class PlayVideoFromIframe extends StatefulWidget {
//   final String source;

//   const PlayVideoFromIframe({Key? key, required this.source}) : super(key: key);

//   @override
//   State<PlayVideoFromIframe> createState() => _PlayVideoFromAssetState();
// }

// class _PlayVideoFromAssetState extends State<PlayVideoFromIframe> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Play video from Netwok')),
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             children: [
// //                   Platform.isAndroid
// //                       ? Html(
// //                           data: """
// //   <video controls>
// //     <source src="https://www.w3schools.com/html/mov_bbb.mp4" />
// //   </video>
// // """,
// //                         )
// //                       : Html(
// //                           data: """

// //   <iframe src="https://www.w3schools.com/html/mov_bbb.mp4"></iframe>""",
// //                           extensions: [
// //                               IframeHtmlExtension(),
// //                             ]),

//               // SizedBox(
//               //   height: 400,
//               //   width: 400,
//               //   child: WebView(
//               //     initialUrl:
//               //         'https://player.vimeo.com/video/389509769?h=8aa99660c3',
//               //     javascriptMode: JavascriptMode
//               //         .unrestricted, // or JavascriptMode.minimal, or JavascriptMode.disabled
//               //   ),
//               // ),
//               // Container(
//               //     height: 400,
//               //     width: 400,
//               //     child: WebView(
//               //       initialUrl: Uri.dataFromString(
//               //               '<html><body><iframe src="https://player.vimeo.com/video/389509769?h=8aa99660c3"></iframe></body></html>',
//               //               mimeType: 'text/html')
//               //           .toString(),
//               //       javascriptMode: JavascriptMode.unrestricted,
//               //     )),
//               SizedBox(
//                 height: 400,
//                 width: 400,
//                 child: view.WebView(
//                   'https://player.vimeo.com/video/389509769?h=8aa99660c3',
//                   aspectRatio: 3 /
//                       4, // or JavascriptMode.minimal, or JavascriptMode.disabled
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void snackBar(String text) {
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(text),
//         ),
//       );
//   }
//
//
//                   widget.source.contains("<iframe")?
//                   HtmlWidget(
//                     '''
//
// ${widget.source}
// <script>
//
// document.addEventListener("webkitplaybacktargetavailabilitychanged", function(event) {
//     if (event.webkitPlaybackTargetAvailability === "available") {
//         var iframe = document.querySelector("iframe");
//         if (iframe) {
//             iframe.parentNode.removeChild(iframe);
//         }
//     } else {
//
//     }
// });
//
// </script>
//
// ''',
//                     onTapImage: (_) {},
//                     onTapUrl: (_) async {
//                       return Future.value(false);
//                     },
//                     factoryBuilder: () => MyWidgetFactory(),
//                   ):  HtmlWidget(
//                     '''
// <iframe src="${widget.source}" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" style="position:absolute;top:0;left:0;width:100%;height:100%;" title="Best of Dolby Vision 12K HDR 120fps"></iframe>
//
// <script>
//
// document.addEventListener("webkitplaybacktargetavailabilitychanged", function(event) {
//     if (event.webkitPlaybackTargetAvailability === "available") {
//         var iframe = document.querySelector("iframe");
//         if (iframe) {
//             iframe.parentNode.removeChild(iframe);
//         }
//     } else {
//
//     }
// });
//
// </script>
//
// ''',
//                     onTapImage: (_) {},
//                     onTapUrl: (_) async {
//                       return Future.value(false);
//                     },
//                     factoryBuilder: () => MyWidgetFactory(),
//                   ),
//
// }


import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/parsing.dart' as parser;
import '../../Config/app_config.dart';

class PlayVideoFromIframe extends StatefulWidget {
  final String source;

  const PlayVideoFromIframe({Key? key, required this.source}) : super(key: key);

  @override
  State<PlayVideoFromIframe> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromIframe> {
  static const platform = MethodChannel('com.brainchief/isAirPlayActive');
  Timer? airplay;
  final GlobalKey webViewKey = GlobalKey();
  late final PodPlayerController controller;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
if (  widget.source.contains("www.youtube"))  {
 // final htmlDocument = parser.parseHtmlDocument
 final htmlDocument = parser.parseHtmlDocument(
      '${widget.source.toString()}');
//log(widget.source);
  log('GETTTEEE${(htmlDocument.getElementsByTagName('iframe').first as html.IFrameElement).src}');


   //   var ytb = (str.substring(startIndex + start.length, endIndex)); // https:/
var ytb = (htmlDocument.getElementsByTagName('iframe').first as html.IFrameElement).src;
  controller = PodPlayerController(
    playVideoFrom: PlayVideoFrom.youtube(ytb!),
    podPlayerConfig: const PodPlayerConfig(
      videoQualityPriority: [720, 360],
      autoPlay: false,
    ),
  )
    ..initialise();
}

if( widget.source.contains("player.vimeo.com")){

  LoadVimeo();
}

    // url = "https://player.vimeo.com/video/424478670";
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    getAllDisplaysPerdoic();
  }
void LoadVimeo() async{
 // final urls = await PodPlayerController.getVimeoUrls('518228118');
 // setState(() => isLoading = false);

  final htmlDocument = parser.parseHtmlDocument(
      '${widget.source.toString()}');
//log(widget.source);
  log('GETTTEEE${(htmlDocument.getElementsByTagName('iframe').first as html.IFrameElement).src}');


  var str ='${(htmlDocument.getElementsByTagName('iframe').first as html.IFrameElement).src}';
  const start = 'video/';
  const end = '?';

  final startIndex = str.indexOf(start);
  final endIndex = str.indexOf(end, startIndex + start.length);
  var vim = (str.substring(startIndex + start.length, endIndex));

  controller = PodPlayerController(
    playVideoFrom: PlayVideoFrom.vimeo(vim),
    podPlayerConfig: const PodPlayerConfig(
      videoQualityPriority: [360],
    ),
  )..initialise();


  }
  Future<void> _getairplayLevel() async {
    String airplayStatus = '';
    log(airplayStatus, name: 'getAirplayStatus');

    try {
      bool? result = await platform.invokeMethod<bool>('getAirplayStatus');
      airplayStatus = 'airplay is $result % .';
      log(airplayStatus, name: 'getAirplayStatus');
      if (result ?? false) {
        stctrl.dashboardController.updateStatus(false).then((value) async {
          await stctrl.dashboardController.removeToken('token');
        });
        exit(0);
      }
    } on PlatformException catch (e) {
      airplayStatus = "Failed to get airplayStatus: '${e.message}'.";
      log(airplayStatus, name: 'airplayStatus');
    }
  }

  void getAllDisplaysPerdoic() {
    airplay = Timer.periodic(Duration(seconds:2), (timer) {
      _getairplayLevel();
      getAllDisplays();
    });
  }

  void getAllDisplays() async {
    DisplayManager displayManager = DisplayManager();
    List<Display>? displays = await displayManager.getDisplays();

    if ((displays?.length ?? 1) > 1) {
      stctrl.dashboardController.updateStatus(false).then((value) async {
        await stctrl.dashboardController.removeToken('token');
      });
      exit(0);
      //displayManager.transferDataToPresentation(" test transfer data ");
    }


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
controller.dispose();

    airplay?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Play video from Netwok')),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {

       return Stack(
          children: [
            Center(
                child:Container(child:
            widget.source.contains("www.youtube") ?   PodVideoPlayer(
              controller: controller,
             // videoThumbnail: const DecorationImage(
               // image: NetworkImage(
                 // 'https://images.unsplash.com/photo-1569317002804-ab77bcf1bce4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dW5zcGxhc2h8ZW58MHx8MHx8&w=1000&q=80',
                // ),
                //fit: BoxFit.cover,
             // ),
            ):  widget.source.contains("player.vimeo.com") ?Container(
child      :  PodVideoPlayer(
  controller: controller,
  // videoThumbnail: const DecorationImage(
  //   image: NetworkImage(
  //     'https://images.unsplash.com/photo-1569317002804-ab77bcf1bce4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dW5zcGxhc2h8ZW58MHx8MHx8&w=1000&q=80',
  //   ),
  //   fit: BoxFit.cover,
  // ),
)  ,

            ):  InAppWebView(
                  key: webViewKey,
                  initialData: InAppWebViewInitialData(data:
                  '''
                                      <style>
                                      iframe{
                                      width:100%;
                                 height:100%;
                                 broder:none;
                                 padding:0;
                                 margin:0;
                                      } 
                                      </style>      
 ${widget.source}
 <script>
 
 document.addEventListener("webkitplaybacktargetavailabilitychanged", function(event) {
     if (event.webkitPlaybackTargetAvailability === "available") {
         var iframe = document.querySelector("iframe");
         if (iframe) {
             iframe.parentNode.removeChild(iframe);
         }
     } else {
      
     }
 });
 
 </script>

                      
                      ''',encoding: "utf-8",mimeType: "text/html"),
                  initialOptions: options,
                  pullToRefreshController:
                  pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action:
                        PermissionRequestResponseAction
                            .GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri?.scheme)) {
                      // ignore: deprecated_member_use

                      // and cancel the request

                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                  },
                  onLoadError:
                      (controller, url, code, message) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController
                          ?.endRefreshing();
                    }

                  },
                  onUpdateVisitedHistory:
                      (controller, url, androidIsReload) {

                  },
                  onConsoleMessage:
                      (controller, consoleMessage) async {

                  },
                  onCloseWindow: (controller) {},
                ),
                  height: 240,)

            ),



            Positioned(
              top: 30,
              left: 5,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.cancel, color: Colors.white),
              ),
            )


          ],
        );
        }else {
        return Stack(
          children: [

        widget.source.contains("www.youtube") ?   PodVideoPlayer(
          controller: controller,
          videoThumbnail: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1569317002804-ab77bcf1bce4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dW5zcGxhc2h8ZW58MHx8MHx8&w=1000&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ):  widget.source.contains("player.vimeo.com") ?Container(
          child      :  PodVideoPlayer(
            controller: controller,
            videoThumbnail: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1569317002804-ab77bcf1bce4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dW5zcGxhc2h8ZW58MHx8MHx8&w=1000&q=80',
              ),
              fit: BoxFit.cover,
            ),
          )  ,

        ):

          InAppWebView(
            key: webViewKey,
            initialData: InAppWebViewInitialData(data:
            '''
            
                                      <style>
                                      iframe{
                                      width:100%;
                                 height:100%;
                                border:none; 
                                      } 
                                      </style>      
 ${widget.source}
 <script>
 
 document.addEventListener("webkitplaybacktargetavailabilitychanged", function(event) {
     if (event.webkitPlaybackTargetAvailability === "available") {
     
     
         var iframe = document.querySelector("iframe");
          
         
     } else {
      
     }
 });
 
 </script>

                      
                      ''', encoding: "utf-8", mimeType: "text/html"),
            initialOptions: options,
            pullToRefreshController:
            pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {},
            androidOnPermissionRequest:
                (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action:
                  PermissionRequestResponseAction
                      .GRANT);
            },
            shouldOverrideUrlLoading:
                (controller, navigationAction) async {
              var uri = navigationAction.request.url;

              if (![
                "http",
                "https",
                "file",
                "chrome",
                "data",
                "javascript",
                "about"
              ].contains(uri?.scheme)) {
                // ignore: deprecated_member_use

                // and cancel the request

              }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              pullToRefreshController?.endRefreshing();
            },
            onLoadError:
                (controller, url, code, message) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController
                    ?.endRefreshing();
              }
            },
            onUpdateVisitedHistory:
                (controller, url, androidIsReload) {

            },
            onConsoleMessage:
                (controller, consoleMessage) async {

            },
            onCloseWindow: (controller) {},

          ),


            Positioned(
              top: 29,
              left: 4,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.cancel, color: Colors.black),
              ),
            )


          ],
        );
      }})));

  }

  void snackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }
}

class MyWidgetFactory extends WidgetFactory with WebViewFactory {}
