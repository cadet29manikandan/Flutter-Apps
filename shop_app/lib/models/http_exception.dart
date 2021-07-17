class HTTPException implements Exception {
  final String mMessage;

  HTTPException(this.mMessage);

  @override
  String toString() {
    return mMessage;
  }
}