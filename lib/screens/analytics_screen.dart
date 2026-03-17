import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: journalAsync.when(
        data: (journals) {
          return ocdAsync.when(
            data: (ocds) {
              int totalObsessions = ocds.where((e) => e.type == OcdType.obsession).length;
              int totalCompulsions = ocds.where((e) => e.type == OcdType.compulsion).length;
              double avgDistress = ocds.isEmpty ? 0 : ocds.map((e) => e.distressLevel).reduce((a, b) => a + b) / ocds.length;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                children: [
                  Text('Overview', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Journal Entries', value: journals.length.toString(), icon: LineIcons.book)),
                      const SizedBox(width: 20),
                      Expanded(child: _StatCard(title: 'OCD Events', value: ocds.length.toString(), icon: LineIcons.bullseye)),
                      const SizedBox(width: 20),
                      Expanded(child: _StatCard(title: 'Avg Distress', value: avgDistress.toStringAsFixed(1), icon: LineIcons.areaChart)),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text('Breakdown', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Obsessions', 
                          value: totalObsessions.toString(), 
                          icon: LineIcons.brain,
                          color: Colors.blueAccent,
                        )
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          title: 'Compulsions', 
                          value: totalCompulsions.toString(), 
                          icon: LineIcons.fingerprint,
                          color: Colors.orangeAccent,
                        )
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({required this.title, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color ?? theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            value, 
            style: GoogleFonts.inter(
              fontSize: 36, 
              fontWeight: FontWeight.w800, 
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            )
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(), 
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            )
          ),
        ],
      ),
    );
  }
}
