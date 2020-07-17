import 'package:fastodon/api/lists_api.dart';
import 'package:fastodon/api/search_api.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/widget/status/status_item_account.dart';
import 'package:flutter/material.dart';

class ListsEdit extends StatefulWidget {
  final String id;
  final String title;

  ListsEdit(this.id, this.title);

  @override
  _ListsEditState createState() => _ListsEditState();
}

class _ListsEditState extends State<ListsEdit> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool searchFocus = false;
  List<OwnerAccount> lists = [];
  List<OwnerAccount> members = [];// text为空时显示

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        searchFocus = focusNode.hasFocus;
      });
    });
    _requestListMember();
  }

  _requestListMember() async{
    members = await ListsApi.getMembers(widget.id);
    if (searchController.text.isEmpty) {
      setState(() {
        lists.addAll(members);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 12, 12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
               Icon(Icons.search),
              SizedBox(width: 5,),
              Expanded(
                  child: TextField(
                    onSubmitted: _search,
                onChanged: _onChanged,
                focusNode: focusNode,
                controller: searchController,
                decoration: InputDecoration(
                    hintText: '搜索已关注的用户',
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none),
              )),
              if (searchFocus)
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: (){_search(searchController.text);},
                )
            ],
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: lists.length,
                itemBuilder: _row),
          )
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int idx) {
    return StatusItemAccount(lists[idx],action: _actionView(lists[idx]),);
  }
  
  _actionView(OwnerAccount account) {
    if (members.contains(account)) {
      return IconButton(icon: Icon(Icons.clear),onPressed: () {_removeAccount(account);},);
    } else {
      return IconButton(icon: Icon(Icons.add),onPressed: () {_addAccount(account);},);
    }
  }

  _removeAccount(OwnerAccount account) async{
    await ListsApi.removeAccount(widget.id, account.id);
    setState(() {
      members.remove(account);
    });
  }

  _addAccount(OwnerAccount account) async{

    await ListsApi.addAccount(widget.id, account.id);

    setState(() {
      members.add(account);
    });
  }

  _search(String q) async{
    q = q.trim();
    if (q.isEmpty) {
      return;
    } else {
      List<OwnerAccount> accounts = [];
      var res = await SearchApi.searchAccounts(q,following: true);
      for (var r in res) {
        accounts.add(OwnerAccount.fromJson(r));
      }
      lists.clear();
      setState(() {
        lists.addAll(accounts);
      });
    }
  }

  _onChanged(String text)  {
    if (text.trim().isEmpty) {
        setState(() {
          lists.clear();
          lists.addAll(members);
        });
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
