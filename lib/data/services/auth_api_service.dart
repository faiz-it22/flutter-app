import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:projects/features/authentication/models/login_response_model.dart';
import 'package:projects/utils/constants/api_constants.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_service.g.dart';

@RestApi()
@injectable
abstract class AuthApiService {
  @factoryMethod
  factory AuthApiService(Dio dio) = _AuthApiService;

  @POST(APIConstants.tLoginUrl)
  Future<LoginResponseModel> login(@Body() Map<String, dynamic> body);
}
