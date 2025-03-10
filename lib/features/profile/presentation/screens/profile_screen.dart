// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/profile_controller.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/edit-profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LoadingIndicator());
          }
          
          if (controller.profile.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load profile'),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Retry',
                    onPressed: controller.fetchProfile,
                  ),
                ],
              ),
            );
          }
          
          final profile = controller.profile.value!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profile.imageUrl != null
                          ? NetworkImage(profile.imageUrl!)
                          : null,
                        child: profile.imageUrl == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (profile.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.verified,
                                color: AppTheme.primaryColor,
                                size: 16,
                              ),
                            ),
                          Text(
                            profile.apartment,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Trust Score: ${profile.trustScore}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Contact Information
                _buildSectionTitle('Contact Information'),
                _buildInfoItem(Icons.email, 'Email', profile.email),
                _buildInfoItem(Icons.phone, 'Phone', profile.phone),
                
                const SizedBox(height: 24),
                
                // Security
                _buildSectionTitle('Security'),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Two-Factor Authentication'),
                  trailing: Switch(
                    value: profile.is2FAEnabled,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      // Toggle 2FA
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Interests
                _buildSectionTitle('Interests'),
                if (profile.interests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No interests added yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.interests.map((interest) => Chip(
                        label: Text(interest),
                        backgroundColor: Colors.grey[200],
                      )).toList(),
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Delete Account',
                        onPressed: controller.deleteAccount,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}