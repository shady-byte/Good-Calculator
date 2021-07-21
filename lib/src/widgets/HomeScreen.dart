import '../classes/calculate.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:vibration/vibration.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  List<int> pointers = [0];
  double startx = 0, starty = 0;
  Offset origin = Offset.zero;
  String directionx = '',
      directiony = '',
      symbol = '',
      number = '',
      keyValue = '';
  bool shake = false, newCalc = false;
  static const Map<int, String> morseCode = {
    0: '-----',
    1: '.----',
    2: '..---',
    3: '...--',
    4: '....-',
    5: '.....',
    6: '-....',
    7: '--...',
    8: '---..',
    9: '----.'
  };

  HomeScreenState() {
    ShakeDetector.autoStart(onPhoneShake: () {
      onShaking();
    });
    Vibration.vibrate(pattern: [500, 800]);
  }

  Widget build(context) {
    var screenSize = MediaQuery.of(context).size;
    return Listener(
      onPointerDown: (e) {
        String x = e.timeStamp.inMilliseconds.toString();
        pointers.add(int.parse(x.substring(0, 9)));
      },
      child: GestureDetector(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                multiplySign(screenSize),
                divideSign(screenSize),
                plusSign(screenSize),
                minusSign(screenSize),
                resultWidget(screenSize, number),
                symbolWidget(screenSize, symbol, keyValue),
              ],
            ),
          ),
        ),
        onTap: callOnTap,
        onLongPress: callOnLongPress,
        onHorizontalDragStart: (e) {
          startx = e.globalPosition.dx;
        },
        onHorizontalDragUpdate: (e) {
          directionx = e.globalPosition.dx > startx ? 'right' : 'left';
        },
        onHorizontalDragEnd: (e) {
          operators(directionx);
        },
        onVerticalDragStart: (e) {
          starty = e.globalPosition.dy;
        },
        onVerticalDragUpdate: (e) {
          directiony = e.globalPosition.dy > starty ? 'top' : 'bottom';
        },
        onVerticalDragEnd: (e) {
          operators(directiony);
        },
      ),
    );
  }

