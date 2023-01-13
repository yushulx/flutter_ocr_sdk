/// MrzLine class.
class MrzLine {
  int confidence = 0;
  String text = '';

  int x1 = 0, y1 = 0, x2 = 0, y2 = 0, x3 = 0, y3 = 0, x4 = 0, y4 = 0;

  @override
  String toString() {
    String result = '';
    result += 'Confidence: $confidence\n';
    result += 'Text: $text\n';
    result += 'x1: $x1\n';
    result += 'y1: $y1\n';
    result += 'x2: $x2\n';
    result += 'y2: $y2\n';
    result += 'x3: $x3\n';
    result += 'y3: $y3\n';
    result += 'x4: $x4\n';

    return result;
  }
}
