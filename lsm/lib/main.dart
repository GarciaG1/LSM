import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrusel de Videos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoCarousel(),
    );
  }
}

class VideoCarousel extends StatefulWidget {
  const VideoCarousel({super.key});

  @override
  _VideoCarouselState createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  int currentIndex = 0;
  List<String> videoAssets = [
    'assets/videos/LSM.mp4', // Asegúrate de que estos archivos estén en la carpeta assets/videos/
    'assets/videos/LSM.mp4',
    'assets/videos/LSM.mp4',
  ];
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.asset(videoAssets[currentIndex])
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true); // El video se repetirá automáticamente
        _controller.setVolume(0); // Quitar el audio del video
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        nextVideo();
      }
    });
  }

  void nextVideo() {
    setState(() {
      currentIndex = (currentIndex + 1) % videoAssets.length;
    });
    _controller.seekTo(Duration.zero);
    _controller.play(); // Reanudar la reproducción desde el principio
  }

  void prevVideo() {
    setState(() {
      currentIndex = (currentIndex - 1 + videoAssets.length) % videoAssets.length;
    });
    _controller.seekTo(Duration.zero);
    _controller.play(); // Reanudar la reproducción desde el principio
  }

  // Obtener la conectividad y el nivel de la batería y concatenar los parámetros en la URL
  Future<String> _getParamsForUrl() async {
    // Obtener el estado de la batería
    final battery = Battery();
    int batteryLevel = await battery.batteryLevel;

    // Obtener el estado de la conectividad
    var connectivityResult = await Connectivity().checkConnectivity();
    String connectivityStatus = '';
    if (connectivityResult == ConnectivityResult.mobile) {
      connectivityStatus = 'mobile';
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connectivityStatus = 'wifi';
    } else {
      connectivityStatus = 'none';
    }

    // Agregar los permisos a la URL
    String cameraPermission = 'false';
    String microphonePermission = 'false';

    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    if (cameraStatus.isGranted) {
      cameraPermission = 'true';
    }

    if (microphoneStatus.isGranted) {
      microphonePermission = 'true';
    }

    // Concatenar los parámetros a la URL
    String url = 'https://www.ventanillabc.bajacalifornia.gob.mx/muac/jitsi/?battery=$batteryLevel&connectivity=$connectivityStatus&cameraPermission=$cameraPermission&microphonePermission=$microphonePermission';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onDoubleTap: () async {
            // Obtener la URL con los parámetros
            String url = await _getParamsForUrl();
            // Verificar que la URL está siendo generada correctamente
            print("Redirigiendo a URL: $url");

            // Verificar permisos antes de abrir el WebView
            bool permissionsGranted = await _checkPermissions();

            if (permissionsGranted) {
              // Redirigir al WebView con la URL si los permisos fueron otorgados
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(url: url),
                ),
              );
            } else {
              // Si los permisos no fueron concedidos, puedes mostrar un mensaje
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Permisos requeridos'),
                  content: Text('Necesitamos permisos para acceder a la cámara y el micrófono.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Stack(
            children: [
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : CircularProgressIndicator(),
              // Botones para cambiar el video
              Positioned(
                left: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: prevVideo,
                ),
              ),
              Positioned(
                right: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: nextVideo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Verificar los permisos de cámara y micrófono
  Future<bool> _checkPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    return cameraPermission.isGranted && microphonePermission.isGranted;
  }
}

// Página WebView
class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 3, 0, 0),
      appBar: AppBar(
        title: Text('WebView'),
        backgroundColor: Colors.black,
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted) // Habilitar JavaScript
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                print('Página cargada: $url');
              },
            ),
          )
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
