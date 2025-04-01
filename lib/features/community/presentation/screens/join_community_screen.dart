// lib/features/community/presentation/screens/join_community_screen.dart

// Core/Shared Imports
import 'package:comet/core/constants/app_constants.dart';
import 'package:comet/core/utils/validators.dart'; // Ensure this import is correct
import 'package:comet/shared/widgets/custom_button.dart';
import 'package:comet/shared/widgets/custom_text_field.dart';
import 'package:comet/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Feature-specific Imports
import 'package:comet/features/community/controller/community_controller.dart';
import 'package:comet/features/community/data/models/community_model.dart';
// Removed unused widget import: 'package:comet/features/community/presentation/widgets/community_widgets.dart';


class JoinCommunityScreen extends StatefulWidget {
  const JoinCommunityScreen({Key? key}) : super(key: key);

  @override
  // Removed private type _JoinCommunityScreenState to fix 'library_private_types_in_public_api' info
  JoinCommunityScreenState createState() => JoinCommunityScreenState();
}

class JoinCommunityScreenState extends State<JoinCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gateCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Added for search
  bool _isPrivate = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _gateCodeController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  // --- Helper to show Snackbars ---
  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) { // Check if the widget is still in the tree
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }
  // --- ---

  @override
  Widget build(BuildContext context) {
    // Use watch for rebuilds on loading state changes, read for actions
    final controller = context.watch<CommunityController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join or Create Community'), // Made const
        backgroundColor: AppConstants.primaryColor, // Ensure defined
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchExistingCommunities(controller),
            const Divider(height: 40),
            _buildCreateNewCommunity(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchExistingCommunities(CommunityController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text( // Made const
          'Find Your Community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text( // Made const where possible
          'Enter your community code or search by name to find and join.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          // FIX: Added label, used hint
          label: 'Search Communities',
          hint: 'Enter community name or code',
          controller: _searchController, // Use search controller
          prefixIcon: Icons.search,
          onChanged: (value) {
            // TODO: Debounce search? Call controller.searchCommunities(value);
             print("Searching for: $value"); // Placeholder
          },
          // No validator needed for search usually
        ),
        const SizedBox(height: 16),
        // Use controller.isSearching or similar specific state if available
        if (controller.isLoading)
          const Center(child: LoadingIndicator()) // Made const
        // Use controller.searchResults or similar specific list
        else if (controller.communities.isNotEmpty) // Placeholder: use search results
          ..._buildSearchResults(controller)
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _searchController.text.isEmpty
                  ? 'Enter a search term above.' // Initial message
                  : 'No communities found matching your search.', // No results message
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
    // TODO: This should display controller.searchResults, not all communities
    List<CommunityModel> results = controller.communities; // Replace with actual search results

    return [
      const Text( // Made const
        'Search Results', // Changed title
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      ListView.builder( // More efficient for potentially long lists
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
          itemCount: results.length,
          itemBuilder: (context, index) {
            final community = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(community.name),
                subtitle: Text(community.address),
                trailing: ElevatedButton(
                  child: const Text('Join'), // Made const
                  onPressed: () async {
                    // FIX: Call the correct controller method (ensure joinCommunity takes communityId and apartmentNumber)
                    // Need an apartment number input for joining! Add a dialog or field.
                    String? apartmentNumber = await _showJoinDialog();
                    if (apartmentNumber != null && apartmentNumber.isNotEmpty) {
                      // Read controller once for action
                      final success = await context.read<CommunityController>().joinCommunity(
                        communityId: community.id,
                        apartmentNumber: apartmentNumber,
                      );
                       // Use helper for snackbar
                      _showSnackbar(
                        success ? 'Successfully joined ${community.name}!' : 'Failed to join community.',
                        isError: !success,
                      );
                      if (success && mounted) { // Check mounted after await
                         Navigator.pop(context); // Go back after joining
                      }
                    } else if (apartmentNumber != null) { // User pressed OK but left field empty
                       _showSnackbar('Apartment number cannot be empty.', isError: true);
                    } // If null, user cancelled dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor, // Ensure defined
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            );
         }),
    ];
  }

  // --- Dialog to get apartment number for joining ---
  Future<String?> _showJoinDialog() {
     final TextEditingController apartmentController = TextEditingController();
     return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
           title: const Text('Enter Your Apartment Number'),
           content: CustomTextField( // Use CustomTextField here too
              label: 'Apartment/Flat Number',
              hint: 'e.g., A-101, #204',
              controller: apartmentController,
              autofocus: true,
              // No validator needed in dialog, check on return
           ),
           actions: [
              TextButton(
                 onPressed: () => Navigator.pop(context, null), // Cancel
                 child: const Text('Cancel'),
              ),
              TextButton(
                 onPressed: () => Navigator.pop(context, apartmentController.text.trim()), // Confirm
                 child: const Text('Join'),
              ),
           ],
        ),
     );
  }
 // --- ---


  Widget _buildCreateNewCommunity(CommunityController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text( // Made const
          'Create a New Community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text( // Made const where possible
          'Can\'t find yours? Create one for your apartment or gated complex.',
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
                // FIX: Added label, used hint, corrected validator
                label: 'Community Name',
                hint: 'e.g., Green Heights Residency',
                controller: _nameController,
                prefixIcon: Icons.apartment,
                validator: Validators.validateRequired, // Ensure Validators.validateRequired exists
              ),
              const SizedBox(height: 16),
              CustomTextField(
                 // FIX: Added label, used hint, corrected validator
                label: 'Description',
                hint: 'e.g., A friendly community with shared amenities',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: Validators.validateRequired, // Ensure Validators.validateRequired exists
              ),
              const SizedBox(height: 16),
              CustomTextField(
                 // FIX: Added label, used hint, corrected validator
                label: 'Address',
                hint: 'Enter the full community address',
                controller: _addressController,
                prefixIcon: Icons.location_on,
                validator: Validators.validateRequired, // Ensure Validators.validateRequired exists
              ),
              const SizedBox(height: 16),
              CustomTextField(
                 // FIX: Added label, used hint
                label: 'Gate Code (Optional)',
                hint: 'Enter gate code if applicable',
                controller: _gateCodeController,
                prefixIcon: Icons.lock,
                // No validator needed for optional field
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Private Community'), // Made const
                subtitle: const Text('Only approved members can join'), // Made const
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
                activeColor: AppConstants.primaryColor, // Ensure defined
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Community',
                // Use controller.isCreating or similar state if available
                isLoading: controller.isLoading, // Check if this is the correct loading state
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // FIX: Use CommunityModel constructor (ensure it matches definition)
                    final newCommunity = CommunityModel(
                      id: '', // ID will be generated by backend/repository
                      name: _nameController.text.trim(),
                      description: _descriptionController.text.trim(),
                      address: _addressController.text.trim(),
                      gateCode: _gateCodeController.text.trim(),
                      isPrivate: _isPrivate,
                      memberIds: [], // Initialize members list
                      adminIds: [], // Initialize admin list
                      createdAt: DateTime.now(), // Set creation time
                    );

                    // Read controller once for action
                    // FIX: Ensure createCommunity returns ID and handles joining
                    // It should probably return CommunityModel? or String? (the new ID)
                    // Also need apartment number for the creator!
                     String? creatorApartment = await _showCreateDialog(); // Get apartment for creator
                     if (creatorApartment != null && creatorApartment.isNotEmpty) {
                       final createdCommunity = await context.read<CommunityController>().createAndJoinCommunity(
                         community: newCommunity,
                         apartmentNumber: creatorApartment,
                       );

                       if (createdCommunity != null && mounted) { // Check mounted after await
                         _showSnackbar('Community created and joined successfully!');
                         Navigator.pop(context); // Go back after creation
                       } else if (mounted){
                         _showSnackbar('Failed to create community.', isError: true);
                       }
                     } else if (creatorApartment != null){ // User pressed OK but left field empty
                        _showSnackbar('Your apartment number is required to create a community.', isError: true);
                     } // If null, user cancelled dialog
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
   // --- Dialog to get apartment number for creating ---
  Future<String?> _showCreateDialog() {
     final TextEditingController apartmentController = TextEditingController();
     return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
           title: const Text('Enter Your Apartment Number'),
           content: Column(
             mainAxisSize: MainAxisSize.min, // Prevent dialog from expanding too much
             children: [
                const Text("You'll be the first member and an admin."),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Apartment/Flat Number',
                  hint: 'e.g., A-101, #204',
                  controller: apartmentController,
                  autofocus: true,
                ),
             ],
           ),
           actions: [
              TextButton(
                 onPressed: () => Navigator.pop(context, null), // Cancel
                 child: const Text('Cancel'),
              ),
              TextButton(
                 onPressed: () => Navigator.pop(context, apartmentController.text.trim()), // Confirm
                 child: const Text('Create & Join'),
              ),
           ],
        ),
     );
  }
 // --- ---

}