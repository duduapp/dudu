import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/filter_item.dart';
import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/view/list_view_util.dart';

class FilterUtil {
  static List<dynamic> filterData(List data, String context, {String mapKey}) {
    List res = List.from(data);
    for (var dataRow in data) {
      for (var filterRow in SettingsProvider().filters[context]) {
        var realDataRow = (mapKey != null && dataRow.containsKey(mapKey))
            ? dataRow[mapKey]
            : dataRow;
        if (realDataRow.containsKey('content') &&
            StringUtil.removeAllHtmlTags(realDataRow['content'])
                .contains(filterRow.phrase)) {
          if (filterRow.expiresAt == null ||
              DateTime.now().isBefore(filterRow.expiresAt)) {
            res.remove(dataRow);
            break;
          }
        }
      }
    }
    return res;
  }

  static applyFilters(List<FilterItem> filters) {
    var settingsFilters = SettingsProvider().filters;
    for (var context in ["home", "notifications", "public", "thread"]) {
      settingsFilters[context].clear();
    }
    for (var f in filters) {
      for (var context in f.context) {
        settingsFilters[context].add(f);
      }
    }
    for (ResultListProvider provider in ListViewUtil.getRootProviders()) {
      provider?.reConstructFilterList();
    }
    SettingsProvider().notificationProvider?.reConstructFilterList();
  }

  static getFiltersAndApply() async {
    var filters = await AccountsApi.getFilters();
    applyFilters(filters);
  }
}
