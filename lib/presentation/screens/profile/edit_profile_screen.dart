import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  File? _pickedImage;
  String? _photoUrl;       // remote URL from Cloudinary
  String? _base64Image;    // local fallback
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    if (profile != null) _populate(profile);
  }

  void _populate(UserProfile p) {
    _nameCtrl.text = p.fullName;
    _ageCtrl.text = p.age.toString();
    _emailCtrl.text = p.email;
    _phoneCtrl.text = p.phone;
    _occupationCtrl.text = p.occupation;
    _locationCtrl.text = p.location;
    _aboutCtrl.text = p.aboutMe;
    // check if stored value is a URL or base64
    if (p.photoUrl != null && p.photoUrl!.startsWith('data:image')) {
      _base64Image = p.photoUrl;
    } else {
      _photoUrl = p.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _occupationCtrl.dispose();
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _pickedImage = file;
      _uploadingImage = true;
    });

    // try Cloudinary first
    if (AppStrings.cloudinaryCloudName != 'YOUR_CLOUD_NAME') {
      final url = await ref.read(profileProvider.notifier).uploadPicture(file);
      if (url != null) {
        setState(() {
          _photoUrl = url;
          _base64Image = null;
          _uploadingImage = false;
        });
        return;
      }
    }

    // fallback: convert to base64 and store locally
    final bytes = await file.readAsBytes();
    final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    setState(() {
      _base64Image = base64Str;
      _photoUrl = null;
      _uploadingImage = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? const Uuid().v4();

    // determine final photo value — URL takes priority over base64
    final finalPhoto = _photoUrl ?? _base64Image;

    final profile = UserProfile(
      id: uid,
      fullName: _nameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      occupation: _occupationCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      aboutMe: _aboutCtrl.text.trim(),
      photoUrl: finalPhoto,
    );
    await ref.read(profileProvider.notifier).saveProfile(profile);
    if (mounted) {
      showSuccessSnackBar(context, 'Profile saved!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: LoadingOverlay(
        isLoading: state.isLoading && !_uploadingImage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _uploadingImage ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surface,
                        child: _buildAvatar(),
                      ),
                      if (_uploadingImage)
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black38,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _uploadingImage ? 'Uploading...' : 'Tap to change photo',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 24),
                AppTextField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    validator: (v) => Validators.required(v, 'Full Name')),
                const SizedBox(height: 16),
                AppTextField(
                    label: 'Age',
                    controller: _ageCtrl,
                    validator: Validators.age,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                AppTextField(
                    label: 'Email',
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                AppTextField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                AppTextField(
                    label: 'Occupation',
                    controller: _occupationCtrl,
                    validator: (v) => Validators.required(v, 'Occupation')),
                const SizedBox(height: 16),
                AppTextField(
                    label: 'Location',
                    controller: _locationCtrl,
                    validator: (v) => Validators.required(v, 'Location')),
                const SizedBox(height: 16),
                AppTextField(
                    label: 'About Me',
                    controller: _aboutCtrl,
                    validator: (v) => Validators.required(v, 'About Me'),
                    maxLines: 3),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (state.isLoading || _uploadingImage) ? null : _submit,
                  child: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // show picked local file first
    if (_pickedImage != null && !_uploadingImage) {
      return ClipOval(
        child: Image.file(_pickedImage!,
            width: 100, height: 100, fit: BoxFit.cover),
      );
    }
    // show base64 local image
    if (_base64Image != null) {
      final bytes = base64Decode(_base64Image!.split(',').last);
      return ClipOval(
        child: Image.memory(bytes, width: 100, height: 100, fit: BoxFit.cover),
      );
    }
    // show remote Cloudinary URL
    if (_photoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _photoUrl!,
          cacheKey: _photoUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorWidget: (ctx, _, e) =>
              const Icon(Icons.add_a_photo, size: 36, color: AppColors.primary),
        ),
      );
    }
    return const Icon(Icons.add_a_photo, size: 36, color: AppColors.primary);
  }
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating),
  );
}
