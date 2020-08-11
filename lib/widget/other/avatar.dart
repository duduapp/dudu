import 'package:cached_network_image/cached_network_image.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:fastodon/pages/user_profile/user_profile.dart';
import 'package:fastodon/public.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  Avatar({
    Key key,
    @required this.account,
    this.width = 50,
    this.height = 50,
    this.navigateToDetail = true
   }) : super(key: key);


  final double width;
  final double height;
  final OwnerAccount account;
  final bool navigateToDetail;

  @override
  Widget build(BuildContext context) {
    //ToDo replace replace holder with default avatar
    if (account == null) {
      return Container(
        width: width,
        height: height,
      );
    }
    return GestureDetector(
      onTap: navigateToDetail ? () => AppNavigate.push(UserProfile(accountId: account.id,)) : null,
      child: ClipRRect(
        child: CachedNetworkImage(
            imageUrl: account.avatar,
            width: width,
            height: height,
            fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
