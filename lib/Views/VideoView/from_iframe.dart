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
// }

import 'dart:io';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_webview/fwfh_webview.dart';

class PlayVideoFromIframe extends StatefulWidget {
  final String source;

  const PlayVideoFromIframe({Key? key, required this.source}) : super(key: key);

  @override
  State<PlayVideoFromIframe> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromIframe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Play video from Netwok')),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HtmlWidget(
                    '''

<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="${widget.source}&autoplay=1&title=0&byline=0" style="position:absolute;top:0;left:0;width:100%;height:100%;" frameborder="0" allow="autoplay; fullscreen; " allowfullscreen></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>
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

''',
                    onTapImage: (_) {},
                    onTapUrl: (_) async {
                      return Future.value(false);
                    },
                    factoryBuilder: () => MyWidgetFactory(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 30,
              left: 5,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.cancel, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
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