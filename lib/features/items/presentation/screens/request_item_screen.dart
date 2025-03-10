// lib/features/items/presentation/screens/request_item_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/item_controller.dart';
import '../../data/models/item_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../community/controller/community_controller.dart';

class RequestItemScreen extends StatefulWidget {
  const RequestItemScreen({Key? key}) : super(key: key);

  @override
  _RequestItemScreenState createState() => _RequestItemScreenState();
}

class _RequestItemScreenState extends State<RequestItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedDuration = 'days';
  String? _selectedCommunityId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isUrgent = false;
  
  List<Map<String, String>> _durationOptions = [
    {'value': 'hours', 'label': 'Hours'},
    {'value': 'days', 'label': 'Days'},
    {'value': 'weeks', 'label': 'Weeks'},
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Fetch user communities on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityController>(context, listen: false).fetchUserCommunities();
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now(),
      end: _endDate ?? DateTime.now().add(Duration(days: 7)),
    );
    
    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final communityController = Provider.of<CommunityController>(context);
    final itemController = Provider.of<ItemController>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Request an Item'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              Text(
                'Item Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Item Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Item Name',
                hintText: 'What do you need to borrow?',
                prefixIcon: Icons.shopping_bag,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Provide details about the item you need',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 24),
              Text(
                'Duration & Community',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Date Range
              ListTile(
                title: Text('Date Range'),
                subtitle: Text(
                  _startDate != null && _endDate != null
                      ? '${_formatDate(_startDate!)} to ${_formatDate(_endDate!)}'
                      : 'Select dates',
                ),
                leading: Icon(Icons.date_range, color: AppConstants.primaryColor),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () => _selectDateRange(context),
              ),
              const Divider(),
              // Alternative Duration
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _durationController,
                      labelText: 'Duration',
                      hintText: 'Duration',
                      prefixIcon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      decoration: InputDecoration(
                        labelText: 'Time Unit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: _durationOptions
                          .map((option) => DropdownMenuItem(
                                value: option['value'],
                                child: Text(option['label']!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDuration = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Community Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Community',
                  hintText: 'Select community',
                  prefixIcon: Icon(Icons.apartment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                value: _selectedCommunityId,
                items: communityController.userCommunities
                    .map((community) => DropdownMenuItem(
                          value: community.id,
                          child: Text(community.name),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a community';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedCommunityId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Urgent Switch
              SwitchListTile(
                title: Text('Mark as Urgent'),
                subtitle: Text('Prioritize your request in the community feed'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value;
                  });
                },
                activeColor: AppConstants.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              // Submit Button
              CustomButton(
                text: 'Post Request',
                isLoading: itemController.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Need either date range or duration
                    if ((_startDate == null || _endDate == null) && 
                        (_durationController.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please specify either a date range or duration')),
                      );
                      return;
                    }
                    
                    final newItem = Item(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      communityId: _selectedCommunityId!,
                      startDate: _startDate,
                      endDate: _endDate,
                      duration: _durationController.text.isNotEmpty
                          ? int.tryParse(_durationController.text) ?? 0
                          : null,
                      durationUnit: _selectedDuration,
                      isUrgent: _isUrgent,
                      status: ItemStatus.pending,
                    );
                    
                    final itemId = await itemController.createItemRequest(newItem);
                    
                    if (itemId != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request posted successfully!')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to post request. Please try again.')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryColorLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'How It Works',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Create a request for an item you need to borrow. Community members will be notified and can offer to lend you the item.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}