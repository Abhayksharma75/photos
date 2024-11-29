import 'dart:math' as math;

extension FloatArrayExtensions on List<double> {
  double dot(List<double> other) {
    if (this.length != other.length) {
      throw ArgumentError("Arrays must have the same length");
    }
    double sum = 0.0;
    for (int i = 0; i < this.length; i++) {
      sum += this[i] * other[i];
    }
    return sum;
  }
}

List<double> normalizeL2(List<double> inputArray) {
  double norm = 0.0;
  for (final val in inputArray) {
    norm += val * val;
  }
  norm = math.sqrt(norm);
  
  return inputArray.map((val) => val / norm).toList();
}
