import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/community_controller.dart';
import '../data/models/community_model.dart';
import '../widgets/community_widgets.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import 'join_community_screen.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../items/presentation/screens/request_item_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({Key? key}) : super(key: key);

  @override
  _CommunityFeedScreenState createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<CommunityController>(context, listen: false);
      controller.fetchUserCommunities();
      controller.fetchAllCommunities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communities'),
        backgroundColor: AppConstants.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'My Communities'),
            Tab(text: 'Discover'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<CommunityController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Center(child: LoadingIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // My Communities Tab
              _buildMyCommunities(controller),
              
              // Discover Tab
              _buildDiscoverCommunities(controller),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestItemScreen()),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        child: Icon(Icons.add),
        tooltip: 'Request an item',
      ),
    );
  }

  Widget _buildMyCommunities(CommunityController controller) {
    if (controller.userCommunities.isEmpty) {
      return EmptyCommunityState(
        message: 'You haven\'t joined any communities yet. Discover and join communities to start sharing!',
        onAction: () {
          _tabController.animateTo(1); // Switch to discover tab
        },
        actionLabel: 'Find Communities',
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.only(top: 8, bottom: 80),
      itemCount: controller.userCommunities.length,
      itemBuilder: (context, index) {
        final community = controller.userCommunities[index];
        return CommunityCard(
          community: community,
          isMember: true,
          onTap: () {
            controller.selectCommunity(community);
            // TODO: Navigate to community detail screen
          },
        );
      },
    );
  }

  Widget _buildDiscoverCommunities(CommunityController controller) {
    if (controller.communities.isEmpty) {
      return EmptyCommunityState(
        message: 'No communities available at the moment. Check back later or create your own community!',
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JoinCommunityScreen()),
          );
        },
        actionLabel: 'Join Community',
      );
    }
    
    // Filter out communities the user is already a member of
    final List<Community> communitiesToJoin = controller.communities
        .where((c) => !controller.userCommunities.any((uc) => uc.id == c.id))
        .toList();
    
    if (communitiesToJoin.isEmpty) {
      return EmptyCommunityState(
        message: 'You\'ve joined all available communities!',
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.only(top: 8, bottom: 80),
      itemCount: communitiesToJoin.length,
      itemBuilder: (context, index) {
        final community = communitiesToJoin[index];
        return CommunityCard(
          community: community,
          isMember: false,
          onTap: () {
            controller.selectCommunity(community);
            // TODO: Navigate to community detail screen
          },
          onJoin: () async {
            final success = await controller.joinCommunity(community.id);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully joined ${community.name}!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to join community. Please try again.')),
              );
            }
          },
        );
      },
    );
  }
}