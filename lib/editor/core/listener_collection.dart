import 'package:flutter/material.dart';

import '../cursor/basic.dart';
import '../exception/editor_node.dart';
import '../node/basic.dart';
import '../shortcuts/arrows/arrows.dart';
import '../widget/menu/optional.dart';
import 'editor_controller.dart';
import 'logger.dart';

class ListenerCollection {
  final tag = 'CallbackCollection';

  final Set<ValueChanged<BasicCursor>> _cursorListeners = {};
  final Set<VoidCallback> _nodesListeners = {};
  final Set<ValueChanged<GestureState>> _gestureListeners = {};
  final Set<ValueChanged<ControllerStatus>> _statusListeners = {};
  final Map<String, Set<ValueChanged<EditorNode>>> _nodeListeners = {};
  final Map<String, Set<ArrowDelegate>> _arrowDelegates = {};
  final Set<ValueChanged<OptionalSelectedType>> _optionalMenuListeners = {};
  final Set<ListenerCollection> _childListeners = {};

  void dispose() {
    logger.i('$tag, dispose');
    _cursorListeners.clear();
    _nodesListeners.clear();
    _gestureListeners.clear();
    _statusListeners.clear();
    _nodeListeners.clear();
    _arrowDelegates.clear();
    _optionalMenuListeners.clear();
    _childListeners.clear();
  }

  void addCursorChangedListener(ValueChanged<BasicCursor> listener) =>
      _cursorListeners.add(listener);

  void removeCursorChangedListener(ValueChanged<BasicCursor> listener) =>
      _cursorListeners.remove(listener);

  void addNodesChangedListener(VoidCallback listener) =>
      _nodesListeners.add(listener);

  void removeNodesChangedListener(VoidCallback listener) =>
      _nodesListeners.remove(listener);

  void addGestureListener(ValueChanged<GestureState> listener) =>
      _gestureListeners.add(listener);

  void removeGestureListener(ValueChanged<GestureState> listener) =>
      _gestureListeners.remove(listener);

  void addStatusChangedListener(ValueChanged<ControllerStatus> listener) =>
      _statusListeners.add(listener);

  void removeStatusChangedListener(ValueChanged<ControllerStatus> listener) =>
      _statusListeners.remove(listener);

  void addOptionalMenuListener(ValueChanged<OptionalSelectedType> listener) =>
      _optionalMenuListeners.add(listener);

  void removeOptionalMenuListener(
          ValueChanged<OptionalSelectedType> listener) =>
      _optionalMenuListeners.remove(listener);

  void addNodeChangedListener(String id, ValueChanged<EditorNode> listener) {
    // logger.i(
    //     '$tag, addNodeChangedCallback:$id, all:${_nodeChangedCallbacks.length}');
    final set = _nodeListeners[id] ?? {};
    set.add(listener);
    _nodeListeners[id] = set;
  }

  void removeNodeChangedListener(String id, ValueChanged<EditorNode> listener) {
    final set = _nodeListeners[id] ?? {};
    set.remove(listener);
    // logger.i('$tag, removeNodeChangedCallback:$id, length:${set.length}');
    if (set.isEmpty) {
      _nodeListeners.remove(id);
    } else {
      _nodeListeners[id] = set;
    }
  }

  void addArrowDelegate(String id, ArrowDelegate callback) {
    // logger.i('$tag, addArrowDelegate:$id, all:${_arrowDelegates.length}');
    final set = _arrowDelegates[id] ?? {};
    set.add(callback);
    _arrowDelegates[id] = set;
  }

  void removeArrowDelegate(String id, ArrowDelegate callback) {
    final set = _arrowDelegates[id] ?? {};
    set.remove(callback);
    // logger.i(
    //     '$tag, addArrowDelegate:$id, length:${set.length}, all:${_arrowDelegates.length}');
    if (set.isEmpty) {
      _arrowDelegates.remove(id);
    } else {
      _arrowDelegates[id] = set;
    }
  }

  void onArrowAccept(AcceptArrowData data) {
    final id = data.id;
    final set = _arrowDelegates[id] ?? {};
    if (set.isEmpty) throw NodeNotFoundException(id);
    // logger.i(
    //     '$tag, onArrowAccept, id:$id, type:${data.type}, length:${set.length}, all:${_arrowDelegates.length}');
    for (var c in Set.of(set)) {
      c.call(data);
    }
    _notifyChildrenListener((v) => v.onArrowAccept(data));
  }

  void notifyCursor(BasicCursor cursor) {
    for (var c in Set.of(_cursorListeners)) {
      c.call(cursor);
    }
    _notifyChildrenListener((v) => v.notifyCursor(cursor));
    // logger.i('$tag, notifyCursor length:${_cursorChangedCallbacks.length}');
  }

  void notifyGesture(GestureState state) {
    for (var c in Set.of(_gestureListeners)) {
      c.call(state);
    }
    _notifyChildrenListener((v) => v.notifyGesture(state));
    // logger.i(
    //     '$tag, notifyDragUpdateDetails length:${_onPanUpdateCallbacks.length}');
  }

  void notifyNode(EditorNode node) {
    for (var c in Set.of(_nodeListeners[node.id] ?? {})) {
      c.call(node);
    }
    _notifyChildrenListener((v) => v.notifyNode(node));
    // logger
    //     .i('$tag, notifyNode length:${_nodeChangedCallbacks[node.id]?.length}');
  }

  void notifyNodes() {
    for (var c in Set.of(_nodesListeners)) {
      c.call();
    }
    _notifyChildrenListener((v) => v.notifyNodes());
    // logger.i('$tag, notifyNodes length:${_nodesChangedCallbacks.length}');
  }

  void notifyStatus(ControllerStatus status) {
    for (var c in Set.of(_statusListeners)) {
      c.call(status);
    }
    _notifyChildrenListener((v) => v.notifyStatus(status));
  }

  void notifyOptionalMenu(OptionalSelectedType type) {
    for (var c in Set.of(_optionalMenuListeners)) {
      c.call(type);
    }
    _notifyChildrenListener((v) => v.notifyOptionalMenu(type));
  }

  void addChildListener(ListenerCollection l) => _childListeners.add(l);

  void removeChildListener(ListenerCollection l) => _childListeners.remove(l);

  void _notifyChildrenListener(ValueChanged<ListenerCollection> l) {
    for (var o in _childListeners) {
      l.call(o);
    }
  }
}

class GestureState {
  final GestureType type;
  final Offset globalOffset;

  GestureState(this.type, this.globalOffset);

  @override
  String toString() {
    return 'GestureState{type: $type, globalOffset: $globalOffset}';
  }
}

enum GestureType { tap, panUpdate, hover }

class CursorOffset {
  final int index;
  final EditingOffset offset;

  CursorOffset(this.index, this.offset);

  CursorOffset.zero()
      : index = 0,
        offset = EditingOffset.zero();

  double get y => offset.y;

  @override
  String toString() {
    return 'CursorOffset{index: $index, offset: $offset}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorOffset &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          offset == other.offset;

  @override
  int get hashCode => index.hashCode ^ offset.hashCode;
}
