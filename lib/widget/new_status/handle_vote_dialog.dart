

import 'package:fastodon/models/json_serializable/vote.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/screen.dart';
import 'package:fastodon/widget/common/normal_flat_button.dart';
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
      data: Theme.of(context).copyWith(primaryColor: Theme.of(context).buttonColor),
      child: Container(
        width: ScreenUtil.width(context) * 0.9,
        padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.poll,color: Theme.of(context).buttonColor,size: 30,),
                SizedBox(width: 5,),
                Text('投票',style: TextStyle(fontSize: 20),)
              ],
            ),
            SizedBox(height: 20,),
            Container(
              width: textWidth,
              child: TextField(
                onChanged: _optionChanged,
                maxLines: null,
                maxLength: 25,
                controller: newVote.option1Controller,
                decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.only(left: 10, right: 10),
                    hintText: '选择1',
                    counterText: '',
                    border: new OutlineInputBorder(
                        borderSide:
                        new BorderSide(color: Colors.teal)),
                    labelText: '选择1'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: textWidth,
              child: TextField(
                onChanged: _optionChanged,
                maxLength: 25,
                maxLines: null,
                controller: newVote.option2Controller,
                decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.only(left: 10, right: 10),
                    hintText: '选择2',
                    counterText: "",
                    border: new OutlineInputBorder(
                        borderSide:
                        new BorderSide(color: Colors.teal)),
                    labelText: '选择2'),
              ),
            ),
            if (newVote.option3Enabled)
              SizedBox(
                height: 10,
              ),
            if (newVote.option3Enabled)
              Row(children: <Widget>[
                Container(
                  width: textWidth,
                  child: TextField(
                    onChanged: _optionChanged,
                    maxLength: 25,
                    maxLines: null,
                    controller: newVote.option3Controller,
                    decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.only(left: 10, right: 10),
                        hintText: '选择3',
                        counterText: "",
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.teal)),
                        labelText: '选择3'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      newVote.removeOption3();
                      _optionChanged('');
                      setState(() {});
                    },
                  ),
                )
              ]),
            if (newVote.option4Enabled)
              SizedBox(
                height: 10,
              ),
            if (newVote.option4Enabled)
              Row(children: <Widget>[
                Container(
                  width: textWidth,
                  child: TextField(
                    onChanged: _optionChanged,
                    maxLength: 25,
                    maxLines: null,
                    controller: newVote.option4Controller,
                    decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.only(left: 10, right: 10),
                        hintText: '选择4',
                        counterText: '',
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.teal)),
                        labelText: '选择4'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      newVote.removeOption4();
                      _optionChanged('');
                      setState(() {});
                    },
                  ),
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
                  child: Text('添加选择'),
                ),
                SizedBox(
                  width: 30,
                ),
                DropdownButton(
                  value: newVote.expiresInString,
                  onChanged: (String newValue) {
                    newVote.expiresIn =
                    Vote.voteOptionsInSeconds[newValue];

                    setState(() {
                      newVote.expiresInString = newValue;
                    });
                  },
                  items: Vote.voteOptions
                      .map<DropdownMenuItem<String>>(
                          (String value) {
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
                Text('多个选择')
              ],
            ),
            Row(children: <Widget>[
              Spacer(),
              NormalFlatButton(text: '取消',onPressed: () => AppNavigate.pop(),),
              NormalFlatButton(text: '确定',onPressed: canCreate ?() => AppNavigate.pop(param: newVote) :null,)
            ],)
          ],
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
