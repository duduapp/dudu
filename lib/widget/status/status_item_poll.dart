import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/utils/request.dart';
import 'package:flutter/material.dart';

class StatusItemPoll extends StatefulWidget {
  final Poll poll;

  StatusItemPoll(this.poll);
  @override
  _StatusItemPollState createState() => _StatusItemPollState();
}

class _StatusItemPollState extends State<StatusItemPoll> {
  var choices = <int>[];
  var radioGroup = "";
  Poll poll;

  @override
  void initState() {
    poll = widget.poll;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if (poll == null) {
      return Container();
    }

    if (poll.voted || poll.expired) {
      return resultPoll();
    } else {
      return votablePoll();
    }

  }

  Widget resultPoll() {
    var rows = <Widget>[];
    for (dynamic option in poll.options) {
      rows.add(optionRow(
          poll.votesCount == 0 ? 0 : option['votes_count'] / poll.votesCount,
          option['title']));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Column(children: rows), pollInfo()]);
  }

  Widget votablePoll() {
    var rows = <Widget>[];
      poll.options.asMap().forEach((key, value) {
        if (poll.multiple) {
          rows.add(CheckboxListTile(
            title: Text(value['title']),
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

          rows.add(RadioListTile(
            value: key.toString(),
            title: Text(value['title']),
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
          ));
        }
      });


    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        Column(children: rows,),
        Container(
          width: 150,
          child: OutlineButton(
            child: Text('投票'),
            onPressed: vote,
          ),
        ),
          pollInfo()
      ],),
    );
  }

  vote() async{
    Map<String, dynamic> paramsMap = Map();
    paramsMap['choices'] = choices;
    var response = await Request.post(url:'${Api.poll}/${poll.id}/votes',params: paramsMap,showDialog: false);
    Poll votedPoll = Poll.fromJson(response);
    if (votedPoll.id.isNotEmpty) {
      setState(() {
        poll = votedPoll;
      });
    }
  }

  Widget pollInfo() {
    return Container(
      margin: EdgeInsets.only(top: 5),
        child: Text(poll.expired
            ? '${poll.votesCount}次投票・已结束'
            : '${poll.votesCount}次投票・${getRemainingTime()}'));
  }

  getRemainingTime() {
    var expireAt = DateTime.parse(poll.expiresAt);
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
                    Text(title)
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
