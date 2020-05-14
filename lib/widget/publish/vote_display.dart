import 'package:fastodon/models/vote.dart';
import 'package:fastodon/untils/screen.dart';
import 'package:flutter/material.dart';

class VoteDisplay extends StatelessWidget {
  final Vote vote;

  VoteDisplay(this.vote);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
      constraints: BoxConstraints(maxWidth: Screen.width(context) - 60),
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.list),
              Text(
                '投票',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (vote.multiChoice)
                Checkbox(
                  value: false,
                )
              else
                Radio(
                  value: false,
                ),
              Flexible(
                  child: Text(
                vote.option1Controller.text,
                overflow: TextOverflow.ellipsis,
              ))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (vote.multiChoice)
                Checkbox(
                  value: false,
                )
              else
                Radio(
                  value: false,
                ),
              Flexible(
                  child: Text(
                vote.option2Controller.text,
                overflow: TextOverflow.ellipsis,
              ))
            ],
          ),
          if (vote.option3Enabled)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (vote.multiChoice)
                  Checkbox(
                    value: false,
                  )
                else
                  Radio(
                    value: false,
                  ),
                Flexible(
                    child: Text(
                  vote.option3Controller.text,
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
          if (vote.option4Enabled)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (vote.multiChoice)
                  Checkbox(
                    value: false,
                  )
                else
                  Radio(
                    value: false,
                  ),
                Flexible(
                    child: Text(
                  vote.option4Controller.text,
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
          Text(vote.expiresInString)
        ],
      ),
    );
  }
}
