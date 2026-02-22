import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/Models/ProgramModel.dart';
import 'package:gms_flutter/Modules/Dashboard/Helper/ProgramDays.dart';
import '../../../../BLoC/Manager.dart';
import '../../../../BLoC/States.dart';
import '../../../../Shared/Constant.dart';
import '../../../../Shared/Components.dart';

class ClassPrograms extends StatefulWidget {
  final String classId;

  const ClassPrograms({super.key, required this.classId});

  @override
  State<ClassPrograms> createState() => _ClassProgramsState();
}

class _ClassProgramsState extends State<ClassPrograms> {
  late Manager manager;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getClassPrograms(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          ReusableComponents.showToast(state.error, background: Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: reusableText(
              content: 'Class Programs',
              fontColor: Colors.greenAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: state is LoadingState
              ? const Center(child: CircularProgressIndicator())
              : _buildProgramsList(manager.classPrograms),
        );
      },
    );
  }

  Widget _buildProgramsList(List<ProgramModel> programs) {
    if (programs.isEmpty) {
      return const Center(
        child: Text(
          "No Programs Found",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final item = programs[index];
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.85, end: 1),
          duration: Duration(milliseconds: 400 + (index * 120)),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: _programCard(item, context),
        );
      },
    );
  }

  Widget _programCard(ProgramModel program, BuildContext context) {
    final totalDays = program.schedule?.days?.length ?? 0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDays(program: program),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.name.toString(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  "Level: ${program.level}",
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Text(
                    "$totalDays DAYS",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
