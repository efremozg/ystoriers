import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/ui/add_post/image_item_widget.dart';
import 'package:y_storiers/ui/camera/add_story.dart';

class GetStoryPage extends StatefulWidget {
  const GetStoryPage({Key? key, required this.closePicker}) : super(key: key);

  final Function() closePicker;

  @override
  State<GetStoryPage> createState() => _GetStoryPageState();
}

class _GetStoryPageState extends State<GetStoryPage> {
  final _loadStreamController = StreamController<bool>();

  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  final int _sizePerPage = 50;

  final _scrollController = ScrollController();

  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  int _totalEntitiesCount = 0;
  int _imageIndex = 0;

  int _page = 0;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  Future<void> _requestAssets() async {
    _loadStreamController.sink.add(true);
    // Request permissions.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only procceed with authorized or limited.
    if (ps != PermissionState.authorized && ps != PermissionState.limited) {
      _loadStreamController.sink.add(false);
      // showToast('Permission is not granted.');
      return;
    }
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: _filterOptionGroup,
    );

    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      _loadStreamController.sink.add(false);
      // showToast('No paths found.');
      return;
    }
    setState(() {
      _path = paths.first;
    });
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities = entities;
      _loadStreamController.sink.add(false);
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _loadStreamController.sink.add(false);
    });
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _loadStreamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data!) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (_path == null) {
            return const Center(child: Text('Request paths first.'));
          }
          if (_entities?.isNotEmpty != true) {
            return const Center(child: Text('No assets found on this device.'));
          }
          return GridView.custom(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1,
              mainAxisExtent: 200,
              crossAxisSpacing: 2,
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == _entities!.length - 8 &&
                    !_isLoadingMore &&
                    _hasMoreToLoad) {
                  _loadMoreAsset();
                }
                final AssetEntity entity = _entities![index];
                return ScaleButton(
                  duration: const Duration(milliseconds: 150),
                  bound: 0.04,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: ImageItemWidget(
                          key: ValueKey<int>(index),
                          entity: entity,
                          onTap: () async {
                            var file = await _entities![index].file;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddStoryPage(
                                  photo: XFile(file!.path),
                                  pictureType: PictureType.back,
                                  mediaType:
                                      _entities![index].type == AssetType.image
                                          ? MediaType.image
                                          : MediaType.video,
                                ),
                              ),
                            );
                          },
                          option: const ThumbnailOption(
                              size: ThumbnailSize.square(400)),
                        ),
                      ),
                      if (_entities?[index].type == AssetType.video)
                        _lengthOfImages()
                    ],
                  ),
                );
              },
              childCount: _entities!.length,
              findChildIndexCallback: (Key key) {
                // Re-use elements.
                if (key is ValueKey<int>) {
                  return key.value;
                }
                return null;
              },
            ),
          );
        });
  }

  Widget _lengthOfImages() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        alignment: Alignment.center,
        width: 40,
        height: 25,
        child: Container(
          margin: const EdgeInsets.only(top: 5),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _requestAssets();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Stack(
          children: [
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 2),
                child: SizedBox(
                  height: 20,
                  child: Center(
                    child: Text(
                      'Добавить историю',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  widget.closePicker();
                },
                child: const SizedBox(
                  height: 25,
                  child: Icon(
                    Icons.close,
                    size: 25,
                  ),
                ),
              ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }
}
