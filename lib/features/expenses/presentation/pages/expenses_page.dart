import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../funds/presentation/pages/funds_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  // Sample data - in real app, this would come from a database
  List<Map<String, dynamic>> expenses = [
    {
      'id': '1',
      'purpose': 'Grocery Shopping',
      'amount': 1250.0,
      'date': DateTime.now(),
      'addedBy': 'Mainak',
      'category': 'Food',
    },
    {
      'id': '2',
      'purpose': 'Electric Bill',
      'amount': 2400.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'addedBy': 'Rahul',
      'category': 'Utilities',
    },
    {
      'id': '3',
      'purpose': 'Water Bill',
      'amount': 800.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'addedBy': 'Priya',
      'category': 'Utilities',
    },
    {
      'id': '4',
      'purpose': 'Internet Bill',
      'amount': 1200.0,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'addedBy': 'Mainak',
      'category': 'Utilities',
    },
    {
      'id': '5',
      'purpose': 'Dinner at Restaurant',
      'amount': 1850.0,
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'addedBy': 'Rahul',
      'category': 'Food',
    },
  ];

  double get totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense['amount']);
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(
        onExpenseAdded: (expense) {
          setState(() {
            expense['id'] = DateTime.now().millisecondsSinceEpoch.toString();
            expense['category'] =
                expense['category'] ?? 'Others'; // Add default category
            expenses.insert(0, expense);
          });
          _showSuccessMessage('Expense added successfully');
        },
      ),
    );
  }

  void _showEditExpenseDialog(Map<String, dynamic> expense, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(
        onExpenseAdded: (updatedExpense) {
          setState(() {
            expenses[index] = {
              ...updatedExpense,
              'id': expense['id'],
              'addedBy': expense['addedBy'],
              'category':
                  updatedExpense['category'] ??
                  'Others', // Ensure category is not null
            };
          });
          _showSuccessMessage('Expense updated successfully');
        },
        isEditing: true,
        initialExpense: expense,
      ),
    );
  }

  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Delete Expense'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                expenses.removeAt(index);
              });
              Navigator.pop(context);
              _showSuccessMessage('Expense deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> totals = {};
    for (var expense in expenses) {
      final category = expense['category'] ?? 'Others'; // Handle null category
      totals[category] = (totals[category] ?? 0) + expense['amount'];
    }
    return totals;
  }

  Color getCategoryColor(String category) {
    final colors = {
      'Food': AppColors.danger,
      'Utilities': AppColors.primary,
      'Transport': const Color(0xFFF59E0B),
      'Entertainment': AppColors.success,
      'Shopping': const Color(0xFF8B5CF6),
      'Others': AppColors.textSecondary,
    };
    return colors[category] ?? AppColors.textSecondary;
  }

  IconData getCategoryIcon(String category) {
    final icons = {
      'Food': HugeIcons.strokeRoundedRestaurant01,
      'Utilities': HugeIcons.strokeRoundedHome03,
      'Transport': HugeIcons.strokeRoundedCar01,
      'Entertainment': HugeIcons.strokeRoundedGameController01,
      'Shopping': HugeIcons.strokeRoundedShoppingBag02,
      'Others': HugeIcons.strokeRoundedCircle,
    };
    return icons[category] ?? HugeIcons.strokeRoundedCircle;
  }

  String getCategoryName(Map<String, dynamic> expense) {
    return expense['category'] ?? 'Others'; // Handle null category
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = getCategoryTotals();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedReceiptDollar,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Expense Management',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedWallet01,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FundsPage()),
              );
            },
            tooltip: 'Funds',
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Expenses',
                    value: '₹${totalExpenses.toStringAsFixed(0)}',
                    icon: HugeIcons.strokeRoundedArrowUp01,
                    color: AppColors.danger,
                    gradient: [AppColors.danger, const Color(0xFFDC2626)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'This Month',
                    value: '${expenses.length}',
                    icon: HugeIcons.strokeRoundedReceiptDollar,
                    color: AppColors.primary,
                    gradient: [AppColors.primary, AppColors.secondary],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Category Stats (only show if there are categories)
          if (categoryTotals.isNotEmpty) ...[
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categoryTotals.entries.map((entry) {
                  final category = entry.key;
                  final total = entry.value;
                  final percentage = totalExpenses > 0
                      ? (total / totalExpenses * 100).toInt()
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: getCategoryColor(
                                    category,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: HugeIcon(
                                    icon: getCategoryIcon(category),
                                    color: getCategoryColor(category),
                                    size: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${total.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: getCategoryColor(category),
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Expenses List
          Expanded(
            child: expenses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return _buildExpenseItem(expense, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPlusSignCircle,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedReceiptDollar,
                  color: Colors.grey.shade400,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first expense to get started',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense, int index) {
    final categoryName = getCategoryName(expense); // Use helper method
    final categoryColor = getCategoryColor(categoryName);

    return GestureDetector(
      onTap: () => _showEditExpenseDialog(expense, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: getCategoryIcon(categoryName),
                  color: categoryColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expense['purpose'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${expense['amount'].toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(width: 8),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expense['addedBy'],
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar01,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(expense['date']),
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit01,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  onPressed: () => _showEditExpenseDialog(expense, index),
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete01,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onPressed: () => _deleteExpense(index),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Add/Edit Expense Bottom Sheet (Keep as is from previous code)
class AddExpenseSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onExpenseAdded;
  final bool isEditing;
  final Map<String, dynamic>? initialExpense;

  const AddExpenseSheet({
    super.key,
    required this.onExpenseAdded,
    this.isEditing = false,
    this.initialExpense,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';
  final List<String> _categories = [
    'Food',
    'Utilities',
    'Transport',
    'Entertainment',
    'Shopping',
    'Others',
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialExpense != null) {
      _purposeController.text = widget.initialExpense!['purpose'];
      _amountController.text = widget.initialExpense!['amount'].toStringAsFixed(
        0,
      );
      _selectedDate = widget.initialExpense!['date'];
      _selectedCategory =
          widget.initialExpense!['category'] ?? 'Others'; // Handle null
      if (widget.initialExpense!.containsKey('notes')) {
        _notesController.text = widget.initialExpense!['notes'];
      }
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showConfirmationDialog() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final purpose = _purposeController.text;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: widget.isEditing ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isEditing
                    ? 'Confirm Expense Update'
                    : 'Confirm Expense Addition',
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing
                    ? 'Are you sure you want to update this expense?'
                    : 'Are you sure you want to add this expense?',
              ),
              const SizedBox(height: 16),
              _buildConfirmationItem('Purpose:', purpose),
              _buildConfirmationItem(
                'Amount:',
                '₹${amount.toStringAsFixed(0)}',
              ),
              _buildConfirmationItem('Category:', _selectedCategory),
              _buildConfirmationItem(
                'Date:',
                DateFormat('dd MMM yyyy').format(_selectedDate),
              ),
              if (_notesController.text.isNotEmpty)
                _buildConfirmationItem('Notes:', _notesController.text),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isEditing
                    ? AppColors.warning
                    : AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: Text(widget.isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    setState(() => _isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final expense = {
      'purpose': _purposeController.text,
      'amount': double.parse(_amountController.text),
      'date': _selectedDate,
      'category': _selectedCategory,
      'addedBy': 'Mainak', // Would come from auth
      'notes': _notesController.text,
    };

    setState(() => _isLoading = false);

    widget.onExpenseAdded(expense);
    Navigator.pop(context);
  }

  Color getCategoryColor(String category) {
    final colors = {
      'Food': AppColors.danger,
      'Utilities': AppColors.primary,
      'Transport': const Color(0xFFF59E0B),
      'Entertainment': AppColors.success,
      'Shopping': const Color(0xFF8B5CF6),
      'Others': AppColors.textSecondary,
    };
    return colors[category] ?? AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isEditing
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: widget.isEditing
                            ? HugeIcons.strokeRoundedEdit01
                            : HugeIcons.strokeRoundedReceiptDollar,
                        color: widget.isEditing
                            ? AppColors.warning
                            : AppColors.danger,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing ? 'Edit Expense' : 'Add New Expense',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Purpose
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purpose',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        hintText: 'Enter expense purpose',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDocumentAttachment,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter purpose';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedDollarCircle,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      padding: const EdgeInsets.all(8),
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? getCategoryColor(category).withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? getCategoryColor(category)
                                    : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: category == 'Food'
                                      ? HugeIcons.strokeRoundedRestaurant01
                                      : category == 'Utilities'
                                      ? HugeIcons.strokeRoundedHome03
                                      : category == 'Transport'
                                      ? HugeIcons.strokeRoundedCar01
                                      : category == 'Entertainment'
                                      ? HugeIcons.strokeRoundedGameController01
                                      : category == 'Shopping'
                                      ? HugeIcons.strokeRoundedShoppingBag02
                                      : HugeIcons.strokeRoundedCircle,
                                  color: getCategoryColor(category),
                                  size: 16,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: getCategoryColor(category),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar01,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowDown02,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes (Optional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add notes about this expense',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedMessage02,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isEditing
                      ? AppColors.warning
                      : AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: widget.isEditing
                      ? AppColors.warning.withOpacity(0.3)
                      : AppColors.danger.withOpacity(0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'UPDATE EXPENSE' : 'ADD EXPENSE',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
