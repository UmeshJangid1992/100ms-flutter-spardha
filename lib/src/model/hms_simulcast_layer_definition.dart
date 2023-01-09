import 'package:hmssdk_flutter/hmssdk_flutter.dart';

///100ms HMSSimulcastLayerDefinition
///
///[HMSSimulcastLayerDefinition] contains hmsSimulcastLayer and hmsResolution.
class HMSSimulcastLayerDefinition {
  HMSSimulcastLayer hmsSimulcastLayer;
  HMSResolution hmsResolution;
  HMSSimulcastLayerDefinition(
      {required this.hmsSimulcastLayer, required this.hmsResolution});

  factory HMSSimulcastLayerDefinition.fromMap(Map map) {
    return HMSSimulcastLayerDefinition(
        hmsSimulcastLayer: HMSSimulcastLayerValue.getHMSSimulcastLayerFromName(
            map["hms_simulcast_layer"]),
        hmsResolution: HMSResolution.fromMap(map["hms_resolution"]));
  }
}
