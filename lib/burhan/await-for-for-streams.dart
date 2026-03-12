import 'dart:async';

Stream<int> createNumberStream() async* {
  for (int i = 0; i <= 10; i++) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}

Future<void> printStreamValues() async {
  print("Listening to the number stream...");

  Stream<int> numberStream = createNumberStream();

  await for (int value in numberStream) {
    print("Received value: $value");
  }

  print("Stream is closed. `await for` loop is complete.");
}

void main() async {
  await printStreamValues();
}
