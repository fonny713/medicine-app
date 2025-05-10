import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../../services/firebase/firestore_service.dart';
import '../../services/firebase/storage_service.dart';
import '../../models/medicine_model.dart';
import '../medicine/add_medicine_page.dart';

class MedicineScannerPage extends StatefulWidget {
  const MedicineScannerPage({super.key});

  @override
  State<MedicineScannerPage> createState() => _MedicineScannerPageState();
}

class _MedicineScannerPageState extends State<MedicineScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.all],
    detectionSpeed: DetectionSpeed.normal,
  );
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final _auth = FirebaseAuth.instance;

  bool _isScanning = true;
  String? _lastCode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final image = capture.image;

    for (final barcode in barcodes) {
      if (!_isScanning) return;
      if (barcode.rawValue == null) continue;
      if (barcode.rawValue == _lastCode) continue;

      setState(() {
        _isScanning = false;
        _lastCode = barcode.rawValue;
      });

      await _controller.stop();
      if (image != null) {
        await _showResultDialog(barcode.rawValue!, image);
      }
      if (mounted) {
        await _controller.start();
        setState(() => _isScanning = true);
      }
    }
  }

  Future<void> _showResultDialog(String code, Uint8List imageBytes) async {
    final medicine = await _firestoreService.getMedicineByBarcode(code);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(medicine != null ? 'Medicine Found' : 'New Medicine'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      imageBytes,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (medicine != null) ...[
                    Text('Name: ${medicine['name'] ?? 'Unknown'}'),
                    Text('Brand: ${medicine['brand'] ?? 'Unknown'}'),
                    const SizedBox(height: 8),
                    const Text('Would you like to save this medicine?'),
                  ] else ...[
                    Text('Barcode: $code'),
                    const SizedBox(height: 8),
                    const Text('Medicine not found in database.'),
                    const Text('Would you like to add it?'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (medicine != null) {
                    // Add to user's medicine list
                    final userId = _auth.currentUser!.uid;
                    final medicineDoc = medicine as DocumentSnapshot;
                    await _firestoreService.updateUserMedicineList(userId, [
                      medicineDoc.id,
                    ]);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Medicine added to your list'),
                        ),
                      );
                    }
                  } else {
                    // Navigate to add medicine form with captured image
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddMedicinePage(
                                barcode: code,
                                imageBytes: imageBytes,
                              ),
                        ),
                      );
                    }
                  }
                },
                child: Text(medicine != null ? 'Save' : 'Add New'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medicine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          if (_isScanning)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Scanning for barcode...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.fill;

    const scanAreaSize = 250.0;
    final scanAreaRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)),
        ),
      ),
      paint,
    );

    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)),
      borderPaint,
    );

    const markerLength = 24.0;
    final markerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    // Draw corner markers
    void drawCornerMarker(Offset point, bool isHorizontalFirst) {
      if (isHorizontalFirst) {
        canvas.drawLine(point, point.translate(markerLength, 0), markerPaint);
        canvas.drawLine(point, point.translate(0, markerLength), markerPaint);
      } else {
        canvas.drawLine(point, point.translate(0, markerLength), markerPaint);
        canvas.drawLine(point, point.translate(markerLength, 0), markerPaint);
      }
    }

    drawCornerMarker(scanAreaRect.topLeft, true);
    drawCornerMarker(scanAreaRect.topRight.translate(-markerLength, 0), false);
    drawCornerMarker(scanAreaRect.bottomLeft.translate(0, -markerLength), true);
    drawCornerMarker(
      scanAreaRect.bottomRight.translate(-markerLength, -markerLength),
      false,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
