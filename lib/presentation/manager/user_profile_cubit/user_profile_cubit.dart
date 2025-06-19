import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ai_logistics_management_order_automation/data/repositories/users_management_repository.dart';
import 'package:ai_logistics_management_order_automation/data/services/multi_storage.dart';
import 'package:ai_logistics_management_order_automation/domain/models/filter_model.dart';
import 'package:ai_logistics_management_order_automation/domain/models/user_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/session/session_cubit.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UsersManagementRepositoryImpl userRepository;

  UserProfileCubit(this.userRepository) : super(UserProfileInitial());

  // Fetch User Details and Save Locally
  Future<bool> fetchUserDetails(String userID, {bool? needLoading}) async {
    if(needLoading != null) {

    } else {
      emit(UserProfileLoading());
    }

    try {
      final userDetails = await userRepository.getUserDetails(userID);
      if (userDetails != null) {

        emit(UserProfileLoaded(userDetails));
        return true;
      } else {
        emit(UserProfileError("User not found"));
        return false;
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
      return false;
    }
  }

  Future<void> updateUserFilter(FilterModel updatedFilter, UserModel userModel) async {
    emit(UserProfileLoading());
    try {
      await userRepository.updateUserFilter(userModel.userID, updatedFilter);
      emit(UserProfileFilterSuccess(message: 'Successfully updated filter'));
      await fetchUserDetails(userModel.userID);
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<bool> checkIfUserProfileActive(BuildContext context) async{
    if (context.read<UserProfileCubit>().state is UserProfileLoaded) {
      return true;
    } else {
      if(await Get.find<MultiStorageHandler>().checkUserIdAvailability()) {
        var userId = await Get.find<MultiStorageHandler>().retrieveUserId();
        if(userId != null) {
        var result = await context.read<UserProfileCubit>().fetchUserDetails(userId);

        if(result) {
          return true;
        } else {
          context.read<SessionCubit>().checkSession();
          return false;
        }
      } else {
        context.read<SessionCubit>().checkSession();
        return false;
      }
      } else {
        context.read<SessionCubit>().checkSession();
        return false;
      }
    }
  }
}
