import 'package:flutter/cupertino.dart';

class Vote {
  var option1Controller = TextEditingController();
  var option2Controller = TextEditingController();
  var option3Controller = TextEditingController();
  var option4Controller = TextEditingController();

  var option3Enabled = false;
  var option4Enabled = false;

  var expiresIn = 86400;
  var expiresInString = '1天';

  var multiChoice = false;

  static List<String> voteOptions = [
    '5分钟',
    '30分钟',
    '1小时',
    '6小时',
    '1天',
    '3天',
    '7天'
  ];

  static Map<String, int> voteOptionsInSeconds = {
    '5分钟': 300,
    '30分钟': 1800,
    '1小时': 3600,
    '6小时': 21600,
    '1天': 86400,
    '3天': 259200,
    '7天': 604800
  };

  Vote(
      {this.option1Controller,
      this.option2Controller,
      this.option3Controller,
      this.option4Controller,
      this.option3Enabled,
      this.option4Enabled,
      this.expiresIn,
      this.expiresInString,
      this.multiChoice});

  Vote.create() {}

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
  canCreate() {
    var options = getOptions();

    for (var v in options) {
      if (v.isEmpty) {
        return false;
      }
    }

    return options.length == options.toSet().length;
  }

  getOptions() {
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
    return Vote(
        option1Controller: this.option1Controller,
        option2Controller: this.option2Controller,
        option3Controller: this.option3Controller,
        option4Controller: this.option4Controller,
        option3Enabled: this.option3Enabled,
        option4Enabled: this.option4Enabled,
        expiresIn: this.expiresIn,
        expiresInString: this.expiresInString,
        multiChoice: this.multiChoice);
  }
}
