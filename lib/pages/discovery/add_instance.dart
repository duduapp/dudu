import 'package:dudu/l10n/l10n.dart';
import 'dart:async';

import 'package:dudu/api/instance_api.dart';
import 'package:dudu/models/instance/instance_manager.dart';
import 'package:dudu/models/instance/server_instance.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/loading_view.dart';
import 'package:dudu/widget/common/normal_flat_button.dart';
import 'package:dudu/widget/discovery/instance_summary.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class AddInstance extends StatefulWidget {
  final String url;

  AddInstance([this.url]);

  @override
  _AddInstanceState createState() => _AddInstanceState();
}

class _AddInstanceState extends State<AddInstance> {
  TextEditingController _controller;
  Timer _debounce;
  Map<String, InstanceItem> requests = {};
  bool loading = false;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.url);
    _controller.addListener(() {
      setState(() {});
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        getUrlInfo();
      });
    });
    if (widget.url != null) {
      getUrlInfo();
    }
    super.initState();
  }

  void getUrlInfo() async {
    setState(() {
      loading = true;
    });
    var input = _controller.text;
    if (requests.containsKey(input)) {
      setState(() {
        loading = false;
      });
      return;
    }

    var url = input;

    if (InstanceManager.instanceExist(url)) {
      setState(() {
        loading = false;
      });
      return;
    }

    if (!input.startsWith('https://')) {
      url = 'https://' + input;
    }

    if (isURL(url)) {
      debugPrint('get instance info:' + url);
      var res = await Request.get(url: InstanceApi.getUrl(url));
      if (res != null) {
        var info = InstanceItem.fromJson(res);
        if (info.uri != null) {
          requests[input] = info;
        }
      } else {
        requests[input] = null;
      }
      setState(() {});
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20,15,20,10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //        Text(S.of(context).increase_instance,style: TextStyle(fontSize: 16),),
            if (InstanceManager.instanceExist(_controller.text))
              Text(
                S.of(context).instance_already_exists,
                style: TextStyle(color: Colors.red),
              ),
            if (loading)
              Center(
                  child: SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                width: 50,
                height: 50,
              )),
            if (requests.containsKey(_controller.text) &&
                requests[_controller.text] == null)
              Text(
                S.of(context).unable_to_connect_to_server,
                style: TextStyle(color: Colors.red),
              ),
            if (requests.containsKey(_controller.text) &&
                requests[_controller.text] != null)
              InstanceSummary(
                ServerInstance(
                    detail: requests[_controller.text],
                    fromStale: false,
                    fromServer: true),
                showAction: false,
              ),
            TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: S.of(context).instance_url,
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).buttonColor)))),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Text(
                S.of(context).please_enter_the_url,
                style: TextStyle(color: Theme.of(context).accentColor,fontSize: 13),
              ),
            ),
            Row(
              children: [
                Spacer(),
                NormalFlatButton(
                  text: S.of(context).cancel,
                  onPressed: () => AppNavigate.pop(),
                ),
                NormalFlatButton(
                  text: S.of(context).determine,
                  onPressed: requests.containsKey(_controller.text) &&
                          requests[_controller.text] != null
                      ? () {
                          InstanceManager.addInstance(
                              requests[_controller.text]);
                          AppNavigate.pop(param: requests[_controller.text]);
                        }
                      : null,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
