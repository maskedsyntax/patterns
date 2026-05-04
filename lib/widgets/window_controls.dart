import 'package:flutter/widgets.dart';

/// Placeholder kept so existing call sites still compile after window_manager
/// was removed. Renders nothing — desktop window chrome is provided by the
/// host OS.
class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
