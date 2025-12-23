import 'package:flutter/material.dart';

/// App-wide theme constants for colors, typography, and animations
class AppTheme {
  // ==================== COLOR SYSTEM ====================
  
  // Primary Colors
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryPurple = Color(0xFF9333EA);
  
  // Accent Colors
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentRose = Color(0xFFE11D48);
  
  // Neutral Colors
  static const Color neutralLightGrey = Color(0xFFF3F4F6);
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralDarkSlate = Color(0xFF1E293B);
  static const Color neutralMediumGrey = Color(0xFF64748B);
  
  // Status Colors
  static const Color statusSuccess = accentEmerald;
  static const Color statusWarning = accentAmber;
  static const Color statusError = accentRose;
  static const Color statusInfo = primaryTeal;
  
  // ==================== TYPOGRAPHY ====================
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: neutralDarkSlate,
    letterSpacing: -0.5,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: neutralDarkSlate,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: neutralDarkSlate,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: neutralDarkSlate,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: neutralDarkSlate,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: neutralDarkSlate,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: neutralDarkSlate,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: neutralDarkSlate,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: neutralMediumGrey,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: neutralMediumGrey,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: neutralMediumGrey,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: neutralMediumGrey,
    letterSpacing: 0.5,
  );
  
  // ==================== ANIMATION CONSTANTS ====================
  
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);
  
  static const Curve animationCurve = Curves.easeOutCubic;
  static const Curve animationBounceCurve = Curves.elasticOut;
  
  // ==================== SPACING SYSTEM ====================
  
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2Xl = 48.0;
  
  // ==================== BORDER RADIUS ====================
  
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  
  // ==================== SHADOWS ====================
  
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ==================== HELPER METHODS ====================
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'accepted':
      case 'confirmed':
        return statusSuccess;
      case 'pending':
      case 'in_progress':
        return statusWarning;
      case 'rejected':
      case 'cancelled':
        return statusError;
      default:
        return statusInfo;
    }
  }
  
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: color ?? neutralWhite,
      borderRadius: BorderRadius.circular(radiusLg),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth ?? 2)
          : null,
      boxShadow: shadowMd,
    );
  }
  
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryIndigo,
    foregroundColor: neutralWhite,
    padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryTeal,
    foregroundColor: neutralWhite,
    padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );
  
  static ButtonStyle accentButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentAmber,
    foregroundColor: neutralWhite,
    padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
  );
}
