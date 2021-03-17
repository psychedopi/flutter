// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:meta/meta.dart';

import 'base/config.dart';
import 'base/context.dart';
import 'base/platform.dart';
import 'version.dart';

/// The current [FeatureFlags] implementation.
///
/// If not injected, a default implementation is provided.
FeatureFlags get featureFlags => context.get<FeatureFlags>();

/// The interface used to determine if a particular [Feature] is enabled.
///
/// The rest of the tools code should use this class instead of looking up
/// features directly. To facilitate rolls to google3 and other clients, all
/// flags should be provided with a default implementation here. Clients that
/// use this class should extent instead of implement, so that new flags are
/// picked up automatically.
abstract class FeatureFlags {
  /// const constructor so that subclasses can be const.
  const FeatureFlags();

  /// Whether flutter desktop for linux is enabled.
  bool get isLinuxEnabled => false;

  /// Whether flutter desktop for macOS is enabled.
  bool get isMacOSEnabled => false;

  /// Whether flutter web is enabled.
  bool get isWebEnabled => false;

  /// Whether flutter desktop for Windows is enabled.
  bool get isWindowsEnabled => false;

  /// Whether android is enabled.
  bool get isAndroidEnabled => true;

  /// Whether iOS is enabled.
  bool get isIOSEnabled => true;

  /// Whether fuchsia is enabled.
  bool get isFuchsiaEnabled => true;

  /// Whether fast single widget reloads are enabled.
  bool get isSingleWidgetReloadEnabled => false;

  /// Whether the CFE experimental invalidation strategy is enabled.
  bool get isExperimentalInvalidationStrategyEnabled => true;

  /// Whether the windows UWP embedding is enabled.
  bool get isWindowsUwpEnabled => false;

  /// Whether a particular feature is enabled for the current channel.
  ///
  /// Prefer using one of the specific getters above instead of this API.
  bool isEnabled(Feature feature) => false;
}

class FlutterFeatureFlags implements FeatureFlags {
  FlutterFeatureFlags({
    @required FlutterVersion flutterVersion,
    @required Config config,
    @required Platform platform,
  }) : _flutterVersion = flutterVersion,
       _config = config,
       _platform = platform;

  final FlutterVersion _flutterVersion;
  final Config _config;
  final Platform _platform;

  @override
  bool get isLinuxEnabled => isEnabled(flutterLinuxDesktopFeature);

  @override
  bool get isMacOSEnabled => isEnabled(flutterMacOSDesktopFeature);

  @override
  bool get isWebEnabled => isEnabled(flutterWebFeature);

  @override
  bool get isWindowsEnabled => isEnabled(flutterWindowsDesktopFeature);

  @override
  bool get isAndroidEnabled => isEnabled(flutterAndroidFeature);

  @override
  bool get isIOSEnabled => isEnabled(flutterIOSFeature);

  @override
  bool get isFuchsiaEnabled => isEnabled(flutterFuchsiaFeature);

  @override
  bool get isSingleWidgetReloadEnabled => isEnabled(singleWidgetReload);

  @override
  bool get isExperimentalInvalidationStrategyEnabled => isEnabled(experimentalInvalidationStrategy);

  @override
  bool get isWindowsUwpEnabled => isEnabled(windowsUwpEmbedding);

  @override
  bool isEnabled(Feature feature) {
    final String currentChannel = _flutterVersion.channel;
    final FeatureChannelSetting featureSetting = feature.getSettingForChannel(currentChannel);
    if (!featureSetting.available) {
      return false;
    }
    bool isEnabled = featureSetting.enabledByDefault;
    if (feature.configSetting != null) {
      final bool configOverride = _config.getValue(feature.configSetting) as bool;
      if (configOverride != null) {
        isEnabled = configOverride;
      }
    }
    if (feature.environmentOverride != null) {
      if (_platform.environment[feature.environmentOverride]?.toLowerCase() == 'true') {
        isEnabled = true;
      }
    }
    return isEnabled;
  }
}

/// All current Flutter feature flags.
const List<Feature> allFeatures = <Feature>[
  flutterWebFeature,
  flutterLinuxDesktopFeature,
  flutterMacOSDesktopFeature,
  flutterWindowsDesktopFeature,
  windowsUwpEmbedding,
  singleWidgetReload,
  flutterAndroidFeature,
  flutterIOSFeature,
  flutterFuchsiaFeature,
  experimentalInvalidationStrategy,
];

/// The [Feature] for flutter web.
const Feature flutterWebFeature = Feature(
  name: 'Flutter for web',
  configSetting: 'enable-web',
  environmentOverride: 'FLUTTER_WEB',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: flutterNext,
  ),
  beta: FeatureChannelSetting(
    available: true,
    enabledByDefault: flutterNext,
  ),
  stable: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: flutterNext,
  ),
);

/// The [Feature] for macOS desktop.
const Feature flutterMacOSDesktopFeature = Feature(
  name: 'beta-quality support for desktop on macOS',
  configSetting: 'enable-macos-desktop',
  environmentOverride: 'FLUTTER_MACOS',
  extraHelpText: flutterNext ?
      'Newer beta versions are available on the beta channel.' : null,
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  beta: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: false,
  ),
  stable: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: false,
  ),
);

/// The [Feature] for Linux desktop.
const Feature flutterLinuxDesktopFeature = Feature(
  name: 'beta-quality support for desktop on Linux',
  configSetting: 'enable-linux-desktop',
  environmentOverride: 'FLUTTER_LINUX',
  extraHelpText: flutterNext ?
      'Newer beta versions are available on the beta channel.' : null,
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  beta: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: false,
  ),
  stable: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: false,
  ),
);

