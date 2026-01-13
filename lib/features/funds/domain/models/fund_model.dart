class Fund {
  final int? id;
  final int messId;
  final int userId;
  final String fundDate;
  final double amount;
  final String notes;
  final int status;
  final String? createdAt;
  final int? createdBy;
  final String? updatedAt;
  final int? updatedBy;
  final String? memberName;

  Fund({
    this.id,
    required this.messId,
    required this.userId,
    required this.fundDate,
    required this.amount,
    required this.notes,
    this.status = 1,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.memberName,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'],
      messId: json['mess_id'] ?? 1,
      userId: json['user_id'] ?? 1,
      fundDate: json['fund_date'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      notes: json['notes'] ?? '',
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'],
      memberName: json['member_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mess_id': messId,
      'user_id': userId,
      'fund_date': fundDate,
      'amount': amount,
      'notes': notes,
      'status': status,
    };
  }

  DateTime get date {
    return _parseDate(fundDate);
  }

  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      // Handle ISO format (2025-12-29T18:30:00.000000Z)
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      }
      // Handle dd-MM-yyyy format
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
}
