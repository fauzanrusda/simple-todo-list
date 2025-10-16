import 'package:flutter/material.dart';
import '../models/task.dart';

enum FilterType { all, active, done }

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  Task? _lastRemovedTask;
  int? _lastRemovedTaskIndex;

  FilterType _filterType = FilterType.all;

  List<Task> get tasks {
    switch (_filterType) {
      case FilterType.active:
        return _tasks.where((task) => !task.isDone).toList();
      case FilterType.done:
        return _tasks.where((task) => task.isDone).toList();
      case FilterType.all:
        return _tasks;
    }
  }

  FilterType get filterType => _filterType;
  
  int get activeTaskCount => _tasks.where((task) => !task.isDone).length;

  void setFilter(FilterType filterType) {
    _filterType = filterType;
    notifyListeners(); 
  }

  void addTask(String title) {
    _tasks.add(Task(title: title));
    notifyListeners();
  }

  void toggleTaskStatus(Task task) {
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void deleteTask(Task task) {
    _lastRemovedTaskIndex = _tasks.indexOf(task);
    _lastRemovedTask = task;
    _tasks.remove(task);
    notifyListeners();
  }
  
  void undoDelete() {
    if (_lastRemovedTask != null && _lastRemovedTaskIndex != null) {
      _tasks.insert(_lastRemovedTaskIndex!, _lastRemovedTask!);
      _lastRemovedTask = null;
      _lastRemovedTaskIndex = null;
      notifyListeners();
    }
  }
}