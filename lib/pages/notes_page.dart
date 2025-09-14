import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'dart:convert';
import 'package:markdown_quill/markdown_quill.dart' as mdq;
import '../utils/export_helper.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NoteService _svc = NoteService();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await _svc.loadNotes();
    if (!mounted) return;
    setState(() => _notes = n);
  }

  Future<void> _edit([Note? note]) async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (ctx) => NoteEditorPage(note: note)),
    );
    if (!mounted) return;
    if (result == true) await _load();
  }

  Future<void> _delete(Note note) async {
    await _svc.delete(note.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes yet — tap + to create one'))
          : ListView.separated(
              itemCount: _notes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final n = _notes[i];
                return ListTile(
                  title: Text(n.title.isEmpty ? '(untitled)' : n.title),
                  subtitle: Text(
                    _notePreview(n).length > 120
                        ? '${_notePreview(n).substring(0, 120)}…'
                        : _notePreview(n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _delete(n),
                  ),
                  onTap: () => _edit(n),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _edit(Note(id: const Uuid().v4(), title: '', body: '')),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final Note? note;
  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  fq.QuillController? _quillController;
  final NoteService _svc = NoteService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.note?.body ?? '');
    // Always use a QuillController (rich editor by default)
    try {
      final deltaJson = widget.note?.quillDelta;
      final doc = deltaJson != null
          ? fq.Document.fromJson(deltaJson['ops'] as List<dynamic>)
          : fq.Document.fromJson([
              {'insert': widget.note?.body ?? '\n'}
            ]);
      _quillController = fq.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _quillController = fq.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _quillController?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Always save Quill delta JSON
    Map<String, dynamic>? deltaMap;
    String bodyFallback = _bodyCtrl.text;
    if (_quillController != null) {
      final delta = _quillController!.document.toDelta();
      deltaMap = {'ops': delta.toJson()};
      bodyFallback = json.encode(delta.toJson());
    }

    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleCtrl.text,
      body: bodyFallback,
      format: 'quill',
      quillDelta: deltaMap,
      updatedAt: DateTime.now(),
    );
    await _svc.addOrUpdate(note);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _exportMarkdown() async {
    if (_quillController == null) return;
    try {
      final delta = _quillController!.document.toDelta();
      final md = mdq.DeltaToMarkdown().convert(delta);
      final fileName = 'note_${widget.note?.id ?? DateTime.now().millisecondsSinceEpoch}.md';
      final saved = await saveMarkdownFile(fileName, '# ${_titleCtrl.text}\n\n$md');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported markdown: $saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New note' : 'Edit note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
          IconButton(icon: const Icon(Icons.file_download), onPressed: _exportMarkdown),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  fq.QuillSimpleToolbar(
                    controller: _quillController ?? fq.QuillController.basic(),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: fq.QuillEditor.basic(
                        controller: _quillController ?? fq.QuillController.basic(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to extract a plain-text preview from a Note (from delta if present)
String _notePreview(Note n) {
  try {
    if (n.quillDelta != null) {
      final doc = fq.Document.fromJson(n.quillDelta!['ops'] as List<dynamic>);
      final plain = doc.toPlainText();
      return plain.trim().isEmpty ? '(empty)' : plain.trim();
    }
  } catch (_) {}
  return n.body.isEmpty ? '(empty)' : n.body;
}
