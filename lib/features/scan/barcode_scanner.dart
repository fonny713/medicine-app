import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.all],
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _isScanning = true;
  String? _lastCode;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (!_isScanning) return;
      if (barcode.rawValue == null) continue;
      if (barcode.rawValue == _lastCode) continue;

      setState(() {
        _isScanning = false;
        _lastCode = barcode.rawValue;
      });

      _showResultDialog(barcode.rawValue!);
    }
  }

  Future<void> _showResultDialog(String code) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Barcode Found'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: $code'),
                const SizedBox(height: 16),
                const Text('Would you like to search for this medicine?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isScanning = true;
                  });
                },
                child: const Text('SCAN AGAIN'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to medicine details page with the code
                },
                child: const Text('SEARCH'),
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
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          // Scanner overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          // Scanning indicator
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

    // Draw semi-transparent overlay
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

    // Draw scan area border
    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)),
      borderPaint,
    );

    // Draw corner markers
    const markerLength = 24.0;
    final markerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    // Top left corner
    canvas.drawLine(
      scanAreaRect.topLeft.translate(0, markerLength),
      scanAreaRect.topLeft,
      markerPaint,
    );
    canvas.drawLine(
      scanAreaRect.topLeft,
      scanAreaRect.topLeft.translate(markerLength, 0),
      markerPaint,
    );

    // Top right corner
    canvas.drawLine(
      scanAreaRect.topRight.translate(0, markerLength),
      scanAreaRect.topRight,
      markerPaint,
    );
    canvas.drawLine(
      scanAreaRect.topRight,
      scanAreaRect.topRight.translate(-markerLength, 0),
      markerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      scanAreaRect.bottomLeft.translate(0, -markerLength),
      scanAreaRect.bottomLeft,
      markerPaint,
    );
    canvas.drawLine(
      scanAreaRect.bottomLeft,
      scanAreaRect.bottomLeft.translate(markerLength, 0),
      markerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      scanAreaRect.bottomRight.translate(0, -markerLength),
      scanAreaRect.bottomRight,
      markerPaint,
    );
    canvas.drawLine(
      scanAreaRect.bottomRight,
      scanAreaRect.bottomRight.translate(-markerLength, 0),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
