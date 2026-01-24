import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/WorkoutModel.dart';
import 'package:gms_flutter/Models/WorkoutProgressModel.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:intl/intl.dart';

class WorkoutProgress extends StatelessWidget {
  int program_workout_id;
  WorkoutModel workoutModel;

  WorkoutProgress({
    super.key,
    required this.program_workout_id,
    required this.workoutModel,
  });

  Manager? _manager;

  // Filters
  String _startDate = '';
  String _endDate = '';
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // UI State
  bool showCharts = true;

  // Data
  List<WorkoutProgressModel> _workoutProgress = [];

  final Color cardBlack = Constant.scaffoldColor;
  final Color panelBlack = const Color(0xff2a2a2a);

  // Pick date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.teal.shade700,
              onPrimary: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: panelBlack),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      if (isStart) {
        _startDate = formatted;
        _startDateController.text = formatted;
      } else {
        _endDate = formatted;
        _endDateController.text = formatted;
      }
      _manager?.updateState();
      if (_startDate.isNotEmpty && _endDate.isNotEmpty) {
        _manager?.getWorkoutProgress(
          program_workout_id,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _manager = Manager.get(context);
    _manager?.getWorkoutProgress(program_workout_id);

    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          ReusableComponents.showToast(
            state.error.toString(),
            background: Colors.red,
          );
        }
      },
      builder: (context, state) {
        _workoutProgress = _manager!.workoutProgresses;
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            _manager!.workoutProgresses.clear();
            showCharts = true;
            _startDateController.clear();
            _endDateController.clear();
          },
          child: Scaffold(
            backgroundColor: cardBlack,
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: reusableText(
                content: 'Workout Progress Dashboard',
                fontColor: Colors.greenAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.teal.shade700,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _openAddRecordDialog(context),
            ),
            body: ConditionalBuilder(
              condition: state is! LoadingState,
              builder: (_) => Column(
                children: [
                  _buildToggleButtons(),
                  _buildFilterSection(context),
                  Expanded(child: _buildBodyByState(state, context)),
                ],
              ),
              fallback: (_) => const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyByState(BLoCStates state, BuildContext context) {
    if (state is SuccessState || state is UpdateNewState) {
      if (_workoutProgress.isEmpty) {
        final msg = _startDate.isEmpty && _endDate.isEmpty
            ? "No progress records found."
            : "No records found in this date range.";

        return Center(
          child: Text(msg, style: const TextStyle(color: Colors.white54)),
        );
      }
      return showCharts
          ? _buildChartsView(context)
          : _buildRecordsView(context);
    }
    if (state is ErrorState) {
      return _buildRetrySection();
    }
    return const SizedBox();
  }

  Widget _buildRetrySection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        reusableText(
          content: 'Connection error!',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _manager?.getWorkoutProgress(program_workout_id),
          child: Container(
            height: 50,
            width: Constant.screenWidth / 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Constant.scaffoldColor],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                "Retry",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade700),
      ),
      child: Row(
        children: [
          _toggleButton("Charts", showCharts, () {
            showCharts = true;
            _manager?.updateState();
          }),
          _toggleButton("Records", !showCharts, () {
            showCharts = false;
            _manager?.updateState();
          }),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? Colors.teal.shade700 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade700),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateField(
              context,
              'Start Date',
              _startDateController,
              true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDateField(
              context,
              'End Date',
              _endDateController,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
    bool isStart,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal.shade300),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Colors.teal.shade300,
          size: 20,
        ),
      ),
      onTap: () => _selectDate(context, isStart),
    );
  }

  Widget _buildChartsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      child: Column(
        children: [
          (workoutModel.sets > 0 && workoutModel.reps != null)
              ? _chartCard(
                  "Lifted Weight Progress",
                  "Track your Lifted Weight over time",
                  _buildWeightChart(_workoutProgress),
                  Colors.teal.shade400,
                  Colors.teal.shade900,
                )
              : (workoutModel.sets > 0 && workoutModel.duration != null)
              ? _chartCard(
                  "Duration Progress",
                  "Track your Trained Duration over time",
                  _buildDurationChart(_workoutProgress),
                  Colors.indigo.shade400,
                  Colors.deepPurple.shade900,
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _chartCard(
    String title,
    String subtitle,
    Widget chart,
    Color start,
    Color end,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [start.withOpacity(.9), end.withOpacity(.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(height: Constant.screenHeight / 3, child: chart),
        ],
      ),
    );
  }

  Widget _buildRecordsView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: _workoutProgress.length,
      itemBuilder: (_, index) {
        return _healthCard(_workoutProgress[index], index, context);
      },
    );
  }

  Widget _healthCard(
    WorkoutProgressModel info,
    int index,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.black87],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recorded: ${ReusableComponents.formatDateTime(info.recordedAt.toString(),format: 'yyyy/MM/dd')}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _infoTile(
                    Icons.monitor_weight,
                    "Weight",
                    "${info.weight} kg",
                  ),
                  if (info.duration != null)
                    _infoTile(Icons.timer, "Duration", "${info.duration} min"),
                  if (info.note != null)
                    _infoTile(Icons.note, "Note", "${info.note}"),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () {
                ReusableComponents.deleteDialog<Manager>(context, () async {
                  _manager?.deleteWorkoutProgress(
                    info.id.toString(),
                    program_workout_id,
                    startDate: _startDate,
                    endDate: _endDate,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<WorkoutProgressModel> infos) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: _chartTitles(infos),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.greenAccent,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.greenAccent.withOpacity(.2),
            ),
            spots: infos
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.weight ?? 0))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChart(List<WorkoutProgressModel> infos) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: _chartTitles(infos),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.blueAccent,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withOpacity(.2),
            ),
            spots: infos
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.duration ?? 0))
                .toList(),
          ),
        ],
      ),
    );
  }

  FlTitlesData _chartTitles(List<WorkoutProgressModel> infos) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (v, meta) {
            final i = v.toInt();
            if (i < 0 || i >= infos.length) return const SizedBox();
            final date = DateFormat('MM/dd').format(infos[i].recordedAt);
            return Text(
              date,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (v, meta) => Text(
            v.toStringAsFixed(0),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddRecordDialog(BuildContext context) async {
    final weight = TextEditingController();
    final duration = TextEditingController();
    final note = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocProvider.value(
          value: Manager.get(context),
          child: BlocBuilder<Manager, BLoCStates>(
            builder: (_, state) {
              return AlertDialog(
                backgroundColor: const Color(0xff2b2b2b),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text(
                  'Add New Record',
                  style: TextStyle(color: Colors.white),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (workoutModel.reps != null)
                      _dialogTextField("Weight (kg)", weight, required: true),
                      if (workoutModel.reps == null)
                      _dialogTextField(
                        "Duration (min)",
                        duration,
                        required: true,
                      ),
                      _dialogTextField("Note", note, isNumber: false),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ConditionalBuilder(
                    condition: state is! LoadingState,
                    builder: (_) => ElevatedButton(
                      onPressed: () {
                        if ((workoutModel.reps != null &&
                                weight.text.isEmpty) ||
                            (workoutModel.reps == null &&
                                duration.text.isEmpty)) {
                          ReusableComponents.showToast(
                            'Weight or Duration are required',
                            background: Colors.red,
                          );
                          return;
                        }

                        final data = {
                          "weight": double.tryParse(weight.text),
                          "duration": double.tryParse(duration.text),
                          "note": note.text.isNotEmpty ? note.text : null,
                          "program_workout_id" : program_workout_id
                        };
                        Manager.get(context).logWorkoutProgress(data).then((_) {
                          ReusableComponents.showToast(
                            'Record added successfully',
                            background: Colors.green,
                          );
                          Navigator.pop(dialogCtx);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    fallback: (_) => const CircularProgressIndicator(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _dialogTextField(
    String label,
    TextEditingController c, {
    bool isNumber = true,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.white70),
              children: required
                  ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
