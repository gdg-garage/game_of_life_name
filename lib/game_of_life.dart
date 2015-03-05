library game_of_life;

/// Cell definition for Game of Life.  
class Cell {
  final int x, y;
  const Cell(this.x, this.y);
  operator==(other) => hashCode == other.hashCode;
  int get hashCode => (x << 8) + y;
  Cell offset(int dx, int dy) => new Cell(x + dx, y + dy);
  toString() => "($x, $y)";
}

Set<Cell> _neighs(Cell p) {
  const dl = const [-1, 0, 1];
  return dl.expand((dx) => dl.map((dy) => p.offset(dx, dy)))
      .where((np) => np != p)
      .toSet();
}

bool _shouldBeAlive(int nc, bool isAlive) =>
    nc == 3 || (nc == 2 && isAlive);

/// One step in Game of Life.
Set<Cell> step(Set<Cell> board) {
  var next = new Set<Cell>();
  board
      .map((p) => _neighs(p))
      .expand((p) => p)
      .fold({}, (Map<Cell,int> map, p) {
        map[p] = map.putIfAbsent(p, () => 0) + 1;
        return map;
      })
      .forEach((Cell p, int frq) {
        if (_shouldBeAlive(frq, board.contains(p))) next.add(p);
      });
  return next;
}
