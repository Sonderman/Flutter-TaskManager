import 'package:get_it/get_it.dart';

import 'Services/HiveDb.dart';


GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerSingleton<HiveDb>(HiveDb());
}

//Locator kullanacağın zaman
/*
UserWorks userWorker = locator<UserWorks>();
*/
