import 'package:flutter/material.dart';

void main() => runApp(const FlashcardApp());


class Flashcard {
  String question;
  String answer;
  Flashcard(this.question, this.answer);
}

class FlashcardApp extends StatefulWidget {
  const FlashcardApp({super.key});

  @override
  State<FlashcardApp> createState() => _FlashcardAppState();
}

class _FlashcardAppState extends State<FlashcardApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B132B),
      ),
      home: FlashcardScreen(
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const FlashcardScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final List<Flashcard> _cards = [
    Flashcard('What is Flutter?',
        'An open-source UI toolkit by Google for building apps for mobile, web and desktop from a single codebase.'),
    Flashcard('Which language does Flutter use?', 'Dart.'),
    Flashcard('What is a Widget in Flutter?',
        'The basic building block of a Flutter UI. Almost everything on screen is a widget.'),
    Flashcard('What is the difference between StatelessWidget and StatefulWidget?',
        'A StatelessWidget never changes once built. A StatefulWidget can rebuild when its state changes using setState().'),
    Flashcard('What does setState() do?',
        'It tells Flutter that the state has changed so the widget should rebuild.'),
    Flashcard('What is hot reload?',
        'A feature that injects updated code into the running app instantly, without losing the current state.'),
  ];

  int _current = 0;
  bool _showAnswer = false;

  Flashcard? get _card => _cards.isEmpty ? null : _cards[_current];

  void _next() {
    if (_cards.isEmpty) return;
    setState(() {
      _current = (_current + 1) % _cards.length;
      _showAnswer = false;
    });
  }

  void _previous() {
    if (_cards.isEmpty) return;
    setState(() {
      _current = (_current - 1 + _cards.length) % _cards.length;
      _showAnswer = false;
    });
  }

  /// Opens a dialog to add a new card or edit the given one.
  Future<void> _openEditor({Flashcard? existing}) async {
    final qController = TextEditingController(text: existing?.question ?? '');
    final aController = TextEditingController(text: existing?.answer ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add flashcard' : 'Edit flashcard'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: qController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a question' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: aController,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter an answer' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    setState(() {
      if (existing == null) {
        _cards.add(Flashcard(qController.text.trim(), aController.text.trim()));
        _current = _cards.length - 1; // jump to the new card
      } else {
        existing.question = qController.text.trim();
        existing.answer = aController.text.trim();
      }
      _showAnswer = false;
    });
  }

  Future<void> _deleteCard() async {
    final card = _card;
    if (card == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete flashcard?'),
        content: const Text('This card will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _cards.removeAt(_current);
      if (_current >= _cards.length) _current = _cards.length - 1;
      if (_current < 0) _current = 0;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final ink = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF14213D);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final surface = isDark ? const Color(0xFF1C2541) : Colors.white;
    const accent = Color(0xFFE0A100);
    final card = _card;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Flashcards',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: muted,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: accent,
        foregroundColor: const Color(0xFF14213D),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add card',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: card == null
            ? _buildEmpty(muted, ink)
            : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  // Counter + progress
                  Row(
                    children: [
                      Text(
                        'Card ${_current + 1} of ${_cards.length}',
                        style: TextStyle(
                            color: muted, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _openEditor(existing: card),
                        icon: Icon(Icons.edit_outlined, color: muted),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: _deleteCard,
                        icon: Icon(Icons.delete_outline_rounded,
                            color: muted),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_current + 1) / _cards.length,
                      minHeight: 4,
                      color: accent,
                      backgroundColor: muted.withAlpha(50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // The flashcard
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Container(
                        key: ValueKey('$_current-$_showAnswer-${card.question}'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border(
                            left: BorderSide(
                              color: _showAnswer ? accent : ink,
                              width: 5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withAlpha(isDark ? 80 : 18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showAnswer ? 'ANSWER' : 'QUESTION',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w700,
                                color: _showAnswer ? accent : muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Text(
                                    _showAnswer
                                        ? card.answer
                                        : card.question,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 24,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                      color: ink,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Show / Hide answer
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          setState(() => _showAnswer = !_showAnswer),
                      icon: Icon(_showAnswer
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      label: Text(
                          _showAnswer ? 'Hide Answer' : 'Show Answer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ink,
                        foregroundColor: isDark
                            ? const Color(0xFF0B132B)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Previous / Next
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _previous,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ink,
                            side: BorderSide(color: muted.withAlpha(120)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _next,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ink,
                            side: BorderSide(color: muted.withAlpha(120)),
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56), // room for the FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(Color muted, Color ink) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.style_outlined, size: 64, color: muted),
            const SizedBox(height: 16),
            Text(
              'No flashcards yet',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add card" to create your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}