/// Contract for all privileged writes. Production requests send a short-lived
/// Firebase ID token; service-role credentials never belong in Flutter.
abstract interface class EdgeFunctionClient {
  Future<Map<String, dynamic>> invoke(
    String function, {
    Map<String, dynamic>? body,
  });
}

class MockEdgeFunctionClient implements EdgeFunctionClient {
  @override
  Future<Map<String, dynamic>> invoke(
    String function, {
    Map<String, dynamic>? body,
  }) async => {'ok': true, 'function': function, 'mock': true, 'data': body};
}
