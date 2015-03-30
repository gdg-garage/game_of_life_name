import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_action_dialog.dart';
import 'game_of_life.dart';
import 'dart:async';
import 'dart:math';

// Helper class
class Message {
  final String _text;
  final String _color;

  Message(String text, String color)
      : _text = text,
        _color = color;

  String get text => _text;
  String get color => _color;
}

// TODO: Devide to more classes.
/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {

  // Constants
  static const _FONT_SIZE = 120; // Default font size in px.
  static const _PIXEL_SIZE = 10; // Default pixel width and height in px.
  static const _INIT_TIME = 1000; // Init time for displaying name in ms.
  static const _STEP_TIME = 100; // Time between two steps in ms.
  static const _COLOR = "red";
  static const _RADIUS = 5;
  static final List _messages = [new Message("Name can not be empty!", "red"), new Message("Age must be a whole number!", "red")];

  // Bind variables
  @published String name = "Test Name";
  @published String age = "1000"; // TODO: Find out better way to input directly integer or validate more effectively.
  @published int fontSize = _FONT_SIZE;
  @published int pixelWidth = _PIXEL_SIZE;
  @published int pixelHeight = _PIXEL_SIZE;
  @published String aging = "";

  // Class variables
  Set<Cell> _board;
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  int _counter;
  PaperActionDialog _dialog;

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  void _showToast(Message message) {
    (shadowRoot.querySelector("#toast") as PaperToast)
        ..dismiss()
        ..setAttribute("text", message.text)
        ..style.background = message.color
        ..show();
  }

  bool validateName() {
    if (name.isEmpty) {
      _showToast(_messages[0]);
      return false;
    }
    return true;
  }

  // TODO: Fix when toast sometimes opens on first focus.
  bool validateAge() {
    if (age.isEmpty || int.parse(age, onError: (e) => null) == null) {
      _showToast(_messages[1]);
      return false;
    }
    return true;
  }

  void enter(Event e, var detail, Node target) {
    if ((e as KeyboardEvent).keyCode == 13) start();
  }

  // TODO: Finish animation of canvas and menu appearance.
  void start() {
    if (validateName() && validateAge()) {
      _counter = int.parse(age);
      shadowRoot.querySelector("#menu").style.display = "none";
      _canvas.style.display = "block";
      shadowRoot.querySelector("#aging").style.display = "flex";
      aging = 0.toString();
      _clearCanvas();
      _context
          ..font = fontSize.toString() + "px Monospace"
          ..fillStyle = _COLOR
          ..fillText(name.toUpperCase(), (_canvas.width / 2) - ((_FONT_SIZE / 2) * (name.length / 2)), (_canvas.height / 2) - (_FONT_SIZE / 2)); // Put text to canvas center by calculation from font size.
      _board = _getPointsFromCanvas();
      new Timer(new Duration(milliseconds: _INIT_TIME), () {
        next();
      });
    }
  }

  // TODO: Simplify and optimize this method.
  Set<Cell> _getPointsFromCanvas() {
    final width = _canvas.width;
    final height = _canvas.height;

    Set<Cell> result = new Set<Cell>();

    final ImageData img = _context.getImageData(0, 0, width, height);

    final pixelsInBigPixel = pixelWidth * pixelHeight;

    for (int pointY = 0; pointY * pixelHeight < height - 1; pointY++) {
      for (int pointX = 0; pointX * pixelWidth < width - 1; pointX++) {
        int count = 0;
        for (int dy = 0; dy < pixelHeight; dy++) {
          for (int dx = 0; dx < pixelWidth; dx++) {
            final int y = pointY * pixelHeight + dy;
            final int x = pointX * pixelWidth + dx;
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

  // TODO: Implement also method previous.
  void next() {
    _board = step(_board);
    _render(_board, circle:true);

    _counter--;
    aging = (int.parse(age) - _counter).toString();

    if (_counter >= 1) {
      new Timer(new Duration(milliseconds: _STEP_TIME), () {
        next();
      });
    } else if (_counter == 0) {
      // TODO: Finish animation to this.
      shadowRoot.querySelector("#control").style.display = "flex";
      shadowRoot.querySelector("#canvasImg").setAttribute("src", _canvas.toDataUrl());
      _dialog = (shadowRoot.querySelector("#dialog") as PaperActionDialog);
      _dialog.open();
    }
  }

  void closeDialog() {
    _dialog.close();
  }

  void _clearCanvas() {
    _context.clearRect(0, 0, _canvas.width, _canvas.height);
    _context.canvas.width = window.innerWidth;
    _context.canvas.height = window.innerHeight;
  }

  void _render(Set<Cell> points, {bool circle:false}) {
    _clearCanvas();
    _context.fillStyle = _COLOR;
    if(circle) { 
      points.forEach((Cell point) {
        _context.beginPath();
        _context.arc(point.x * pixelWidth + pixelWidth ~/ 2, point.y * pixelHeight + pixelHeight ~/ 2, _RADIUS, 0, 2 * PI);
        _context.fill();
      });
    } else points.forEach((Cell point) => _context.fillRect(point.x * pixelWidth, point.y * pixelHeight, pixelWidth, pixelHeight));
  }

  /// Called when main-app has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    super.ready();
    _canvas = shadowRoot.querySelector("#canvas");
    _context = _canvas.context2D;
    // TODO: Find out why method focus doesn't work. Also in reset method.
    (shadowRoot.querySelector("#name") as PaperInput).focus();
  }

  void _resetValues() {
    name = "";
    age = "";
    fontSize = _FONT_SIZE;
    pixelWidth = _PIXEL_SIZE;
    pixelHeight = _PIXEL_SIZE;
  }

  // TODO: Finish animations to all this actions.
  void reset() {
    //_resetValues(); // Uncomment if you want to erase also all values;
    shadowRoot.querySelector("#menu").style.display = "flex";
    _canvas.style.display = "none";
    shadowRoot.querySelector("#aging").style.display = "none";
    shadowRoot.querySelector("#control").style.display = "none";
    (shadowRoot.querySelector("#name") as PaperInput).focus();
  }
}
