import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../widgets/window_controls.dart';

/// Desktop Today / Home cockpit.
class DesktopHomeScreen extends ConsumerWidget {
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenTrack;
  final VoidCallback onOpenRecovery;
  final VoidCallback onOpenInsights;
  final VoidCallback onOpenSettings;

  const DesktopHomeScreen({
    super.key,
    required this.onOpenJournal,
    required this.onOpenTrack,
    required this.onOpenRecovery,
    required this.onOpenInsights,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final journals = ref.watch(journalProvider).asData?.value ?? const [];
    final ocds = ref.watch(ocdProvider).asData?.value ?? const [];
    final delays = ref.watch(delaySessionProvider).asData?.value ?? const [];
    final erp = ref.watch(erpExerciseSessionProvider).asData?.value ?? const [];
    final steps = ref.watch(exposureStepProvider).asData?.value ?? const [];
    final responses =
        ref.watch(responsePreventionProvider).asData?.value ?? const [];
    final surfs = ref.watch(urgeSurfProvider).asData?.value ?? const [];

    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasCheckedIn = journals.any((entry) => entry.date == todayKey);
    
    final metrics = AnalyticsService.buildRecoveryMetrics(
      delaySessions: delays,
      erpSessions: erp,
      exposureSteps: steps,
      responsePreventionLogs: responses,
      urgeSurfSessions: surfs,
    );
    final dashboard = AnalyticsService.buildRecoveryDashboard(
      journals: journals,
      ocds: ocds,
      delaySessions: delays,
      erpSessions: erp,
      exposureSteps: steps,
      responsePreventionLogs: responses,
      urgeSurfSessions: surfs,
    );
    
    final recentDelay = _latestDelay(delays);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    // Calculate dynamic check-in status for the last 7 days
    final today = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      final hasJournal = journals.any((e) => e.date == dateKey);
      final hasOcd = ocds.any((e) => DateFormat('yyyy-MM-dd').format(e.datetime) == dateKey);
      final hasDelay = delays.any((e) => DateFormat('yyyy-MM-dd').format(e.createdAt) == dateKey);
      final hasErp = erp.any((e) => DateFormat('yyyy-MM-dd').format(e.createdAt) == dateKey);
      final hasResponse = responses.any((e) => DateFormat('yyyy-MM-dd').format(e.createdAt) == dateKey);
      final hasSurf = surfs.any((e) => DateFormat('yyyy-MM-dd').format(e.createdAt) == dateKey);
      
      final active = hasJournal || hasOcd || hasDelay || hasErp || hasResponse || hasSurf;
      final weekdayStr = DateFormat('E').format(date).substring(0, 1);
      return (weekdayStr, active);
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            ),
          ),
          child: AppBar(
            toolbarHeight: 48,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Home',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: onOpenSettings,
                icon: const Icon(LineIcons.cog, size: 18),
              ),
              const WindowControls(),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(40, 36, 40, 48),
            children: [
              // Mockup Header with Sun Icon & Greeting
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 38,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            fontFamily: AppTheme.displayFamily,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "You've got this. One step at a time.",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.light_mode_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Mockup Dashboard Grid Layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Recovery Score & Quick Actions
                  Expanded(
                    child: Column(
                      children: [
                        // Recovery Score Card
                        _DashboardCard(
                          onTap: onOpenInsights,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Recovery score',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    LineIcons.angleRight,
                                    size: 16,
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${dashboard.recoveryScore}',
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 54,
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Great progress',
                                        style: TextStyle(
                                          color: Color(0xFF34C759),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: CustomPaint(
                                        size: const Size(160, 60),
                                        painter: _WavyLinePainter(color: theme.colorScheme.primary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Quick Actions Card
                        _DashboardCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick actions',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _ActionItem(
                                icon: Icons.hourglass_empty_rounded,
                                title: recentDelay != null ? 'Resume compulsion delay' : 'Start compulsion delay',
                                subtitle: recentDelay != null ? 'Pick up where you left off' : 'Practice sitting with urges',
                                onTap: onOpenRecovery,
                              ),
                              const SizedBox(height: 12),
                              _ActionItem(
                                icon: LineIcons.penNib,
                                title: hasCheckedIn ? 'Read today\'s check-in' : 'Daily check-in',
                                subtitle: hasCheckedIn ? 'Open Journal to read or add more' : 'Write a short journal entry',
                                onTap: onOpenJournal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Right Column: Practice Streak & Explore
                  Expanded(
                    child: Column(
                      children: [
                        // Practice Streak Card
                        _DashboardCard(
                          onTap: onOpenInsights,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Practice streak',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    LineIcons.angleRight,
                                    size: 16,
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${metrics.practiceStreakDays}',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 54,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'days',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Weekday Check-in Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for (final (dayLabel, active) in last7Days)
                                    Column(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: active ? theme.colorScheme.primary : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: active ? null : Border.all(color: theme.dividerColor, width: 1.5),
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: active ? Colors.black : theme.dividerColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          dayLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Explore Card
                        _DashboardCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _ExploreTile(
                                icon: LineIcons.penNib,
                                label: 'Journal',
                                subtitle: 'Reflect and process',
                                onTap: onOpenJournal,
                              ),
                              _ExploreTile(
                                icon: Icons.self_improvement_rounded,
                                label: 'Recovery tools',
                                subtitle: 'Support your practice',
                                onTap: onOpenRecovery,
                              ),
                              _ExploreTile(
                                icon: LineIcons.list,
                                label: 'Track',
                                subtitle: 'Log thoughts and urges',
                                onTap: onOpenTrack,
                              ),
                              _ExploreTile(
                                icon: LineIcons.barChart,
                                label: 'Insights',
                                subtitle: 'See your patterns',
                                onTap: onOpenInsights,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DelaySession? _latestDelay(List<DelaySession> sessions) {
    DelaySession? latest;
    for (final session in sessions) {
      if (latest == null || session.createdAt.isAfter(latest.createdAt)) {
        latest = session;
      }
    }
    return latest;
  }
}

/// Generic container matching the dark themed dashboard cards in the mockup
class _DashboardCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _DashboardCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Quick action inner item
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explore item
class _ExploreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ExploreTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LineIcons.angleRight,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wavy score painter that draws the yellow progression line exactly like the mock
class _WavyLinePainter extends CustomPainter {
  final Color color;

  _WavyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.25, size.height * 0.9,
      size.width * 0.25, size.height * 0.3,
      size.width * 0.5, size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.75, size.height * 0.9,
      size.width * 0.75, size.height * 0.1,
      size.width, size.height * 0.3,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
