import 'package:dudu/api/status_api.dart';
import 'package:dudu/l10n/l10n.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/i18n_util.dart';
import 'package:dudu/utils/view/list_view_util.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/listview/provider_easyrefresh_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteBy extends StatelessWidget {
  final StatusItemData data;
  final String hostUrl;


  FavoriteBy(this.data,this.hostUrl);

  @override
  Widget build(BuildContext context) {
    String  zan_or_shoucang =
    context.select<SettingsProvider, String>((m) => m.get('zan_or_shoucang'));

    bool isZh = I18nUtil.isZh(context);

    var zan_text = isZh ? (zan_or_shoucang == '0' ? '赞' : S.of(context).favorites) : S.of(context).favorites;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(zan_text),
      ),
      body: ChangeNotifierProvider<ResultListProvider>(
        create: (context) => ResultListProvider(
            requestUrl: StatusApi.favouritedByUrl(data:data, hostUrl:hostUrl),
            buildRow: ListViewUtil.accountRowFunction(),
            headerLinkPagination: true
        ),
        child: ProviderEasyRefreshListView(),
      ),
    );
  }
}
