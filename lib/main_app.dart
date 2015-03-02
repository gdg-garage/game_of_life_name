// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' hide Point;

import 'package:polymer/polymer.dart';
import 'game_of_life.dart';

/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String name = '';
  CanvasElement _canvas;
  static const _FONT_SIZE = 20; // Font size in px.
  
  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  void begin() {
    _canvas.context2D
        ..clearRect(0, 0, _canvas.width, _canvas.height) // Clear canvas.
        ..font = _FONT_SIZE.toString()+"px Monospace"
        ..fillText(name.toUpperCase(), (_canvas.width/2)-((_FONT_SIZE/2)*(name.length/2)), (_canvas.height/2)-(_FONT_SIZE/2)); // Put text to canvas center by calculation from font size.
  }

  Set<Point> getPointsFromCanvas() {
    final width = _canvas.width;
    final height = _canvas.height;

    Set<Point> result = new Set<Point>();

    ImageData img =
        _canvas.context2D.getImageData(0, 0, width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int index = ((y * width) + x) * 4;
//        if (img.data[index] != 0) {
//          print("R: $x, $y");
//        }
//        if (img.data[index + 1] != 0) {
//          print("G: $x, $y");
//        }
//        if (img.data[index + 2] != 0) {
//          print("B: $x, $y");
//        }
        if (img.data[index + 3] != 0) {
          print("A: $x, $y");
          result.add(new Point(x, y));
        }
      }
    }

    return result;
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
