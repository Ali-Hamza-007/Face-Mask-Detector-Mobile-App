import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  String result = "Ready to Scan";
  bool isLoading = false;
  bool useFrontCamera = false;

  final picker = ImagePicker();
  final String apiUrl =
      "https://ali-hamza-007-face-mask-detector.hf.space/predict";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(
      source: source,
      preferredCameraDevice: useFrontCamera
          ? CameraDevice.front
          : CameraDevice.rear,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        result = "Analyzing...";
        isLoading = true;
      });
      await uploadImage(_image!);
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send().timeout(const Duration(seconds: 20));
      var res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          result = data['prediction'].toString().toUpperCase();
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        result = "Error";
        isLoading = false;
      });
    }
  }

  Color getStatusColor() {
    if (result.contains("MASK") && !result.contains("NO"))
      return Colors.greenAccent;
    if (result.contains("NO")) return Colors.redAccent;
    return Colors.white70;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Aesthetic Blobs
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.purple.withOpacity(0.1),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Face Mask Detector",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    "AI-Powered Mask Detection",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // Main Scanner View
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _image != null
                                ? Image.file(_image!, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.white.withOpacity(0.03),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.face_retouching_natural,
                                          size: 80,
                                          color: Colors.white10,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "No Image Captured",
                                          style: TextStyle(
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                            if (isLoading)
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: Container(
                                  color: Colors.black26,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          "SCANNING...",
                                          style: TextStyle(
                                            color: Colors.blue[200],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Result Section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: getStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          result.contains("MASK") && !result.contains("NO")
                              ? Icons.verified
                              : Icons.warning_amber_rounded,
                          color: getStatusColor(),
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "DETECTION RESULT",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              result,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: getStatusColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Modern Floating Bottom Bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.photo_library_outlined,
                            label: "Gallery",
                            onTap: () => pickImage(ImageSource.gallery),
                            color: Colors.white10,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _ActionButton(
                            icon: Icons.camera_alt_rounded,
                            label: "Take Photo",
                            onTap: () => pickImage(ImageSource.camera),
                            color: Colors.blueAccent,
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: "",
                          onTap: () => setState(() {
                            _image = null;
                            result = "Ready to Scan";
                          }),
                          color: Colors.white10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          // Changed padding to ensure small screens don't overflow
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Added to prevent expanding infinitely
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20, // Slightly reduced size to fit better
                color: isPrimary ? Colors.white : Colors.white70,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4), // Reduced spacing
                Flexible(
                  // Wrapped text in Flexible to prevent "RenderParagraph" errors
                  child: Text(
                    label,
                    overflow:
                        TextOverflow.ellipsis, // Added overflow protection
                    style: TextStyle(
                      fontSize: 13, // Slightly smaller font for better fit
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
