import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Custom window control buttons (minimize, maximize, close) for Linux and Windows.
/// On macOS, returns an empty widget since native traffic lights are preserved.
class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    _checkMaximized();
  }

  Future<void> _checkMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = maximized);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    const size = 14.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.remove_rounded,
          iconSize: size,
          color: color,
          hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          onTap: () => windowManager.minimize(),
          tooltip: 'Minimize',
        ),
        _ControlButton(
          icon: _isMaximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          iconSize: _isMaximized ? size - 2 : size,
          color: color,
          hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          onTap: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
            _checkMaximized();
          },
          tooltip: _isMaximized ? 'Restore' : 'Maximize',
        ),
        _ControlButton(
          icon: Icons.close_rounded,
          iconSize: size,
          color: color,
          hoverColor: Colors.redAccent.withValues(alpha: 0.15),
          hoverIconColor: Colors.redAccent,
          onTap: () => windowManager.close(),
          tooltip: 'Close',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color color;
  final Color hoverColor;
  final Color? hoverIconColor;
  final VoidCallback onTap;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.hoverColor,
    required this.onTap,
    required this.tooltip,
    this.hoverIconColor,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isHovered ? widget.hoverColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: _isHovered
                  ? (widget.hoverIconColor ?? widget.color)
                  : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
