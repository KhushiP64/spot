import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spot/core/themes.dart';
import 'package:spot/ui/widgets/common_widgets/commonWidgets.dart';

class AudioMessageBubble extends StatefulWidget {
  final String url;
  final bool isSender;
  final String audioName;
  const AudioMessageBubble(
      {super.key,
      required this.url,
      required this.isSender,
      required this.audioName});

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late AudioPlayer player;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    // 3. Use 'mounted' check before every setState
    _stateSubscription = player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state == PlayerState.playing);
      }
    });

    _durationSubscription = player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() => duration = newDuration);
      }
    });

    _positionSubscription = player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() => position = newPosition);
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  // ************************ handle on play and pause music *****************************
  void handleOnPlayMusic() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.play(UrlSource(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonWidgets.chatBubbleUI(
        isSender: widget.isSender,
        width:
            MediaQuery.of(context).size.width * CommonWidgets.chatBubbleWidth,
        childWidget: Row(
          children: [
            Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: AppColorTheme.primaryHover,
                ),
                child: InkWell(
                    onTap: handleOnPlayMusic,
                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20.w, color: AppColorTheme.white))),

            Expanded(
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      // This removes the extra padding around the slider
                      trackHeight: 2.0,
                      overlayShape: SliderComponentShape
                          .noOverlay, // Removes the large hover circle
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      padding: EdgeInsets.only(
                          bottom: 8.h,
                          left: 12.w,
                          right: 12.w), // Removes internal padding
                    ),
                    child: Slider(
                      activeColor: AppColorTheme.primaryHover,
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        await player.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(widget.audioName,
                              softWrap: true,
                              style: AppFontStyles.dmSansRegular.copyWith(
                                  fontSize: 12.sp,
                                  color: AppColorTheme.black87)),
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                        Text(
                            "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: AppFontStyles.dmSansRegular.copyWith(
                                fontSize: 11.sp, color: AppColorTheme.black50)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // InkWell(
            //   onTap: (){},
            //   child: Padding(padding: EdgeInsets.only(left: 6.w),
            //     child: SvgPicture.asset(AppMedia.download, width: 20.w, height: 20.h,),
            //   ),
            // ),
          ],
        ));
  }
}
