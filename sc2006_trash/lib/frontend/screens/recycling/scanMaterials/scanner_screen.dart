import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/manually_input.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/upload_photo_manually_input.dart';
//import 'package:flutter_create_test/frontend/screens/recycling/scanMaterials/upload_photo_scan_material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_create_test/backend/services/model_AI_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _predictedLabel = "Detecting...";
  double _confidence = 0.0;
  bool _isProcessingFrame = false;
  bool _showQuantitySelector = false; // Flag to show/hide QuantitySelector
  String selectedMaterialString = "";
  Set<MaterialsType> selectedMaterials = <MaterialsType>{};
  int quantity = 5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await ModelAIService.loadModel();

      _cameraController!.startImageStream((CameraImage image) async {
        if (_isProcessingFrame) return;
        _isProcessingFrame = true;

        try {
          await _runModelOnFrame(image);
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {
          // Optionally log or ignore error
        } finally {
          _isProcessingFrame = false;
        }
      });

      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (_) {
      // Optionally handle init failure
    }
  }

  Future<void> _runModelOnFrame(CameraImage image) async {
    final img.Image convertedImage = _convertCameraImage(image);
    final img.Image resizedImage = img.copyResize(
      convertedImage,
      width: 224,
      height: 224,
    );

    var input = List.generate(
      224,
      (y) => List.generate(224, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [
          pixel.r.toDouble() / 255.0,
          pixel.g.toDouble() / 255.0,
          pixel.b.toDouble() / 255.0,
        ];
      }),
    );

    var inputTensor = [input];
    var output = List.filled(
      1 * ModelAIService.labels.length,
      0.0,
    ).reshape([1, ModelAIService.labels.length]);

    ModelAIService.interpreter.run(inputTensor, output);

    double maxConfidence = 0;
    int maxIndex = 0;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    setState(() {
      _predictedLabel = ModelAIService.labels[maxIndex];
      _confidence = maxConfidence * 100;
      selectedMaterialString =
          "$_predictedLabel (${_confidence.toStringAsFixed(1)}%)"; // Set selectedMaterials here
    });
  }

  img.Image _convertCameraImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final img.Image rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + (1.370705 * (vp - 128))).round();
        int g =
            (yp - (0.337633 * (up - 128)) - (0.698001 * (vp - 128))).round();
        int b = (yp + (1.732446 * (up - 128))).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        final color = img.ColorRgba8(r, g, b, 255);
        rgbImage.setPixel(x, y, color);
      }
    }

    return rgbImage;
  }

  void _toggleQuantitySelector() {
    setState(() {
      _showQuantitySelector = !_showQuantitySelector;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 0) quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isCameraInitialized
              ? Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_cameraController!)),
                  Positioned(
                    top: 30,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedMaterialString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 280,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Positioned(
                    top: 560,
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _toggleQuantitySelector,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.6),
                        child: Column(
                          children: [
                            SizedBox(height: 24),
                            Center(
                              child: Icon(
                                Icons.note_rounded,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                            Center(
                              child: Text(
                                "Input Quanity",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_showQuantitySelector)
                    quantitySelectorWithSave(
                      quantity: quantity,
                      onIncrement: incrementQuantity,
                      onDecrement: decrementQuantity,
                      onPressed: () {
                        if (quantity > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UploadPhotoManuallyInput(
                                    quantity: quantity,
                                    selectedMaterials: selectedMaterials,
                                  ),
                            ),
                          );
                        } else {
                          showDialogBox(
                            context: context,
                            title: "Invalid Quantity",
                            content: "Please enter a quantity greater than 0.",
                            onPressed: () {},
                          );
                          return;
                        }
                      },
                      onClose: _toggleQuantitySelector,
                    ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
