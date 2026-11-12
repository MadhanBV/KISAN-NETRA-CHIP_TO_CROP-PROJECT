import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Clean, structured typography renderer for AI bot responses and farmer advisories.
/// Eradicates raw markdown clutter (e.g. `***`, `---`, `###`), gracefully parses
/// bullet points, numbered lists, and bold emphasis into an elegant mobile UI.
class CleanAiTextView extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color? textColor;

  const CleanAiTextView({
    super.key,
    required this.text,
    this.isUser = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedText = _sanitize(text);
    final blocks = _parseBlocks(sanitizedText);

    if (blocks.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.45,
          color: isUser ? Colors.white : (textColor ?? AppColors.textPrimary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks.map((block) => _buildBlock(block)).toList(),
    );
  }

  /// Removes raw markdown dividers and unwanted artifact lines
  String _sanitize(String raw) {
    var s = raw;
    // Remove divider lines like ***, ---, ___
    s = s.replaceAll(RegExp(r'^\s*[\*\-_]{3,}\s*$', multiLine: true), '');
    // Remove isolated triple asterisks
    s = s.replaceAll(RegExp(r'\*{3,}'), '');
    s = s.replaceAll(RegExp(r'-{3,}'), '');
    // Normalize excessive newlines
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return s.trim();
  }

  List<_TextBlock> _parseBlocks(String input) {
    final lines = input.split('\n');
    final List<_TextBlock> blocks = [];

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Check for markdown headings: ### Title or ## Title
      if (line.startsWith(RegExp(r'^#{1,4}\s*'))) {
        final title = line.replaceFirst(RegExp(r'^#{1,4}\s*'), '').trim();
        if (title.isNotEmpty) {
          blocks.add(_TextBlock(type: _BlockType.heading, content: title));
        }
        continue;
      }

      // Check for bullet items: * Item, - Item, • Item
      if (line.startsWith(RegExp(r'^[\*\-•]\s+'))) {
        final content = line.replaceFirst(RegExp(r'^[\*\-•]\s+'), '').trim();
        if (content.isNotEmpty) {
          blocks.add(_TextBlock(type: _BlockType.bullet, content: content));
        }
        continue;
      }

      // Check for numbered items: 1. Item, 2) Item
      final numMatch = RegExp(r'^(\d+)[\.\)]\s+').firstMatch(line);
      if (numMatch != null) {
        final number = numMatch.group(1)!;
        final content = line.substring(numMatch.end).trim();
        if (content.isNotEmpty) {
          blocks.add(_TextBlock(type: _BlockType.numbered, content: content, prefix: number));
        }
        continue;
      }

      // Otherwise normal paragraph
      blocks.add(_TextBlock(type: _BlockType.paragraph, content: line));
    }

    return blocks;
  }

  Widget _buildBlock(_TextBlock block) {
    final baseColor = isUser ? Colors.white : (textColor ?? AppColors.textPrimary);

    switch (block.type) {
      case _BlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3.5,
                height: 14,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: isUser ? Colors.white70 : const Color(0xFF1B8755),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  _cleanInlineMarkdown(block.content),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isUser ? Colors.white : const Color(0xFF0F4D33),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 5.5,
                height: 5.5,
                decoration: BoxDecoration(
                  color: isUser ? Colors.white70 : const Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.2,
                      height: 1.45,
                      color: baseColor,
                    ),
                    children: _buildSpans(block.content, baseColor),
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.numbered:
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isUser ? Colors.white24 : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  block.prefix ?? "•",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isUser ? Colors.white : const Color(0xFF1B8755),
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.2,
                      height: 1.45,
                      color: baseColor,
                    ),
                    children: _buildSpans(block.content, baseColor),
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                height: 1.48,
                color: baseColor,
              ),
              children: _buildSpans(block.content, baseColor),
            ),
          ),
        );
    }
  }

  /// Parses **bold** segments into bold TextSpans while keeping the rest normal
  List<TextSpan> _buildSpans(String text, Color baseColor) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: baseColor),
          ),
        );
      }
      final boldText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: boldText,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isUser ? Colors.white : const Color(0xFF0F4D33),
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final remainder = text.substring(lastIndex).replaceAll('**', '').trim();
      if (remainder.isNotEmpty) {
        spans.add(
          TextSpan(
            text: remainder,
            style: TextStyle(color: baseColor),
          ),
        );
      }
    }

    return spans;
  }

  String _cleanInlineMarkdown(String text) {
    return text.replaceAll(RegExp(r'\*\*'), '').replaceAll(RegExp(r'#+'), '').trim();
  }
}

enum _BlockType { heading, bullet, numbered, paragraph }

class _TextBlock {
  final _BlockType type;
  final String content;
  final String? prefix;

  _TextBlock({required this.type, required this.content, this.prefix});
}
