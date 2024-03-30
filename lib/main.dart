import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/index.html');
}

Future<String> loadAsset2(name) async {
  print('it is assets$name');
  return await rootBundle.loadString('assets$name');
}

Future<dynamic> loadAsset3(name) async {
  ByteData imageData = await rootBundle.load('assets$name');
  return imageData.buffer.asUint8List();
}

List<String> getContentType(uri) {
  if (uri.endsWith(".ico")) {
    return ["image", "x-icon"];
  } else if (uri.endsWith(".js")) {
    return ["application", "javascript"];
  } else if (uri.endsWith(".css")) {
    return ["text", "css"];
  } else if (uri.endsWith(".json")) {
    return ["application", "json"];
  } else if (uri.endsWith(".png")) {
    return ["image", "png"];
  } else if (uri.endsWith(".svg")) {
    return ["image", "svg+xml"];
  } else if (uri.endsWith(".jpg")) {
    return ["image", "jpeg"];
  } else {
    return ["text", "plain"];
  }
}

var server;

startServer() async {
  server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
  print("Server running on IP : " +
      server.address.toString() +
      " On Port : " +
      server.port.toString());
  await for (var request in server) {
    debugPrint("GOT REQUEST ${request.uri.toString()}");
    // print(content);
    var content = await loadAsset();
    if (request.uri.toString() == "/" ||
        request.uri.toString().startsWith("/water") ||
        request.uri.toString().startsWith("/maps")) {
      request.response
        ..headers.contentType = ContentType("text", "html", charset: "utf-8")
        ..write(content)
        ..close();
    } else {
      var contentTypeInfo = getContentType(request.uri.toString());
      print(contentTypeInfo);

      if (request.uri.toString().endsWith('.png') ||
          request.uri.toString().endsWith('.ico') ||
          request.uri.toString().endsWith('.svg') ||
          request.uri.toString().endsWith('.jpg')) {
        var content3 = await loadAsset3(request.uri.toString());
        request.response
          ..headers.contentType = ContentType(
              contentTypeInfo[0], contentTypeInfo[1],
              charset: "utf-8")
          ..add(content3)
          ..close();
      } else {
        var content3 = await loadAsset2(request.uri.toString());
        request.response
          ..headers.contentType = ContentType(
              contentTypeInfo[0], contentTypeInfo[1],
              charset: "utf-8")
          ..write(content3)
          ..close();
      }
    }
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  startServer();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  String navURI = "http://localhost:3000";
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // detect Android back button click
        final controller = webViewController;
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("InAppWebView test"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri(navURI)),
                initialSettings: InAppWebViewSettings(
                    allowsBackForwardNavigationGestures: true),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      navURI = "http://localhost:3000";
                      webViewController?.loadUrl(
                          urlRequest: URLRequest(url: WebUri(navURI)));
                    });
                  },
                  child: Text("home"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      navURI =
                          "http://127.0.0.1:3000/water?geoserver_url=https://geoserver.gramvaani.org:8443&block_pkey=null&app_name=nrmApp&dist_name=Angul&block_name=Angul";

                      webViewController?.loadUrl(
                          urlRequest: URLRequest(url: WebUri(navURI)));
                    });
                  },
                  child: Text("water"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
