///Package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

///Project imports
import 'package:hms_room_kit/hms_room_kit.dart';
import 'package:hms_room_kit/src/meeting/meeting_store.dart';
import 'package:hms_room_kit/src/model/poll_store.dart';
import 'package:hms_room_kit/src/widgets/poll_widgets/poll_quiz_selection_widget.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_cross_button.dart';
import 'package:hms_room_kit/src/widgets/poll_widgets/poll_creation_widgets/poll_form.dart';
import 'package:hms_room_kit/src/widgets/poll_widgets/poll_creation_widgets/poll_question_card.dart';

///[PollAndQuizBottomSheet] renders the poll and quiz creation UI
class PollAndQuizBottomSheet extends StatelessWidget {
  const PollAndQuizBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.87,
      child: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HMSTitleText(
                      text: "Polls and Quizzes",
                      fontSize: 20,
                      textColor: HMSThemeColors.onSurfaceHighEmphasis,
                    ),
                    const HMSCrossButton(),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 16),
                  child: Divider(
                    color: HMSThemeColors.borderDefault,
                    height: 5,
                  ),
                ),

                ///Poll and Quiz selection buttons
                if (context
                        .read<MeetingStore>()
                        .localPeer
                        ?.role
                        .permissions
                        .pollWrite ??
                    false)
                  const PollQuizSelectionWidget(),

                if (context
                        .read<MeetingStore>()
                        .localPeer
                        ?.role
                        .permissions
                        .pollWrite ??
                    false)
                  const SizedBox(
                    height: 24,
                  ),

                ///Poll or Quiz Section
                if (context
                        .read<MeetingStore>()
                        .localPeer
                        ?.role
                        .permissions
                        .pollWrite ??
                    false)
                  const PollForm(),

                ///This section shows all the previous polls
                ///which are either started or stopped
                if (context
                        .read<MeetingStore>()
                        .localPeer
                        ?.role
                        .permissions
                        .pollRead ??
                    false)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: HMSTitleText(
                      text: "Previous Polls and Quizzes",
                      textColor: HMSThemeColors.onSurfaceHighEmphasis,
                      fontSize: 20,
                      letterSpacing: 0.15,
                    ),
                  ),

                if (context
                        .read<MeetingStore>()
                        .localPeer
                        ?.role
                        .permissions
                        .pollRead ??
                    false)
                  Selector<MeetingStore, Tuple2<int, List<HMSPollStore>>>(
                    selector: (_, meetingStore) => Tuple2(
                        meetingStore.pollQuestions.length,
                        meetingStore.pollQuestions),
                    builder: (_, data, __) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.item1,
                        itemBuilder: (BuildContext context, int index) {
                          return ChangeNotifierProvider.value(
                              value: data.item2[index],
                              child: const PollQuestionCard());
                        },
                      );
                    },
                  ),
                const SizedBox(
                  height: 8,
                )
              ],
            ),
          )),
    );
  }
}