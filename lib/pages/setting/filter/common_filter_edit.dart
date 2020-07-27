import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/models/provider/result_list_provider.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

class CommonFilterEdit extends StatefulWidget {
  final String id;
  final String phrase;
  final List context;
  final bool wholeWord;
  final bool newFilter;
  final ResultListProvider provider;

  CommonFilterEdit({this.id, this.phrase, this.context, this.wholeWord,this.newFilter = false,this.provider});

  @override
  _CommonFilterEditState createState() => _CommonFilterEditState();
}

class _CommonFilterEditState extends State<CommonFilterEdit> {
  bool wholeWord;
  TextEditingController phraseController;

  @override
  void initState() {
    wholeWord = widget.wholeWord ?? true;
    phraseController = TextEditingController(text: widget.phrase);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('添加新的过滤器',style: TextStyle(fontSize: 20),),
          TextField(
            controller: phraseController,
            decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).buttonColor))),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                value: wholeWord,
                onChanged: (bool value) {
                  setState(() {
                    wholeWord = value;
                  });
                },
              ),
              Text('整个单词')
            ],
          ),
          Text('如果关键字或缩写只有字母或数字，则只有在匹配整个单词才会应用'),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                child: Text('取消',style: TextStyle(color: Theme.of(context).buttonColor),),
                onPressed: () => AppNavigate.pop(context),
              ),
              Spacer(),
              if (!widget.newFilter)
              FlatButton(
                child: Text('移除',style: TextStyle(color: Theme.of(context).buttonColor)),
                onPressed: _remove,
              ),
              FlatButton(
                child: Text(widget.newFilter ?'新建':'更新',style: TextStyle(color: Theme.of(context).buttonColor)),
                onPressed: _updateOrCreate,
              ),
            ],
          )
        ],
      ),
    );
  }

  _remove() async{
    AppNavigate.pop(context);
    var res = await AccountsApi.removeFilter(widget.id);
    if (res != null) {
      widget.provider.removeByIdWithAnimation(widget.id);
    }
  }

  _updateOrCreate() async{
    AppNavigate.pop(context);
    if (widget.newFilter) {
      var res = await AccountsApi.addFilter(phraseController.text.trim(), widget.context, wholeWord);
      if (res != null) {
        widget.provider.addToListWithAnimation(res);
      }
    } else {
      var res = await AccountsApi.updateFilter(
          widget.id, phraseController.text.trim(), widget.context, wholeWord);
      if (res != null) {
        widget.provider.update(res);
      }
    }


  }
}
