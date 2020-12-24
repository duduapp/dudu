import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/vote.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/screen.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:dudu/widget/common/sized_icon_button.dart';
import 'package:flutter/material.dart';

class HandleVoteDialog extends StatefulWidget {
  final Vote vote;

  HandleVoteDialog({this.vote});
  @override
  _HandleVoteDialogState createState() => _HandleVoteDialogState();
}

class _HandleVoteDialogState extends State<HandleVoteDialog> {
  Vote newVote;
  bool canCreate;

  @override
  void initState() {
    super.initState();
    if (widget.vote == null) {
      newVote = Vote();
    } else {
      newVote = widget.vote.clone();
    }
    canCreate = newVote.canCreate();
  }

  @override
  Widget build(BuildContext context) {
    var textWidth = ScreenUtil.width(context) * 0.6;
    return Theme(
      data: Theme.of(context)
          .copyWith(primaryColor: Theme.of(context).buttonColor),
      child: Container(
        width: ScreenUtil.width(context) * 0.9,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    IconFont.vote,
                    color: Theme.of(context).buttonColor,
                    size: 30,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    S.of(context).vote,
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _optionChanged,
                      maxLines: null,
                      maxLength: 25,
                      controller: newVote.option1Controller,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          hintText: S.of(context).choice1,
                          counterText: '',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                          labelText: S.of(context).choice1),
                    ),
                  ),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: false,
                    child: ClickableIconButton(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(Icons.clear),
                      ),
                      onTap: () {
                        newVote.removeOption4();
                        _optionChanged('');
                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _optionChanged,
                      maxLength: 25,
                      maxLines: null,
                      controller: newVote.option2Controller,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          hintText: S.of(context).choice2,
                          counterText: "",
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                          labelText: S.of(context).choice2),
                    ),
                  ),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: false,
                    child: ClickableIconButton(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(Icons.clear),
                      ),
                      onTap: () {
                        newVote.removeOption4();
                        _optionChanged('');
                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
              if (newVote.option3Enabled)
                SizedBox(
                  height: 10,
                ),
              if (newVote.option3Enabled)
                Row(children: <Widget>[
                  Expanded(
                    child: Container(
                      // width: textWidth,
                      child: TextField(
                        onChanged: _optionChanged,
                        maxLength: 25,
                        maxLines: null,
                        controller: newVote.option3Controller,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 10),
                            hintText: S.of(context).choice3,
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                            labelText: S.of(context).choice3),
                      ),
                    ),
                  ),
                  ClickableIconButton(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(Icons.clear),
                    ),
                    onTap: () {
                      newVote.removeOption3();
                      _optionChanged('');
                      setState(() {});
                    },
                  )
                ]),
              if (newVote.option4Enabled)
                SizedBox(
                  height: 10,
                ),
              if (newVote.option4Enabled)
                Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: _optionChanged,
                      maxLength: 25,
                      maxLines: null,
                      controller: newVote.option4Controller,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          hintText: S.of(context).choice4,
                          counterText: '',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                          labelText: S.of(context).choice4),
                    ),
                  ),
                  ClickableIconButton(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(Icons.clear),
                    ),
                    onTap: () {
                      newVote.removeOption4();
                      _optionChanged('');
                      setState(() {});
                    },
                  )
                ]),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  OutlineButton(
                    onPressed: () {
                      newVote.addOption();
                      setState(() {});
                    },
                    child: Text(S.of(context).add_selection),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  DropdownButton(
                    value: newVote.expiresInString,
                    onChanged: (dynamic newValue) {
                      newVote.expiresIn = Vote.voteOptionsInSeconds[newValue];

                      setState(() {
                        newVote.expiresInString = newValue;
                      });
                    },
                    items: Vote.voteOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Checkbox(
                      value: newVote.multiChoice,
                      onChanged: (value) {
                        setState(() {
                          newVote.multiChoice = value;
                        });
                      },
                    ),
                  ),
                  Text(S.of(context).multiple_choices)
                ],
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  NormalFlatButton(
                    text: S.of(context).cancel,
                    onPressed: () => AppNavigate.pop(),
                  ),
                  NormalFlatButton(
                    text: S.of(context).determine,
                    onPressed: canCreate
                        ? () => AppNavigate.pop(param: newVote)
                        : null,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _optionChanged(_) {
    if (canCreate != newVote.canCreate())
      setState(() {
        canCreate = !canCreate;
      });
  }
}
