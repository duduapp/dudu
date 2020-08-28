import 'package:dudu/api/lists_api.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/pages/setting/lists/lists_add.dart';
import 'package:dudu/pages/setting/lists/lists_eidt.dart';
import 'package:dudu/pages/timeline/lists_timeline.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListsPage extends StatefulWidget {
  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  BuildContext providerContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('列表'),
        actions: <Widget>[
          IconButton(
            icon: Icon(IconFont.follow,size: 28,),
            onPressed: () => _showAddDialog(),
          )
        ],
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
          create: (context) => ResultListProvider(
              requestUrl: Api.lists,
              buildRow: _row,
              enableRefresh: false,
              enableLoad: false,
              reverseData: true),
          builder: (context, snapshot) {
            providerContext = context;
            return ProviderEasyRefreshListView(useAnimatedList: true,);
          }),
    );
  }

  Widget _row(int idx, List data, ResultListProvider provider) {
    var list = data[idx];
    return ListRow(
      padding: 0,
      child: InkWell(
        onTap: () => AppNavigate.push(ListTimeline(list['id'])),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Icon(
              IconFont.list,
              size: 25,
            ),
            SizedBox(width: 5,),
            Text(
              list['title'],
              style: TextStyle(fontSize: 18),
            ),
            Spacer(),
            PopupMenuButton(
              offset: Offset(0, 35),
              icon: Icon(IconFont.moreHoriz,size: 28,),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                new PopupMenuItem<String>(value: 'edit', child: new Text('编辑列表')),
                new PopupMenuItem<String>(
                    value: 'rename', child: new Text('重命名列表')),
                new PopupMenuItem<String>(
                    value: 'delete', child: new Text('删除列表')),
              ],
              onSelected: (String value) {
                switch (value) {
                  case 'edit':
                    _showEditDialog(list['id']);
                    break;
                  case 'rename':
                    _showRenameDialog(list['id'], list['title'], provider);
                    break;
                  case 'delete':
                    _remove(list['id'], provider);
                    break;
                }
              },
            )
          ]),
        ),
      ),
    );
  }

  _showEditDialog(String listId) {
    DialogUtils.showRoundedDialog(
        context: context, content: ListsEdit(listId, ""), radius: 3);
  }

  _showRenameDialog(String id, String title, ResultListProvider provider) {

    DialogUtils.showRoundedDialog(context: context,content: ListsRename(id: id,title: title,provider: provider,));

  }

  _showAddDialog() {
    ResultListProvider provider =
        Provider.of<ResultListProvider>(providerContext, listen: false);
    DialogUtils.showRoundedDialog(
        context: providerContext,
        content: ListsAdd(
          provider: provider,
        ));
  }

  _remove(String id, ResultListProvider provider) async {
    await ListsApi.remove(id);
    provider.removeByIdWithAnimation(id);
  }
}

class ListsRename extends StatefulWidget {
  final String id;
  final String title;
  final ResultListProvider provider;

  const ListsRename({Key key, this.id, this.title,this.provider}) : super(key: key);
  
  @override
  _ListsRenameState createState() => _ListsRenameState();
}

class _ListsRenameState extends State<ListsRename> {
  TextEditingController _controller;
  
  @override
  void initState() {
    _controller = TextEditingController(text: widget.title);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12,12,12,5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).buttonColor))),
            controller: _controller,
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Spacer(),
              NormalCancelFlatButton(),
              NormalFlatButton(
                text: '重命名列表',
                onPressed: () async {
                  AppNavigate.pop();
                  var data =
                  await ListsApi.updateTitle(widget.id, _controller.text.trim());
                  widget.provider.update(data);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

