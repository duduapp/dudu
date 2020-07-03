import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

class CommonFilterEdit extends StatefulWidget {
  final String id;
  final String phrase;
  final List context;
  final bool wholeWord;
  final bool newFilter;

  CommonFilterEdit({this.id, this.phrase, this.context, this.wholeWord,this.newFilter = false});

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
              child: Text('取消'),
              onPressed: () => AppNavigate.pop(context),
            ),
            Spacer(),
            if (!widget.newFilter)
            FlatButton(
              child: Text('移除'),
              onPressed: _remove,
            ),
            FlatButton(
              child: Text(widget.newFilter ?'新建':'更新'),
              onPressed: _updateOrCreate,
            ),
          ],
        )
      ],
    );
  }

  _remove() async{
    AccountsApi.removeFilter(widget.id).then(
        (dynamic d) {eventBus.emit(EventBusKey.filterEdited);}
    );
    AppNavigate.pop(context);
  }

  _updateOrCreate() async{
    if (widget.newFilter) {
      AccountsApi.addFilter(phraseController.text.trim(), widget.context, wholeWord).then((_)=>eventBus.emit(EventBusKey.filterEdited) );
    } else {
      AccountsApi.updateFilter(
          widget.id, phraseController.text.trim(), widget.context, wholeWord)
          .then(
              (dynamic d) {
            eventBus.emit(EventBusKey.filterEdited);
          }
      );
    }

    AppNavigate.pop(context);
  }
}
