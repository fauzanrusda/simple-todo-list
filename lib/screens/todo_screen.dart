import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TodoScreen extends StatelessWidget {
  TodoScreen({super.key});

  final TextEditingController _taskController = TextEditingController();

  void _addTask(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final title = _taskController.text;

    if (title.length >= 3) {
      taskProvider.addTask(title);
      _taskController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tugas minimal harus 3 karakter.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // Membuat SnackBar mengambang
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Tasks'),
        scrolledUnderElevation: 0, // Menghilangkan bayangan saat scroll
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0, // AppBar tanpa bayangan
        actions: [
          PopupMenuButton<FilterType>(
            onSelected: (filter) {
              context.read<TaskProvider>().setFilter(filter);
            },
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: FilterType.all,
                child: Text('Semua Tugas'),
              ),
              const PopupMenuItem(
                value: FilterType.active,
                child: Text('Sedang Dikerjakan'),
              ),
              const PopupMenuItem(
                value: FilterType.done,
                child: Text('Selesai'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Daftar Tugas di bagian atas
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  // Tampilan saat tidak ada tugas
                  if (provider.tasks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Kotak masuk Anda kosong',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Tampilan ListView dengan Dismissible
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: provider.tasks.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      return Dismissible(
                        key: ValueKey(task.id), // Key unik untuk setiap item
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          provider.deleteTask(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tugas dihapus'),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'BATAL',
                                onPressed: () {
                                  provider.undoDelete();
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (_) {
                              provider.toggleTaskStatus(task);
                            },
                            activeColor: Colors.blueGrey,
                            shape: const CircleBorder(),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: task.isDone
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Pembatas antara list dan input
            const Divider(height: 1),

            // 2. Area Input di bagian bawah
            _buildTaskInput(context),
          ],
        ),
      ),
    );
  }

  // Widget terpisah untuk area input
  Widget _buildTaskInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                hintText: 'Tambahkan tugas baru...',
                border: InputBorder.none, // Desain input yang sangat bersih
              ),
              onSubmitted: (_) => _addTask(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _addTask(context),
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}