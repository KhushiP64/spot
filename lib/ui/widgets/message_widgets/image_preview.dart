import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:spot/ui/widgets/common_widgets/common_modal.dart';
import 'package:toastification/toastification.dart';
import 'package:video_player/video_player.dart';
import '../../../core/utils.dart';
import '../../../providers/data_list_provider.dart';
import '../../../providers/group_provider.dart';
import '../chat_list_widgets/forward_list_bottom_sheet.dart';

class ImagePreview extends StatefulWidget {
  final String imgUrl;
  final String imgName;
  final Map<String, dynamic> messageItem;
  final bool isVideo;
  const ImagePreview({
    super.key,
    required this.imgUrl,
    required this.imgName,
    required this.messageItem,
    this.isVideo = false
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final TextEditingController searchValue = TextEditingController();
  final TextEditingController vGroupName = TextEditingController();
  final TextEditingController tDescription = TextEditingController();
  TextEditingController searchAddUser = TextEditingController();
  Map<String, dynamic> currentUserData = {};
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  bool isGroupNameNotValid = true;
  bool isSubmit = false;
  bool _isLoading = false;
  File? chooseProfile;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.imgUrl))
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController!.play();
        });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;

      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
    }
  }

  void onPressBack() {
    Navigator.of(context).pop();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setSelectedImage({});
  }

  void handleOnClickReplyMsg() {
    final fromUserId = widget.messageItem['iFromUserId'];
    final fullName = widget.messageItem['vFullName'];

    Navigator.of(context).pop({
      'replyFileThumb': widget.imgUrl,
      'replyFileName': widget.imgName,
      'replyText': '',
      'isImage': true,
      'iFromUserId': fromUserId,
      'vFullName': fullName,
    });
  }

  void handleOnClickForwardMsg() async {
    try {
      final currentUser = await CommonFunctions.getLoginUser();
      final dataListProvider = Provider.of<DataListProvider>(context, listen: false);
      await dataListProvider.getForwardUsers();
      if (!mounted) return;

      CommonModal.show(
        context: context,
        child: ForwardBottomSheet(
          context: context,
          currentUser: currentUser,
          searchUsers: searchController,
          controller: _scrollController,
          closeForwardListModal: closeForwardListModal,
          onSearchChanged: onChangedSearchForwardUsers,
          isGroupMsgs: false,
        )
      );
    } catch (error) {
      // print("Error while getting forward user list: $error");
    }
  }

  void closeForwardListModal() {
    final provider = context.read<GroupProvider>();
    final dataListProvider = context.read<DataListProvider>();
    closeCreateGroupModal();
    vGroupName.text = '';
    tDescription.text = '';
    provider.clearProfile();
    provider.clearGroupMembers();

    setState(() {
      _currentPage = 1;
      searchController.clear();
    });
  }

  void onChangedSearchForwardUsers(String value) {
    final dataListProvider = context.read<DataListProvider>();
    final searchText = value.trim().toLowerCase();

    if (searchText.isEmpty) {
      dataListProvider.resetForwardUserFilter();
    } else {
      final originalList = dataListProvider.allForwardUsers;
      final filteredData = originalList.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        return name.contains(searchText);
      }).toList();

      dataListProvider.setForwardUsersList(filteredData);
    }
  }

  void closeCreateGroupModal() async {
    Navigator.of(context).pop();
    setState(() {
      isSubmit = true;
      isGroupNameNotValid = false;
    });
  }

  void closeListChatGroupModal() {
    final provider = context.read<GroupProvider>();
    final dataListProvider = context.read<DataListProvider>();
    closeCreateGroupModal();
    vGroupName.text = '';
    tDescription.text = '';
    provider.clearProfile();
    provider.clearGroupMembers();

    setState(() {
      _currentPage = 1;
      searchAddUser.clear();
    });
  }

  void handleDownloadImage() async {
    final success = await CommonFunctions.downloadFileWithPermission(widget.imgUrl, widget.imgName, context);
    final bool isGif = widget.imgUrl.toLowerCase().endsWith('.gif');

    if (success) {
      toastification.show(
        context: context,
        title: widget.isVideo ? Text('Video downloaded successfully') : isGif ? Text('Gif downloaded successfully') : Text('Image downloaded successfully'),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    } else {
      toastification.show(
        context: context,
        title: const Text('Image download failed.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topCenter,
      );
    }
  }

  Widget _buildCustomProgressBar() {
    return ValueListenableBuilder(
      valueListenable: _videoController!,
      builder: (context, VideoPlayerValue value, child) {
        // Calculate current position and total duration in milliseconds
        final int duration = value.duration.inMilliseconds;
        final int position = value.position.inMilliseconds;

        return Container(
          color: AppColorTheme.black.withOpacity(0.2),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(value.position),
                style: AppFontStyles.dmSansBold.copyWith(color: AppColorTheme.white, fontSize: 12.sp),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    // This creates the "Round" handle you want
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0.w),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0.w),
                    trackHeight: 2.0.h,
                    activeTrackColor: AppColorTheme.primaryHover,
                    inactiveTrackColor: AppColorTheme.white.withOpacity(0.9),
                    thumbColor: AppColorTheme.primaryHover,
                  ),
                  child: Slider(
                    value: position.toDouble().clamp(0.0, duration.toDouble()),
                    min: 0.0,
                    max: duration.toDouble(),
                    onChanged: (double newValue) {
                      // Seek to the new position when the user drags the round thumb
                      _videoController!.seekTo(Duration(milliseconds: newValue.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(value.duration),
                style: AppFontStyles.dmSansBold.copyWith(color: AppColorTheme.white, fontSize: 12.sp),
              ),
            ],
          ),
        );
      },
    );
  }

