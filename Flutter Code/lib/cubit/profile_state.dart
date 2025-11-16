import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String userName;
  final List<String> userAllergies;

  const ProfileState({this.userName = '', this.userAllergies = const []});

  ProfileState copyWith({String? userName, List<String>? userAllergies}) {
    return ProfileState(
      userName: userName ?? this.userName,
      userAllergies: userAllergies ?? this.userAllergies,
    );
  }

  // This is for equatable, it helps compare two states
  @override
  List<Object> get props => [userName, userAllergies];
}
