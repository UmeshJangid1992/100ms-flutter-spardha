// Package imports
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/change_role_options.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/change_simulcast_layer_option.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/local_peer_tile_dialog.dart';
import 'package:hmssdk_flutter_example/common/util/app_color.dart';
import 'package:hmssdk_flutter_example/common/util/utility_components.dart';
import 'package:provider/provider.dart';

// Project imports
import 'package:hmssdk_flutter_example/common/ui/organisms/brb_tag.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/degrade_tile.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/hand_raise.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/audio_mute_status.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/network_icon_widget.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/peer_name.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/tile_border.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/rtc_stats_view.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/video_view.dart';
import 'package:hmssdk_flutter_example/data_store/meeting_store.dart';
import 'package:hmssdk_flutter_example/model/peer_track_node.dart';
import 'package:hmssdk_flutter_example/common/ui/organisms/remote_peer_tile_dialog.dart';

class VideoTile extends StatefulWidget {
  final double itemHeight;
  final double itemWidth;
  final ScaleType scaleType;
  final bool islongPressEnabled;
  final bool isOneToOne;
  VideoTile(
      {Key? key,
      this.itemHeight = 200.0,
      this.itemWidth = 200.0,
      this.scaleType = ScaleType.SCALE_ASPECT_FILL,
      this.islongPressEnabled = true,
      this.isOneToOne = false})
      : super(key: key);

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  String name = "";
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    MeetingStore _meetingStore = context.read<MeetingStore>();

    bool mutePermission =
        _meetingStore.localPeer?.role.permissions.mute ?? false;
    bool unMutePermission =
        _meetingStore.localPeer?.role.permissions.unMute ?? false;
    bool removePeerPermission =
        _meetingStore.localPeer?.role.permissions.removeOthers ?? false;
    bool changeRolePermission =
        _meetingStore.localPeer?.role.permissions.changeRole ?? false;
    bool isSimulcastEnabled =
        (_meetingStore.localPeer?.role.publishSettings?.simulcast?.video !=
            null);