// Helper to format 00:00 time
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {

    final bool isGif = widget.imgUrl.toLowerCase().endsWith('.gif');

    return WillPopScope(
      onWillPop: () async {
        final chatProvider = context.read<ChatProvider>();
        chatProvider.setSelectedImage({});
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColorTheme.lightPrimary,
        appBar: null,
        floatingActionButton: Container(
          padding: EdgeInsets.only(right: 6.w, bottom: 6.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(6.r)),
            boxShadow: [
              BoxShadow(
                color: AppColorTheme.secondary.withOpacity(0.2),
                offset: Offset(0, 1),
                blurRadius: 6,
                spreadRadius: 0
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: handleOnClickReplyMsg,
            icon: Icon(FeatherIcons.cornerUpLeft, color: Colors.black, size: 16.w),
            label: Text("Reply", style: AppFontStyles.dmSansRegular.copyWith(color: Colors.black, fontSize: 14.sp)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
              side: BorderSide.none,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 6.w, right: 12.w, top: 12.h, bottom: 20.h),
                color: AppColorTheme.lightPrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: AppColorTheme.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(6.r)),
                            onTap: onPressBack,
                            child: SvgPicture.asset(AppMedia.leftArrow),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                          ),
                          child: Text(
                            widget.imgName,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyles.dmSansRegular.copyWith(fontSize: 16.sp, color: AppColorTheme.inputTitle),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Material(
                          color: AppColorTheme.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(6.r)),
                            onTap: handleDownloadImage,
                            child: SvgPicture.asset(AppMedia.download),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Material(
                          color: AppColorTheme.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(6.r)),
                            onTap: handleOnClickForwardMsg,
                            child: SvgPicture.asset(AppMedia.forward),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onDoubleTapDown: (details) => _doubleTapDetails = details,
                    onDoubleTap: _handleDoubleTap,
                    child: widget.isVideo
                      ? _isVideoInitialized
                        ? Center(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                /// Video player
                                VideoPlayer(_videoController!),

                                /// Video play / pause button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _videoController!.value.isPlaying
                                        ? _videoController!.pause()
                                        : _videoController!.play();
                                    });
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Center(
                                      child: AnimatedOpacity(
                                        // Only show the button when paused
                                        opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                                        duration: Duration(milliseconds: 200),
                                        child: Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: AppColorTheme.black.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// bottom seeking line
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: _buildCustomProgressBar(),
                                  // Container(
                                  //   height: 40.h,
                                  //   alignment: Alignment.bottomCenter,
                                  //   child: VideoProgressIndicator(
                                  //     _videoController!,
                                  //     allowScrubbing: true,
                                  //     padding: EdgeInsets.symmetric(vertical: 4.h),
                                  //     colors: VideoProgressColors(
                                  //       playedColor: AppColorTheme.primaryHover,
                                  //       bufferedColor: Colors.white24,
                                  //       backgroundColor: Colors.white12,
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Center(
                          child: CircularProgressIndicator(color: AppColorTheme.primaryHover),
                        )
                      : InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: isGif ? 1.0 : 0.5,
                          maxScale: isGif ? 1.0 : 4,
                          panEnabled: !isGif,
                          scaleEnabled: !isGif,
                          child: Image.network(
                            widget.imgUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: AppColorTheme.primaryHover)
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                            );
                          },
                        ),
                      ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

