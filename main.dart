import 'package:flutter/material.dart';

void main() => runApp(const GamesApp());

class GamesApp extends StatelessWidget {
  const GamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const WelcomeScreen(),
    );
  }
}

// ---------------- شاشة الترحيب ----------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('أهلاً بك 👋',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('اختر اللعبة اللي تبيها',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 32),
              _GameCard(
                icon: Icons.groups,
                title: 'أسئلة ونقاط',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PlayersSetup())),
              ),
              _GameCard(
                icon: Icons.menu_book,
                title: 'أسئلة دينية جميلة',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ComingSoon('أسئلة دينية جميلة'))),
              ),
              _GameCard(
                icon: Icons.psychology,
                title: 'تخمين الشخصية',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ComingSoon('تخمين الشخصية'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _GameCard(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, size: 36),
        title: Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
          child: Text('قريباً... 🚧', style: TextStyle(fontSize: 24))),
    );
  }
}

// ---------------- لعبة 1: إضافة اللاعبين ----------------
class PlayersSetup extends StatefulWidget {
  const PlayersSetup({super.key});

  @override
  State<PlayersSetup> createState() => _PlayersSetupState();
}

class _PlayersSetupState extends State<PlayersSetup> {
  final _controller = TextEditingController();
  final List<String> _names = [];
  static const int maxPlayers = 6;

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty || _names.length >= maxPlayers) return;
    setState(() {
      _names.add(name);
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أسئلة ونقاط')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('اللاعبين (${_names.length}/$maxPlayers)',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _add(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'اكتب اسم اللاعب',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _names.length >= maxPlayers ? null : _add,
                  child: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _names.length,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(_names[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _names.removeAt(i)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _names.length < 2
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ScoreScreen(List<String>.from(_names))),
                        ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('ابدأ اللعبة', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- لعبة 1: شاشة النقاط ----------------
class ScoreScreen extends StatefulWidget {
  final List<String> names;
  const ScoreScreen(this.names, {super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  late final List<int> _scores = List<int>.filled(widget.names.length, 0);

  void _finish() {
    final order = List<int>.generate(widget.names.length, (i) => i)
      ..sort((a, b) => _scores[b].compareTo(_scores[a]));
    final top = _scores[order.first];
    final winners = order.where((i) => _scores[i] == top).toList();
    final winnerText = winners.length == 1
        ? '🏆 الفائز: ${widget.names[winners.first]}'
        : '🤝 تعادل بين: ${winners.map((i) => widget.names[i]).join(' و ')}';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(winnerText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final i in order)
              ListTile(
                dense: true,
                title: Text(widget.names[i]),
                trailing: Text('${_scores[i]} نقطة',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text('القائمة الرئيسية'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _scores.fillRange(0, _scores.length, 0));
            },
            child: const Text('لعبة جديدة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('النقاط')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.names.length,
              itemBuilder: (_, i) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(widget.names[i],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() => _scores[i]--),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text('${_scores[i]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _scores[i]++),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _finish,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('انتهاء', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
