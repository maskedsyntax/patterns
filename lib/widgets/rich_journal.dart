/// Journal entries are stored as Quill Delta JSON (a small rich-text format).
///
/// Entries written before rich text existed are plain strings; every helper
/// here transparently upgrades them, so old notes and JSON backups keep working
/// without a migration step.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// A single styled run of text - used for read-only rendering (list previews,
/// PDF export) without depending on Quill's widget layer.
class RichRun {
  final String text;
  final bool bold;
  final bool italic;

  const RichRun(this.text, {this.bold = false, this.italic = false});
}

/// Whether [content] looks like stored Delta JSON (vs. legacy plain text).
List<dynamic>? _tryDecodeDelta(String content) {
  if (content.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(content);
    if (decoded is List) return decoded;
  } catch (_) {
    /* legacy plain text */
  }
  return null;
}

/// Builds an editable [Document] from stored [content].
Document documentFromStored(String content) {
  final delta = _tryDecodeDelta(content);
  if (delta != null) {
    try {
      return Document.fromJson(delta);
    } catch (_) {
      /* malformed - fall back to plain */
    }
  }
  final doc = Document();
  if (content.isNotEmpty) doc.insert(0, content);
  return doc;
}

/// Serialises a [Document] back to the stored Delta JSON string.
String storedFromDocument(Document document) =>
    jsonEncode(document.toDelta().toJson());

/// Plain text of an entry - for search, previews fallback, and empty checks.
String plainTextFromStored(String content) {
  final delta = _tryDecodeDelta(content);
  if (delta != null) {
    try {
      return Document.fromJson(delta).toPlainText().trim();
    } catch (_) {
      /* fall through */
    }
  }
  return content.trim();
}

/// Decomposes stored [content] into styled runs for read-only rendering.
///
/// Block-level list items are flattened into lines prefixed with a bullet, so
/// previews and PDF export show "• item" rather than running the lines
/// together. Bold/italic styling inside a bullet is preserved.
List<RichRun> richRunsFromStored(String content) {
  final delta = _tryDecodeDelta(content);
  if (delta == null) {
    final plain = content.trim();
    return plain.isEmpty ? const [] : [RichRun(plain)];
  }
  List<Map<String, dynamic>> ops;
  try {
    ops = Document.fromJson(delta).toDelta().toJson();
  } catch (_) {
    final plain = content.trim();
    return plain.isEmpty ? const [] : [RichRun(plain)];
  }

  // In Quill, a line's text comes before the newline op that carries its
  // block attributes (e.g. {"list":"bullet"}). Accumulate inline runs per line,
  // then decide on a bullet prefix when the line closes.
  final lines = <({List<RichRun> runs, bool bullet})>[];
  var current = <RichRun>[];
  void endLine(bool bullet) {
    lines.add((runs: current, bullet: bullet));
    current = [];
  }

  for (final op in ops) {
    final insert = op['insert'];
    if (insert is! String) continue; // skip embeds
    final attrs = op['attributes'] as Map<String, dynamic>?;
    if (insert == '\n') {
      endLine(attrs?['list'] == 'bullet');
      continue;
    }
    final bold = attrs?['bold'] == true;
    final italic = attrs?['italic'] == true;
    final parts = insert.split('\n');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        current.add(RichRun(parts[i], bold: bold, italic: italic));
      }
      if (i < parts.length - 1) endLine(false);
    }
  }
  if (current.isNotEmpty) endLine(false);

  // Drop the empty trailing line produced by the document's final newline.
  while (lines.isNotEmpty && lines.last.runs.isEmpty && !lines.last.bullet) {
    lines.removeLast();
  }

  final out = <RichRun>[];
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].bullet) out.add(const RichRun('•  '));
    out.addAll(lines[i].runs);
    if (i < lines.length - 1) out.add(const RichRun('\n'));
  }
  return out;
}

/// A read-only [TextSpan] (bold/italic preserved) for list-card previews.
TextSpan richPreviewSpan(String content, TextStyle? base) {
  final runs = richRunsFromStored(content);
  return TextSpan(
    style: base,
    children: [
      for (final run in runs)
        TextSpan(
          text: run.text,
          style: TextStyle(
            fontWeight: run.bold ? FontWeight.w700 : null,
            fontStyle: run.italic ? FontStyle.italic : null,
          ),
        ),
    ],
  );
}

/// A compact Bold / Italic toggle bar bound to a [QuillController]. Buttons
/// highlight when the current selection already has that style and tapping
/// again removes it (true toggle, no markers).
class JournalFormatToolbar extends StatefulWidget {
  final QuillController controller;

  const JournalFormatToolbar({super.key, required this.controller});

  @override
  State<JournalFormatToolbar> createState() => _JournalFormatToolbarState();
}

class _JournalFormatToolbarState extends State<JournalFormatToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool _isActive(Attribute attr) =>
      widget.controller.getSelectionStyle().attributes.containsKey(attr.key);

  void _toggle(Attribute attr) {
    final active = _isActive(attr);
    widget.controller.formatSelection(
      active ? Attribute.clone(attr, null) : attr,
    );
    setState(() {});
  }

  // Lists are block-level: "active" means the line's list value is 'bullet'.
  bool _isBulletActive() =>
      widget.controller
          .getSelectionStyle()
          .attributes[Attribute.list.key]
          ?.value ==
      Attribute.ul.value;

  void _toggleBullet() {
    final active = _isBulletActive();
    widget.controller.formatSelection(
      active ? Attribute.clone(Attribute.ul, null) : Attribute.ul,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FormatButton(
          active: _isActive(Attribute.bold),
          onTap: () => _toggle(Attribute.bold),
          child: const Text(
            'B',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        const SizedBox(width: 4),
        _FormatButton(
          active: _isActive(Attribute.italic),
          onTap: () => _toggle(Attribute.italic),
          child: const Text(
            'I',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _FormatButton(
          active: _isBulletActive(),
          onTap: _toggleBullet,
          child: const Icon(Icons.format_list_bulleted, size: 18),
        ),
      ],
    );
  }
}

class _FormatButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final Widget child;

  const _FormatButton({
    required this.active,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = active
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: fg),
          child: child,
        ),
      ),
    );
  }
}
