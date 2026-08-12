import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favourites have no endpoint. Per CLAUDE.md the storage sits behind an
/// interface so swapping in `/user/favorites` later is a one-line provider
/// change.
abstract class FavoritesRepository {
  Future<Set<String>> load();

  Future<void> save(Set<String> assetIds);
}

class PrefsFavoritesRepository implements FavoritesRepository {
  const PrefsFavoritesRepository();

  static const _key = 'market.favorites';

  @override
  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  @override
  Future<void> save(Set<String> assetIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, assetIds.toList());
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => const PrefsFavoritesRepository(),
);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => ref.watch(favoritesRepositoryProvider).load();

  Future<void> toggle(String assetId) async {
    final next = {...state.value ?? const <String>{}};
    if (!next.remove(assetId)) next.add(assetId);
    state = AsyncData(next);
    await ref.read(favoritesRepositoryProvider).save(next);
  }

  bool contains(String assetId) => state.value?.contains(assetId) ?? false;
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
