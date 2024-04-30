import 'package:flutter/material.dart';
import '../../editor/command/replace.dart';
import '../../editor/exception/editor_node.dart';
import '../../editor/extension/int.dart';

import '../command/selecting/depth.dart';
import '../core/context.dart';
import '../core/editor_controller.dart';
import '../core/logger.dart';
import '../cursor/basic.dart';
import '../node/basic.dart';
import '../cursor/node_position.dart';

class TabIntent extends Intent {
  const TabIntent();
}

class ShiftTabIntent extends Intent {
  const ShiftTabIntent();
}

class TabAction extends ContextAction<TabIntent> {
  final NodeContext nodeContext;

  TabAction(this.nodeContext);

  @override
  void invoke(TabIntent intent, [BuildContext? context]) {
    logger.i('$runtimeType is invoking!');
    final cursor = nodeContext.cursor;
    try {
      if (cursor is EditingCursor) {
        final index = cursor.index;
        final node = nodeContext.getNode(index);
        int lastDepth = index == 0 ? 0 : nodeContext.getNode(index - 1).depth;
        final r = node.onEdit(EditingData(
            cursor.position, EventType.increaseDepth, nodeContext.listeners,
            extras: lastDepth));
        nodeContext.execute(ReplaceNode(
            Replace(index, index + 1, [r.node], r.position.toCursor(index))));
      } else if (cursor is SelectingNodeCursor) {
        final index = cursor.index;
        int lastDepth = index == 0 ? 0 : nodeContext.getNode(index - 1).depth;
        final r = nodeContext.getNode(cursor.index).onSelect(SelectingData(
            SelectingPosition(cursor.begin, cursor.end),
            EventType.increaseDepth,
            nodeContext.listeners,
            extras: lastDepth));
        nodeContext.execute(ReplaceNode(
            Replace(index, index + 1, [r.node], r.position.toCursor(index))));
      } else if (cursor is SelectingNodesCursor) {
        nodeContext.execute(IncreaseNodesDepth(cursor));
      }
    } on DepthNotAbleToIncreaseException catch (e) {
      logger.e('$runtimeType, ${e.message}');
    }
  }
}

class ShiftTabAction extends ContextAction<ShiftTabIntent> {
  final NodeContext nodeContext;

  ShiftTabAction(this.nodeContext);

  @override
  void invoke(ShiftTabIntent intent, [BuildContext? context]) {
    logger.i('$runtimeType is invoking!');
    final cursor = nodeContext.cursor;
    try {
      if (cursor is EditingCursor) {
        final index = cursor.index;
        final node = nodeContext.getNode(index);
        final r = node.onEdit(EditingData(
            cursor.position, EventType.decreaseDepth, nodeContext.listeners));
        nodeContext.execute(ReplaceNode(
            Replace(index, index + 1, [r.node], r.position.toCursor(index))));
      } else if (cursor is SelectingNodeCursor) {
        final index = cursor.index;
        final r = nodeContext.getNode(index).onSelect(SelectingData(
            SelectingPosition(cursor.begin, cursor.end),
            EventType.decreaseDepth,
            nodeContext.listeners));
        nodeContext.execute(ReplaceNode(
            Replace(index, index + 1, [r.node], r.position.toCursor(index))));
      } else if (cursor is SelectingNodesCursor) {
        nodeContext.execute(DecreaseNodesDepth(cursor));
      }
    } on DepthNeedDecreaseMoreException catch (e) {
      logger.e('$runtimeType, ${e.message}');
      if (cursor is! SingleNodeCursor) return;
      int index = cursor.index;
      final node = nodeContext.getNode(index);
      final nodes = <EditorNode>[node.newNode(depth: node.depth.decrease())];
      correctDepth(nodeContext.nodeLength, (i) => nodeContext.getNode(i),
          index + 1, e.depth, nodes);
      nodeContext.execute(ReplaceNode(
          Replace(cursor.index, cursor.index + nodes.length, nodes, cursor)));
    }
  }
}
