class Point {
  final int x, y;
  const Point(this.x, this.y);
  operator==(other) => hashCode == other.hashCode;
  int get hashCode => (x << 8) + y;
  Point offset(int dx, int dy) => new Point(x + dx, y + dy);
  toString() => "($x, $y)";
}

Set<Point> neighs(Point p) {
  const dl = const [-1, 0, 1];
  return dl.expand((dx) => dl.map((dy) => p.offset(dx, dy)))
      .where((np) => np != p)
      .toSet();
}

bool shouldBeAlive(int nc, bool isAlive) =>
    nc == 3 || (nc == 2 && isAlive);

Set<Point> step(Set<Point> board) {
  var next = new Set<Point>();
  board
      .map((p) => neighs(p))
      .expand((p) => p)
      .fold({}, (Map<Point,int> map, p) {
        map[p] = map.putIfAbsent(p, () => 0) + 1;
        return map;
      })
      .forEach((Point p, int frq) {
        if (shouldBeAlive(frq, board.contains(p))) next.add(p);
      });
  return next;
}


main() {
  var glider = [[1, 3], [2, 3], [3, 3], [3, 2], [2, 1]];
  var board = new Set.from(glider.map((e) => new Point(e[0], e[1])));
  board = step(board);
  board = step(board);
  board = step(board);
  board = step(board);
  board = step(board);
  board = step(board);
  print(board);
}