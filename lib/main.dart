import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const BingoApp());
}

class BingoApp extends StatelessWidget {
  const BingoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bingo'),
        ),
        body: const BingoHome(),
      ),
    );
  }
}

class BingoHome extends StatefulWidget {
  const BingoHome({Key? key}) : super(key: key);

  @override
  State<BingoHome> createState() => _BingoHomeState();
}

class _BingoHomeState extends State<BingoHome> {
  List<String> _history = [];
  static const _alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  List<String> _remaining = [..._alphabet];
  List<List<String>> _cells = [];
  final _cellNum = 5;
  late Size _screenSize;
  late Orientation _orientation;
  static const _cellSizeMax = 80.0;
  late double _cellSize;
  late bool _bingo = false;

  @override
  void initState() {
    _cells = _CellGenerator(_cellNum).generate();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    _orientation = MediaQuery.of(context).orientation;
    switch (_orientation) {
      case Orientation.landscape:
        _cellSize = [
          _screenSize.width / 10,
          _screenSize.height / 7,
          _cellSizeMax
        ].reduce(min);
        break;
      case Orientation.portrait:
        _cellSize = [
          _screenSize.width / 5,
          _screenSize.height / 10,
          _cellSizeMax
        ].reduce(min);
        break;
    }
    return _buildContainer();
  }

  Widget _buildContainer() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: _cellSizeMax / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _pushReset(),
                child: const Text('Reset'),
              ),
              const SizedBox(width: _cellSizeMax / 2),
              ElevatedButton(
                onPressed: () => _pushLottery(),
                child: const Text('Lottery'),
              ),
            ],
          ),
          const SizedBox(height: _cellSizeMax / 2),
          _buildMainContainer(),
        ],
      );

  Widget _buildMainContainer() {
    switch (_orientation) {
      case Orientation.landscape:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildArea(),
          const SizedBox(width: _cellSizeMax / 2),
          _buildHistory(),
        ]);
      case Orientation.portrait:
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildArea(),
          const SizedBox(width: _cellSizeMax / 2),
          _buildHistory(),
        ]);
    }
  }

  Widget _buildArea() => SizedBox(
        width: _cellSize * 5,
        height: _cellSize * 5,
        child: Stack(
          children: [
            _buildColumn(),
            Center(
              child: Container(
                child: _buildInformationText(),
              ),
            ),
          ],
        ),
      );

  Widget? _buildInformationText() {
    if (_bingo) {
      return const Text(
        "BINGO!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 60.0,
          color: Colors.pink,
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildColumn() => Column(
        children: List.generate(
          _cellNum,
          (index) => _buildRow(index),
        ),
      );

  Widget _buildRow(int rowIndex) => Row(
        children:
            List.generate(_cellNum, (index) => _buildCell(rowIndex, index)),
      );

  Widget _buildCell(int rowIndex, int columnIndex) {
    final cell = _cells[rowIndex][columnIndex];

    return Container(
      width: _cellSize,
      height: _cellSize,
      decoration: buildBoxDecoration(rowIndex, columnIndex),
      child: Center(child: Text(cell, style: const TextStyle(fontSize: 18))),
    );
  }

  BoxDecoration buildBoxDecoration(int rowIndex, int columnIndex) {
    if (_history.contains(_cells[rowIndex][columnIndex])) {
      return BoxDecoration(
        border: Border.all(color: Colors.black),
        shape: BoxShape.rectangle,
        color: Colors.blue,
      );
    } else {
      return BoxDecoration(
        border: Border.all(color: Colors.black),
      );
    }
  }

  Widget _buildHistory() {
    switch (_orientation) {
      case Orientation.landscape:
        return Column(children: [
          const Center(child: Text("History", style: TextStyle(fontSize: 18))),
          Container(
            height: _cellSize * 4,
            width: _cellSize * 2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: GridView.count(
              crossAxisCount: 4,
              children: List.generate(_history.length,
                  (index) => Center(child: Text(_history[index]))),
            ),
          )
        ]);
      case Orientation.portrait:
        return Column(children: [
          const Center(child: Text("History", style: TextStyle(fontSize: 18))),
          Container(
            height: _cellSize * 2,
            width: _cellSize * 5,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: GridView.count(
              crossAxisCount: 10,
              children: List.generate(_history.length,
                  (index) => Center(child: Text(_history[index]))),
            ),
          )
        ]);
    }
  }

  void _pushReset() {
    setState(() {
      _history = [];
      _remaining = [..._alphabet];
      _bingo = false;
      _cells = _CellGenerator(_cellNum).generate();
    });
  }

  void _pushLottery() {
    if (_bingo || _remaining.isEmpty) {
      return;
    }
    setState(() {
      _history.add(_remaining.removeAt(Random().nextInt(_remaining.length)));
      for (var rowIndex = 0; rowIndex < _cellNum; rowIndex++) {
        if (List.generate(_cellNum, (i) => i)
            .every((e) => _history.contains(_cells[rowIndex][e]))) {
          _bingo = true;
          break;
        }
      }
      for (var columnIndex = 0; columnIndex < _cellNum; columnIndex++) {
        if (List.generate(_cellNum, (i) => i)
            .every((e) => _history.contains(_cells[e][columnIndex]))) {
          _bingo = true;
          break;
        }
      }
      if (List.generate(_cellNum, (i) => i)
          .every((e) => _history.contains(_cells[e][e]))) {
        _bingo = true;
      }
      if (List.generate(_cellNum, (i) => i)
          .every((e) => _history.contains(_cells[e][_cellNum - e - 1]))) {
        _bingo = true;
      }
    });
  }
}

class _CellGenerator {
  final int _cellNum;
  static const _alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  final List<String> _remaining = [..._alphabet];

  _CellGenerator(this._cellNum);

  List<List<String>> generate() {
    var cells = List.generate(
        _cellNum,
        (_) => List.generate(_cellNum,
            (_) => _remaining.removeAt(Random().nextInt(_remaining.length))));
    return cells;
  }
}
