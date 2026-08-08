/// The settings feature's composition root — binds the server-side preference bag
/// (`GET/PATCH /settings`) to its data implementation. Kept alive for the app lifetime
/// (stateless), like the other repository providers.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/user_settings_remote_data_source.dart';
import '../../data/repositories/user_settings_repository_impl.dart';
import '../../domain/repositories/user_settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
UserSettingsRemoteDataSource userSettingsRemoteDataSource(Ref ref) =>
    UserSettingsRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
UserSettingsRepository userSettingsRepository(Ref ref) =>
    UserSettingsRepositoryImpl(ref.watch(userSettingsRemoteDataSourceProvider));
