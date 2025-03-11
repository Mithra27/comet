import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:comet/features/items/controller/item_controller.dart';
import 'package:comet/features/items/data/models/item_model.dart'; // Make sure this import contains Item class
import 'package:comet/features/items/presentation/screens/my_items_screen.dart'; // Make sure this import contains MyItemsScreen

// If MyItemsScreen isn't properly imported, create a stub version
// Remove this if MyItemsScreen is already defined in your imported files
class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('MyItemsScreen Stub'),
      ),
    );
  }
}

// Create a stub Item class and ItemStatus enum if they're missing from your imports
// Remove these if they're already defined in your imported files
class Item {
  final String id;
  final String name;
  final String description;
  final String requesterId;
  final DateTime createdAt;
  final ItemStatus status;
  final String? lenderId;
  final bool isUrgent;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.requesterId,
    required this.createdAt,
    required this.status,
    this.lenderId,
    required this.isUrgent,
  });
}

enum ItemStatus { pending, accepted, completed }

// Generate mocks with mockito's build_runner
class MockItemController extends Mock implements ItemController {
  // These should match the actual properties in ItemController
  @override
  List<Item> userItems = [];
  
  @override
  bool isLoading = false;
  
  @override
  String currentUserId = 'test-user-id';
}

void main() {
  late MockItemController mockItemController;
  
  setUp(() {
    mockItemController = MockItemController();
  });
  
  testWidgets('MyItemsScreen shows loading indicator when isLoading is true', 
      (WidgetTester tester) async {
    // Setup
    mockItemController.isLoading = true;
    
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ItemController>.value(
          value: mockItemController,
          child: const MyItemsScreen(),
        ),
      ),
    );
    
    // Verify
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  testWidgets('MyItemsScreen shows empty state when no items', 
      (WidgetTester tester) async {
    // Setup
    mockItemController.isLoading = false;
    mockItemController.userItems = [];
    
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ItemController>.value(
          value: mockItemController,
          child: const MyItemsScreen(),
        ),
      ),
    );
    
    // Verify - should find at least one of the empty state texts
    expect(find.text('No Active Requests'), findsOneWidget);
  });
  
  testWidgets('MyItemsScreen shows item cards when items are available', 
      (WidgetTester tester) async {
    // Setup
    mockItemController.isLoading = false;
    mockItemController.userItems = [
      Item(
        id: 'test-id-1',
        name: 'Test Item 1',
        description: 'Test Description 1',
        requesterId: 'test-user-id',
        createdAt: DateTime.now(),
        status: ItemStatus.pending,
        isUrgent: false,
      ),
      Item(
        id: 'test-id-2',
        name: 'Test Item 2',
        description: 'Test Description 2',
        requesterId: 'test-user-id',
        createdAt: DateTime.now(),
        status: ItemStatus.accepted,
        lenderId: 'lender-id',
        isUrgent: true,
      ),
    ];
    
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ItemController>.value(
          value: mockItemController,
          child: const MyItemsScreen(),
        ),
      ),
    );
    
    // Verify
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('Test Description 1'), findsOneWidget);
    expect(find.text('URGENT'), findsOneWidget); // From the urgent item
  });

  testWidgets('MyItemsScreen tabs navigation works', 
      (WidgetTester tester) async {
    // Setup
    mockItemController.isLoading = false;
    
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ItemController>.value(
          value: mockItemController,
          child: const MyItemsScreen(),
        ),
      ),
    );
    
    // Initial tab should be "My Requests"
    expect(find.text('No Active Requests'), findsOneWidget);
    
    // Tap on the second tab (Lending)
    await tester.tap(find.text('Lending'));
    await tester.pumpAndSettle();
    
    // Should find the empty state for Lending
    expect(find.text('No Lending Items'), findsOneWidget);
    
    // Tap on the third tab (Completed)
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    
    // Should find the empty state for Completed
    expect(find.text('No Completed Exchanges'), findsOneWidget);
  });
}
