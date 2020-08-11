import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/api/search_api.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/widget/common/measure_size.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class StatusTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged onChanged;

  const StatusTextEditor({this.controller, this.focusNode,this.onChanged});

  @override
  _StatusTextEditorState createState() => _StatusTextEditorState();
}

class _StatusTextEditorState extends State<StatusTextEditor> {
  double firstWidgetHeight = 0;
  double currentWidgetHeight = 0;
  SuggestionsBoxController _boxController = SuggestionsBoxController();

  @override
  Widget build(BuildContext context) {
    return MeasureSize(
      onChange: (size) {
        if (currentWidgetHeight != size.height) {
          try {
            _boxController?.resize();
          } catch (e) {

          }
        }
      },
      child: TypeAheadField(
        suggestionsBoxVerticalOffset: 5,
        keepSuggestionsOnLoading: false,
        suggestionsCallback: (pattern) async{
          String firstChar;
          String query;
          var arr = pattern.split(' ');
          if (arr.length > 1) {
            if (arr.last.isNotEmpty) {
              firstChar = arr.last.substring(0,1);
              query = arr.last.substring(1);
            }
          } else {
            if (pattern.isNotEmpty) {
              firstChar = pattern.substring(0,1);
              query = pattern.substring(1);
            }
          }
          if (pattern.isEmpty || firstChar == null || query == null || query.isEmpty) return null;
          switch (firstChar) {
            case '@':
              if (!query.contains('@'))
                return await SearchApi.searchAccounts(query);
              break;
            case '#':
              var res = await SearchApi.searchHashtags(query);
              return res['hashtags'];
              break;
            case ':':
              return await SearchApi.searchEmoji(query);
              break;
          }
          return null;
        },
        itemBuilder: (context, suggestion) {
          // 通过返回数据的结构来判断类型
          if (suggestion.containsKey('username')) {
            OwnerAccount account = OwnerAccount.fromJson(suggestion);
            return Padding(
              padding: const EdgeInsets.all(10),
              child: StatusItemAccount(account,noNavigateOnClick: true,),
            );
          } else if (suggestion.containsKey('history')) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('#'+suggestion['name'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            );
          } else if (suggestion.containsKey('shortcode')) {
            return ListTile(
              leading: SizedBox(width:35,height: 35,child: CachedNetworkImage(imageUrl: suggestion['static_url'],)),
              title: Text(':${suggestion['shortcode']}:',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
            );
          }
          return Container();
        },
        onSuggestionSelected: (suggestion) {
          if (suggestion.containsKey('username')) {
            _insertSelection('@', suggestion['acct']);
          } else if (suggestion.containsKey('history')) {
            _insertSelection('#', suggestion['name']);
          } else if (suggestion.containsKey('shortcode')) {
            _insertSelection(':', suggestion['shortcode']+':');
          }

        },

        suggestionsBoxController: _boxController,

        keepSuggestionsOnSuggestionSelected: true,

        hideOnEmpty: true,

        noItemsFoundBuilder: (_) => SizedBox(width: 0,height: 0,),

        hideOnLoading: true,

        hideSuggestionsOnKeyboardHide: true,

        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          color: Theme.of(context).backgroundColor,
          elevation: 2,
        ),

        textFieldConfiguration: TextFieldConfiguration(
          focusNode: widget.focusNode,
          controller: widget.controller,
          onChanged: (v) {
            if (widget.controller.text.isEmpty) {
              _boxController.close();
            }
            widget.onChanged(v);
            },
          style: TextStyle(fontSize: 19),

          autofocus: true,
          maxLength: 500,
          maxLines: null,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15),
              hintText: '有什么新鲜事',
              counterText: '',
              disabledBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              labelStyle: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }


  _insertSelection(String firstChar,String replaceWith) {
    var controller = widget.controller;
    controller.text = controller.text.substring(0,controller.text.lastIndexOf(firstChar)+1);
    controller.text = controller.text+replaceWith+' ';
    widget.focusNode.requestFocus();
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
  }
}
