import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/pages/user_profile/user_profile.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/view/status_action_util.dart';
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
      onTap: navigateToDetail ? () => AppNavigate.push(UserProfile(account,!StatusActionUtil.sameInstance(context))) : null,
      child: ClipRRect(
        child: CachedNetworkImage(
            placeholder: (context,string) {
              return Image(
                width: width,
                height: height,
                image: AssetImage(
                    'assets/images/missing.png'
                ),
              );
            },
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
