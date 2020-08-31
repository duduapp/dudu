import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/pages/setting/filter/common_filter_edit.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/common/list_row.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider<ResultListProvider>(
        create: (context) => ResultListProvider(
            requestUrl: AccountsApi.filterUrl,
            buildRow: _buildRow,
            enableRefresh: false,enableLoad: false),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: CustomAppBar(
              title: Text(title),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _add(context),
                )
              ],
            ),
            body: ProviderEasyRefreshListView(useAnimatedList: false,),
          );
        });
  }

  _buildRow(int idx, List dynamic, ResultListProvider provider) {
    var data = dynamic[idx];
    var context = data['context'];
    if (context.contains(widget.type.toString().split('.')[1])) {
      return InkWell(
        onTap: () => _editRow(
            id: data['id'],
            phrase: data['phrase'],
            phraseContext: context,
            wholeWord: data['whole_word'],
            provider: provider),
        child: ListRow(
          child: Container(
              padding: EdgeInsets.all(8),
              child: Text(
                data['phrase'],
                style: TextStyle(fontSize: 14),
              )),
        ),
      );
    } else {
      return Container();
    }
  }

  _editRow(
      {String id,
      String phrase,
      List phraseContext,
      bool wholeWord,
      ResultListProvider provider}) {
    DialogUtils.showRoundedDialog(context: context,content: CommonFilterEdit(
      id: id,
      phrase: phrase,
      context: phraseContext,
      wholeWord: wholeWord,
      provider: provider,
    ));

  }

  _add(BuildContext context) {
    ResultListProvider provider = Provider.of<ResultListProvider>(context,listen: false);
    List phraseContext = [widget.type.toString().split('.')[1]];

    DialogUtils.showRoundedDialog(context: context,content: CommonFilterEdit(
      context: phraseContext,
      newFilter: true,
      provider: provider,
    ));
  }
}
