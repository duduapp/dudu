import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/lists_api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:flutter/material.dart';

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
                hintText: S.of(context).list_name,
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
                text: S.of(context).new_list,
                onPressed: () async {
                  if (_controller.text.trim().isEmpty) {
                    DialogUtils.toastFinishedInfo(S.of(context).list_name_cannot_be_empty);
                    return;
                  }
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
