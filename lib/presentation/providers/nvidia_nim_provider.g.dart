// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nvidia_nim_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nvidiaNimServiceHash() => r'e51f2b8dec52896906c64411b926268b91a67861';

/// See also [nvidiaNimService].
@ProviderFor(nvidiaNimService)
final nvidiaNimServiceProvider = AutoDisposeProvider<NvidiaNimService>.internal(
  nvidiaNimService,
  name: r'nvidiaNimServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nvidiaNimServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NvidiaNimServiceRef = AutoDisposeProviderRef<NvidiaNimService>;
String _$nvidiaNimStateHash() => r'3d02daa65ce4c9128a586a5b09370f3198191dc4';

/// See also [NvidiaNimState].
@ProviderFor(NvidiaNimState)
final nvidiaNimStateProvider =
    AutoDisposeNotifierProvider<NvidiaNimState, AsyncValue<String>>.internal(
      NvidiaNimState.new,
      name: r'nvidiaNimStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nvidiaNimStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NvidiaNimState = AutoDisposeNotifier<AsyncValue<String>>;
String _$cpfValidationStateHash() =>
    r'3792b21bf21a5ae2799446b133c88a3b608a9fd7';

/// See also [CpfValidationState].
@ProviderFor(CpfValidationState)
final cpfValidationStateProvider =
    AutoDisposeNotifierProvider<
      CpfValidationState,
      AsyncValue<Map<String, dynamic>?>
    >.internal(
      CpfValidationState.new,
      name: r'cpfValidationStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cpfValidationStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CpfValidationState =
    AutoDisposeNotifier<AsyncValue<Map<String, dynamic>?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
