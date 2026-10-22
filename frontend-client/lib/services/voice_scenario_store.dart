import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/voice_scenario.dart';

/// Abstract key/value backend for scenario metadata.
///
/// Injectable so tests can supply an in-memory map instead of real
/// `shared_preferences` platform channels.
abstract class ScenarioMetadataBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Default backend backed by `shared_preferences`.
class SharedPreferencesMetadataBackend implements ScenarioMetadataBackend {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

/// Abstracts the private directory where recordings are stored, plus file
/// deletion. Injectable so tests use a temp dir and never touch path_provider.
abstract class RecordingFileStorage {
  /// Absolute path to the private directory that holds recordings.
  Future<String> recordingsDirectoryPath();

  /// Deletes [filePath] if it exists; never throws.
  Future<void> deleteFile(String filePath);

  /// Whether [filePath] currently exists on disk.
  Future<bool> fileExists(String filePath);
}

/// Default storage using the app-private documents directory. Recordings are
/// placed under a `voice_scenarios/` subfolder that is not world-readable and
/// is never registered as a Flutter asset.
class AppPrivateRecordingStorage implements RecordingFileStorage {
  static const String _subdir = 'voice_scenarios';

  @override
  Future<String> recordingsDirectoryPath() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}$_subdir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      // Best-effort: a failed delete must not crash the manager. We avoid
      // logging the full path to limit leaking private file locations.
      debugPrint('[RecordingStorage] Delete failed for a recording file');
    }
  }

  @override
  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (_) {
      return false;
    }
  }
}

/// Persists the list of [VoiceScenario] metadata and manages their audio files.
///
/// Metadata is stored as a JSON list under a single preferences key; audio
/// bytes remain in private files referenced by [VoiceScenario.filePath]. All
/// operations are defensive: corruption or missing files degrade gracefully
/// instead of throwing.
class VoiceScenarioStore {
  static const String metadataKey = 'ghostbuster.voice_scenarios.v1';

  final ScenarioMetadataBackend _backend;
  final RecordingFileStorage _storage;

  VoiceScenarioStore({
    ScenarioMetadataBackend? backend,
    RecordingFileStorage? storage,
  })  : _backend = backend ?? SharedPreferencesMetadataBackend(),
        _storage = storage ?? AppPrivateRecordingStorage();

  /// Absolute directory where new recordings should be written.
  Future<String> recordingsDirectory() => _storage.recordingsDirectoryPath();

  /// Whether a scenario's audio file still exists on disk.
  Future<bool> audioExists(VoiceScenario scenario) =>
      _storage.fileExists(scenario.filePath);

  /// Loads all persisted scenarios (newest first). Corrupted metadata yields an
  /// empty list rather than an error.
  Future<List<VoiceScenario>> loadAll() async {
    final raw = await _backend.read(metadataKey);
    // decodeList may return a const [] (unmodifiable); copy before sorting.
    final scenarios = List<VoiceScenario>.of(VoiceScenario.decodeList(raw))
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return scenarios;
  }

  Future<void> _saveAll(List<VoiceScenario> scenarios) async {
    await _backend.write(metadataKey, VoiceScenario.encodeList(scenarios));
  }

  /// Adds or replaces a scenario (matched by id) and persists the list.
  Future<List<VoiceScenario>> upsert(VoiceScenario scenario) async {
    final all = await loadAll();
    final index = all.indexWhere((s) => s.id == scenario.id);
    if (index >= 0) {
      all[index] = scenario;
    } else {
      all.add(scenario);
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _saveAll(all);
    return all;
  }

  /// Renames and/or re-describes an existing scenario.
  Future<List<VoiceScenario>> rename(
    String id, {
    required String name,
    String? description,
  }) async {
    final all = await loadAll();
    final index = all.indexWhere((s) => s.id == id);
    if (index < 0) return all;
    all[index] = all[index].copyWith(name: name, description: description);
    await _saveAll(all);
    return all;
  }

  /// Deletes a scenario's metadata and its audio file. Safe if already gone.
  Future<List<VoiceScenario>> delete(String id) async {
    final all = await loadAll();
    final index = all.indexWhere((s) => s.id == id);
    if (index < 0) return all;
    final removed = all.removeAt(index);
    await _saveAll(all);
    await _storage.deleteFile(removed.filePath);
    return all;
  }
}
