import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);

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
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Overview', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Journal Entries', value: journals.length.toString(), icon: Icons.book)),
                      const SizedBox(width: 16),
                      Expanded(child: _StatCard(title: 'Total OCD Events', value: ocds.length.toString(), icon: Icons.warning_amber_rounded)),
                      const SizedBox(width: 16),
                      Expanded(child: _StatCard(title: 'Avg Distress', value: avgDistress.toStringAsFixed(1), icon: Icons.trending_up)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Breakdown', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Obsessions', value: totalObsessions.toString(), icon: Icons.psychology)),
                      const SizedBox(width: 16),
                      Expanded(child: _StatCard(title: 'Compulsions', value: totalCompulsions.toString(), icon: Icons.touch_app)),
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

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
