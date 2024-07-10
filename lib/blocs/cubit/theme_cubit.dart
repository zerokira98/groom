import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:groom/model/themedatas.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  late SharedPreferences _sp;
  ThemeDatas themeDatas;
  ThemeCubit({required this.themeDatas})
      : super(ThemeState(
            themeData: themeDatas.lightTheme(),
            currentScheme: FlexScheme.custom,
            mode: ThemeMode.system));
  void getThemeData() async {
    _sp = await SharedPreferences.getInstance();
    var b = _sp.getString('themeMode');
    var d = _sp.getString('FlexScheme');
    FlexScheme scheme = FlexScheme.values.firstWhere(
        (element) => element.name == d,
        orElse: () => FlexScheme.values[0]);
    if (b == null) {
      var c = await _sp.setString('themeMode', 'light');
      await _sp.setString('FlexScheme', scheme.name);
      if (c) {
        print('c$c');
      }
      emit(ThemeState(
          themeData: themeDatas.lightTheme(scheme),
          currentScheme: scheme,
          mode: ThemeMode.light));
    } else if (b == 'dark') {
      emit(ThemeState(
          themeData: themeDatas.darkTheme(scheme),
          currentScheme: scheme,
          mode: ThemeMode.dark));
    } else if (b == 'light') {
      // _sp.setString('themeMode', 'dark');
      emit(ThemeState(
          themeData: themeDatas.lightTheme(scheme),
          currentScheme: scheme,
          mode: ThemeMode.light));
    }
  }

  void changeColorScheme(FlexScheme scheme) async {
    // emit()
    var b = _sp.getString('themeMode');
    await _sp.setString('FlexScheme', scheme.name);
    // print(b);
    switch (b) {
      case null:
        _sp.setString('themeMode', 'light');
        emit(ThemeState(
            themeData: themeDatas.lightTheme(scheme),
            currentScheme: scheme,
            mode: ThemeMode.light));
        break;
      case 'light':
        emit(ThemeState(
            themeData: themeDatas.lightTheme(scheme),
            currentScheme: scheme,
            mode: ThemeMode.light));
        break;
      case 'dark':
        emit(ThemeState(
            themeData: themeDatas.darkTheme(scheme),
            currentScheme: scheme,
            mode: ThemeMode.dark));
        break;
      default:
    }
  }

  void changeDarkLight() async {
    var b = _sp.getString('themeMode');
    var d = _sp.getString('FlexScheme');
    FlexScheme scheme = FlexScheme.values.firstWhere(
        (element) => element.name == d,
        orElse: () => FlexScheme.values[0]);
    if (b == 'dark') {
      _sp.setString('themeMode', 'light');
      emit(ThemeState(
          themeData: themeDatas.lightTheme(scheme),
          currentScheme: scheme,
          mode: ThemeMode.light));
    } else if (b == 'light') {
      _sp.setString('themeMode', 'dark');
      emit(ThemeState(
          themeData: themeDatas.darkTheme(scheme),
          currentScheme: scheme,
          mode: ThemeMode.dark));
    }
  }
}
