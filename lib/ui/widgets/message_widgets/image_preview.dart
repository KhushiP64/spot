import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spot/core/media.dart';
import 'package:spot/core/responsive_fonts.dart';
import 'package:spot/providers/chat_provider.dart';
import 'package:toastification/toastification.dart';
import '../../../core/utils.dart';
import '../../../providers/data_list_provider.dart';
import '../../../providers/group_provider.dart';
import '../chat_list_widgets/forward_list_bottom_sheet.dart';

class ImagePreview extends StatefulWidget {
  final String imgUrl;
  final String imgName;
  final Map<String, dynamic> messageItem;
  final bool isVideo;
  const ImagePreview(
      {super.key,
      required this.imgUrl,
      required this.imgName,
      required this.messageItem,
      this.isVideo = false});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final TextEditingController searchValue = TextEditingController();
  final TextEditingController vGroupName = TextEditingController();
  final TextEditingController tDescription = TextEditingController();
  TextEditingController searchAddUser = TextEditingController();
  Map<String, dynamic> currentUserData = {};

  bool isGroupNameNotValid = true;
  bool isSubmit = false;
  bool _isLoading = false;
  File? chooseProfile;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
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
      final dataListProvider =
          Provider.of<DataListProvider>(context, listen: false);
      await dataListProvider.getForwardUsers();
      if (!mounted) return;

      ForwardBottomSheet.show(
        context: context,
        currentUser: currentUser,
        searchUsers: searchController,
        controller: _scrollController,
        closeForwardListModal: closeForwardListModal,
        onSearchChanged: onChangedSearchForwardUsers,
        isGroupMsgs: false,
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
    final success = await CommonFunctions.downloadFileWithPermission(
        widget.imgUrl, widget.imgName, context);
    if (success) {
      toastification.show(
        context: context,
        title: const Text('Image downloaded successfully'),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
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
                  spreadRadius: 0),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: handleOnClickReplyMsg,
            icon: Icon(
              FeatherIcons.cornerUpLeft,
              color: Colors.black,
              size: 16.w,
            ),
            label: Text(
              "Reply",
              style: AppFontStyles.dmSansRegular.copyWith(
                color: Colors.black,
                fontSize: 14.sp,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              side: BorderSide.none,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: 6.w, right: 12.w, top: 12.h, bottom: 20.h),
                color: AppColorTheme.lightPrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onPressBack,
                          child: SvgPicture.asset(
                            AppMedia.leftArrow,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.60,
                          ),
                          child: Text(
                            widget.imgName,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyles.dmSansRegular.copyWith(
                                fontSize: 16.sp,
                                color: AppColorTheme.inputTitle),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: handleDownloadImage,
                          child: SvgPicture.asset(AppMedia.download),
                        ),
                        SizedBox(width: 16.w),
                        GestureDetector(
                          onTap: handleOnClickForwardMsg,
                          child: SvgPicture.asset(AppMedia.forward),
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
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.network(
                        widget.imgUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColorTheme.primaryHover));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white, size: 50),
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
