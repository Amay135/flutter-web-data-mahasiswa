import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

html.VideoElement? videoElement;
html.MediaStream? mediaStream;
String? viewId;
bool kameraSiap = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MahasiswaPage(),
    );
  }
}

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final TextEditingController npmController = TextEditingController();
  final TextEditingController namaController = TextEditingController();

  Uint8List? foto;
  String? fotoBase64;
  List data = [];

  @override
  void initState() {
    super.initState();
    initCamera();
    getData();
  }

  Future<void> initCamera() async {
    try {
      videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      viewId = 'camera-${DateTime.now().microsecondsSinceEpoch}';
      ui_web.platformViewRegistry.registerViewFactory(
        viewId!,
        (int id) => videoElement!,
      );

      mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'environment'},
        'audio': false,
      });

      videoElement!.srcObject = mediaStream;

      setState(() {
        kameraSiap = true;
      });
    } catch (e) {
      try {
        mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
          'video': true,
          'audio': false,
        });
        videoElement!.srcObject = mediaStream;
        setState(() {
          kameraSiap = true;
        });
      } catch (e2) {
        setState(() {
          kameraSiap = false;
        });
      }
    }
  }

  Future<void> getData() async {
    try {
      final response = await http.get(
        Uri.parse('https://asnawi.web.id/mhsapi/'),
      );
      final hasil = jsonDecode(response.body);
      setState(() {
        if (hasil is List) {
          data = hasil;
        } else if (hasil['data'] != null) {
          data = hasil['data'];
        } else {
          data = [];
        }
      });
    } catch (e) {
      print("GET ERROR: $e");
    }
  }

  Future<void> ambilFoto() async {
    try {
      if (!kameraSiap || videoElement == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kamera tidak tersedia")));
        return;
      }

      final canvas = html.CanvasElement(
        width: videoElement!.videoWidth,
        height: videoElement!.videoHeight,
      );
      canvas.context2D.drawImage(videoElement!, 0, 0);
      final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
      final b64 = dataUrl.split(',').last;

      setState(() {
        foto = base64Decode(b64);
        fotoBase64 = b64;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Foto berhasil diambil")));
    } catch (e) {
      print("FOTO ERROR: $e");
    }
  }

  Future<void> simpanData() async {
    if (fotoBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ambil foto terlebih dahulu")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://asnawi.web.id/mhsapi/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "npm": npmController.text.trim(),
          "nama": namaController.text.trim(),
          "foto": fotoBase64,
        }),
      );

      print(response.body);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));

      npmController.clear();
      namaController.clear();
      setState(() {
        foto = null;
        fotoBase64 = null;
      });

      getData();
    } catch (e) {
      print("POST ERROR: $e");
    }
  }

  @override
  void dispose() {
    mediaStream?.getTracks().forEach((t) => t.stop());
    npmController.dispose();
    namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Mahasiswa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 200,
                  width: 300,
                  child: kameraSiap && viewId != null
                      ? HtmlElementView(viewType: viewId!)
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text("Kamera tidak tersedia"),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: ambilFoto,
                child: const Text("Ambil Foto"),
              ),

              if (foto != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.memory(foto!, height: 80, fit: BoxFit.cover),
                ),

              TextField(
                controller: npmController,
                decoration: const InputDecoration(
                  labelText: "NPM",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: simpanData,
                child: const Text("Simpan Data"),
              ),

              const Divider(),

              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    Widget avatar;
                    final fotoStr = data[index]['foto']?.toString() ?? '';

                    if (fotoStr.isNotEmpty) {
                      avatar = CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://asnawi.web.id/mhsapi/$fotoStr",
                        ),
                      );
                    } else {
                      avatar = const CircleAvatar(child: Icon(Icons.person));
                    }

                    return Card(
                      child: ListTile(
                        leading: avatar,
                        title: Text(data[index]['nama']?.toString() ?? ''),
                        subtitle: Text(data[index]['npm']?.toString() ?? ''),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
