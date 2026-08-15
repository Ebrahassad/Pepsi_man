/// Generic fixed-size object pool to avoid allocating thousands of
/// short-lived objects every frame (obstacles/items) while the runner
/// moves at speed.
class ObjectPool<T> {
  final List<T> _pool = [];
  final List<bool> _inUse = [];
  final T Function() _factory;
  final void Function(T item)? _reset;

  ObjectPool({
    required int size,
    required T Function() factory,
    void Function(T item)? reset,
  })  : _factory = factory,
        _reset = reset {
    for (int i = 0; i < size; i++) {
      _pool.add(_factory());
      _inUse.add(false);
    }
  }

  /// Acquires a free item from the pool, or grows the pool by one if all
  /// slots are currently in use.
  T acquire() {
    for (int i = 0; i < _pool.length; i++) {
      if (!_inUse[i]) {
        _inUse[i] = true;
        return _pool[i];
      }
    }
    final item = _factory();
    _pool.add(item);
    _inUse.add(true);
    return item;
  }

  void release(T item) {
    final index = _pool.indexOf(item);
    if (index == -1) return;
    _inUse[index] = false;
    _reset?.call(item);
  }

  void releaseAll() {
    for (int i = 0; i < _inUse.length; i++) {
      _inUse[i] = false;
      _reset?.call(_pool[i]);
    }
  }

  int get activeCount => _inUse.where((v) => v).length;
  int get totalCount => _pool.length;
}

/// Convenience pools for obstacle/item instances. The generic `ObjectPool`
/// above is deliberately type-agnostic so it can back both.
class ObstaclePool<T> extends ObjectPool<T> {
  ObstaclePool({required super.size, required super.factory, super.reset});
}

class ItemPool<T> extends ObjectPool<T> {
  ItemPool({required super.size, required super.factory, super.reset});
}
