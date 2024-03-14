import 'package:flutter/services.dart';

import '../command/basic_command.dart';
import '../command/modification.dart';
import '../cursor/basic_cursor.dart';
import '../cursor/rich_text_cursor.dart';
import '../node/rich_text_node/rich_text_node.dart';
import '../extension/string_extension.dart';
import 'controller.dart';

CommandIfRecord? generateCommand(
    TextEditingDelta delta, RichEditorController controller) {
  if (delta is TextEditingDeltaInsertion) {
    return _generateFromInsertion(delta, controller);
  } else if (delta is TextEditingDeltaReplacement) {
    return _generateFromReplacement(delta, controller);
  }
  return null;
}

CommandIfRecord? _generateFromInsertion(
    TextEditingDeltaInsertion delta, RichEditorController controller) {
  final cursor = controller.cursor;
  if (cursor is EditingCursor) {
    final node = controller.getNode(cursor.index)!;
    if (node is RichTextNode) {
      final position = cursor.position as RichTextNodePosition;
      final text = delta.textInserted;
      final span = node.getSpan(position.index);
      final offset = position.offset - span.offset;
      final newNode = node.update(
          position.index, span.copy(text: (v) => v.insert(offset, text)));
      final command = ModifyNode(
          cursor,
          EditingCursor(
              cursor.index,
              RichTextNodePosition(
                  position.index, position.offset + text.length)),
          newNode);
      return CommandIfRecord(delta.composing == TextRange.empty, command);
    }
  } else if (cursor is SelectingNodeCursor) {
  } else if (cursor is SelectingNodesCursor) {}
  return null;
}

CommandIfRecord? _generateFromReplacement(
    TextEditingDeltaReplacement delta, RichEditorController controller) {
  final cursor = controller.cursor;
  if (cursor is EditingCursor) {
    final node = controller.getNode(cursor.index)!;
    if (node is RichTextNode) {
      final position = cursor.position as RichTextNodePosition;
      final text = delta.replacementText;
      final range = delta.replacedRange;
      final index = position.index;
      final span = node.getSpan(index);
      final offset = position.offset - span.offset;
      final correctRange = TextRange(start: offset - range.end, end: offset);
      final newNode = node.update(
          index, span.copy(text: (v) => v.replace(correctRange, text)));
      return CommandIfRecord(
          true,
          ModifyNode(
              EditingCursor(cursor.index,
                  RichTextNodePosition(index, correctRange.start)),
              EditingCursor(
                  cursor.index,
                  RichTextNodePosition(
                      index, correctRange.start + text.length)),
              newNode,
              old: newNode.update(position.index,
                  span.copy(text: (v) => v.remove(correctRange)))));
    }
  } else if (cursor is SelectingNodeCursor) {
  } else if (cursor is SelectingNodesCursor) {}
  return null;
}

class CommandIfRecord {
  final bool record;
  final BasicCommand command;

  CommandIfRecord(this.record, this.command);
}
