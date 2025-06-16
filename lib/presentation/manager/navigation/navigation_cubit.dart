import 'package:bloc/bloc.dart';
import 'package:go_router/go_router.dart';


part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  late StatefulNavigationShell statefulNavigationShell;

  NavigationCubit() : super(NavigationState(0, ''));

  void setNavigationShell(StatefulNavigationShell shell) {
    statefulNavigationShell = shell;
  }

  void goBranch(int index, {bool initialLocation = false}) {
    statefulNavigationShell.goBranch(index, initialLocation: initialLocation);
    emit(NavigationState(index, state.currentPageName));
  }

  void updateCurrentPageName(String page) {
    print('page $page');
    emit(NavigationState(state.currentBranchIndex, page));
  }
}
