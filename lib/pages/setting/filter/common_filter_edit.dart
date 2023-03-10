import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/filter_util.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.newFilter?S.of(context).add_new_filter:S.of(context).edit_filter,style: TextStyle(fontSize: 20),),
            TextField(
              controller: phraseController,
              maxLines: null,
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
                Text(S.of(context).whole_word)
              ],
            ),
            Text(S.of(context).if_the_keyword_or_abbreviation_has_only_letters_or_numbers),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                NormalCancelFlatButton(),
                Spacer(),
                if (!widget.newFilter)
                  NormalFlatButton(
                    text: S.of(context).remove,
                    onPressed: _remove,
                  ),
                NormalFlatButton(
                  text: widget.newFilter ?S.of(context).create:S.of(context).update,
                  onPressed: _updateOrCreate,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _remove() async{
    AppNavigate.pop();
    var res = await AccountsApi.removeFilter(widget.id);
    if (res != null) {
      widget.provider.removeByIdWithAnimation(widget.id);
      FilterUtil.getFiltersAndApply();
    }
  }

  _updateOrCreate() async{
    if (phraseController.text.trim().isEmpty) {
      DialogUtils.toastFinishedInfo(S.of(context).filter_cannot_be_empty);
      return;
    }
    AppNavigate.pop();
    if (widget.newFilter) {
      var res = await AccountsApi.addFilter(phraseController.text.trim(), widget.context, wholeWord);
      if (res != null) {
        widget.provider.addToListWithAnimation(res);
        FilterUtil.getFiltersAndApply();
      }
    } else {
      var res = await AccountsApi.updateFilter(
          widget.id, phraseController.text.trim(), widget.context, wholeWord);
      if (res != null) {
        widget.provider.update(res);
        FilterUtil.getFiltersAndApply();
      }
    }


  }
}
