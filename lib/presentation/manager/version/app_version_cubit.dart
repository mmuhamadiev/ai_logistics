import 'package:bloc/bloc.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/app_version_repository.dart';
import 'package:meta/meta.dart';

part 'app_version_state.dart';

class AppVersionCubit extends Cubit<AppVersionState> {
  final AppVersionRepository repository;

  AppVersionCubit(this.repository)
      : super(AppVersionState(isOutdated: false, isLoading: true));

  void checkAppVersion() async {
    emit(AppVersionState(isOutdated: false, isLoading: true));
    bool outdated = await repository.isAppOutdated();
    emit(AppVersionState(isOutdated: outdated, isLoading: false));
  }
}
