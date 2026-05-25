import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/app_colors.dart';
import '../../../core/detection_constants.dart';
import '../../monitoring/presentation/monitoring_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onStartRecording(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!context.mounted) return;

    if (status.isGranted) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const MonitoringScreen(),
        ),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Camera access is required. Open Settings to enable it.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera permission is needed to monitor the pool.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Pool monitoring',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Place the device facing the pool, then start recording. '
                'Inference runs every ${DetectionConstants.sampleInterval.inSeconds} '
                'seconds after each run finishes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: () => _onStartRecording(context),
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Start recording'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