/// The [Feature] for Windows desktop.
const Feature flutterWindowsDesktopFeature = Feature(
  name: 'beta-quality support for desktop on Windows',
  configSetting: 'enable-windows-desktop',
  environmentOverride: 'FLUTTER_WINDOWS',
  extraHelpText: flutterNext ?
      'Newer beta versions are available on the beta channel.' : null,
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  beta: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: false,
  ),
  stable: FeatureChannelSetting(
    available: flutterNext,
    enabledByDefault: false,
  ),
);

/// The [Feature] for Android devices.
const Feature flutterAndroidFeature = Feature(
  name: 'Flutter for Android',
  configSetting: 'enable-android',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  beta: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  stable: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
);


/// The [Feature] for iOS devices.
const Feature flutterIOSFeature = Feature(
  name: 'Flutter for iOS',
  configSetting: 'enable-ios',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  beta: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  stable: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
);

/// The [Feature] for Fuchsia support.
const Feature flutterFuchsiaFeature = Feature(
  name: 'Flutter for Fuchsia',
  configSetting: 'enable-fuchsia',
  environmentOverride: 'FLUTTER_FUCHSIA',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
);

/// The fast hot reload feature for https://github.com/flutter/flutter/issues/61407.
const Feature singleWidgetReload = Feature(
  name: 'Hot reload optimization for changes to class body of a single widget',
  configSetting: 'single-widget-reload-optimization',
  environmentOverride: 'FLUTTER_SINGLE_WIDGET_RELOAD',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  beta: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
  stable: FeatureChannelSetting(
    available: false,
    enabledByDefault: false,
  ),
);

/// The CFE experimental invalidation strategy.
const Feature experimentalInvalidationStrategy = Feature(
  name: 'Hot reload optimization that reduces incremental artifact size',
  configSetting: 'experimental-invalidation-strategy',
  environmentOverride: 'FLUTTER_CFE_EXPERIMENTAL_INVALIDATION',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  dev: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  beta: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
  stable: FeatureChannelSetting(
    available: true,
    enabledByDefault: true,
  ),
);

/// The feature for enabling the Windows UWP embeding.
const Feature windowsUwpEmbedding = Feature(
  name: 'Flutter for Windows UWP',
  configSetting: 'enable-windows-uwp-desktop',
  master: FeatureChannelSetting(
    available: true,
    enabledByDefault: false,
  ),
);

/// A [Feature] is a process for conditionally enabling tool features.
///
/// All settings are optional, and if not provided will generally default to
/// a "safe" value, such as being off.
///
/// The top level feature settings can be provided to apply to all channels.
/// Otherwise, more specific settings take precedence over higher level
/// settings.
class Feature {
  /// Creates a [Feature].
  const Feature({
    @required this.name,
    this.environmentOverride,
    this.configSetting,
    this.extraHelpText,
    this.master = const FeatureChannelSetting(),
    this.dev = const FeatureChannelSetting(),
    this.beta = const FeatureChannelSetting(),
    this.stable = const FeatureChannelSetting(),
  });

  /// The user visible name for this feature.
  final String name;

  /// The settings for the master branch and other unknown channels.
  final FeatureChannelSetting master;

  /// The settings for the dev branch.
  final FeatureChannelSetting dev;

  /// The settings for the beta branch.
  final FeatureChannelSetting beta;

  /// The settings for the stable branch.
  final FeatureChannelSetting stable;

  /// The name of an environment variable that can override the setting.
  ///
  /// The environment variable needs to be set to the value 'true'. This is
  /// only intended for usage by CI and not as an advertised method to enable
  /// a feature.
  ///
  /// If not provided, defaults to `null` meaning there is no override.
  final String environmentOverride;

  /// The name of a setting that can be used to enable this feature.
  ///
  /// If not provided, defaults to `null` meaning there is no config setting.
  final String configSetting;

  /// Additional text to add to the end of the help message.
  ///
  /// If not provided, defaults to `null` meaning there is no additional text.
  final String extraHelpText;

  /// A help message for the `flutter config` command, or null if unsupported.
  String generateHelpMessage() {
    if (configSetting == null) {
      return null;
    }
    final StringBuffer buffer = StringBuffer('Enable or disable $name. '
        'This setting will take effect on ');
    final List<String> channels = <String>[
      if (master.available) 'master',
      if (dev.available) 'dev',
      if (beta.available) 'beta',
      if (stable.available) 'stable',
    ];
    if (channels.length == 1) {
      buffer.write('the ${channels.single} channel.');
    } else if (channels.length == 2) {
      buffer.write('the ${channels.join(' and ')} channels.');
    } else {
      final String prefix = (channels.toList()
        ..removeLast()).join(', ');
      buffer.write('the $prefix, and ${channels.last} channels.');
    }
    if (extraHelpText != null) {
      buffer.write(' $extraHelpText');
    }
    return buffer.toString();
  }

  /// Retrieve the correct setting for the provided `channel`.
  FeatureChannelSetting getSettingForChannel(String channel) {
    switch (channel) {
      case 'stable':
        return stable;
      case 'beta':
        return beta;
      case 'dev':
        return dev;
      case 'master':
      default:
        return master;
    }
  }
}

/// A description of the conditions to enable a feature for a particular channel.
class FeatureChannelSetting {
  const FeatureChannelSetting({
    this.available = false,
    this.enabledByDefault = false,
  });

  /// Whether the feature is available on this channel.
  ///
  /// If not provided, defaults to `false`. This implies that the feature
  /// cannot be enabled even by the settings below.
  final bool available;

  /// Whether the feature is enabled by default.
  ///
  /// If not provided, defaults to `false`.
  final bool enabledByDefault;
}

const bool flutterNext = true;
