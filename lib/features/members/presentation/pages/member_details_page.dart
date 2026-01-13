import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/models/member_model.dart';

class MemberDetailsPage extends StatelessWidget {
  final Member member;

  const MemberDetailsPage({super.key, required this.member});

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
                  icon: HugeIcons.strokeRoundedUser,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Member Details',
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
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedEdit01,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: member.userPhoto != null
                            ? ClipOval(
                                child: Image.network(
                                  member.userPhoto!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedUser,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                      ),
                      if (member.isActive)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(member.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: _getRoleIcon(member.role),
                                color: _getRoleColor(member.role),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                member.role.toUpperCase(),
                                style: TextStyle(
                                  color: _getRoleColor(member.role),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedId,
                              color: AppColors.textSecondary,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '#${member.id.toString().padLeft(4, '0')}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact Info Section
            _buildSection(
              title: 'Contact Information',
              icon: HugeIcons.strokeRoundedFlipPhone,
              children: [
                _buildCompactInfoRow(
                  icon: HugeIcons.strokeRoundedPhoneCheck,
                  label: 'Phone',
                  value: member.phone,
                  onTap: () {},
                ),
                _buildCompactInfoRow(
                  icon: HugeIcons.strokeRoundedMail01,
                  label: 'Email',
                  value: member.email,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Personal Details Section
            _buildSection(
              title: 'Personal Details',
              icon: HugeIcons.strokeRoundedUser,
              children: [
                if (member.dob.isNotEmpty)
                  _buildCompactInfoRow(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    label: 'Date of Birth',
                    value: member.dob,
                  ),
                if (member.aadharNo.isNotEmpty)
                  _buildCompactInfoRow(
                    icon: HugeIcons.strokeRoundedId,
                    label: 'Aadhar Number',
                    value: member.aadharNo,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Guardian Information
            if (member.guardianName.isNotEmpty ||
                member.guardianPhone.isNotEmpty)
              _buildSection(
                title: 'Guardian Information',
                icon: HugeIcons.strokeRoundedShieldUser,
                children: [
                  if (member.guardianName.isNotEmpty)
                    _buildCompactInfoRow(
                      icon: HugeIcons.strokeRoundedUser02,
                      label: 'Guardian Name',
                      value: member.guardianName,
                    ),
                  if (member.guardianPhone.isNotEmpty)
                    _buildCompactInfoRow(
                      icon: HugeIcons.strokeRoundedPhoneDeveloperMode,
                      label: 'Guardian Phone',
                      value: member.guardianPhone,
                      onTap: () {},
                    ),
                ],
              ),
            if (member.guardianName.isNotEmpty ||
                member.guardianPhone.isNotEmpty)
              const SizedBox(height: 16),

            // Status Section
            _buildSection(
              title: 'Account Status',
              icon: HugeIcons.strokeRoundedInformationCircle,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: member.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: member.isActive
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.danger.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: member.isActive
                                ? HugeIcons.strokeRoundedCheckmarkCircle01
                                : HugeIcons.strokeRoundedCancel01,
                            color: member.isActive
                                ? AppColors.success
                                : AppColors.danger,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: member.isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: member.isActive
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.danger.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.isActive ? 'ACTIVE' : 'INACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: member.isActive
                                ? AppColors.success
                                : AppColors.danger,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: HugeIcon(icon: icon, color: AppColors.primary, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildCompactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: AppColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowUpRight01,
                color: AppColors.primary,
                size: 16,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Call',
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.danger;
      case 'manager':
        return AppColors.warning;
      case 'member':
      default:
        return AppColors.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return HugeIcons.strokeRoundedShield01;
      case 'manager':
        return HugeIcons.strokeRoundedSetting06;
      case 'member':
      default:
        return HugeIcons.strokeRoundedUser;
    }
  }
}
