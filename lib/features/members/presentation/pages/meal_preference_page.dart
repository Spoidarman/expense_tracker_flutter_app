import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';

class MealPreferencePage extends StatefulWidget {
  final String memberName;
  
  const MealPreferencePage({super.key, required this.memberName});

  @override
  State<MealPreferencePage> createState() => _MealPreferencePageState();
}

class _MealPreferencePageState extends State<MealPreferencePage> {
  // Form state
  bool _isSingleDay = true; // true = single day, false = date range
  DateTime _selectedDate = DateTime.now();
  DateTimeRange? _selectedDateRange;
  
  // Meal selection
  bool _wantMealToday = true;
  bool _lunchSelected = true;
  bool _dinnerSelected = true;
  
  String _mealTime = 'both'; // 'lunch', 'dinner', 'both'

  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _handleSubmit() {
    // Prepare data
    String dateInfo;
    if (_isSingleDay) {
      dateInfo = DateFormat('dd MMM yyyy').format(_selectedDate);
    } else if (_selectedDateRange != null) {
      dateInfo = '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    String mealInfo;
    if (_mealTime == 'both') {
      mealInfo = 'Lunch & Dinner';
    } else if (_mealTime == 'lunch') {
      mealInfo = 'Lunch Only';
    } else {
      mealInfo = 'Dinner Only';
    }

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _wantMealToday 
              ? 'Meal preference saved: $mealInfo for $dateInfo'
              : 'Marked as NOT eating for $dateInfo',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Preference'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Member Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.restaurant, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Setting preference for',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.memberName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Want Meal Today Radio Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Do you want meal?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<bool>(
                    title: const Text('Yes, I want meal'),
                    value: true,
                    groupValue: _wantMealToday,
                    activeColor: AppColors.success,
                    onChanged: (value) {
                      setState(() {
                        _wantMealToday = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('No, I don\'t want meal'),
                    value: false,
                    groupValue: _wantMealToday,
                    activeColor: AppColors.danger,
                    onChanged: (value) {
                      setState(() {
                        _wantMealToday = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Meal Time Selection (only show if want meal)
            if (_wantMealToday) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select meal time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.lunch_dining, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          const Text('Lunch Only'),
                        ],
                      ),
                      value: 'lunch',
                      groupValue: _mealTime,
                      activeColor: AppColors.warning,
                      onChanged: (value) {
                        setState(() {
                          _mealTime = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.dinner_dining, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Dinner Only'),
                        ],
                      ),
                      value: 'dinner',
                      groupValue: _mealTime,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _mealTime = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.restaurant, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          const Text('Both Lunch & Dinner'),
                        ],
                      ),
                      value: 'both',
                      groupValue: _mealTime,
                      activeColor: AppColors.success,
                      onChanged: (value) {
                        setState(() {
                          _mealTime = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Date Selection Type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select date preference',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTypeChip(
                          'Single Day',
                          Icons.calendar_today,
                          _isSingleDay,
                          () {
                            setState(() {
                              _isSingleDay = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTypeChip(
                          'Date Range',
                          Icons.date_range,
                          !_isSingleDay,
                          () {
                            setState(() {
                              _isSingleDay = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            if (_isSingleDay)
              InkWell(
                onTap: () => _selectSingleDate(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              )
            else
              InkWell(
                onTap: () => _selectDateRange(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.date_range,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Date Range',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDateRange != null
                                  ? '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                                  : 'Tap to select date range',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedDateRange != null 
                                    ? AppColors.textPrimary 
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (_selectedDateRange != null)
                              Text(
                                '${_selectedDateRange!.duration.inDays + 1} days',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            
            // Submit Button
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Save Preference',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTypeChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
