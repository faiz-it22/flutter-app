Future<String> fetchUserData({bool isSuccess = true}) {
  return Future.delayed(Duration(seconds: 2), () {
    if (isSuccess) {
      return "User data fetched successfully!";
    } else {
      throw Exception("Failed to fetch user data.");
    }
  });
}

Future<void> runWithAsyncAwait() async {
  print("--- Running with async/await ---");
  try {
    String data = await fetchUserData(isSuccess: true);
    print("Success: $data");
  } catch (error) {
    print("Caught error: $error");
  } finally {
    print("Async/await example finished.\n");
  }
}

void runWithThenCatch() {
  print("--- Running with .then().catchError() ---");
  fetchUserData(isSuccess: true)
    .then((data) {
      print("Success: $data");
    })
    .catchError((error) {
      print("Caught error: $error");
    })
    .whenComplete(() {
      print("Successful .then() example finished.");

      fetchUserData(isSuccess: false)
        .then((data) {
          print("This will not be printed.");
        })
        .catchError((error) {
          print("Caught error: $error");
        })
        .whenComplete(() {
          print("Failing .then() example finished.");
          print("\nBoth examples are complete.");
        });
    });
}

void main() async {
  await runWithAsyncAwait();
  runWithThenCatch();
}
