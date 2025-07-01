import 'package:flutter/material.dart';
import '../../models/workspace_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<WorkspaceItem> _items = WorkspaceItem.getDummyItems();
  String _selectedType = 'all';
  int _selectedIndex = 0;

  List<WorkspaceItem> get _filteredItems {
    if (_selectedType == 'all') return _items;
    return _items.where((item) => item.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.text,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Implement profile
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Welcome to Ignition',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.text,
                fontSize: 24.sp,
              ),
            ),
          ),
          _buildFeatureGrid(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 ? AppColors.primary : AppColors.text,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.space_dashboard_outlined,
              color: _selectedIndex == 1 ? AppColors.primary : AppColors.text,
            ),
            label: 'Spaces',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: _selectedIndex == 2 ? AppColors.primary : AppColors.text,
            ),
            label: 'Bookings',
          ),
          
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: _selectedIndex == 3 ? AppColors.primary : AppColors.text,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'Book a Space',
        'route': AppConstants.bookingRoute,
      },
      {
        'icon': Icons.space_dashboard,
        'title': 'View Spaces',
        'route': AppConstants.spaceDetailsRoute,
      },
      {
        'icon': Icons.history,
        'title': 'My Bookings',
        'route': AppConstants.bookingRoute,
      },
      {
        'icon': Icons.support_agent,
        'title': 'Support',
        'route': AppConstants.bookingRoute,
      },
    ];

    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          final isSelected = index == _selectedIndex;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap:
                  () =>
                      Navigator.pushNamed(context, feature['route'] as String),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 32.w,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      feature['title'] as String,
                      style: AppTextStyles.body1.copyWith(
                        color: isSelected ? Colors.white : AppColors.text,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          color: isSelected ? Colors.white : AppColors.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
      backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildItemCard(WorkspaceItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getItemIcon(item.type),
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  if (!item.isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(128),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Booked',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Item Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.capacity} ${item.capacity > 1 ? 'people' : 'person'}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.text,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price}/hr',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      if (item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(51),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Available',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'room':
        return Icons.meeting_room;
      case 'table':
        return Icons.table_restaurant;
      case 'chair':
        return Icons.chair;
      default:
        return Icons.space_dashboard;
    }
  }
}
