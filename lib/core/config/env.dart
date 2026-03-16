abstract class Env {
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );

  static const useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );
}