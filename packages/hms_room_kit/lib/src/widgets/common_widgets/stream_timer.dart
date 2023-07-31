import 'package:flutter/material.dart';
import 'package:hms_room_kit/src/common/app_color.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_subtitle_text.dart';

class HMSStreamTimer extends StatefulWidget {
  final DateTime startedAt;

  const HMSStreamTimer({super.key, required this.startedAt});
  @override
  State<HMSStreamTimer> createState() => _HMSStreamTimerState();
}

class _HMSStreamTimerState extends State<HMSStreamTimer> {
  format(Duration d) {
    String time = d.toString().split('.').first.padLeft(8, "0");
    if (time.substring(0, 2) == "00") {
      time = time.substring(3, time.length);
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return HMSSubtitleText(
            text: format(DateTime.now().difference(widget.startedAt)),
            textColor: themeSubHeadingColor);
      },
    );
  }
}