import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/funds_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/members_service.dart';
import '../../../members/domain/models/member_model.dart';

class FundsPage extends StatefulWidget {
  const FundsPage({super.key});

  @override
  State<FundsPage> createState() => _FundsPageState();
}

class _FundsPageState extends State<FundsPage> {
  List<Map<String, dynamic>> fundTransactions = [];
  List<Member> members = [];
  bool _isLoading = true;
  double totalFunds = 0.0;
  int _messId = 1;
  int _userId = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUserData();
    await _loadMembers();
    await _loadFunds();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      _messId = int.tryParse(userData['mess_id'] ?? '') ?? 1;
      _userId = int.tryParse(userData['user_id'] ?? '') ?? 1;
    });
  }

  Future<void> _loadMembers() async {
    final result = await MembersService.getMembers();
    if (result['status'] == true) {
      final List<dynamic> membersData = result['data'] ?? [];
      setState(() {
        members = membersData.map((json) => Member.fromJson(json)).toList();
      });
    }
  }

  String _getMemberName(int? userId) {
    if (userId == null) return 'Unknown';
    final member = members.firstWhere(
      (m) => m.id == userId,
      orElse: () => Member(
        id: 0,
        roleId: 0,
        role: '',
        name: 'Unknown',
        email: '',
        phone: '',
        dob: '',
        aadharNo: '',
        guardianName: '',
        guardianPhone: '',
        status: 0,
      ),
    );
    return member.name;
  }

  Future<void> _loadFunds() async {
    setState(() {
      _isLoading = true;
    });

    final result = await FundsService.getFunds();

    if (!mounted) return;

    if (result['status'] == true) {
      final Map<String, dynamic> data = result['data'] ?? {};
      final List<dynamic> fundsData = data['list'] ?? [];
      final double totalFundFromApi =
          double.tryParse(data['total_fund']?.toString() ?? '0') ?? 0.0;

      setState(() {
        fundTransactions = fundsData.map((item) {
          return {
            'id': item['id'].toString(),
            'memberId': item['user_id'],
            'memberName': _getMemberName(item['user_id']),
            'amount': double.tryParse(item['amount'].toString()) ?? 0.0,
            'date': _parseDate(item['fund_date']),
            'notes': item['notes'] ?? '',
            'fundDate': _formatDateForApi(item['fund_date']),
          };
        }).toList();
        totalFunds = totalFundFromApi > 0
            ? totalFundFromApi
            : fundTransactions.fold(
                0.0,
                (sum, item) => sum + (item['amount'] as double),
              );
        _isLoading = false;
      });
    } else {
      setState(() {
        fundTransactions = [];
        totalFunds = 0.0;
        _isLoading = false;
      });
    }
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr).toLocal();
      }
      final parts = dateStr.split('-');
      if (parts.length == 3 && parts[0].length <= 2) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatDateForApi(String? apiDateStr) {
    try {
      final date = _parseDate(apiDateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
  }

  void _showAddFundDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddFundSheet(messId: _messId, userId: _userId, members: members),
    );

    if (result == true) {
      _showSuccessMessage('Fund added successfully');
      _loadFunds();
    }
  }

  // ADDED: Edit fund function
  void _editFund(Map<String, dynamic> fund) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFundSheet(
        messId: _messId,
        userId: _userId,
        members: members,
        isEditing: true,
        initialFund: fund,
      ),
    );

    if (result == true) {
      _showSuccessMessage('Fund updated successfully');
      _loadFunds();
    }
  }

  void _deleteFund(Map<String, dynamic> fund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Delete Fund'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this fund transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final result = await FundsService.deleteFund(
                id: int.parse(fund['id']),
                messId: _messId,
                userId: fund['memberId'] ?? _userId,
                fundDate: fund['fundDate'],
                amount: fund['amount'],
                notes: fund['notes'],
              );

              if (result['status'] == true) {
                _showSuccessMessage('Fund deleted successfully');
                _loadFunds();
              } else {
                setState(() => _isLoading = false);
                _showErrorMessage(result['message'] ?? 'Failed to delete fund');
              }
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: HugeIcons.strokeRoundedWallet01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Fund Management',
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
              icon: HugeIcons.strokeRoundedRefresh,
              color: Colors.black,
              size: 24,
            ),
            onPressed: _loadFunds,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFunds,
        child: _isLoading
            ? _buildShimmerLoading()
            : Column(
                children: [
                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Funds',
                            value: '₹${totalFunds.toStringAsFixed(0)}',
                            icon: HugeIcons.strokeRoundedWallet01,
                            color: AppColors.success,
                            gradient: [
                              AppColors.success,
                              const Color(0xFF059669),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Transactions',
                            value: '${fundTransactions.length}',
                            icon: HugeIcons.strokeRoundedReceiptDollar,
                            color: AppColors.primary,
                            gradient: [AppColors.primary, AppColors.secondary],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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
                          hintText: 'Search fund transactions...',
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction List
                  Expanded(
                    child: fundTransactions.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: fundTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = fundTransactions[index];
                              return _buildTransactionItem(transaction);
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFundDialog,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPlusSignCircle,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Add Fund',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < 3; i++) ...[
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ],
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
                  icon: HugeIcons.strokeRoundedWallet01,
                  color: Colors.grey.shade400,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No fund transactions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first fund to get started',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return GestureDetector(
      onLongPress: () => _deleteFund(transaction),
      onTap: () => _editFund(transaction), // ADDED: Tap to edit
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
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: AppColors.success,
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
                          transaction['memberName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '+₹${transaction['amount'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction['notes'],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                        ).format(transaction['date']),
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
            // ADDED: Edit button alongside delete button
            Row(
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit01,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  onPressed: () => _editFund(transaction),
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
                  onPressed: () => _deleteFund(transaction),
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

// Add Fund Sheet
class AddFundSheet extends StatefulWidget {
  final int messId;
  final int userId;
  final List<Member> members;
  final bool isEditing; // ADDED
  final Map<String, dynamic>? initialFund; // ADDED

  const AddFundSheet({
    super.key,
    required this.messId,
    required this.userId,
    required this.members,
    this.isEditing = false, // ADDED
    this.initialFund, // ADDED
  });

  @override
  State<AddFundSheet> createState() => _AddFundSheetState();
}

class _AddFundSheetState extends State<AddFundSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedMemberId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ADDED: Initialize with existing data if editing
    if (widget.isEditing && widget.initialFund != null) {
      _selectedMemberId = widget.initialFund!['memberId'];
      _amountController.text = widget.initialFund!['amount'].toStringAsFixed(0);
      _notesController.text = widget.initialFund!['notes'];
      _selectedDate = widget.initialFund!['date'];
    }
  }

  @override
  void dispose() {
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
      final memberName = widget.members
          .firstWhere(
            (m) => m.id == _selectedMemberId,
            orElse: () => Member(
              id: 0,
              roleId: 0,
              role: '',
              name: 'Unknown',
              email: '',
              phone: '',
              dob: '',
              aadharNo: '',
              guardianName: '',
              guardianPhone: '',
              status: 0,
            ),
          )
          .name;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: widget.isEditing ? AppColors.warning : AppColors.success,
              ), // MODIFIED
              const SizedBox(width: 8),
              Text(
                widget.isEditing
                    ? 'Confirm Fund Update'
                    : 'Confirm Fund Addition',
              ), // MODIFIED
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing
                    ? 'Are you sure you want to update this fund?'
                    : 'Are you sure you want to add this fund?',
              ), // MODIFIED
              const SizedBox(height: 16),
              _buildConfirmationItem('Member:', memberName),
              _buildConfirmationItem(
                'Amount:',
                '₹${amount.toStringAsFixed(0)}',
              ),
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
                    : AppColors.success, // MODIFIED
                foregroundColor: Colors.white,
              ),
              child: Text(widget.isEditing ? 'Update' : 'Confirm'), // MODIFIED
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

    final fundDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
    final amount = double.parse(_amountController.text);
    final notes = _notesController.text.isEmpty
        ? 'Fund contribution'
        : _notesController.text;

    // MODIFIED: Handle both add and edit
    final result = widget.isEditing
        ? await FundsService.editFund(
            id: int.parse(widget.initialFund!['id']),
            messId: widget.messId,
            userId: _selectedMemberId ?? widget.userId,
            fundDate: fundDate,
            amount: amount,
            notes: notes,
          )
        : await FundsService.addFund(
            messId: widget.messId,
            userId: _selectedMemberId ?? widget.userId,
            fundDate: fundDate,
            amount: amount,
            notes: notes,
          );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['status'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                result['message'] ??
                    (widget.isEditing
                        ? 'Failed to update fund'
                        : 'Failed to add fund'),
              ), // MODIFIED
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                          : AppColors.success.withOpacity(0.1), // MODIFIED
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: widget.isEditing
                            ? HugeIcons.strokeRoundedEdit01
                            : HugeIcons.strokeRoundedMoneyAdd01, // MODIFIED
                        color: widget.isEditing
                            ? AppColors.warning
                            : AppColors.success, // MODIFIED
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing ? 'Edit Fund' : 'Add New Fund', // MODIFIED
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Member Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Member',
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMemberId,
                        isExpanded: true,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Choose a member',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                        items: widget.members.map((member) {
                          return DropdownMenuItem<int>(
                            value: member.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(member.name),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedMemberId = value);
                        },
                      ),
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
                            icon: HugeIcons.strokeRoundedDollar01,
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
                            icon: HugeIcons.strokeRoundedArrowDown01,
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

              // Notes
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
                        hintText: 'Add notes about this fund',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedMessage01,
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
                      : AppColors.success, // MODIFIED
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: widget.isEditing
                      ? AppColors.warning.withOpacity(0.3)
                      : AppColors.success.withOpacity(0.3), // MODIFIED
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
                        widget.isEditing
                            ? 'UPDATE FUND'
                            : 'ADD FUND', // MODIFIED
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
