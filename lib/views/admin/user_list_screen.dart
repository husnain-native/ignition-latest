import 'package:flutter/material.dart';
import 'package:ignition/services/auth_service.dart';
import 'package:ignition/models/user_model.dart';
import 'package:ignition/theme/app_colors.dart';
import 'package:ignition/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Remove _usersFuture and _fetchUsers

  Stream<List<UserModel>> _userStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return UserModel.fromJson(data);
              }).toList(),
        );
  }

  Future<void> _deleteUser(String userId) async {
    final url = 'https://fcm-backend-q97m.onrender.com/delete-user';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': userId}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User deleted successfully.')));
      } else {
        throw Exception(data['error'] ?? 'Failed to delete user');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete User'),
            content: Text('Are you sure you want to delete ${user.fullName}?'),
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

  void _showUserDetailDialog(UserModel user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isResetting = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('User Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Name required'
                                    : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        enabled: false, // Email is not editable
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Phone required'
                                    : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving || isResetting
                          ? null
                          : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed:
                      isSaving || isResetting
                          ? null
                          : () async {
                            if (!(formKey.currentState?.validate() ?? false))
                              return;
                            setState(() => isSaving = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.id)
                                  .update({
                                    'fullName': nameController.text.trim(),
                                    'phoneNumber': phoneController.text.trim(),
                                  });
                              if (context.mounted) Navigator.of(context).pop();
                              if (mounted)
                                setState(() {
                                  // _usersFuture = _fetchUsers(); // This line is removed
                                });
                            } catch (e) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                          'Failed to update user: $e',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            }
                            setState(() => isSaving = false);
                          },
                  child:
                      isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed:
                      isSaving || isResetting
                          ? null
                          : () async {
                            setState(() => isResetting = true);
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                    email: emailController.text.trim(),
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          'Password Reset Email Sent',
                                        ),
                                        content: Text(
                                          'A password reset email has been sent to ${emailController.text.trim()}.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                          'Failed to send reset email: $e',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            }
                            setState(() => isResetting = false);
                          },
                  child:
                      isResetting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Send Password Reset Email'),
                ),
              ],
            );
          },
        );
      },
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
      body: StreamBuilder<List<UserModel>>(
        stream: _userStream(),
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
              width: 370.w,
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
                columnSpacing: 40.w,
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
                      DataCell(
                        Text(user.fullName, style: AppTextStyles.body1),
                        onTap: () => _showUserDetailDialog(user),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 82, 10, 5),
                          ),
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
