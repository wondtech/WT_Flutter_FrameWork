// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************
//
// Usage:
//   import 'package:wt_framework/wt.dart';

/// WondTech Flutter MVC framework.
///
/// A single import (`package:wt_framework/wt.dart`) exposes the app shell
/// ([WtApp]), routing ([WtRouter]/[WtRoute]), the MVC building blocks
/// ([WtController], [WtModel], [WtView]), global [WtConfig], the
/// [WtSession]/[WtSecurity]/[WtHelper] utilities, and the v1.4 animation layer
/// ([WtFadeIn]/[WtSlideIn]/[WtScaleIn]/[WtStagger], the [WtAnimateX] extensions
/// and [WtTransition] page transitions).
library;

// Core
export 'libs/core/wt_app.dart';
export 'libs/core/wt_router.dart';

// Config
export 'libs/config/wt_config.dart';

// MVC
export 'libs/mvc/wt_controller.dart';
export 'libs/mvc/wt_model.dart';
export 'libs/mvc/wt_view.dart';

// Helpers
export 'libs/helpers/wt_security.dart';
export 'libs/helpers/wt_session.dart';
export 'libs/helpers/wt_helper.dart';
export 'libs/helpers/wt_validator.dart';

// Theme & i18n (v1.4)
export 'libs/theme/wt_theme.dart';
export 'libs/i18n/wt_i18n.dart';

// Animation (v1.4)
export 'libs/anim/wt_anim_types.dart';
export 'libs/anim/wt_animate.dart';
export 'libs/anim/wt_transitions.dart';
