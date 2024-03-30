import 'dart:typed_data';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
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

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String statusText = "Start Server";
  String address = "";
  var controller;

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

  startServer() async {
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);

    setState(() {
      statusText =
          "Starting server on Port : $server.address.toString():$server.port.toString()";
      address = server.address.toString();
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('http://127.0.0.1:3000'));
    });
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
    setState(() {
      statusText = "Server running on IP : " +
          server.address.toString() +
          " On Port : " +
          server.port.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              startServer();
            },
            child: Text(statusText),
          ),
          address != ''
              ? Expanded(
                  child: SizedBox(
                      height: 500,
                      child: WebViewWidget(controller: controller)),
                )
              : Container(),
          address != ''
              ? Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            controller = WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..setBackgroundColor(const Color(0x00000000))
                              ..setNavigationDelegate(
                                NavigationDelegate(
                                  onProgress: (int progress) {
                                    // Update loading bar.
                                  },
                                  onPageStarted: (String url) {},
                                  onPageFinished: (String url) {},
                                  onWebResourceError:
                                      (WebResourceError error) {},
                                  onNavigationRequest:
                                      (NavigationRequest request) {
                                    if (request.url.startsWith(
                                        'https://www.youtube.com/')) {
                                      return NavigationDecision.prevent;
                                    }
                                    return NavigationDecision.navigate;
                                  },
                                ),
                              )
                              ..loadRequest(Uri.parse('http://127.0.0.1:3000'));
                          });
                        },
                        child: Text("home")),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          controller = WebViewController()
                            ..setJavaScriptMode(JavaScriptMode.unrestricted)
                            ..setBackgroundColor(const Color(0x00000000))
                            ..setNavigationDelegate(
                              NavigationDelegate(
                                onProgress: (int progress) {
                                  // Update loading bar.
                                },
                                onPageStarted: (String url) {},
                                onPageFinished: (String url) {},
                                onWebResourceError: (WebResourceError error) {},
                                onNavigationRequest:
                                    (NavigationRequest request) {
                                  if (request.url
                                      .startsWith('https://www.youtube.com/')) {
                                    return NavigationDecision.prevent;
                                  }
                                  return NavigationDecision.navigate;
                                },
                              ),
                            )
                            ..loadRequest(Uri.parse(
                                'http://127.0.0.1:3000/water?geoserver_url=https://geoserver.gramvaani.org:8443&block_pkey=null&app_name=nrmApp&dist_name=Angul&block_name=Angul'));
                        });
                      },
                      child: Text("water"),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    ));
  }
}
