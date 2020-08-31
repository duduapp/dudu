import 'package:dudu/constant/api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/request.dart';
import 'package:dudu/utils/view/status_action_util.dart';

import 'package:flutter/material.dart';

class StatusItemPoll extends StatefulWidget {
  final StatusItemData status;

  StatusItemPoll(this.status);
  @override
  _StatusItemPollState createState() => _StatusItemPollState();
}

class _StatusItemPollState extends State<StatusItemPoll> {
  var choices = <int>[];
  var radioGroup = "";


  @override
  void initState() {
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    if (widget.status.poll == null) {
      return Container();
    } else {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: ScreenUtil.scaleFromSetting(SettingsProvider().get('text_scale'))),
        child: Container(
          padding: EdgeInsets.only(bottom: 6),
          child: widget.status.poll.voted || widget.status.poll.expired ? resultPoll() : votablePoll(),
        ),
      );
    }



  }

  Widget resultPoll() {
    var rows = <Widget>[];
    for (dynamic option in widget.status.poll.options) {
      rows.add(optionRow(
          widget.status.poll.votesCount == 0 ? 0 : option['votes_count'] / widget.status.poll.votesCount,
          option['title']));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Column(children: rows), pollInfo()]);
  }

  Widget votablePoll() {
    var rows = <Widget>[];
      widget.status.poll.options.asMap().forEach((key, value) {
        if (widget.status.poll.multiple) {
          rows.add(CheckboxListTile(
            title: Text(value['title'],style: TextStyle(fontSize: 12),),
            value: choices.contains(key),
            onChanged: (value) {
              if (value) {
                setState(() {
                  choices.add(key);
                });

              } else {
                setState(() {
                  choices.removeWhere((element) => element == key);
                });

              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ));
        } else {

          rows.add(SizedBox(
            //height: 32,
            child: RadioListTile(
              dense: true,
              value: key.toString(),
              title: Text(value['title'],style: TextStyle(fontSize: 12),),
              groupValue: radioGroup,
              onChanged: (value) {
                setState(() {
                  setState(() {
                    radioGroup = value;
                  });
                  choices.clear();
                  choices.add(key);
                });

              },
              selected: choices.contains(key),
            ),
          ));
        }
      });


    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      Column(children: rows,),
      SizedBox(height: 5,),
      ButtonTheme(
        minWidth: 100,
     //   height: 28,
        child: OutlineButton(
          child: Text('投票',style: TextStyle(fontSize:12,color: Theme.of(context).buttonColor),),
          onPressed: vote,
        ),
      ),
        pollInfo()
    ],);
  }

  vote() async{
    Map<String, dynamic> paramsMap = Map();
    paramsMap['choices'] = choices;
    var response = await Request.post(url:'${Api.poll}/${widget.status.poll.id}/votes',params: paramsMap,showDialog: true);
    if (response != null)
    StatusActionUtil.updateStatusVote(widget.status, response, context);


  }

  Widget pollInfo() {
    return Container(
      margin: EdgeInsets.only(top: 5),
        child: Text(widget.status.poll.expired
            ? '${widget.status.poll.votesCount}次投票・已结束'
            : '${widget.status.poll.votesCount}次投票・${getRemainingTime()}',style: TextStyle(fontSize: 10,color: Theme.of(context).accentColor),));
  }

  getRemainingTime() {
    var expireAt = DateTime.parse(widget.status.poll.expiresAt);
    var diff = expireAt.difference(DateTime.now());
    return diff.inDays > 0 ? '剩余${diff.inDays}天': diff.inHours > 0 ? '剩余${diff.inHours}小时' :'剩余${diff.inMinutes}分钟';
  }

  Widget optionRow(double pententage, String title) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          margin: EdgeInsets.only(top: 5),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: pententage == 1
                    ? BorderRadius.circular(5)
                    : BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5)),
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: constraints.maxWidth * pententage,
                  color: Colors.grey[400],
                  child: Opacity(
                    child: Text('a'),
                    opacity: 0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                width: constraints.maxWidth,
                child: Row(
                  children: <Widget>[
                    Text('${(pententage * 100).round()}%'),
                    SizedBox(
                      width: 5,
                    ),
                    Flexible(child: Text(title,overflow: TextOverflow.ellipsis,maxLines: 1,style: TextStyle(fontSize: 12),))
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
