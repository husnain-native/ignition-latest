import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/space_model.dart';
import '../../models/booking_model.dart';
import '../../services/space_service.dart';
import '../../services/booking_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../view_models/auth_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpaceDetailsScreen extends StatefulWidget {
  final SpaceModel space;

  const SpaceDetailsScreen({super.key, required this.space});

  @override
  State<SpaceDetailsScreen> createState() => _SpaceDetailsScreenState();
}

class _SpaceDetailsScreenState extends State<SpaceDetailsScreen> {
  final SpaceService _spaceService = SpaceService();
  final BookingService _bookingService = BookingService();
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedTimeSlot;
  bool _isLoading = false;
  List<DateTime> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _isLoading = true);
    try {
      final slots = await _spaceService.getAvailableSlots(
        widget.space.id,
        _selectedDate,
      );
      setState(() {
        _availableSlots = slots;
        _selectedTimeSlot = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load available slots: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadAvailableSlots();
    }
  }

  Future<void> _bookSpace() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthViewModel>().user;
      if (user == null) throw Exception('User not found');

      final booking = BookingModel(
        id: '', // Will be set by the service
        userId: user.uid,
        spaceId: widget.space.id,
        startTime: _selectedTimeSlot!,
        endTime: _selectedTimeSlot!.add(const Duration(hours: 1)),
        totalPrice: widget.space.pricePerHour,
        status: AppConstants.pending,
        createdAt: DateTime.now(),
      );

      await _bookingService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create booking: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Space image and back button
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.space.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            backgroundColor: AppColors.primary,
          ),

          // Space details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.space.name, style: AppTextStyles.h1),
                  SizedBox(height: 8.h),
                  Text(
                    'Rs.${widget.space.pricePerHour}/hr',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                  SizedBox(height: 16.h),
                  Text(widget.space.description, style: AppTextStyles.body1),
                  SizedBox(height: 24.h),

                  // Amenities
                  Text('Amenities', style: AppTextStyles.h3),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                        widget.space.amenities
                            .map(
                              (amenity) => Chip(
                                label: Text(amenity),
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Date selection
                  Text('Select Date', style: AppTextStyles.h3),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: AppTextStyles.body1,
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Time slots
                  Text('Available Time Slots', style: AppTextStyles.h3),
                  SizedBox(height: 8.h),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_availableSlots.isEmpty)
                    const Text('No slots available for this date')
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          _availableSlots
                              .map(
                                (slot) => ChoiceChip(
                                  label: Text('${slot.hour}:00'),
                                  selected: _selectedTimeSlot == slot,
                                  onSelected: (selected) {
                                    setState(
                                      () =>
                                          _selectedTimeSlot =
                                              selected ? slot : null,
                                    );
                                  },
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  SizedBox(height: 32.h),

                  // Book button
                  CustomButton(
                    onPressed: _isLoading ? null : _bookSpace,
                    text: 'Book Now',
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
