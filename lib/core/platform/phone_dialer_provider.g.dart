// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_dialer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tests override this with a recording fake.

@ProviderFor(phoneDialer)
const phoneDialerProvider = PhoneDialerProvider._();

/// Tests override this with a recording fake.

final class PhoneDialerProvider
    extends $FunctionalProvider<PhoneDialer, PhoneDialer, PhoneDialer>
    with $Provider<PhoneDialer> {
  /// Tests override this with a recording fake.
  const PhoneDialerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phoneDialerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phoneDialerHash();

  @$internal
  @override
  $ProviderElement<PhoneDialer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhoneDialer create(Ref ref) {
    return phoneDialer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhoneDialer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhoneDialer>(value),
    );
  }
}

String _$phoneDialerHash() => r'0778f49efb7261f93f730551af04551656d57715';
