import 'dart:html';

import 'package:polymer/polymer.dart';
import 'game_of_life.dart';
import 'dart:async';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  
  @observable String name = '';
  CanvasElement _canvas;
  static const _FONT_SIZE = 40; // Font size in px.
  static const _PIXEL_WIDTH = 5;
  static const _PIXEL_HEIGHT = 5;
  Set<Cell> board;

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  void begin() {
    _canvas.context2D
        ..clearRect(0, 0, _canvas.width, _canvas.height) // Clear canvas.
        ..font = _FONT_SIZE.toString()+"px Monospace"
        ..fillText(name.toUpperCase(), (_canvas.width/2)-((_FONT_SIZE/2)*(name.length/2)), (_canvas.height/2)-(_FONT_SIZE/2)); // Put text to canvas center by calculation from font size.
  }

  // TODO: Simplify and optimize this method.
  Set<Cell> getPointsFromCanvas() {
    final width = _canvas.width;
    final height = _canvas.height;

    Set<Cell> result = new Set<Cell>();

    ImageData img =
        _canvas.context2D.getImageData(0, 0, width, height);

    final pixelsInBigPixel = _PIXEL_WIDTH * _PIXEL_HEIGHT;

    for (int pointY = 0; pointY * _PIXEL_HEIGHT < height - 1; pointY++) {
      for (int pointX = 0; pointX * _PIXEL_WIDTH < width - 1; pointX++) {
        int count = 0;
        for (int dy = 0; dy < _PIXEL_HEIGHT; dy++) {
          for (int dx = 0; dx < _PIXEL_WIDTH; dx++) {
            final int y = pointY * _PIXEL_HEIGHT + dy;
            final int x = pointX * _PIXEL_WIDTH + dx;
            final int index = ((y * width) + x) * 4;
            if (img.data[index + 3] != 0) {
              count++;
            }
          }
        }
        if (count > pixelsInBigPixel ~/ 2) {
          result.add(new Cell(pointX, pointY));
        }
      }
    }

    return result;
  }

  void start() {
    board = getPointsFromCanvas();
    next();
  }

  void next() {
    board = step(board);
    _render(board);

    new Timer(new Duration(milliseconds: 100), () {
      next();
    });
  }

  void _render(Set<Cell> points) {
    _canvas.context2D.clearRect(0, 0, _canvas.width, _canvas.height); // Clear canvas.
    points.forEach((Cell point) => _canvas.context2D.fillRect(point.x * _PIXEL_WIDTH, point.y * _PIXEL_HEIGHT, _PIXEL_WIDTH, _PIXEL_HEIGHT));
  }

  /// Called when main-app has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    super.ready();
    _canvas = shadowRoot.querySelector("#canvas");
  }
}
