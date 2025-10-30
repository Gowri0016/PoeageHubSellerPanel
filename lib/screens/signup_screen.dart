import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  Widget _buildImageUploadButton(
    String label,
    dynamic image,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              image == null ? Icons.upload : Icons.check_circle,
              color: image == null ? Colors.grey : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                image == null ? label : 'Image uploaded',
                style: TextStyle(
                  color: image == null ? Colors.grey[600] : Colors.green,
                ),
              ),
            ),
            if (image != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    switch (label) {
                      case 'Upload Selfie':
                        _selfieImage = null;
                        break;
                      case 'Upload Aadhar Front':
                        _aadharFrontImage = null;
                        break;
                      case 'Upload Aadhar Back':
                        _aadharBackImage = null;
                        break;
                      case 'Upload GST Certificate':
                        _gstCertificateImage = null;
                        break;
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _sellerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _aadharNumberController = TextEditingController();

  // On web these will be XFile, on mobile/desktop File
  dynamic _selfieImage;
  dynamic _aadharFrontImage;
  dynamic _aadharBackImage;
  dynamic _gstCertificateImage;

  @override
  void dispose() {
    _sellerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _phoneController.dispose();
    _gstNumberController.dispose();
    _aadharNumberController.dispose();
    super.dispose();
  }

  Future<dynamic> _pickImage(String type) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        switch (type) {
          case 'selfie':
            _selfieImage = kIsWeb ? image : File(image.path);
            break;
          case 'aadharFront':
            _aadharFrontImage = kIsWeb ? image : File(image.path);
            break;
          case 'aadharBack':
            _aadharBackImage = kIsWeb ? image : File(image.path);
            break;
          case 'gst':
            _gstCertificateImage = kIsWeb ? image : File(image.path);
            break;
        }
      });
      return kIsWeb ? image : File(image.path);
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selfieImage == null ||
        _aadharFrontImage == null ||
        _aadharBackImage == null ||
        _gstCertificateImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required images')),
      );
      return;
    }

    try {
      debugPrint(
        'SignupScreen: submitting signup for ${_emailController.text.trim()}',
      );
      await context.read<AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        sellerName: _sellerNameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        phone: _phoneController.text.trim(),
        gstNumber: _gstNumberController.text.trim(),
        aadharNumber: _aadharNumberController.text.trim(),
        selfieImage: _selfieImage!,
        aadharFrontImage: _aadharFrontImage!,
        aadharBackImage: _aadharBackImage!,
        gstCertificateImage: _gstCertificateImage!,
      );

      if (mounted) {
        // After successful signup, send user to waiting-for-approval page.
        debugPrint('SignupScreen: signup successful, navigating to /waiting');
        Navigator.of(context).pushReplacementNamed('/waiting');
      }
    } catch (error) {
      if (!mounted) return;
      debugPrint('SignupScreen: signup error -> $error');
      // Show detailed error to the user and log it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Seller Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _sellerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your business name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Business Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your business address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _gstNumberController,
                    decoration: const InputDecoration(
                      labelText: 'GST Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your GST number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aadharNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Aadhar Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Aadhar number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Required Documents:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildImageUploadButton(
                    'Upload Selfie',
                    _selfieImage,
                    () => _pickImage('selfie'),
                  ),
                  const SizedBox(height: 12),
                  _buildImageUploadButton(
                    'Upload Aadhar Front',
                    _aadharFrontImage,
                    () => _pickImage('aadharFront'),
                  ),
                  const SizedBox(height: 12),
                  _buildImageUploadButton(
                    'Upload Aadhar Back',
                    _aadharBackImage,
                    () => _pickImage('aadharBack'),
                  ),
                  const SizedBox(height: 12),
                  _buildImageUploadButton(
                    'Upload GST Certificate',
                    _gstCertificateImage,
                    () => _pickImage('gst'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: context.watch<AuthProvider>().isLoading
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: context.watch<AuthProvider>().isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign Up'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
