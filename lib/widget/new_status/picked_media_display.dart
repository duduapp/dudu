import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dudu/constant/icon_font.dart';
import 'package:dudu/models/json_serializable/media_attachment.dart';
import 'package:dudu/models/status/picked_media.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PickedMediaDisplay extends StatelessWidget {
  final List<PickedMedia> medias;

  PickedMediaDisplay(this.medias,
      {this.updateParentState, this.onAddMediaClicked});

  final Function updateParentState;
  final Function onAddMediaClicked;

  openMediaDescriptionDialog(BuildContext context, PickedMedia media) {
    var imageTitle = media.description;
    TextEditingController controller = TextEditingController(text: imageTitle);
    var color = Theme.of(context).toggleableActiveColor;
    showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData(primaryColor: color),
            child: AlertDialog(
              content: Container(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '为视觉障碍人士添加文字说明',
                  ),
                  maxLength: 450,
                  maxLines: null,
                ),
                width: ScreenUtil.width(context),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    '取消',
                    style: TextStyle(color: color),
                  ),
                  onPressed: () => AppNavigate.pop(),
                ),
                FlatButton(
                  child: Text(
                    '确定',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    media.description = controller.text;
                    AppNavigate.pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Widget buildImage(BuildContext context) {
    return Container(
      //width: Screen.width(context) - 60,
      padding: EdgeInsets.only(left: 15, right: 10, top: 10),
      alignment: Alignment.bottomLeft,
      width: 250,
      height: 260,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, idx) {
          if (medias.length < idx + 1) {
            return InkWell(
              onTap: onAddMediaClicked,
              child: Container(
                width: 110,
                height: 110,
                color: Theme.of(context).backgroundColor,
                child: Center(
                  child: Icon(
                    IconFont.follow,
                    size: 40,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            );
          }

          PickedMedia media = medias[idx];
          if (media.remote != null) {
            return Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: media.remote.previewUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, str, progress) {
                    return Container(
                      color:Theme.of(context).backgroundColor,
                      child: Center(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.5)),
                            strokeWidth: 30,
                            value: progress.progress,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                _cornerDeleteIcon(media)
              ],
            );
          }
          return _localNavigateWrapper(
              context,
              FutureBuilder<File>(
                future: media.localThumbFile(), // a Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.hasData)
                    return Stack(
                      children: [
                        Image.file(
                          snapshot.data,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                        _cornerDeleteIcon(media)
                      ],
                    );
                  else
                    return Container();
                },
              ),
              idx: idx);
        },
        itemCount: medias.length < 4 ? medias.length + 1 : medias.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 5, crossAxisSpacing: 5, crossAxisCount: 2),
      ),
    );
  }

  Widget _localNavigateWrapper(BuildContext context, Widget child,
      {int idx = 0}) {
    List<AssetEntity> pickedMedias = [];
    for (PickedMedia media in medias) {
      if (media.local != null) {
        pickedMedias.add(media.local);
      }
    }
    return InkWell(
      onTap: () async {
        await AppNavigate.push(CustomAssetPickerViewer(
            currentIndex: idx,
            assets: pickedMedias,
            actionIcons: [Icon(IconFont.delete), Icon(IconFont.edit)],
            originList: medias,
            previewThumbSize: const [1200,1200],
            onEditClicked: (dynamic media) {
              if (media is PickedMedia) {
                openMediaDescriptionDialog(context, media);
              }
            },
            //        selectedAssets: choosedMedias,
            selectorProvider: AssetPickerProvider(
                maxAssets: 1, routeDuration: Duration(milliseconds: 200)),
            themeData: AssetPicker.themeData(Colors.blue)));
        if (updateParentState != null) {
          updateParentState();
        }
      },
      child: child,
    );
  }

  Widget _cornerDeleteIcon(PickedMedia media) {
    return Positioned(
      top: 0,
      right: 0,
      child: InkWell(
        onTap: () {
          medias.remove(media);
          if (updateParentState != null) {
            updateParentState();
          }
        },
        child: Opacity(
          opacity: 0.7,
          child: Container(
            padding: EdgeInsets.all(7),
            color: Colors.grey,
            child: Icon(
              IconFont.clear,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildVideo(BuildContext context) {
    PickedMedia media = medias[0];
    if (media.local != null) {
      return _localNavigateWrapper(
          context,
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: FutureBuilder<Uint8List>(
              future: media.local.thumbData, // a Future<String> or null
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                if (snapshot.hasData)
                  return Stack(
                    children: [
                      Image.memory(
                        snapshot.data,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      _cornerDeleteIcon(media),
                      Positioned.fill(
                        child: Center(
                            child: Icon(
                          Icons.play_circle_filled,
                          size: 55,
                          color: Colors.white,
                        )),
                      )
                    ],
                  );
                else
                  return Container();
              },
            ),
          ));
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: media.remote.previewUrl,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, str, progress) {
                return Container(
                  color: Theme.of(context).backgroundColor,
                  child: Center(
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.5)),
                        strokeWidth: 30,
                        value: progress.progress,
                      ),
                    ),
                  ),
                );
              },
            ),
            _cornerDeleteIcon(media),
            Positioned.fill(
              child: Center(
                  child: Icon(
                Icons.play_circle_filled,
                size: 55,
                color: Colors.white,
              )),
            )
          ],
        ),
      );
    }
    return Container();
  }

  Widget buildAudio(BuildContext context) {
    PickedMedia media = medias[0];
    if (media.local != null) {
      return _localNavigateWrapper(
          context,
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              height: 80,
              width: 80,
              color: Theme.of(context).backgroundColor,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      IconFont.audio,
                      size: 40,
                    ),
                  ),
                  _cornerDeleteIcon(media),
                ],
              ),
            ),
          ));
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Container(
          height: 80,
          width: 80,
          color: Theme.of(context).backgroundColor,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  IconFont.audio,
                  size: 40,
                ),
              ),
              _cornerDeleteIcon(media),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (medias.length > 0) {
      if (medias.length > 1) {
        return buildImage(context);
      }
      if (medias.length == 1) {
        PickedMedia media = medias[0];
        var type = media?.local?.type;
        var remoteType = media?.remote?.type;

        if (type != null) {
          switch (type) {
            case AssetType.image:
              return buildImage(context);
              break;
            case AssetType.video:
              return buildVideo(context);
              break;
            case AssetType.audio:
              return buildAudio(context);
              break;
          }
        } else {
          MediaAttachment remote = media.remote;
          switch (remote.type) {
            case "video":
              return buildVideo(context);
            case "image":
              return buildImage(context);
            case "audio":
              return buildAudio(context);
            case "gifv":
              return buildImage(context);
          }
        }
      }
    }
    return Container();
  }
}
