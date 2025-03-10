import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/community_controller.dart';
import '../data/models/community_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';

class JoinCommunityScreen extends StatefulWidget {
  const JoinCommunityScreen({Key? key}) : super(key: key);

  @override
  _JoinCommunityScreenState createState() => _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends State<JoinCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gateCodeController = TextEditingController();
  bool _isPrivate = true;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _gateCodeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Community'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Consumer<CommunityController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchExistingCommunities(controller),
                Divider(height: 40),
                _buildCreateNewCommunity(controller),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSearchExistingCommunities(CommunityController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your Community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your community code or search by name to find and join your gated community.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Enter community name or code',
          prefixIcon: Icons.search,
          onChanged: (value) {
            // TODO: Implement search functionality
          },
        ),
        const SizedBox(height: 16),
        if (controller.isLoading)
          Center(child: LoadingIndicator())
        else if (controller.communities.isNotEmpty) 
          ..._buildSearchResults(controller)
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No communities found matching your search',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
  
  List<Widget> _buildSearchResults(CommunityController controller) {
    // For simplicity, showing all communities here
    // In a real app, you would filter based on search term
    return [
      Text(
        'Communities',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      ...controller.communities.map((community) => Card(
        margin: EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(community.name),
          subtitle: Text(community.address),
          trailing: ElevatedButton(
            child: Text('Join'),
            onPressed: () async {
              final success = await controller.joinCommunity(community.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully joined ${community.name}!')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to join community. Please try again.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      )).toList(),
    ];
  }
  
  Widget _buildCreateNewCommunity(CommunityController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a New Community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Don\'t see your community? Create a new one for your apartment or gated complex.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Community Name',
                hintText: 'Enter community name',
                prefixIcon: Icons.apartment,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Briefly describe your community',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                labelText: 'Address',
                hintText: 'Enter the full address',
                prefixIcon: Icons.location_on,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _gateCodeController,
                labelText: 'Gate Code (Optional)',
                hintText: 'Enter gate code if applicable',
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Private Community'),
                subtitle: Text('Only approved members can join'),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
                activeColor: AppConstants.primaryColor,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Community',
                isLoading: controller.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newCommunity = Community(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      address: _addressController.text,
                      gateCode: _gateCodeController.text,
                      isPrivate: _isPrivate,
                    );
                    
                    final communityId = await controller.createCommunity(newCommunity);
                    
                    if (communityId != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Community created successfully!')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create community. Please try again.')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}