
import 'package:fastodon/pages/home/new_article.dart';
import 'package:flutter/material.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/models/article_item.dart';
import 'package:like_button/like_button.dart';

class StatusItemAction extends StatefulWidget {
  StatusItemAction({
    Key key,
    this.item,
  }) : super(key: key);
  final StatusItemData item;

  @override
  _StatusItemActionState createState() => _StatusItemActionState();
}

class _StatusItemActionState extends State<StatusItemAction> {

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onPressFavoutite(bool isLiked) async {
    requestFavorite(isLiked);

    return !isLiked;
  }

  requestFavorite(bool isLiked) async{
    var url = !isLiked ? Api.FavouritesArticle(widget.item.id) : Api.UnFavouritesArticle(widget.item.id);
    try {
      StatusItemData data = StatusItemData.fromJson(await Request.post(url: url));
      widget.item.favourited = data.favourited;
    } catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var buttonColor = Theme.of(context).buttonColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        InkWell(
          onTap: () {
            AppNavigate.push(context, NewArticle(replyTo: widget.item));
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.reply, color: buttonColor),
              SizedBox(width: 3),
              Text(
                '${widget.item.favouritesCount}',
                style:
                    TextStyle(color: buttonColor, fontSize: 12),
              ),
            ],
          ),
        ),
        Spacer(),
        Row(children: [
          LikeButton(
            likeBuilder: (bool isLiked) {
              return isLiked ? Icon(Icons.repeat_one,color: Colors.blue[800],): Icon(Icons.repeat,color: buttonColor,);
            },
            isLiked: widget.item.reblogged,
            bubblesColor: BubblesColor(dotPrimaryColor: Colors.blue[700],dotSecondaryColor: Colors.blue[300]),
            circleColor: CircleColor(start: Colors.blue[300],end: Colors.blue[700]),
          ),
          Text('${widget.item.reblogsCount}',
              style:
                  TextStyle(color: buttonColor, fontSize: 12))
        ]),
        Spacer(),
        LikeButton(
          likeBuilder: (bool isLiked) {
            return isLiked ? Icon(Icons.star,color: Colors.yellow[800],): Icon(Icons.star_border,color: buttonColor,);
          },
          isLiked: widget.item.favourited,
          onTap: _onPressFavoutite,
        ),
        Spacer(flex: 1,),
        LikeButton(
          likeBuilder: (bool isLiked) {
            return isLiked ? Icon(Icons.bookmark,color:Colors.green[800]): Icon(Icons.bookmark_border,color: buttonColor,);
          },
          isLiked: true,
          bubblesColor: BubblesColor(dotPrimaryColor: Colors.green[700],dotSecondaryColor: Colors.green[300]),
          circleColor: CircleColor(start: Colors.green[300],end: Colors.green[700]),
        ),
        Spacer(),
        PopupMenuButton(
          offset: Offset(0,35),
          icon: Icon(Icons.more_horiz,color: buttonColor,),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            new PopupMenuItem<String>(
                value: 'value01', child: new Text('复制链接')),
            new PopupMenuItem<String>(
                value: 'value02', child: new Text('复制嘟文')),
            new PopupMenuItem<String>(
                value: 'value03', child: new Text('隐藏')),
            new PopupMenuItem<String>(
                value: 'value04', child: new Text('屏蔽'))
          ],
        )
      ],
    );
  }
}
