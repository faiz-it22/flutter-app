import 'dart:isolate';

int fib(int n) {
  if (n < 2) {
    return n;
  }
  return fib(n - 2) + fib(n - 1);
}

Future<void> runFibonacciInIsolate() async {
  print('Starting Fibonacci calculation in a separate isolate...');

  final result = await Isolate.run(() => fib(40));

  print('Fibonacci calculation finished. Result: $result');
}

void main() async {
  await runFibonacciInIsolate();
}
