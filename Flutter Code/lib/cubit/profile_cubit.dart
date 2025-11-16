import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final Box _userBox = Hive.box('user');

  ProfileCubit() : super(const ProfileState()) {
    loadProfile();
  }

  void loadProfile() {
    final String savedName = _userBox.get('userName', defaultValue: '');
    final List<String> savedAllergies = List<String>.from(
      _userBox.get('userAllergies', defaultValue: []),
    );

    emit(ProfileState(userName: savedName, userAllergies: savedAllergies));
  }

  Future<void> updateProfile(String newName, List<String> newAllergies) async {
    await _userBox.put('userName', newName);
    await _userBox.put('userAllergies', newAllergies);

    emit(ProfileState(userName: newName, userAllergies: newAllergies));
  }
}
