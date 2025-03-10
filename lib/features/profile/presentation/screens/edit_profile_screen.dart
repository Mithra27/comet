// lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/profile_controller.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../config/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController _controller = Get.find<ProfileController>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  final RxList<String> _selectedInterests = <String>[].obs;
  
  @override
  void initState() {
    super.initState();
    final profile = _controller.profile.value;
    if (profile != null) {
      _nameController.text = profile.name;
      _phoneController.text = profile.phone;
      _apartmentController.text = profile.apartment;
      _selectedInterests.value = List.from(profile.interests);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _apartmentController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && !_selectedInterests.contains(interest)) {
      _selectedInterests.add(interest);
      _interestController.clear();
    }
  }

  void _removeInterest(String interest) {
    _selectedInterests.remove(interest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: LoadingIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Center(
                    child: Stack(
                      children: [
                        Obx(() {
                          final imageFile = _controller.selectedImage.value;
                          final profileImageUrl = _controller.profile.value?.imageUrl;
                          
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: imageFile != null
                              ? FileImage(imageFile)
                              : (profileImageUrl != null
                                  ? NetworkImage(profileImageUrl) as ImageProvider
                                  : null),
                            child: imageFile == null && profileImageUrl == null
                              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                              : null,
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _controller.pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_controller.selectedImage.value != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: _controller.uploadProfileImage,
                          child: const Text('Upload Image'),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Personal Information
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _apartmentController,
                    labelText: 'Apartment/Flat Number',
                    prefixIcon: Icons.home_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your apartment/flat number';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Interests
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add items you\'re interested in sharing or borrowing',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _interestController,
                          labelText: 'Add Interest',
                          prefixIcon: Icons.interests_outlined,
                          onSubmitted: (_) => _addInterest(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addInterest,
                        icon: const Icon(Icons.add_circle),
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedInterests.map((interest) => Chip(
                      label: Text(interest),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeInterest(interest),
                      backgroundColor: Colors.grey[200],
                    )).toList(),
                  )),
                  
                  const SizedBox(height: 32),
                  
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _controller.updateProfile(
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          apartment: _apartmentController.text.trim(),
                        );
                        _controller.updateInterests(_selectedInterests);
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}