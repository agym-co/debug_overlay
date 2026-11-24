import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../debug_helper.dart';

class MediaQueryDebugHelper extends StatelessWidget {
  const MediaQueryDebugHelper({super.key, this.selectable = false});

  /// Whether the rows can be selected, for example to copy a value.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return DiagnosticsBasedDebugHelper(
      title: const Text('MediaQuery'),
      // ignore: discarded_futures, https://github.com/dart-lang/linter/issues/3429
      diagnosticsStream: _getDiagnostics(context).asStream(),
      selectable: selectable,
    );
  }

  Future<List<DiagnosticsNode>> _getDiagnostics(BuildContext context) async {
    // A SafeArea, ListView or Scaffold above zeroes insets in the nearest
    // MediaQuery, so they come from the view.
    final view = MediaQueryData.fromView(View.of(context));
    var data = MediaQuery.maybeOf(context);
    if (data == null) {
      data = view;
      if (!kReleaseMode) {
        data = data.copyWith(platformBrightness: debugBrightnessOverride);
      }
    }

    return [
      StringProperty('Size', _formatSize(data.size), quoted: false),
      DoubleProperty(
        'Device Pixel Ratio',
        data.devicePixelRatio,
        defaultValue: 1,
      ),
      DoubleProperty(
        'Text Scale Factor',
        // ignore: deprecated_member_use
        data.textScaleFactor,
        defaultValue: 1,
      ),
      EnumProperty('Platform Brightness', data.platformBrightness),
      _insetsProperty('Padding', view.padding),
      _insetsProperty('View Insets', view.viewInsets),
      _insetsProperty('System Gesture Insets', view.systemGestureInsets),
      _insetsProperty('View Padding', view.viewPadding),
      FlagProperty(
        'Always use 24 Hour Format',
        value: data.alwaysUse24HourFormat,
        ifTrue: 'Always use 24 Hour Format',
      ),
      FlagProperty(
        'Accessible Navigation',
        value: data.accessibleNavigation,
        ifTrue: 'Use accessible navigation',
      ),
      FlagProperty(
        'Invert Colors',
        value: data.invertColors,
        ifTrue: 'The device inverts colors',
      ),
      FlagProperty(
        'High Contrast',
        value: data.highContrast,
        ifTrue: 'Should use high contrast',
      ),
      FlagProperty(
        'Disable Animations',
        value: data.disableAnimations,
        ifTrue: 'Disable animations',
      ),
      FlagProperty(
        'Bold Text',
        value: data.boldText,
        ifTrue: 'Use bold text',
      ),
      EnumProperty(
        'Navigation Mode',
        data.navigationMode,
        defaultValue: NavigationMode.traditional,
      ),
    ];
  }
}

/// Formats [size] like [Size.toString], which release builds strip.
String _formatSize(Size size) =>
    'Size(${size.width.toStringAsFixed(1)}, ${size.height.toStringAsFixed(1)})';

/// Formats [insets] like [EdgeInsets.toString], which release builds strip.
///
/// Zero insets count as the default value, so the default level hides them.
StringProperty _insetsProperty(String name, EdgeInsets insets) {
  String format(EdgeInsets it) =>
      'EdgeInsets(${it.left.toStringAsFixed(1)}, ${it.top.toStringAsFixed(1)}, '
      '${it.right.toStringAsFixed(1)}, ${it.bottom.toStringAsFixed(1)})';
  return StringProperty(
    name,
    format(insets),
    quoted: false,
    defaultValue: format(EdgeInsets.zero),
  );
}
