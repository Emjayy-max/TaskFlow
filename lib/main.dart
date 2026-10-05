import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task.dart';

const blue = Color(0xFF1688F8);
const darkBlue = Color(0xFF061B35);
const bg = Color(0xFFF4F7FB);
const textDark = Color(0xFF12233F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('taskBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: blue),
        scaffoldBackgroundColor: bg,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E2EE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E2EE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>('taskBox');

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 86,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good afternoon,',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'TaskFlow 👋',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Stay organized. Get things done.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline),
          ),
        ],
      ),

      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          final tasks = box.values.toList();

          return Column(
            children: [
              _topSection(tasks),
              Expanded(
                child: tasks.isEmpty
                    ? _empty(context)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: tasks.length,
                        itemBuilder: (_, i) =>
                            _taskCard(context, tasks[i]),
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 5,
        onPressed: () => showTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _topSection(List<Task> tasks) {
    final high = tasks
        .where((t) => t.priority.toLowerCase() == 'high')
        .length;

    final medium = tasks
        .where((t) => t.priority.toLowerCase() == 'medium')
        .length;

    final low = tasks
        .where((t) => t.priority.toLowerCase() == 'low')
        .length;

    return Container(
      color: darkBlue,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                SizedBox(width: 14),
                Icon(Icons.search, color: Colors.white70),
                SizedBox(width: 10),
                Text(
                  'Search tasks...',
                  style: TextStyle(color: Colors.white60),
                ),
                Spacer(),
                Icon(Icons.tune, color: Colors.white70),
                SizedBox(width: 14),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              _stat('${tasks.length}', 'Total', Colors.white),
              _stat('$high', 'High', const Color(0xFFFFA7A7)),
              _stat('$medium', 'Medium', const Color(0xFFFFD17A)),
              _stat('$low', 'Low', const Color(0xFF8BE5BA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String number, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                color: color == Colors.white ? blue : color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(BuildContext context, Task task) {
    final priority = task.priority.toLowerCase();

    final priorityColor = priority == 'high'
        ? Colors.red
        : priority == 'medium'
            ? Colors.orange
            : priority == 'low'
                ? Colors.green
                : Colors.grey;

    return Dismissible(
      key: ValueKey(task.key),
      direction: DismissDirection.endToStart,

      confirmDismiss: (_) => _confirmDelete(context, task),

      onDismissed: (_) {
        task.delete();
      },

      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 25),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(height: 3),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(
            left: BorderSide(
              color: priorityColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                priority == 'high'
                    ? Icons.flag
                    : Icons.task_alt,
                color: priorityColor,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),

                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),

                  const SizedBox(height: 7),

                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _chip(
                        Icons.calendar_today,
                        formatDate(task.date),
                        Colors.blue,
                      ),
                      if (task.category.isNotEmpty)
                        _chip(
                          Icons.folder_outlined,
                          task.category,
                          Colors.blue,
                        ),
                      if (task.priority.isNotEmpty)
                        _chip(
                          Icons.flag_outlined,
                          task.priority,
                          priorityColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () =>
                  showTaskDialog(context, task: task),
              icon: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: blue.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt,
              size: 45,
              color: blue,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a task to get started.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => showTaskDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Task'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    Task task,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Delete Task?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADD / EDIT TASK
// ============================================================

Future<void> showTaskDialog(
  BuildContext context, {
  Task? task,
}) async {
  final title = TextEditingController(text: task?.title);
  final description =
      TextEditingController(text: task?.description);
  final category =
      TextEditingController(text: task?.category);
  final priority =
      TextEditingController(text: task?.priority);
  final location =
      TextEditingController(text: task?.location);
  final assignedTo =
      TextEditingController(text: task?.assignedTo);
  final notes =
      TextEditingController(text: task?.notes);

  DateTime date = task?.date ?? DateTime.now();
  final editing = task != null;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 550,
                maxHeight: 720,
              ),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Icon(
                            editing
                                ? Icons.edit
                                : Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            editing ? 'Edit Task' : 'Add Task',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // FORM
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _field(
                            title,
                            'Task Title',
                            Icons.search,
                            'Enter title',
                          ),

                          _field(
                            description,
                            'Description',
                            Icons.notes_outlined,
                            'Enter description',
                            lines: 3,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  category,
                                  'Category',
                                  Icons.folder_outlined,
                                  'e.g. School',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _field(
                                  priority,
                                  'Priority',
                                  Icons.flag_outlined,
                                  'High / Medium',
                                ),
                              ),
                            ],
                          ),

                          _field(
                            location,
                            'Location',
                            Icons.location_on_outlined,
                            'Enter location',
                          ),

                          _field(
                            assignedTo,
                            'Assigned To',
                            Icons.person_outline,
                            'Person or team',
                          ),

                          _field(
                            notes,
                            'Notes',
                            Icons.description_outlined,
                            'Additional notes',
                            lines: 3,
                          ),

                          const SizedBox(height: 4),

                          // DATE
                          InkWell(
                            borderRadius:
                                BorderRadius.circular(12),
                            onTap: () async {
                              final picked =
                                  await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );

                              if (picked != null) {
                                setState(() => date = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration:
                                  const InputDecoration(
                                labelText: 'Due Date',
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  color: blue,
                                ),
                                suffixIcon: Icon(
                                  Icons.chevron_right,
                                ),
                              ),
                              child: Text(
                                formatDate(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BUTTONS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (title.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Task title cannot be empty.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (editing) {
                                task!
                                  ..title = title.text.trim()
                                  ..description =
                                      description.text.trim()
                                  ..category =
                                      category.text.trim()
                                  ..priority =
                                      priority.text.trim()
                                  ..location =
                                      location.text.trim()
                                  ..assignedTo =
                                      assignedTo.text.trim()
                                  ..notes =
                                      notes.text.trim()
                                  ..date = date;

                                await task.save();
                              } else {
                                await Hive.box<Task>(
                                  'taskBox',
                                ).add(
                                  Task(
                                    title: title.text.trim(),
                                    description:
                                        description.text.trim(),
                                    category:
                                        category.text.trim(),
                                    priority:
                                        priority.text.trim(),
                                    location:
                                        location.text.trim(),
                                    assignedTo:
                                        assignedTo.text.trim(),
                                    notes:
                                        notes.text.trim(),
                                    date: date,
                                  ),
                                );
                              }

                              Navigator.pop(dialogContext);
                            },
                            icon: Icon(
                              editing
                                  ? Icons.save
                                  : Icons.add,
                            ),
                            label: Text(
                              editing
                                  ? 'Save Changes'
                                  : 'Create Task',
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
        },
      );
    },
  );

  for (final controller in [
    title,
    description,
    category,
    priority,
    location,
    assignedTo,
    notes,
  ]) {
    controller.dispose();
  }
}

// ============================================================
// TEXT FIELD
// ============================================================

Widget _field(
  TextEditingController controller,
  String label,
  IconData icon,
  String hint, {
  int lines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    ),
  );
}

// ============================================================
// DATE
// ============================================================

String formatDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.year}';
}