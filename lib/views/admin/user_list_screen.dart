import 'package:flutter/material.dart';
import 'package:ignition/services/auth_service.dart';
import 'package:ignition/models/user_model.dart';
import 'package:ignition/theme/app_colors.dart';
import 'package:ignition/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<UserModel>> _fetchUsers() async {
    final usersRaw = await AuthService().getAllUsers();
    return usersRaw.map((data) => UserModel.fromJson(data)).toList();
  }

  Future<void> _deleteUser(String userId) async {
    await AuthService().deleteUser(userId);
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete User'),
            content: Text(
              'Are you sure you want to delete \\${user.fullName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteUser(user.id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color.fromARGB(255, 82, 10, 5)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        titleTextStyle: TextStyle(
          color: AppColors.secondaryDark,
          fontSize: 24.sp,
        ),
        backgroundColor: AppColors.info,
        iconTheme: IconThemeData(color: AppColors.secondaryDark),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 700.w,
              padding: EdgeInsets.all(16.w),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 168, 19, 8).withOpacity(0.8),
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.primary.withOpacity(0.15);
                  }
                  return null;
                }),
                columnSpacing: 24.w,
                columns: [
                  DataColumn(
                    label: Text(
                      'Name',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Email',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Phone',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Delete',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                rows: List<DataRow>.generate(users.length, (index) {
                  final user = users[index];
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (index % 2 == 0) {
                        return Colors.grey[100];
                      }
                      return Colors.white;
                    }),
                    cells: [
                      DataCell(Text(user.fullName, style: AppTextStyles.body1)),
                      DataCell(Text(user.email, style: AppTextStyles.body1)),
                      DataCell(
                        Text(user.phoneNumber, style: AppTextStyles.body1),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(user),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/signup');
        },
        backgroundColor: const Color.fromARGB(255, 110, 23, 11),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
