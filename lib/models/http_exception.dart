// implements inheriting an abstract class (abstract meaning we can't directly instantiate it)
// forced to implement all functions the parent class has
//
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  // overriding Exception class toString();
  @override
  String toString() {
    return message;
    // return super.toString();
  }
}
