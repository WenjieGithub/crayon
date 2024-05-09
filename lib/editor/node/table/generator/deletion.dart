import '../../../../editor/cursor/basic.dart';
import '../../../core/context.dart';
import '../../../core/copier.dart';
import '../../../cursor/node_position.dart';
import '../../../cursor/table.dart';
import '../../../exception/editor_node.dart';
import '../../../shortcuts/delete.dart';
import '../../basic.dart';
import '../../rich_text/rich_text.dart';
import '../table.dart';
import '../table_cell.dart';
import 'common.dart';

NodeWithPosition deleteWhileEditing(
    EditingData<TablePosition> data, TableNode node) {
  return operateWhileEditing(
      data, node, (c) => DeleteAction(c).invoke(DeleteIntent()));
}

NodeWithPosition deleteWhileSelecting(
    SelectingData<TablePosition> data, TableNode node) {
  final left = data.left;
  final right = data.right;
  final emptyTextNode = RichTextNode.from([]);
  if (left == node.beginPosition && right == node.endPosition) {
    return NodeWithPosition(
        emptyTextNode, EditingPosition(emptyTextNode.beginPosition));
  }
  if (left.inSameCell(right)) {
    final cell = node.getCellByPosition(left);
    final context = data.context
        .getChildContext(cell.getId(node.id, left.row, left.column))!;
    final sameIndex = left.index == right.index;
    BasicCursor cursor = sameIndex
        ? SelectingNodeCursor(left.index, left.position, right.position)
        : SelectingNodesCursor(IndexWithPosition(left.index, left.position),
            IndexWithPosition(right.index, right.position));
    DeleteAction(ActionContext(context, () => cursor)).invoke(DeleteIntent());
    throw NodeUnsupportedException(
        node.runtimeType, 'operateWhileEditing', null);
  }
  final newNode = node.updateMore(left, right, (t) {
    return t
        .map((e) => e.updateMore(0, e.length, (m) {
              return m.map((n) => TableCell([RichTextNode.from([])])).toList();
            }))
        .toList();
  });
  return NodeWithPosition(
      newNode,
      SelectingPosition(
          left,
          right.copy(
              position: (p) => p.copy(
                  index: to(0), position: to(emptyTextNode.endPosition)))));
}
