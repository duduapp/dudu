import 'package:dudu/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:nav_router/nav_router.dart';

class Vote {
  var option1Controller = TextEditingController();
  var option2Controller = TextEditingController();
  var option3Controller = TextEditingController();
  var option4Controller = TextEditingController();

  var option3Enabled = false;
  var option4Enabled = false;

  var _expiresInString;

  var expiresIn = 86400;
  String get expiresInString {
    if (_expiresInString != null) {
      return _expiresInString;
    }
    return S.of(navGK.currentState.overlay.context).day1;
  }

  var multiChoice = false;

  set expiresInString(String str) {
    _expiresInString = str;
  }

  static List<String> get voteOptions => [
        S.of(navGK.currentState.overlay.context).minutes5,
        S.of(navGK.currentState.overlay.context).minutes30,
        S.of(navGK.currentState.overlay.context).hour1,
        S.of(navGK.currentState.overlay.context).hours6,
        S.of(navGK.currentState.overlay.context).day1,
        S.of(navGK.currentState.overlay.context).days3,
        S.of(navGK.currentState.overlay.context).days7
      ];

  static Map<String, int> get voteOptionsInSeconds => {
        S.of(navGK.currentState.overlay.context).minutes5: 300,
        S.of(navGK.currentState.overlay.context).minutes30: 1800,
        S.of(navGK.currentState.overlay.context).hour1: 3600,
        S.of(navGK.currentState.overlay.context).hours6: 21600,
        S.of(navGK.currentState.overlay.context).day1: 86400,
        S.of(navGK.currentState.overlay.context).days3: 259200,
        S.of(navGK.currentState.overlay.context).days7: 604800
      };

  Vote();

  Vote.create(List<String> options, int expiresIn, bool multiChoose) {
    if (options.length == 0) {
    } else {
      option1Controller.text = options[0];
      if (options.length >= 2) option2Controller.text = options[1];
      if (options.length >= 3) {
        option3Controller.text = options[2];
        option3Enabled = true;
      }
      if (options.length == 4) {
        option4Controller.text = options[3];
        option4Enabled = true;
      }
    }
    this.expiresIn = expiresIn;
    this.expiresInString = voteOptionsInSeconds.keys.firstWhere(
        (k) => voteOptionsInSeconds[k] == expiresIn,
        orElse: () => null);
    this.multiChoice = multiChoose;
  }

  // 把option4的数据移到option3
  removeOption3() {
    if (option4Enabled) {
      option3Controller.text = option4Controller.text;
      option4Controller.clear();
      option4Enabled = false;
    } else {
      option3Controller.clear();
      option3Enabled = false;
    }
  }

  removeOption4() {
    option4Controller.clear();
    option4Enabled = false;
  }

  //是否可以根据现有数据创建投票
  bool canCreate() {
    var options = getOptions();

    for (var v in options) {
      if (v.isEmpty) {
        return false;
      }
    }

    return options.length == options.toSet().length;
  }

  List<String> getOptions() {
    var options = [option1Controller.text, option2Controller.text];
    if (option3Enabled) {
      options.add(option3Controller.text);
    }
    if (option4Enabled) {
      options.add(option4Controller.text);
    }
    return options;
  }

  sameValueInList(List list) {}

  addOption() {
    if (option3Enabled) {
      option4Enabled = true;
    } else if (option4Enabled) {
      return;
    } else {
      option3Enabled = true;
    }
  }

  allEnabled() {
    return option3Enabled && option4Enabled;
  }

  Vote clone() {
    return Vote()
      ..option1Controller = option1Controller
      ..option2Controller = option2Controller
      ..option3Controller = option3Controller
      ..option4Controller = option4Controller
      ..option3Enabled = option3Enabled
      ..option4Enabled = option4Enabled
      ..expiresIn = expiresIn
      ..expiresInString = expiresInString
      ..multiChoice = multiChoice;
//    return Vote(
//        option1Controller: this.option1Controller,
//        option2Controller: this.option2Controller,
//        option3Controller: this.option3Controller,
//        option4Controller: this.option4Controller,
//        option3Enabled: this.option3Enabled,
//        option4Enabled: this.option4Enabled,
//        expiresIn: this.expiresIn,
//        expiresInString: this.expiresInString,
//        multiChoice: this.multiChoice);
  }
}
