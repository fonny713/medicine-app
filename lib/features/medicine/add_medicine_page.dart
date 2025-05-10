import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase/firestore_service.dart';
import '../../services/firebase/storage_service.dart';
import '../../widgets/custom_text_input.dart';
import '../../models/medicine_model.dart';

class AddMedicinePage extends StatefulWidget {
  final String barcode;
  final Uint8List imageBytes;

  const AddMedicinePage({
    super.key,
    required this.barcode,
    required this.imageBytes,
  });

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _dosageController = TextEditingController();
  final _summaryController = TextEditingController();

  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _ingredientsController.dispose();
    _dosageController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final medicineData = {
        'name': _nameController.text,
        'brand': _brandController.text,
        'ingredients':
            _ingredientsController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
        'barcode': widget.barcode,
        'naturalness': 0, // Will be analyzed later
        'summary': _summaryController.text,
        'sideEffects': <String>[], // Will be analyzed later
        'dosageInfo': _dosageController.text,
        'interactions': <String>[], // Will be analyzed later
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': _auth.currentUser!.uid,
      };

      await _firestoreService.saveMedicineWithImage(
        medicineData,
        widget.imageBytes,
        widget.barcode,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving medicine: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Medicine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  widget.imageBytes,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text('Barcode: ${widget.barcode}'),
              const SizedBox(height: 24),
              CustomTextInput(
                controller: _nameController,
                label: 'Medicine Name',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                controller: _brandController,
                label: 'Brand',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                controller: _ingredientsController,
                label: 'Ingredients (comma-separated)',
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                controller: _dosageController,
                label: 'Dosage Information',
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter dosage information';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                controller: _summaryController,
                label: 'Medicine Summary',
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter medicine summary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicine,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save Medicine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
