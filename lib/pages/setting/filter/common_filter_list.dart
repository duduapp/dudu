import 'package:fastodon/api/accounts_api.dart';
import 'package:fastodon/constant/event_bus_key.dart';
import 'package:fastodon/pages/setting/filter/common_filter_edit.dart';
import 'package:fastodon/widget/common/list_row.dart';
import 'package:fastodon/widget/listview/easyrefresh_listview.dart';
import 'package:flutter/material.dart';

enum FilterType { home, notifications, public, thread }

class CommonFilterList extends StatefulWidget {
  final FilterType type;

  CommonFilterList(this.type);

  @override
  _CommonFilterListState createState() => _CommonFilterListState();
}

class _CommonFilterListState extends State<CommonFilterList> {



  @override
  Widget build(BuildContext context) {
    var title;
    switch (widget.type) {
      case FilterType.home:
        title = '主页';
        break;
      case FilterType.notifications:
        title = '通知';
        break;
      case FilterType.public:
        title = '公共时间轴';
        break;
      case FilterType.thread:
        title = '对话';
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        actions: <Widget>[
          IconButton(icon:Icon(Icons.add),onPressed: _add,)
        ],
      ),
      body: EasyRefreshListView(
        requestUrl: AccountsApi.filterUrl,
        buildRow: _buildRow,
        enableRefresh: false,
        triggerRefreshEvent: [EventBusKey.filterEdited],
      ),
    );
  }

  _buildRow(int idx, List dynamic) {
    var data = dynamic[idx];
    var context = data['context'];
    if (context.contains(widget.type.toString().split('.')[1])) {
      return InkWell(
        onTap: () => _editRow(id: data['id'],phrase: data['phrase'],phraseContext: context,wholeWord: data['whole_word']),
        child: ListRow(
          child: Container(
              padding: EdgeInsets.all(8),
              child: Text(
                data['phrase'],
                style: TextStyle(fontSize: 16),
              )),
        ),
      );
    } else {
      return Container();
    }
  }

  _editRow({String id,String phrase,List phraseContext,bool wholeWord}) {
    showDialog(context: context,builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(8),
        title: Text('编辑过滤器'),
        content: CommonFilterEdit(id: id,phrase: phrase,context: phraseContext,wholeWord: wholeWord,),
      );
    });
  }

  _add() {
    List phraseContext = [widget.type.toString().split('.')[1]];
    showDialog(context: context,builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(8),
        title: Text('添加新的过滤器'),
        content: CommonFilterEdit(context: phraseContext,newFilter: true,),
      );
    });
  }
}