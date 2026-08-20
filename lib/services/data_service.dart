import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/election_data.dart';

/// Point this at wherever the backend scraper publishes fetched_data.json.
/// Example:
/// Override with --dart-define=DATA_URL=<another-public-json-url> when needed.
const String kDataUrl = String.fromEnvironment(
  'DATA_URL',
  defaultValue:
      'https://raw.githubusercontent.com/ehab-op17/palestine-election-tracker/main/data/fetched_data.json',
);

const String _cacheKey = 'cached_election_data_v1';

class DataService {
  /// Fetch order: live URL -> local cache -> bundled seed asset.
  /// Always returns a dataset; never throws to the UI layer.
  Future<DataFetchResult> loadDataset({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null) {
        _refreshInBackground();
        return DataFetchResult(dataset: cached, source: DataSource.cache);
      }
    }

    try {
      final live = await _fetchLive();
      if (live != null) {
        await _saveToCache(live);
        return DataFetchResult(
            dataset: ElectionDataset.fromJson(live), source: DataSource.live);
      }
    } catch (_) {
      // Fall through to seed.
    }

    final seed = await _loadSeed();
    return DataFetchResult(dataset: seed, source: DataSource.seed);
  }

  Future<void> _refreshInBackground() async {
    try {
      final live = await _fetchLive();
      if (live != null) {
        await _saveToCache(live);
      }
    } catch (_) {
      // UI already has cached or seed data to show.
    }
  }

  Future<Map<String, dynamic>?> _fetchLive() async {
    if (kDataUrl.isEmpty) return null;
    final resp = await http
        .get(Uri.parse(kDataUrl))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<ElectionDataset?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return ElectionDataset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(json));
  }

  Future<ElectionDataset> _loadSeed() async {
    final raw = await rootBundle.loadString('assets/data/seed_data.json');
    return ElectionDataset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

enum DataSource { live, cache, seed }

class DataFetchResult {
  final ElectionDataset dataset;
  final DataSource source;

  DataFetchResult({required this.dataset, required this.source});

  String get sourceLabel {
    switch (source) {
      case DataSource.live:
        return 'Live data';
      case DataSource.cache:
        return 'Cached (last successful fetch)';
      case DataSource.seed:
        return kDataUrl.isEmpty
            ? 'Bundled seed data - configure DATA_URL for live updates'
            : 'Bundled seed data - network unavailable';
    }
  }
}
