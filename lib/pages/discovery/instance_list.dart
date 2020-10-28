

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/constant/db_key.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/public.dart';
import 'package:dudu/widget/common/custom_app_bar.dart';
import 'package:dudu/widget/discovery/instance_summary.dart';
import 'package:flutter/material.dart';

class InstanceList extends StatefulWidget {
  @override
  _InstanceListState createState() => _InstanceListState();
}

class _InstanceListState extends State<InstanceList> {
  
  List<String> instances = [];
  Map<String,dynamic> instancesInfo = {};

  @override
  void initState() {
    getInstances();
    super.initState();
  }

  getInstances() async{

    await getInstancesFromServer();

    getInstancesFromDb();

    getInstanceDetail();
  }

  getInstancesFromServer() async{
    String res = await Request.get(url:AppConfig.instancesUrl,withToken: false,enableCache: true);
    if (res != null) {
      List<String> ins = res.split('\n');
      ins.forEach((element) => element.trim());
      ins.removeWhere((element) => element.isEmpty);
      instances.addAll(ins);
    }
  }

  getInstanceDetail() async{
    for (var url in instances) {
      Request.get(url:'https://'+url+'/api/v1/instance',withToken: false,enableCache: true).then((res){
        instancesInfo[url] = res;
        setState(() {

        });
      });

    }

  }

  getInstancesFromDb() {

  }


   Widget rowBuilder(BuildContext context,int idx) {
    var url = instances[idx];
    InstanceItem info;
    if (instancesInfo.containsKey(url)) {
      var infoStr = instancesInfo[url];
      if (infoStr != null)
        info = InstanceItem.fromJson(infoStr);
    }
    return info == null ? Container() : InstanceSummary(info);
   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('发现'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(itemBuilder: rowBuilder,itemCount: instances.length,),
    );
  }
}
