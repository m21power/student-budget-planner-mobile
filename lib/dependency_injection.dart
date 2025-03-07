import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:hackathon_mobile/core/network/network.dart';
import 'package:hackathon_mobile/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:hackathon_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:hackathon_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'features/auth/data/repo_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/register_usecase.dart';

final sl = get_it.GetIt.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initNotifications() async {
  var androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: androidInitialize);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> init() async {
  //core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // external
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => sharedPreferences);

  // features - auth
  //repository

  sl.registerLazySingleton<AuthRepository>(() =>
      AuthRepoImpl(networkInfo: sl(), client: sl(), sharedPreferences: sl()));
  // usecases
  sl.registerLazySingleton<LoginUsecase>(
      () => LoginUsecase(authRepository: sl()));
  sl.registerLazySingleton<RegisterUsecase>(
      () => RegisterUsecase(authRepository: sl()));
  sl.registerLazySingleton<IsLoggedInUsecase>(
      () => IsLoggedInUsecase(authRepository: sl()));

  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(
      loginUsecase: sl(), registerUsecase: sl(), isLoggedInUsecase: sl()));
}
