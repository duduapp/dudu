import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/vote.dart';
import 'package:dudu/utils/screen.dart';
import 'package:flutter/material.dart';

class VoteDisplay extends StatelessWidget {
  final Vote vote;

  VoteDisplay(this.vote);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
      constraints: BoxConstraints(maxWidth: ScreenUtil.width(context) - 60),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).backgroundColor),
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(IconFont.vote,color: Colors.blue,),
              SizedBox(width: 5,),
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
