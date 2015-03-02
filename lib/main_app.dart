// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' hide Point;

import 'package:polymer/polymer.dart';
import 'game_of_life.dart' as game_of_life;
import 'dart:async';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String name = '';
  CanvasElement _canvas;
  static const _FONT_SIZE = 40; // Font size in px.
  static const _PIXEL_WIDTH = 5;
  static const _PIXEL_HEIGHT = 5;
  Set<game_of_life.Point> board;

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  void begin() {
    _canvas.context2D
        ..clearRect(0, 0, _canvas.width, _canvas.height) // Clear canvas.
        ..font = _FONT_SIZE.toString()+"px Monospace"
        ..fillText(name.toUpperCase(), (_canvas.width/2)-((_FONT_SIZE/2)*(name.length/2)), (_canvas.height/2)-(_FONT_SIZE/2)); // Put text to canvas center by calculation from font size.
  }

  Set<game_of_life.Point> getPointsFromCanvas() {
    final width = _canvas.width;
    final height = _canvas.height;

    Set<game_of_life.Point> result = new Set<game_of_life.Point>();

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
          result.add(new game_of_life.Point(pointX, pointY));
        }
      }
    }

    return result;
  }

  void start() {
    board = getPointsFromCanvas();
    step();
  }

  void step() {
    board = game_of_life.step(board);
    _render(board);

    new Timer(new Duration(milliseconds: 100), () {
      step();
    });
  }

  void _render(Set<game_of_life.Point> points) {
    _canvas.context2D.clearRect(0, 0, _canvas.width, _canvas.height); // Clear canvas.
    points.forEach((game_of_life.Point point) => _canvas.context2D.fillRect(point.x, point.y, _PIXEL_WIDTH, _PIXEL_HEIGHT));
  }

  // Optional lifecycle methods - uncomment if needed.

//  /// Called when an instance of main-app is inserted into the DOM.
//  attached() {
//    super.attached();
//  }

//  /// Called when an instance of main-app is removed from the DOM.
//  detached() {
//    super.detached();
//  }

//  /// Called when an attribute (such as a class) of an instance of
//  /// main-app is added, changed, or removed.
//  attributeChanged(String name, String oldValue, String newValue) {
//    super.attributeChanges(name, oldValue, newValue);
//  }

  /// Called when main-app has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    super.ready();
    _canvas = shadowRoot.querySelector("#canvas");
  }
}
