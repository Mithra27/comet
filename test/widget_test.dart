import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:comet/features/items/controller/item_controller.dart';
import 'package:comet/features/items/data/models/item_model.dart';
import 'package:comet/features/items/presentation/screens/my_items_screen.dart';

// Generate mocks with mockito's build_runner
class MockItemController extends Mock implements ItemController {
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
          child: MyItemsScreen(),
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
          child: MyItemsScreen(),
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
          child: MyItemsScreen(),
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
          child: MyItemsScreen(),
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
