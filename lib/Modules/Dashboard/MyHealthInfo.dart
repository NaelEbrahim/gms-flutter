import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/HealthInfoModel.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';
import 'package:intl/intl.dart';

import '../../BLoC/Manager.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class MyHealthInfo extends StatefulWidget {
  const MyHealthInfo({super.key});

  @override
  State<MyHealthInfo> createState() => _MyHealthInfoState();
}

class _MyHealthInfoState extends State<MyHealthInfo> {
  late Manager manager;
  bool showCharts = true;

  String _startDate = '';
  String _endDate = '';
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController w = TextEditingController();
  TextEditingController h = TextEditingController();
  TextEditingController waist = TextEditingController();
  TextEditingController arm = TextEditingController();
  TextEditingController thigh = TextEditingController();
  TextEditingController notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.userHealthInfo();
  }

  @override
  void dispose() {
    manager.userHealthInfos.clear();
    startDateController.dispose();
    endDateController.dispose();
    w.dispose();
    h.dispose();
    waist.dispose();
    arm.dispose();
    thigh.dispose();
    notes.dispose();
    super.dispose();
  }

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
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      if (isStart) {
        _startDate = formatted;
        startDateController.text = formatted;
      } else {
        _endDate = formatted;
        endDateController.text = formatted;
      }
      if (_startDate.isNotEmpty && _endDate.isNotEmpty) {
        manager.userHealthInfo(startDate: _startDate, endDate: _endDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: reusableText(
              content: 'Health Metrics Dashboard',
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
        );
      },
    );
  }

  Widget _buildBodyByState(BLoCStates state, BuildContext context) {
    if (state is SuccessState || state is UpdateNewState) {
      if (manager.userHealthInfos.isEmpty) {
        final msg = _startDate.isEmpty && _endDate.isEmpty
            ? "No health records found."
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
          onTap: () => manager.userHealthInfo(),
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
            setState(() {
              showCharts = true;
            });
          }),
          _toggleButton("Records", !showCharts, () {
            setState(() {
              showCharts = false;
            });
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
              startDateController,
              true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDateField(
              context,
              'End Date',
              endDateController,
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
          _chartCard(
            "Weight Progress",
            "Track your weight changes over time",
            _buildWeightChart(manager.userHealthInfos),
            Colors.teal.shade400,
            Colors.teal.shade900,
          ),
          const SizedBox(height: 20),
          _chartCard(
            "BMI Progress",
            "Monitor your body mass index trend",
            _buildBMIChart(manager.userHealthInfos),
            Colors.indigo.shade400,
            Colors.deepPurple.shade900,
          ),
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
          colors: [start.withAlpha(229), end.withAlpha(204)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
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
          SizedBox(height: 220, child: chart),
        ],
      ),
    );
  }

  Widget _buildRecordsView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: manager.userHealthInfos.length,
      itemBuilder: (_, index) {
        return _healthCard(manager.userHealthInfos[index], index, context);
      },
    );
  }

  Widget _healthCard(HealthInfoModel info, int index, BuildContext context) {
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
                "Recorded: ${info.recordedAt}",
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
                    "${info.weightKg} kg",
                  ),
                  _infoTile(Icons.height, "Height", "${info.heightCm} cm"),
                  if (info.waistCircumference != null)
                    _infoTile(
                      Icons.accessibility,
                      "Waist",
                      "${info.waistCircumference} cm",
                    ),
                  if (info.armCircumference != null)
                    _infoTile(
                      Icons.fitness_center,
                      "Arm",
                      "${info.armCircumference} cm",
                    ),
                  if (info.thighCircumference != null)
                    _infoTile(
                      Icons.straighten,
                      "Thigh",
                      "${info.thighCircumference} cm",
                    ),
                  if (info.notes != null)
                    _infoTile(Icons.note, "Note", info.notes!),
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
                  manager.deleteHealthRecord(
                    info.id.toString(),
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

  Widget _buildWeightChart(List<HealthInfoModel> infos) {
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
              color: Colors.greenAccent.withAlpha(51),
            ),
            spots: infos
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIChart(List<HealthInfoModel> infos) {
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
              color: Colors.blueAccent.withAlpha(51),
            ),
            spots: infos
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.bmi))
                .toList(),
          ),
        ],
      ),
    );
  }

  FlTitlesData _chartTitles(List<HealthInfoModel> infos) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (v, meta) {
            final i = v.toInt();
            if (i < 0 || i >= infos.length) return const SizedBox();
            final date = DateFormat('MM/dd').format(infos[i].recordedDateTime);
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
    w.clear();
    h.clear();
    waist.clear();
    arm.clear();
    thigh.clear();
    notes.clear();
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Constant.scaffoldColor,
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
                _dialogTextField("Weight (kg)", w, required: true),
                _dialogTextField("Height (cm)", h, required: true),
                _dialogTextField("Waist (cm)", waist),
                _dialogTextField("Arm (cm)", arm),
                _dialogTextField("Thigh (cm)", thigh),
                _dialogTextField("Notes", notes, isNumber: false),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (w.text.isEmpty || h.text.isEmpty) {
                  ReusableComponents.showToast(
                    'Height and weight are required',
                    background: Colors.red,
                  );
                  return;
                }
                final data = {
                  "userId": SharedPrefHelper.getString('id'),
                  "weightKg": double.tryParse(w.text) ?? 0,
                  "heightCm": double.tryParse(h.text) ?? 0,
                  "waistCircumference": double.tryParse(waist.text),
                  "armCircumference": double.tryParse(arm.text),
                  "thighCircumference": double.tryParse(thigh.text),
                  "notes": notes.text.isNotEmpty ? notes.text : null,
                };
                manager.logHealthInfo(data);
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
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
