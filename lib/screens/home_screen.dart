import 'package:flutter/material.dart';
import 'tailor_dashboard.dart';
import 'customer_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.12),
              colorScheme.secondary.withOpacity(0.08),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.checkroom,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Grace Tailor Studio',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onBackground
                                        .withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  'Smart bookings • Measurements • Pickup',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Info',
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Grace Tailor Studio',
                              applicationVersion: '1.0.0',
                              children: const [
                                Text(
                                  'Manage tailor bookings, body measurements, '
                                  'and pickup requests in one simple workspace.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Hero section
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Tailoring made modern.',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Choose how you want to continue. '
                                    'Access bookings, measurements, designs, and more from one place.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: const [
                                      _FeatureChip(
                                        icon: Icons.event,
                                        label: 'Visual booking calendar',
                                      ),
                                      _FeatureChip(
                                        icon: Icons.straighten,
                                        label: 'Interactive measurements',
                                      ),
                                      _FeatureChip(
                                        icon: Icons.local_shipping,
                                        label: 'Smart pickup requests',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Illustration
                            if (MediaQuery.of(context).size.width > 600)
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary.withOpacity(0.9),
                                      colorScheme.secondary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary
                                          .withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.design_services,
                                    size: 56,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dashboards section
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          return Flex(
                            direction:
                                isWide ? Axis.horizontal : Axis.vertical,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _DashboardCard(
                                  title: 'I am the Tailor',
                                  subtitle:
                                      'Manage bookings, designs, measurements, and customer complaints.',
                                  accentColor: colorScheme.primary,
                                  icon: Icons.cut,
                                  primaryActionLabel: 'Open Tailor Dashboard',
                                  onPrimaryTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TailorDashboard(),
                                      ),
                                    );
                                  },
                                  chips: const [
                                    'Today\'s bookings',
                                    'Design gallery',
                                    'Customer measurements',
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: isWide ? 16 : 0,
                                  height: isWide ? 0 : 16),
                              Expanded(
                                child: _DashboardCard(
                                  title: 'I am the Customer',
                                  subtitle:
                                      'Book suits visually, track pickups, and manage your own measurements.',
                                  accentColor: Colors.teal,
                                  icon: Icons.person_outline,
                                  primaryActionLabel:
                                      'Open Customer Dashboard',
                                  onPrimaryTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CustomerDashboard(),
                                      ),
                                    );
                                  },
                                  chips: const [
                                    'Cinema-style booking',
                                    'My measurements',
                                    'Pickup & delivery',
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final String primaryActionLabel;
  final VoidCallback onPrimaryTap;
  final List<String> chips;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.primaryActionLabel,
    required this.onPrimaryTap,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map(
                    (c) => Chip(
                      label: Text(
                        c,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: accentColor.withOpacity(0.08),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onPrimaryTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(primaryActionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        icon,
        size: 16,
        color: Colors.blue[700],
      ),
      backgroundColor: Colors.blue[50],
      label: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}


