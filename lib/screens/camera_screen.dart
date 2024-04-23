import 'package:deduct_ai/screens/object_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isloading = false;
  bool _isRecording = false;
  bool _isFlashOn = false;
  String? case_id;
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<List<String>?> analyzeVideoAndString(
      File videoFile, String inputString) async {
    String apiUrl = 'http://192.168.134.120:8000/api/create_case/';

    try {
      setState(() {
        _isloading = true;
      });
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'video_recording', // Name of the file field in the form
          videoFile.path,
        ),
      );
      request.fields['name'] = 'hello';
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(await response.stream.bytesToString());
        print('Response: $jsonResponse');
        setState(() {
          case_id = jsonResponse["id"];
        });
        return (jsonResponse['objects_list'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error sending request: $e');
      return null;
    }
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    if (mounted) {
      setState(() {}); // Trigger a rebuild once camera is initialized
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startStopRecording(BuildContext context) async {
    if (_isRecording) {
      await _controller.stopVideoRecording().then((value) {
        analyzeVideoAndString(File(value.path), 'car').then((objects) {
          if (objects != null) {
            print('Objects detected: $objects');
          }
          return objects;
        }).then((_) {
          _videoFile = File(value.path);
          setState(() {
            _isloading = false;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ObjectScreen(
                id: case_id,
                proofs: _,
              ),
            ),
          );
        });
      });
    } else {
      try {
        await _controller.startVideoRecording();
      } on CameraException catch (e) {
        print('Error: $e');
        return;
      }
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appTheme[50]),
        ),
        backgroundColor: AppColors.appTheme[800],
      ),
      backgroundColor: AppColors.appTheme[800],
      body: _isloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Analysing...',
                    style: GoogleFonts.firaSans(
                      fontSize: deviceWidth * 0.06,
                      fontWeight: FontWeight.w500,
                      color: AppColors.appTheme[100],
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  CircularProgressIndicator(
                    color: AppColors.appTheme[50],
                  ),
                ],
              ),
            )
          : Column(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return SizedBox(
                          height: deviceHeight * 0.75,
                          child: CameraPreview(_controller));
                    } else {
                      return SizedBox(
                        height: deviceHeight * 0.75,
                        width: deviceWidth,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: deviceWidth * 0.01),
                    IconButton(
                      onPressed: () async {
                        try {
                          String? path;
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.video);
                          if (result != null) {
                            path = result.files.single.path;
                          }
                          if (path != null) {
                            print('Uploaded video path: $path');
                          }
                        } catch (e) {
                          print('Error: $e');
                        }
                      },
                      icon: Icon(
                        Icons.photo,
                        color: AppColors.appTheme[50],
                        size: deviceWidth * 0.1,
                      ),
                    ),
                    IconButton.filled(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          _isRecording
                              ? Colors.red
                              : const Color.fromARGB(255, 128, 128, 128),
                        ),
                      ),
                      onPressed: () => _startStopRecording(context),
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.camera,
                        size: deviceWidth * 0.13,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.yellow : Colors.white,
                        size: deviceWidth * 0.1,
                      ),
                      onPressed: _toggleFlash,
                    ),
                    SizedBox(width: deviceWidth * 0.005),
                  ],
                ),
              ],
            ),
    );
  }
}
