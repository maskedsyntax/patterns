import 'package:flutter/material.dart';

import '../../widgets/window_controls.dart';

/// Shared 48px title bar + body for desktop main panes.
class DesktopPageScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget body;
  final Color? backgroundColor;

  const DesktopPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.leading,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
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
            leading: leading,
            automaticallyImplyLeading: false,
            title: Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            actions: [...?actions, const WindowControls()],
          ),
        ),
      ),
      body: body,
    );
  }
}

/// Fixed-width left pane + expandable right pane (Journal / Recovery style).
class DesktopSplitView extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double leftWidth;

  const DesktopSplitView({
    super.key,
    required this.left,
    required this.right,
    this.leftWidth = 280,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: leftWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
            child: left,
          ),
        ),
        Expanded(child: right),
      ],
    );
  }
}

/// Centered dialog used instead of bottom sheets on desktop.
Future<T?> showDesktopDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 560,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 720),
        child: builder(dialogContext),
      ),
    ),
  );
}
