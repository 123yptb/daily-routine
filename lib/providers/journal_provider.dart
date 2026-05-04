import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_model.dart';

const _uuid = Uuid();
const _journalBox = 'journal_entries';

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]) {
    _load();
  }

  Box<JournalEntry> get _box => Hive.box<JournalEntry>(_journalBox);

  void _load() {
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<JournalEntry> addEntry({
    required String content,
    String? title,
    String? mood,
    double? moodScore,
    List<String>? tags,
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      content: content,
      date: DateTime.now(),
      title: title,
      mood: mood,
      moodScore: moodScore,
      tags: tags,
    );
    await _box.put(entry.id, entry);
    _load();
    return entry;
  }

  Future<void> updateEntry(
    String id, {
    String? content,
    String? title,
    String? mood,
    double? moodScore,
    List<String>? tags,
    bool? isFavorite,
  }) async {
    final entry = _box.get(id);
    if (entry == null) return;
    if (content != null) entry.content = content;
    if (title != null) entry.title = title;
    if (mood != null) entry.mood = mood;
    if (moodScore != null) entry.moodScore = moodScore;
    if (tags != null) entry.tags = tags;
    if (isFavorite != null) entry.isFavorite = isFavorite;
    await entry.save();
    _load();
  }

  Future<void> toggleFavorite(String id) async {
    final entry = _box.get(id);
    if (entry == null) return;
    entry.isFavorite = !entry.isFavorite;
    await entry.save();
    _load();
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
    _load();
  }

  List<JournalEntry> get favoriteEntries =>
      state.where((e) => e.isFavorite).toList();
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>(
        (_) => JournalNotifier());

final favoriteJournalProvider = Provider<List<JournalEntry>>((ref) {
  return ref.watch(journalProvider).where((e) => e.isFavorite).toList();
});
