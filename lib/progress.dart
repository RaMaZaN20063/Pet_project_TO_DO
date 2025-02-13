import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/model/todo_model.dart';
import 'package:todo_app/services/database_services.dart';
import 'dart:math';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  final DatabaseServices _databaseServices = DatabaseServices();
  final List<String> _motivationalQuotes = [
    "Keep pushing forward!",
    "You are stronger than you think!",
    "Success is the sum of small efforts!",
    "Believe in yourself and all that you are!",
    "Your hard work will pay off!"
  ];
  
  String _currentMotivation = "Press the button for motivation!";
  
  List<Todo> _todos = [];
  int _completedTasks = 0;
  int _totalTasks = 0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    _databaseServices.todos.listen((todos) {
      if (mounted) {
        setState(() {
          _todos = todos;
          _completedTasks = todos.where((todo) => todo.completed).length;
          _totalTasks = todos.length;
          _progress = _totalTasks == 0 ? 0 : _completedTasks / _totalTasks;
        });
      }
    });
  }

  void _generateMotivation() {
    setState(() {
      _currentMotivation = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    });
  }

  List<PieChartSectionData> _getSections() {
    if (_totalTasks == 0) {
      return [
        PieChartSectionData(
          value: 2,
          color: Colors.grey,
          title: "0%",
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: _completedTasks.toDouble(),
        color: _progress <= 0.5 ? Colors.red : Colors.green,
        title: "${(_progress * 100).toInt()}%",
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: (_totalTasks - _completedTasks).toDouble(),
        color: Colors.grey,
        title: "",
        radius: 50,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Прогресс"),
      ),
      body: _totalTasks == 0
          ? const Center(child: Text("Нет задач для отображения"))
          : Container(
              height: 700,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 700),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Прогресс задач",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Всего задач: $_totalTasks",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Процент выполнения: ${(_progress * 100).toInt()}%",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _getSections(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Выполнено: $_completedTasks из $_totalTasks",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generateMotivation,
                          child: const Text("Get Motivation"),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentMotivation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            if (_progress == 1.0)
                              Text('🔥 You have done all of the tasks 🔥', style: TextStyle(fontSize: 18),)
                            else if (_progress <= 0.5)
                              Text('You still need to do work hard 😭', style: TextStyle(fontSize: 18),)
                            else 
                              Text(
                                'Left only ${(100 - (_progress * 100) + 1).toInt()}% to do 😊',
                                style: const TextStyle(fontSize: 18),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
