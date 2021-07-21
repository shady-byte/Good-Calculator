import 'package:math_expressions/math_expressions.dart';

String calculate(String expression) {
  Parser p = new Parser();
  Expression exp = p.parse(expression);
  ContextModel cm = ContextModel();
  String result = exp.evaluate(EvaluationType.REAL, cm).toString();
  double x = double.parse(result);
  int y = x.floor();
  if (x - y == 0) {
    return '$y';
  } else {
    if (result.length < 10) {
      return '$x';
    } else {
      return '${x.toStringAsFixed(10)}';
    }
  }
}
