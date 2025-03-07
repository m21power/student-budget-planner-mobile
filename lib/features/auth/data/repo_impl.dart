import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hackathon_mobile/core/constants/api_constant.dart';
import 'package:hackathon_mobile/core/constants/global_constant.dart';
import 'package:hackathon_mobile/core/error/failure.dart';
import 'package:hackathon_mobile/core/network/network.dart';
import 'package:hackathon_mobile/features/auth/domain/entities/user_entities.dart';
import 'package:hackathon_mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepoImpl implements AuthRepository {
  final NetworkInfo networkInfo;
  final http.Client client;
  final SharedPreferences sharedPreferences;
  AuthRepoImpl(
      {required this.networkInfo,
      required this.client,
      required this.sharedPreferences});
  @override
  Future<Either<Failure, UserEntities>> login(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        var uri = Uri.parse('${ApiConstant.BaseUrl}/login');
        var response = await client.post(uri,
            body: jsonEncode({'email': email, 'password': password}));
        if (response.statusCode == 200) {
          var decodedResponse = jsonDecode(response.body);
          var id = decodedResponse['id'];
          var name = decodedResponse['name'];
          var badges = List<String>.from(decodedResponse['badge']);
          print('test');
          UserEntities user = UserEntities(
              id: id.toString(),
              email: email,
              name: name.toString(),
              badges: badges.toList(),
              password: password);
          await sharedPreferences.setString(
              Constant.sharedPrefereceKey, user.toJson());
          return Right(user);
        }
        return Left(ServerFailure(message: 'Server Failure'));
      } catch (e) {
        return Left(ServerFailure(message: 'Server Failure'));
      }
    } else {
      return Left(NetworkFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> register(
      String name, String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        var uri = Uri.parse('${ApiConstant.BaseUrl}/register');
        var response = await client.post(uri,
            body: jsonEncode(
                {'name': name, 'email': email, 'password': password}));
        print(response.body);
        if (response.statusCode == 200) {
          return Right(unit);
        }
      } catch (e) {
        return Left(ServerFailure(message: 'Server Failure'));
      }
      return Left(ServerFailure(message: 'Server Failure'));
    } else {
      return Left(NetworkFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> isLoggedIn() async {
    try {
      var user = sharedPreferences.getString(Constant.sharedPrefereceKey);
      if (user != null) {
        return Right(unit);
      }
      return Left(CacheFailure(message: 'Cache Failure'));
    } catch (e) {
      return Left(NetworkFailure(message: 'Server Failure'));
    }
  }
}