    return Semantics(
      label: "fl_${context.read<PeerTrackNode>().peer.name}_video_tile",
      child: context.read<PeerTrackNode>().uid.contains("mainVideo")
          ? InkWell(
              onLongPress: () {
                if (!widget.islongPressEnabled) {
                  return;
                }
                var peerTrackNode = context.read<PeerTrackNode>();
                HMSPeer peerNode = peerTrackNode.peer;
                if (!mutePermission ||
                    !unMutePermission ||
                    !removePeerPermission ||
                    !changeRolePermission) return;
                if (peerTrackNode.peer.peerId !=
                    _meetingStore.localPeer!.peerId)
                  showDialog(
                      context: context,
                      builder: (_) => RemotePeerTileDialog(
                            isAudioMuted:
                                peerTrackNode.audioTrack?.isMute ?? true,
                            isVideoMuted: peerTrackNode.track == null
                                ? true
                                : peerTrackNode.track!.isMute,
                            peerName: peerNode.name,
                            changeVideoTrack: (mute, isVideoTrack) {
                              Navigator.pop(context);
                              _meetingStore.changeTrackState(
                                  peerTrackNode.track!, mute);
                            },
                            changeAudioTrack: (mute, isAudioTrack) {
                              Navigator.pop(context);
                              _meetingStore.changeTrackState(
                                  peerTrackNode.audioTrack!, mute);
                            },
                            removePeer: () async {
                              Navigator.pop(context);
                              var peer = await _meetingStore.getPeer(
                                  peerId: peerNode.peerId);
                              _meetingStore.removePeerFromRoom(peer!);
                            },
                            changeRole: () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (_) => ChangeRoleOptionDialog(
                                        peerName: peerNode.name,
                                        roles: _meetingStore.roles,
                                        peer: peerNode,
                                        changeRole: (role, forceChange) {
                                          _meetingStore.changeRoleOfPeer(
                                              peer: peerNode,
                                              roleName: role,
                                              forceChange: forceChange);
                                        },
                                      ));
                            },
                            changeLayer: () async {
                              Navigator.pop(context);
                              HMSRemoteVideoTrack track =
                                  peerTrackNode.track as HMSRemoteVideoTrack;
                              List<HMSSimulcastLayerDefinition>
                                  layerDefinitions =
                                  await track.getLayerDefinition();
                              HMSSimulcastLayer selectedLayer =
                                  await track.getLayer();
                              if (layerDefinitions.isNotEmpty)
                                showDialog(
                                    context: context,
                                    builder: (_) =>
                                        ChangeSimulcastLayerOptionDialog(
                                            layerDefinitions:
                                                layerDefinitions,
                                            selectedLayer: selectedLayer,
                                            track: track));
                            },
                            mute: mutePermission,
                            unMute: unMutePermission,
                            removeOthers: removePeerPermission,
                            roles: changeRolePermission,
                            simulcast: isSimulcastEnabled &&
                                (!(peerTrackNode.track as HMSRemoteVideoTrack)
                                    .isMute),
                            pinTile: peerTrackNode.pinTile,
                            changePinTileStatus: () {
                              _meetingStore
                                  .changePinTileStatus(peerTrackNode);
                              Navigator.pop(context);
                            },
                          ));
                else
                  showDialog(
                      context: context,
                      builder: (_) => LocalPeerTileDialog(
                          isAudioMode: false,
                          toggleCamera: () {
                            if (_meetingStore.isVideoOn)
                              _meetingStore.switchCamera();
                          },
                          peerName: peerNode.name,
                          changeRole: () {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (_) => ChangeRoleOptionDialog(
                                      peerName: peerNode.name,
                                      roles: _meetingStore.roles,
                                      peer: peerNode,
                                      changeRole: (role, forceChange) {
                                        _meetingStore.changeRoleOfPeer(
                                            peer: peerNode,
                                            roleName: role,
                                            forceChange: forceChange);
                                      },
                                    ));
                          },
                          roles: changeRolePermission,
                          changeName: () async {
                            String name =
                                await UtilityComponents.showInputDialog(
                                    context: context,
                                    placeholder: "Enter Name");
                            if (name.isNotEmpty) {
                              _meetingStore.changeName(name: name);
                            }
                          }));
              },
              child: Container(
                key: key,
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.all(2),
                height: widget.itemHeight + 110,
                width: widget.itemWidth - 5.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: themeBottomSheetColor,
                ),
                child: Semantics(
                  label:
                      "fl_${context.read<PeerTrackNode>().peer.name}_video_on",
                  child: Stack(
                    children: [
                      VideoView(
                        uid: context.read<PeerTrackNode>().uid,
                        scaleType: widget.scaleType,
                        itemHeight: widget.itemHeight,
                        itemWidth: widget.itemWidth,
                      ),

                      Semantics(
                        label:
                            "fl_${context.read<PeerTrackNode>().peer.name}_degraded_tile",
                        child: DegradeTile(
                          itemHeight: widget.itemHeight,
                          itemWidth: widget.itemWidth,
                        ),
                      ),
                      if (!widget.isOneToOne)
                        Positioned(
                          //Bottom left
                          bottom: 5,
                          left: 5,
                          child: Container(
                            decoration: BoxDecoration(
                                color: themeTileNameColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 4, top: 4, bottom: 4),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    NetworkIconWidget(),
                                    PeerName(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      HandRaise(), //top left
                      BRBTag(), //bottom right
                      AudioMuteStatus(), //top right
                      if (!widget.isOneToOne)
                        Semantics(
                          label: "fl_stats_on_tile",
                          child: RTCStatsView(
                              isLocal:
                                  context.read<PeerTrackNode>().peer.isLocal),
                        ),
                      TileBorder(
                          itemHeight: widget.itemHeight,
                          itemWidth: widget.itemWidth,
                          name: context.read<PeerTrackNode>().peer.name,
                          uid: context.read<PeerTrackNode>().uid)
                    ],
                  ),
                ),
              ),
            )
          : Semantics(
              label:
                  "fl_${context.read<PeerTrackNode>().peer.name}_screen_share_tile",
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                key: key,
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.all(2),
                height: widget.itemHeight + 110,
                width: widget.itemWidth - 5.0,
                child: Stack(
                  children: [
                    VideoView(
                      uid: context.read<PeerTrackNode>().uid,
                      scaleType: widget.scaleType,
                    ),
                    Positioned(
                      //Bottom left
                      bottom: 5,
                      left: 5,
                      child: Container(
                        key: Key(
                            "fl_${context.read<PeerTrackNode>().peer.name}_name"),
                        decoration: BoxDecoration(
                            color: themeTileNameColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 4, top: 4, bottom: 4),
                            child: PeerName(),
                          ),
                        ),
                      ),
                    ),
                    RTCStatsView(isLocal: false),
                    Align(
                      alignment: Alignment.topRight,
                      child: widget.islongPressEnabled
                          ? UtilityComponents.rotateScreen(context)
                          : SizedBox(),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
