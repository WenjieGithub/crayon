import '../core/command_invoker.dart';
import '../core/editor_controller.dart';
import '../cursor/basic_cursor.dart';
import '../node/basic_node.dart';
import 'basic_command.dart';

class ModifyNode implements BasicCommand {
  final SingleNodeCursor cursor;
  final EditorNode node;

  ModifyNode(this.cursor, this.node);

  @override
  UpdateControllerOperation? run(RichEditorController controller) {
    return controller.update(Update(cursor.index, node, cursor));
  }

  @override
  String toString() {
    return 'ModifyNode{cursor: $cursor, node: $node}';
  }
}

class ModifyNodeWithoutChangeCursor implements BasicCommand {
  final int index;
  final EditorNode node;

  ModifyNodeWithoutChangeCursor(this.index, this.node);

  @override
  UpdateControllerOperation? run(RichEditorController controller) {
    return controller.update(Update(index, node, controller.cursor));
  }

  @override
  String toString() {
    return 'ModifyNodeWithoutChangeCursor{index: $index, node: $node}';
  }

}