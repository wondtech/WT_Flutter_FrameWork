// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

/// Shared enums for the WT animation layer.
///
/// Kept dependency-free (no `WtConfig`, no widgets) so both [WtConfig] and the
/// animation widgets can import it without creating an import cycle.
library;

/// Direction an entrance animation slides *from*.
///
/// e.g. [WtDir.bottom] makes the child rise up into place.
enum WtDir {
  /// Enters from above, moving down.
  top,

  /// Enters from below, moving up (the common "rise in").
  bottom,

  /// Enters from the left, moving right.
  left,

  /// Enters from the right, moving left.
  right,
}

/// Page transition used by [WtRouter] when pushing a route.
///
/// [platform] keeps Flutter's default per-platform [MaterialPageRoute] look and
/// is the framework default, so upgrading changes no existing navigation. The
/// rest are pure-Flutter transitions built with a `PageRouteBuilder`.
enum WtTransition {
  /// Default [MaterialPageRoute] (platform-native). No behaviour change.
  platform,

  /// No animation — the new page appears instantly.
  none,

  /// Cross-fade between pages.
  fade,

  /// New page slides in from the right (LTR back-navigation feel).
  slideRight,

  /// New page slides in from the left.
  slideLeft,

  /// New page slides up from the bottom (modal feel).
  slideUp,

  /// New page scales up from slightly smaller.
  scale,

  /// New page fades in while scaling up (a soft "zoom in").
  fadeScale,
}
