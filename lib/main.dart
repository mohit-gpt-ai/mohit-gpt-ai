import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MohitGPTApp());

class RelatedVideo {
  final String title;
  final String duration;

  const RelatedVideo(this.title, this.duration);
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<RelatedVideo> videos;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.videos = const [],
  });
}

class AIResult {
  final String answer;
  final List<RelatedVideo> videos;

  const AIResult(this.answer, this.videos);
}

class AIService {
  Future<AIResult> ask(String question) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return AIResult(
      'Demo answer for: "$question"\n\n'
      'Mohit GPT AI will explain the answer step by step.\n\n'
      'In the final production version, this answer will come from a real AI backend.',
      const [
        RelatedVideo('Concept Explained from Basics', '18 min'),
        RelatedVideo('Practice Questions', '25 min'),
      ],
    );
  }
}

class MohitGPTApp extends StatelessWidget {
  const MohitGPTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mohit GPT AI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF635BFF),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF635BFF),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onAskAI: () => setState(() => index = 1)),
      const AIChatScreen(),
      const BatchesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Ask AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Batches',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onAskAI;

  const HomeScreen({
    super.key,
    required this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      ('Ask Question', Icons.question_answer),
      ('Photo Question', Icons.image_search),
      ('Recorded Videos', Icons.play_circle),
      ('My Batches', Icons.school),
      ('Notes & PDFs', Icons.description),
      ('Tests', Icons.quiz),
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Mohit GPT AI',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Question → AI Answer → Related Video',
        ),
        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 40,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ask Mohit GPT AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Write a question or upload a photo and get an explanation.',
                ),
                const SizedBox(height: 15),
                FilledButton.icon(
                  onPressed: onAskAI,
                  icon: const Icon(Icons.chat),
                  label: const Text('Ask Now'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Study Tools',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        GridView.builder(
          itemCount: tools.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (_, i) {
            return Card(
              child: InkWell(
                onTap: onAskAI,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        tools[i].$2,
                        size: 32,
                      ),
                      const Spacer(),
                      Text(
                        tools[i].$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final input = TextEditingController();
  final picker = ImagePicker();
  final ai = AIService();

  bool loading = false;
  Uint8List? imageBytes;

  final messages = <ChatMessage>[
    const ChatMessage(
      text: 'Hello! अपना question लिखो या question की photo भेजो।',
      isUser: false,
    ),
  ];

  Future<void> pickPhoto() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    imageBytes = await file.readAsBytes();
    setState(() {});
  }

  Future<void> send() async {
    final question = input.text.trim();

    if (question.isEmpty && imageBytes == null) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: question.isEmpty
              ? 'Please solve this photo question.'
              : question,
          isUser: true,
        ),
      );

      loading = true;
    });

    final result = await ai.ask(
      question.isEmpty
          ? 'Question from uploaded photo'
          : question,
    );

    setState(() {
      messages.add(
        ChatMessage(
          text: result.answer,
          isUser: false,
          videos: result.videos,
        ),
      );

      input.clear();
      imageBytes = null;
      loading = false;
    });
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.auto_awesome),
              ),
              SizedBox(width: 12),
              Text(
                'Mohit GPT AI',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: messages.length + (loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == messages.length) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final m = messages[i];

              return Align(
                alignment: m.isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 360,
                  ),
                  child: Column(
                    crossAxisAlignment: m.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: m.isUser
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Text(m.text),
                      ),

                      ...m.videos.map(
                        (video) => Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.play_circle_fill,
                            ),
                            title: Text(video.title),
                            subtitle:
                                Text(video.duration),
                            trailing:
                                const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening video: ${video.title}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (imageBytes != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.image),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Question photo selected',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      imageBytes = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                onPressed: loading ? null : pickPhoto,
                icon:
                    const Icon(Icons.image_outlined),
              ),

              Expanded(
                child: TextField(
                  controller: input,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => send(),
                  decoration:
                      const InputDecoration(
                    hintText: 'Ask your question...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              IconButton(
                onPressed: loading ? null : send,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const batches = [
      (
        'NEET 2027 Complete Batch',
        'Physics, Chemistry, Biology'
      ),
      (
        'Physics Foundation',
        'Concept videos and practice'
      ),
      (
        'Biology Mastery',
        'NCERT and tests'
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Batches',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...batches.map(
          (batch) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.play_lesson),
              ),
              title: Text(batch.$1),
              subtitle: Text(batch.$2),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        Center(
          child: CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),
        ),

        SizedBox(height: 14),

        Center(
          child: Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 24),

        ListTile(
          leading: Icon(Icons.wallpaper),
          title: Text('Custom Wallpaper'),
        ),

        ListTile(
          leading: Icon(Icons.receipt_long),
          title: Text('Payment History'),
        ),

        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    );
  }
}
