import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:projects/data/local/user_schema.dart';
import 'package:projects/data/services/auth_api_service.dart';
import 'package:projects/features/authentication/models/login_response_model.dart';

@lazySingleton
class AuthenticationRepository {
  final AuthApiService _authApiService;
  final Box<User> _userBox;
  final _secureStorage = const FlutterSecureStorage();

  AuthenticationRepository(this._authApiService, this._userBox);

  LoginResponseModel? _loginResponse;
  LoginResponseModel? get loginResponse => _loginResponse;

  // Check if User is Logged In
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Login
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final body = {
        "username": username,
        "password": password,
      };

      final loginModel = await _authApiService.login(body);

      // Securely save tokens
      await _secureStorage.write(key: 'accessToken', value: loginModel.accessToken);
      await _secureStorage.write(key: 'refreshToken', value: loginModel.refreshToken);
      
      // Save User to Hive
      final newUser = User()
        ..username = username
        ..lastLogin = DateTime.now();
        
      await _userBox.put('current_user', newUser);

      _loginResponse = loginModel;
      return loginModel;
    } catch (e) {
      throw 'Authentication failed. Please check your credentials.';
    }
  }

  // Retrieve tokens securely
  Future<String?> getAccessToken() async => await _secureStorage.read(key: 'accessToken');

  // Logout
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    await _userBox.clear();
    _loginResponse = null;
  }
}