//The functions we use in the application
  void onShaking() {
    setState(() {
      String result = calculate(number);
      number = result;
      newCalc = true;
    });
    var vibrates = readResult(number);
    vibrates.insert(0, 0);
    vibrates.insert(1, 600);
    vibrates[2] = 1200;
    Vibration.vibrate(pattern: vibrates);
  }

  void twoFingerTap() {
    setState(() {
      shake = true;
      if (symbol.length <= 4 && symbol.length > 0) {
        if (symbol.startsWith('.')) {
          symbol = symbol + '-' * (5 - symbol.length);
        } else {
          symbol = symbol + '.' * (5 - symbol.length);
        }
      }
      morseCode.forEach((key, value) {
        if (value == symbol) {
          number = number + '$key';
        }
      });
      symbol = '';
      keyValue = '';
    });
    Vibration.vibrate(pattern: [0, 200, 80, 200]);
  }

  void resetApp() {
    setState(() {
      symbol = '';
      keyValue = '';
      number = '';
    });
    Vibration.vibrate(pattern: [0, 200, 80, 200]);
  }

  void printDotSymbol() {
    if (newCalc) {
      if (number.lastIndexOf(new RegExp(r'\D')) != number.length - 1) {
        number = '';
        newCalc = false;
      }
    }
    setState(() {
      if (symbol.length > 4) {
        symbol = '';
        keyValue = '';
      } else {
        symbol = symbol + '.';
        morseCode.forEach((key, value) {
          if (symbol.startsWith('.')) {
            int x = symbol.length;
            if (value == (symbol + '-' * (5 - x))) {
              keyValue = '$key';
            }
          }
        });
      }
    });
    Vibration.vibrate(duration: 200);
  }

  void printDashSymbol() {
    if (newCalc) {
      if (number.lastIndexOf(new RegExp(r'\D')) != number.length - 1) {
        number = '';
        newCalc = false;
      }
    }
    setState(() {
      if (symbol.length > 4) {
        symbol = '';
        keyValue = '';
      } else {
        symbol = symbol + '-';
        morseCode.forEach((key, value) {
          if (symbol.startsWith('-')) {
            int x = symbol.length;
            if (value == (symbol + '.' * (5 - x))) {
              keyValue = '$key';
            }
          }
        });
      }
    });
    Vibration.vibrate(duration: 350);
  }

  List<int> readResult(String result) {
    List<int> vibrates = [];
    result.split('').forEach((element) {
      if (element == '-') {
        vibrates.add(300);
        vibrates.add(400);
      } else if (element == '.') {
        vibrates.add(100);
      } else {
        morseCode.forEach((key, value) {
          if (int.parse(element) == key) {
            value.split('').forEach((e) {
              if (vibrates.isEmpty) {
                vibrates.add(300);
              } else if (vibrates.isNotEmpty && vibrates.last != 610) {
                vibrates.add(300);
              }

              if (e == '.') {
                vibrates.add(150);
              } else if (e == '-') {
                vibrates.add(400);
              }
            });
          }
        });
      }
      vibrates.add(610);
    });
    if (result.contains('.')) {
      vibrates[10 * result.indexOf('.') + 2] = 680;
    }
    return vibrates;
  }

  void operators(String direction) {
    if (true) {
      if (number.lastIndexOf(new RegExp(r'\D')) != number.length - 1) {
        if (direction == 'left') {
          setState(() {
            number = number + '-';
          });
        } else if (direction == 'right') {
          setState(() {
            number = number + '+';
          });
        } else if (direction == 'top') {
          setState(() {
            number = number + '*';
          });
        } else if (direction == 'bottom') {
          setState(() {
            number = number + '/';
          });
        }
        Vibration.vibrate(pattern: [0, 200, 20, 200]);
      }
    }
  }

  bool validate() {
    if (pointers.last - pointers[pointers.length - 2] <= 10) {
      return false;
    } else {
      return true;
    }
  }

  void callOnTap() {
    if (pointers.last - pointers[pointers.length - 2] <= 10) {
      twoFingerTap();
    } else {
      printDotSymbol();
    }
  }

  void callOnLongPress() {
    if (pointers.last - pointers[pointers.length - 2] <= 10) {
      resetApp();
    } else {
      printDashSymbol();
    }
  }
}

Widget multiplySign(var screenSize) {
  return Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.only(top: 0.011 * screenSize.height),
      child: Text(
        '*',
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
          fontSize: 50.0,
        ),
      ),
    ),
  );
}

Widget divideSign(var screenSize) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(bottom: 0.011 * screenSize.height),
      child: Text(
        '/',
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
          fontSize: 50.0,
        ),
      ),
    ),
  );
}

Widget plusSign(var screenSize) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.only(left: 0.02 * screenSize.width),
      child: Text(
        '+',
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
          fontSize: 50.0,
        ),
      ),
    ),
  );
}

Widget minusSign(var screenSize) {
  return Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: EdgeInsets.only(right: 0.02 * screenSize.width),
      child: Text(
        '-',
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
          fontSize: 50.0,
        ),
      ),
    ),
  );
}

Widget resultWidget(var screenSize, String number) {
  return Positioned(
    top: 0.08 * screenSize.height,
    left: 0.07 * screenSize.width,
    right: 0.07 * screenSize.width,
    child: Text(
      number,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 57.0,
      ),
    ),
  );
}

Widget symbolWidget(var screenSize, String symbol, String keyValue) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(bottom: 0.16 * screenSize.height),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            keyValue,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 50.0,
            ),
          ),
          Text(
            symbol,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 80.0,
            ),
          ),
        ],
      ),
    ),
  );
}
