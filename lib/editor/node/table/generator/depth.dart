import '../../../core/context.dart';
import '../../../cursor/basic.dart';
import '../../../cursor/table.dart';
import '../../../exception/editor_node.dart';
import '../../../shortcuts/tab.dart';
import '../../basic.dart';
import '../table.dart';
import 'common.dart';

NodeWithCursor increaseDepthWhileEditing(
    EditingData<TablePosition> data, TableNode node) {
  return operateWhileEditing(
      data, node, (c) => TabAction(c).invoke(TabIntent()));
}

NodeWithCursor decreaseDepthWhileEditing(
    EditingData<TablePosition> data, TableNode node) {
  return operateWhileEditing(
      data, node, (c) => ShiftTabAction(c).invoke(ShiftTabIntent()));
}

NodeWithCursor increaseDepthWhileSelecting(
    SelectingData<TablePosition> data, TableNode node) {
  final left = data.left;
  final right = data.right;
  int lastDepth = data.extras is int ? data.extras : 0;
  int depth = node.depth;
  if (left == node.beginPosition && right == node.endPosition) {
    if (lastDepth < depth) {
      throw DepthNotAbleToIncreaseException(node.runtimeType, depth);
    }
    return NodeWithCursor(node.newNode(depth: depth + 1), data.cursor);
  }
  if (left.sameCell(right)) {
    final cell = node.getCell(left.cellPosition);
    final sameIndex = left.index == right.index;
    BasicCursor cursor = sameIndex
        ? SelectingNodeCursor(left.index, left.position, right.position)
        : SelectingNodesCursor(left.cursor, right.cursor);
    if (!cell.wholeSelected(cursor)) {
      final context = buildTableCellNodeContext(
          data.context, left.cellPosition, node, cursor, data.index);
      TabAction(ActionContext(context, () => cursor)).invoke(TabIntent());
      throw NodeUnsupportedException(
          node.runtimeType, 'operateWhileEditing', null);
    }
  }
  throw NodeUnsupportedException(
      node.runtimeType, 'increaseDepthWhileSelecting', data.cursor);
}

NodeWithCursor decreaseDepthWhileSelecting(
    SelectingData<TablePosition> data, TableNode node) {
  final left = data.left;
  final right = data.right;
  int lastDepth = data.extras is int ? data.extras : 0;
  int depth = node.depth;
  if (left == node.beginPosition && right == node.endPosition) {
    if (lastDepth < depth) {
      throw DepthNotAbleToIncreaseException(node.runtimeType, depth);
    }
    return NodeWithCursor(node.newNode(depth: depth + 1), data.cursor);
  }
  if (left.sameCell(right)) {
    final cell = node.getCell(left.cellPosition);
    final sameIndex = left.index == right.index;
    BasicCursor cursor = sameIndex
        ? SelectingNodeCursor(left.index, left.position, right.position)
        : SelectingNodesCursor(left.cursor, right.cursor);
    if (!cell.wholeSelected(cursor)) {
      final context = buildTableCellNodeContext(
          data.context, left.cellPosition, node, cursor, data.index);
      ShiftTabAction(ActionContext(context, () => cursor))
          .invoke(ShiftTabIntent());
      throw NodeUnsupportedException(
          node.runtimeType, 'operateWhileEditing', null);
    }
  }
  throw NodeUnsupportedException(
      node.runtimeType, 'decreaseDepthWhileSelecting', data.cursor);
}
