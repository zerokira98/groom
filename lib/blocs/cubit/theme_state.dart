part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final ThemeMode mode;
  final ThemeData themeData;

  final FlexScheme currentScheme;

  const ThemeState(
      {required this.currentScheme,
      required this.themeData,
      required this.mode});
  @override
  List<Object> get props => [mode, currentScheme, themeData];
}
