///Dart imports
import 'dart:convert';

///Package imports
import 'package:hms_room_kit/hms_room_kit.dart';
import 'package:hms_room_kit/src/hmssdk_interactor.dart';
import 'package:hms_room_kit/src/service/app_secrets.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class Theme {
  final String? name;
  final bool? defaultTheme;
  final Map<String, String>? palette;

  Theme({
    this.name,
    this.defaultTheme,
    this.palette,
  });

  factory Theme.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Theme();
    }
    return Theme(
      name: json['name'],
      defaultTheme: json['default'],
      palette: Map<String, String>.from(json['palette']),
    );
  }
}

class ScreenElements {
  final String? title;
  final String? subTitle;

  ScreenElements({
    this.title,
    this.subTitle,
  });

  factory ScreenElements.fromJson(Map<String, dynamic>? json) {
    return ScreenElements(
      title: json?['title'],
      subTitle: json?['sub_title'],
    );
  }
}

class Preview {
  final ScreenElements? previewHeader;
  final JoinForm? joinForm;

  Preview({
    this.previewHeader,
    this.joinForm,
  });

  factory Preview.fromJson(Map<String, dynamic>? json) {
    return Preview(
      previewHeader: ScreenElements.fromJson(json?['preview_header']),
      joinForm: JoinForm.fromJson(json?['join_form']),
    );
  }
}

enum JoinButtonType { JOIN_BTN_TYPE_JOIN_ONLY, JOIN_BTN_TYPE_JOIN_AND_GO_LIVE }

extension JoinButtonTypeValues on JoinButtonType {
  static JoinButtonType getButtonTypeFromName(String joinType) {
    switch (joinType) {
      case 'JOIN_BTN_TYPE_JOIN_ONLY':
        return JoinButtonType.JOIN_BTN_TYPE_JOIN_ONLY;
      case 'JOIN_BTN_TYPE_JOIN_AND_GO_LIVE':
        return JoinButtonType.JOIN_BTN_TYPE_JOIN_AND_GO_LIVE;
      default:
        return JoinButtonType.JOIN_BTN_TYPE_JOIN_ONLY;
    }
  }
}

class JoinForm {
  final JoinButtonType? joinBtnType;
  final String? joinBtnLabel;
  final String? goLiveBtnLabel;

  JoinForm({this.joinBtnLabel, this.joinBtnType, this.goLiveBtnLabel});

  factory JoinForm.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return JoinForm();
    } else {
      return JoinForm(
          joinBtnType:
              JoinButtonTypeValues.getButtonTypeFromName(json['join_btn_type']),
          joinBtnLabel: json['join_btn_label'],
          goLiveBtnLabel: json['go_live_btn_label']);
    }
  }
}

class Screens {
  final Preview? preview;
  final Map<String, dynamic>? conferencing;
  final Map<String, dynamic>? leave;

  Screens({
    this.preview,
    this.conferencing,
    this.leave,
  });

  factory Screens.fromJson(Map<String, dynamic>? json) {
    return Screens(
      preview: Preview.fromJson(json?['preview']?['default']?['elements']),
      conferencing: json?['conferencing'],
      leave: json?['leave'],
    );
  }
}

class AppLogo {
  final String? url;

  AppLogo({this.url});

  factory AppLogo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppLogo();
    } else {
      return AppLogo(url: json['url']);
    }
  }
}

class AppTypoGraphy {
  final String? typography;

  AppTypoGraphy({this.typography});

  factory AppTypoGraphy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppTypoGraphy();
    } else {
      return AppTypoGraphy(typography: json['font_family']);
    }
  }
}

class LayoutData {
  final String? id;
  final String? roleId;
  final String? templateId;
  final String? appId;
  final List<Theme>? themes;
  final AppTypoGraphy? typography;
  final AppLogo? logo;
  final Screens? screens;

  LayoutData({
    this.id,
    this.roleId,
    this.templateId,
    this.appId,
    this.themes,
    this.typography,
    this.logo,
    this.screens,
  });

  factory LayoutData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LayoutData();
    }
    return LayoutData(
      id: json['id'],
      roleId: json['role_id'],
      templateId: json['template_id'],
      appId: json['app_id'],
      themes: List<Theme>.from(
        (json['themes'] ?? []).map((theme) => Theme.fromJson(theme)),
      ),
      typography: AppTypoGraphy.fromJson(json['typography']),
      logo: AppLogo.fromJson(json['logo']),
      screens: Screens.fromJson(json['screens']),
    );
  }
}

class HMSRoomLayout {
  static List<LayoutData>? data;
  static int? limit;
  static String? last;

  static Future<void> getRoomLayout(
      {required HMSSDKInteractor hmsSDKInteractor,
      required String authToken}) async {
    dynamic value = await hmsSDKInteractor.getRoomLayout(
        authToken: authToken, endPoint: getLayoutAPIEndpoint());
    if (value != null && value.runtimeType != HMSException) {
      _setLayout(layoutJson: jsonDecode(value));
      HMSThemeColors.applyLayoutColors(data?[0].themes?[0].palette);
    }
  }

  static void _setLayout({required Map<String, dynamic> layoutJson}) {
    data = List<LayoutData>.from((layoutJson['data'] ?? [])
        .map((appData) => LayoutData.fromJson(appData)));
    limit = layoutJson['limit'];
    last = layoutJson['last'];
  }
}