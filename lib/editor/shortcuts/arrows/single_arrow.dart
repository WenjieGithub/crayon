import 'package:flutter/material.dart';

import '../../core/context.dart';
import '../../core/logger.dart';
import '../../cursor/basic.dart';
import '../../exception/editor_node.dart';
import 'arrows.dart';

class LeftArrowAction extends ContextAction<LeftArrowIntent> {
    final NodeContext nodeContext;

  LeftArrowAction(this.nodeContext);

  @override
  void invoke(LeftArrowIntent intent, [BuildContext? context]) {
    logger.i('$runtimeType is invoking!');
    _onLeftOrUp(ArrowType.left, nodeContext, runtimeType);
  }
}

class RightArrowAction extends ContextAction<RightArrowIntent> {
    final NodeContext nodeContext;

  RightArrowAction(this.nodeContext);

  @override
  void invoke(RightArrowIntent intent, [BuildContext? context]) {
    logger.i('$runtimeType is invoking!');
    _onRightOrDown(ArrowType.right, nodeContext, runtimeType);
  }
}

class UpArrowAction extends ContextAction<UpArrowIntent> {
    final NodeContext nodeContext;

  UpArrowAction(this.nodeContext);

  @override
  void invoke(UpArrowIntent intent, [BuildContext? context]) {
    logger.i('$runtimeType is invoking!');
    _onLeftOrUp(ArrowType.up, nodeContext, runtimeType);
  }
}

class DownArrowAction extends ContextAction<DownArrowIntent> {
    final NodeContext nodeContext;

  DownArrowAction(this.nodeContext);

  @override
  void invoke(DownArrowIntent intent, [BuildContext? context]) {
    logger.i('$runtimeType is invoking!');
    _onRightOrDown(ArrowType.down, nodeContext, runtimeType);
  }
}

void _onLeftOrUp(ArrowType type, NodeContext nodeContext, Type actionType) {
  final cursor = nodeContext.cursor;
  int index = -1;
  late NodePosition position;
  ArrowType t = type;
  if (cursor is EditingCursor) {
    index = cursor.index;
    position = cursor.position;
  } else if (cursor is SelectingNodeCursor) {
    index = cursor.index;
    position = cursor.left;
    t = ArrowType.current;
  } else if (cursor is SelectingNodesCursor) {
    index = cursor.left.index;
    position = cursor.left.position;
    t = ArrowType.current;
  }
  if (index == -1) return;
  try {
    nodeContext.onArrowAccept(
        AcceptArrowData(nodeContext.getNode(index).id, t, position));
  } on ArrowLeftBeginException catch (e) {
    logger.e('$actionType error ${e.message}');
    final lastIndex = index - 1;
    if (lastIndex < 0) return;
    nodeContext.onArrowAccept(AcceptArrowData(nodeContext.getNode(lastIndex).id,
        ArrowType.current, nodeContext.getNode(lastIndex).endPosition));
  } on ArrowUpTopException catch (e) {
    logger.e('$actionType error ${e.message}');
    final lastIndex = index - 1;
    if (lastIndex < 0) return;
    final node = nodeContext.getNode(lastIndex);
    nodeContext.onArrowAccept(AcceptArrowData(
        node.id, ArrowType.current, node.endPosition,
        extras: e.offset));
  } on NodeNotFoundException catch (e) {
    logger.e('$actionType error ${e.message}');
    nodeContext.updateCursor(EditingCursor(index, position));
  }
}

void _onRightOrDown(
    ArrowType type, NodeContext nodeContext, Type actionType) {
  final cursor = nodeContext.cursor;
  int index = -1;
  ArrowType t = type;
  late NodePosition position;
  if (cursor is EditingCursor) {
    index = cursor.index;
    position = cursor.position;
  } else if (cursor is SelectingNodeCursor) {
    index = cursor.index;
    position = cursor.right;
    t = ArrowType.current;
  } else if (cursor is SelectingNodesCursor) {
    index = cursor.right.index;
    position = cursor.right.position;
    t = ArrowType.current;
  }
  if (index == -1) return;
  try {
    nodeContext.onArrowAccept(
        AcceptArrowData(nodeContext.getNode(index).id, t, position));
  } on ArrowRightEndException catch (e) {
    logger.e('$actionType error ${e.message}');
    final nextIndex = index + 1;
    if (nextIndex > nodeContext.nodeLength - 1) return;
    nodeContext.onArrowAccept(AcceptArrowData(nodeContext.getNode(nextIndex).id,
        ArrowType.current, nodeContext.getNode(nextIndex).beginPosition));
  } on ArrowDownBottomException catch (e) {
    logger.e('$actionType error ${e.message}');
    final nextIndex = index + 1;
    if (nextIndex > nodeContext.nodeLength - 1) return;
    final node = nodeContext.getNode(nextIndex);
    nodeContext.onArrowAccept(AcceptArrowData(
        node.id, ArrowType.current, node.beginPosition,
        extras: e.offset));
  } on NodeNotFoundException catch (e) {
    logger.e('$actionType error ${e.message}');
    nodeContext.updateCursor(EditingCursor(index, position));
  }
}
