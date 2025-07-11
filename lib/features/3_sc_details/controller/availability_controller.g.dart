// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availabilityControllerHash() =>
    r'bdbb03a14873eec51927f430e01d257561094bdc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AvailabilityController
    extends BuildlessAutoDisposeAsyncNotifier<ScheduleData> {
  late final AvailabilityParams arg;

  FutureOr<ScheduleData> build(AvailabilityParams arg);
}

/// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
/// Providernya akan bernama `availabilityControllerProvider`.
/// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
/// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
///
/// Copied from [AvailabilityController].
@ProviderFor(AvailabilityController)
const availabilityControllerProvider = AvailabilityControllerFamily();

/// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
/// Providernya akan bernama `availabilityControllerProvider`.
/// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
/// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
///
/// Copied from [AvailabilityController].
class AvailabilityControllerFamily extends Family<AsyncValue<ScheduleData>> {
  /// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
  /// Providernya akan bernama `availabilityControllerProvider`.
  /// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
  /// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
  ///
  /// Copied from [AvailabilityController].
  const AvailabilityControllerFamily();

  /// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
  /// Providernya akan bernama `availabilityControllerProvider`.
  /// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
  /// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
  ///
  /// Copied from [AvailabilityController].
  AvailabilityControllerProvider call(AvailabilityParams arg) {
    return AvailabilityControllerProvider(arg);
  }

  @override
  AvailabilityControllerProvider getProviderOverride(
    covariant AvailabilityControllerProvider provider,
  ) {
    return call(provider.arg);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'availabilityControllerProvider';
}

/// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
/// Providernya akan bernama `availabilityControllerProvider`.
/// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
/// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
///
/// Copied from [AvailabilityController].
class AvailabilityControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AvailabilityController,
          ScheduleData
        > {
  /// Anotasi `@riverpod` akan men-generate provider untuk kita secara otomatis.
  /// Providernya akan bernama `availabilityControllerProvider`.
  /// `keepAlive: true` bisa ditambahkan jika kita ingin state-nya tidak di-dispose
  /// saat tidak digunakan, tapi untuk jadwal lebih baik di-dispose.
  ///
  /// Copied from [AvailabilityController].
  AvailabilityControllerProvider(AvailabilityParams arg)
    : this._internal(
        () => AvailabilityController()..arg = arg,
        from: availabilityControllerProvider,
        name: r'availabilityControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$availabilityControllerHash,
        dependencies: AvailabilityControllerFamily._dependencies,
        allTransitiveDependencies:
            AvailabilityControllerFamily._allTransitiveDependencies,
        arg: arg,
      );

  AvailabilityControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.arg,
  }) : super.internal();

  final AvailabilityParams arg;

  @override
  FutureOr<ScheduleData> runNotifierBuild(
    covariant AvailabilityController notifier,
  ) {
    return notifier.build(arg);
  }

  @override
  Override overrideWith(AvailabilityController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AvailabilityControllerProvider._internal(
        () => create()..arg = arg,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        arg: arg,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AvailabilityController, ScheduleData>
  createElement() {
    return _AvailabilityControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailabilityControllerProvider && other.arg == arg;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, arg.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailabilityControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ScheduleData> {
  /// The parameter `arg` of this provider.
  AvailabilityParams get arg;
}

class _AvailabilityControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AvailabilityController,
          ScheduleData
        >
    with AvailabilityControllerRef {
  _AvailabilityControllerProviderElement(super.provider);

  @override
  AvailabilityParams get arg => (origin as AvailabilityControllerProvider).arg;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
