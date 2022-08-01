import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    Key? key,
    required this.entity,
    this.selected,
    this.index,
    required this.option,
    this.onTap,
  }) : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption option;
  final bool? selected;
  final int? index;
  final GestureTapCallback? onTap;

  Widget buildContent(BuildContext context) {
    if (entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(entity, option);
  }

  Widget _buildImageWidget(AssetEntity entity, ThumbnailOption option) {
    print(entity.videoDuration);
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AssetEntityImage(
            entity,
            isOriginal: false,
            thumbnailSize: option.size,
            thumbnailFormat: option.format,
            fit: BoxFit.cover,
          ),
        ),
        if (selected != null)
          if (selected!)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 20,
                width: 20,
                margin: const EdgeInsets.only(right: 5, top: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1,
                    color: Colors.white,
                  ),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        // if (entity.mimeType == 'video')
      ],
    );
    // Stack(
    //   children: [
    //     AssetEntityImage(
    //       entity,
    //       isOriginal: false,
    //       thumbnailFormat: option.format,
    //       fit: BoxFit.cover,
    //     ),
    //     if (entity.type == AssetType.video)
    //       Align(
    //         alignment: Alignment.topRight,
    //         child: Container(
    //           margin: const EdgeInsets.only(right: 5, top: 5),
    //           child: Text('${entity.videoDuration.inSeconds}'),
    //         ),
    //       )
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: buildContent(context),
    );
  }
}
