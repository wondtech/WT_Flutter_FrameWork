// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
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
/// ([WtController], [WtModel], [WtView]), global [WtConfig], and the
/// [WtSession]/[WtSecurity]/[WtHelper] utilities.
library wt;

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
