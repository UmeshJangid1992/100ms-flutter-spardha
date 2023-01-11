import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hand_raise_example/meeting/peer_track_node.dart';
import 'package:hand_raise_example/utilities.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    implements HMSUpdateListener, HMSActionResultListener {
  List<PeerTrackNode> nodes = [];
  late HMSSDK _hmssdk;
  bool isAudioOn = true, isVideoOn = true, isHandRaised = false;

  @override
  void initState() {
    super.initState();
    _hmssdk = HMSSDK();
    _hmssdk.build();
    _hmssdk.addUpdateListener(listener: this);
    _hmssdk.join(config: Utilities.getHMSConfig());
  }

  @override
  void onHMSError({required HMSException error}) {}

  @override
  void onJoin({required HMSRoom room}) {}

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (peer.isLocal) {
      if (trackUpdate == HMSTrackUpdate.trackMuted) {
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          isAudioOn = false;
        } else {
          isVideoOn = false;
        }
      } else if (trackUpdate == HMSTrackUpdate.trackUnMuted) {
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          isAudioOn = true;
        } else {
          isVideoOn = true;
        }
      }
      updateUI();
    }
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      int index =
          nodes.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
      if (index != -1) {
        nodes[index].track = track as HMSVideoTrack;
      } else {
        if (track.source == "SCREEN") {
          nodes.add(PeerTrackNode(
              peer: peer,
              uid: "${peer.peerId}${track.trackId}",
              track: track as HMSVideoTrack));
        } else {
          if (peer.isLocal) {
            nodes.insert(
                0,
                PeerTrackNode(
                    peer: peer,
                    uid: "${peer.peerId}mainVideo",
                    track: track as HMSVideoTrack));
          } else {
            nodes.add(PeerTrackNode(
                peer: peer,
                uid: "${peer.peerId}mainVideo",
                track: track as HMSVideoTrack));
          }
        }
      }
      updateUI();
    }
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        int index =
            nodes.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
        if (index == -1) {
          if (peer.isLocal) {
            nodes.insert(
                0, PeerTrackNode(peer: peer, uid: "${peer.peerId}mainVideo"));
          } else {
            nodes
                .add(PeerTrackNode(peer: peer, uid: "${peer.peerId}mainVideo"));
          }
        }
        updateUI();
        break;
      case HMSPeerUpdate.peerLeft:
        int index =
            nodes.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
        if (index != -1) {
          nodes.removeAt(index);
        }
        updateUI();
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        if (peer.isLocal) {
          isHandRaised =
              peer.metadata?.contains("\"isHandRaised\":true") ?? false;          
        }
        int index =
            nodes.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
        if (index != -1) {
          nodes[index].peer = peer;
          updateUI();
        }
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        break;
    }
  }

  void leaveMeeting() {
    _hmssdk.removeUpdateListener(listener: this);
    _hmssdk.leave(hmsActionResultListener: this);
    Navigator.pop(context);
  }

  void updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  void handRaise() {
      _hmssdk.changeMetadata(
      metadata: "{\"isHandRaised\":${!isHandRaised}}",
      hmsActionResultListener: this);
  }

  @override
  Widget build(BuildContext context) {
    final heightofEachTile = MediaQuery.of(context).size.height / 2;
    final widthofEachTile = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        leaveMeeting();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(),
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,),
                  delegate: SliverChildBuilderDelegate(
                      ((context, index) => Stack(children: [
                            (nodes[index].track == null ||
                                    nodes[index].track!.isMute)
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(20, 23, 28, 1),
                                    ),
                                    child: Center(
                                      child: CircleAvatar(
                                          backgroundColor: Colors.purple,
                                          radius: 36,
                                          child: Text(
                                            nodes[index].peer.name[0],
                                            style: const TextStyle(
                                                fontSize: 36,
                                                color: Colors.white),
                                          )),
                                    ),
                                  )
                                : HMSVideoView(
                                    key: Key(nodes[index].uid),
                                    track: nodes[index].track!,
                                    scaleType: ScaleType.SCALE_ASPECT_FILL,
                                  ),
                            (nodes[index]
                                        .peer
                                        .metadata
                                        ?.contains("\"isHandRaised\":true") ??
                                    false)
                                ? const Positioned(
                                    bottom: 90,
                                    right: 10,
                                    child: Icon(
                                      Icons.back_hand_rounded,
                                      color: Colors.amber,
                                    ))
                                : Container()
                          ])),
                      childCount: nodes.length),
                )
              ],
            ),
            (nodes.isNotEmpty && nodes[0].peer.isLocal)
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 60,
                        width: widthofEachTile - 20,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(29, 34, 41, 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                _hmssdk.switchAudio(isOn: isAudioOn);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(60),
                                        blurRadius: 3.0,
                                        spreadRadius: 5.0,
                                      ),
                                    ]),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                      isAudioOn ? Icons.mic : Icons.mic_off,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                _hmssdk.switchVideo(isOn: isVideoOn);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(60),
                                        blurRadius: 3.0,
                                        spreadRadius: 5.0,
                                      ),
                                    ]),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                      isVideoOn
                                          ? Icons.videocam
                                          : Icons.videocam_off_rounded,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                leaveMeeting();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(60),
                                        blurRadius: 3.0,
                                        spreadRadius: 5.0,
                                      ),
                                    ]),
                                child: const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child:
                                      Icon(Icons.call_end, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
            // (nodes.isNotEmpty && nodes[0].peer.isLocal)
            //     ? Positioned(
            //         top: 30,
            //         right: 10,
            //         child: GestureDetector(
            //           onTap: () {
            //             handRaise();
            //           },
            //           child: CircleAvatar(
            //             radius: 25,
            //             backgroundColor: Colors.transparent.withOpacity(0.2),
            //             child: Icon(
            //               Icons.back_hand_rounded,
            //               color: isHandRaised ? Colors.amber : Colors.white,
            //             ),
            //           ),
            //         ),
            //       )
            //     : Container()
          ],
        ),
      ),
    );
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onException(
      {HMSActionResultListenerMethod methodType =
          HMSActionResultListenerMethod.unknown,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.changeMetadata:
        log("Error occured ${hmsException.message}");
        break;
      case HMSActionResultListenerMethod.leave:
        log("Error occured ${hmsException.message}");
        break;
    }
  }

  @override
  void onSuccess(
      {HMSActionResultListenerMethod methodType =
          HMSActionResultListenerMethod.unknown,
      Map<String, dynamic>? arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.changeMetadata:
        log("Hand Raise successful");
        break;
      case HMSActionResultListenerMethod.leave:
        _hmssdk.destroy();
        log("Leave room successful");
        break;
    }
  }
}