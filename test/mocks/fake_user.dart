import 'package:task_radar/features/shared/data/models/user_model.dart';

// Usuário admin para testes
final fakeAdminUser = UserModel(
  id: 1,
  username: 'emilys',
  email: 'emily.johnson@x.dummyjson.com',
  firstName: 'Emily',
  lastName: 'Johnson',
  gender: 'female',
  image: 'https://dummyjson.com/icon/emilys/128',
  role: 'admin',
  phone: '+81 965-431-3024',
  company: 'Dooley, Kozey and Cronin',
  department: 'Engineering',
  accessToken: 'fake_access_token',
  refreshToken: 'fake_refresh_token',
);

final fakeModeratorUser = UserModel(
  id: 2,
  username: 'moderator',
  email: 'gcezair0@gmail.com',
  firstName: 'Guilherme',
  lastName: 'Cezar',
  gender: 'male',
  image: 'https://dummyjson.com/icon/emilys/128',
  role: 'moderator',
  phone: '+87 9 9618-2672',
  company: 'Senai Soluções Digitais',
  department: 'Squad Apps',
  accessToken: 'fake_access_token',
  refreshToken: 'fake_refresh_token',
);