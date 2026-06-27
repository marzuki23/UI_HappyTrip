import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../services/trip_log_service.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        children: [
          // ── KARTU PROFIL USER ──
          _buildProfileCard(),

          const SizedBox(height: 24),

          // ── MENU SECTION ──
          _buildMenuSection(),

          const SizedBox(height: 24),

          // ── TOMBOL LOGOUT ──
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  KARTU PROFIL
  // ─────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003D6B), Color(0xFF0061A8), Color(0xFF0097D6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0061A8).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle background
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            controller.userName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            controller.userEmail.value,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          )),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            const Text(
                              "Happy Traveler",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MENU SECTION
  // ─────────────────────────────────────────────
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── LOG AKTIVITAS ──
          Obx(() {
            final count = TripLogService.to.logs.length;
            return _MenuItem(
              icon: Icons.history_rounded,
              iconColor: const Color(0xFF0061A8),
              iconBg: const Color(0xFFE8F0FE),
              title: "Log Aktivitas",
              subtitle: count == 0 ? "Belum ada perjalanan" : "$count perjalanan tersimpan",
              trailing: count > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0061A8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$count",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    )
                  : null,
              onTap: () => Get.toNamed(Routes.ACTIVITY_LOG),
              showDivider: true,
            );
          }),

          // ── TENTANG APLIKASI ──
          _MenuItem(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFE0F2FE),
            title: "Tentang Aplikasi",
            subtitle: "HappyTrip v1.0.0",
            onTap: () {
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF003D6B), Color(0xFF0061A8)]),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text("HappyTrip",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                        const SizedBox(height: 6),
                        Text("Versi 1.0.0",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        const SizedBox(height: 12),
                        Text(
                          "Aplikasi perencanaan perjalanan wisata yang membantu Anda merencanakan itinerary dengan cerdas.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0061A8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Tutup",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TOMBOL LOGOUT
  // ─────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _MenuItem(
        icon: Icons.logout_rounded,
        iconColor: const Color(0xFFDC2626),
        iconBg: const Color(0xFFFEF2F2),
        title: "Keluar",
        subtitle: "Logout dari akun",
        titleColor: const Color(0xFFDC2626),
        onTap: () => controller.logoutUser(),
        showDivider: false,
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  WIDGET MENU ITEM REUSABLE
// ═══════════════════════════════════════════════
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.trailing,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: titleColor ?? const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  // Trailing widget atau default arrow
                  if (trailing != null) ...[
                    trailing!,
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 76,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}