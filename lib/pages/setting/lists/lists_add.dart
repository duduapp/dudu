import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/utils/app_navigate.dart';
import 'package:fastodon/widget/common/normal_flat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListsAdd extends StatefulWidget {
  final ResultListProvider provider;

  const ListsAdd({Key key, this.provider}) : super(key: key);

  @override
  _ListsAddState createState() => _ListsAddState();
}

class _ListsAddState extends State<ListsAdd> {

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {


    return Container(
      padding: EdgeInsets.fromLTRB(12,12,12,5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: '列表名',
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).buttonColor))),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Spacer(),
              NormalFlatButton(
                text: '',
              ),
              NormalCancelFlatButton(),
              NormalFlatButton(
                text: '新建列表',
                onPressed: () async {
                  AppNavigate.pop();
                  var newList = await ListsApi.add(_controller.text.trim());
                  widget.provider.addToListWithAnimation(newList);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
