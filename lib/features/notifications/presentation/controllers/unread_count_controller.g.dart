// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UnreadCountController)
final unreadCountControllerProvider = UnreadCountControllerProvider._();

final class UnreadCountControllerProvider
    extends $AsyncNotifierProvider<UnreadCountController, UnreadCount> {
  UnreadCountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountControllerHash();

  @$internal
  @override
  UnreadCountController create() => UnreadCountController();
}

String _$unreadCountControllerHash() =>
    r'554e7d5db7ec3bfc5d37440714905654a48f5cbe';

abstract class _$UnreadCountController extends $AsyncNotifier<UnreadCount> {
  FutureOr<UnreadCount> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UnreadCount>, UnreadCount>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UnreadCount>, UnreadCount>,
              AsyncValue<UnreadCount>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
