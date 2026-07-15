// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_taxonomy_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(editorLanguages)
final editorLanguagesProvider = EditorLanguagesProvider._();

final class EditorLanguagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LanguageRef>>,
          List<LanguageRef>,
          FutureOr<List<LanguageRef>>
        >
    with
        $FutureModifier<List<LanguageRef>>,
        $FutureProvider<List<LanguageRef>> {
  EditorLanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorLanguagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorLanguagesHash();

  @$internal
  @override
  $FutureProviderElement<List<LanguageRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LanguageRef>> create(Ref ref) {
    return editorLanguages(ref);
  }
}

String _$editorLanguagesHash() => r'a9fce834e026babf9fa4b65fcf6331a45b418e0b';

@ProviderFor(editorGenres)
final editorGenresProvider = EditorGenresProvider._();

final class EditorGenresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GenreRef>>,
          List<GenreRef>,
          FutureOr<List<GenreRef>>
        >
    with $FutureModifier<List<GenreRef>>, $FutureProvider<List<GenreRef>> {
  EditorGenresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorGenresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorGenresHash();

  @$internal
  @override
  $FutureProviderElement<List<GenreRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GenreRef>> create(Ref ref) {
    return editorGenres(ref);
  }
}

String _$editorGenresHash() => r'cd4a50c9eedd3ed1ff7204f2aa91860621a0c20a';
