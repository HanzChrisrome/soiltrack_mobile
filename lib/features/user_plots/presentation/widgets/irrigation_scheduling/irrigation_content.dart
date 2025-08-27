import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart'
    show Time, showPicker;
import 'package:soiltrack_mobile/features/home/provider/irrigation/irrigation_notifier.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';
import 'irrigation_type_toggle.dart';

class IrrigationSchedule {
  int? id;
  final String type;
  final TimeOfDay? time;
  final Duration? duration;
  final String? label;
  final List<String> days;

  IrrigationSchedule({
    required this.id,
    required this.type,
    this.time,
    this.duration,
    this.label,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'time': time != null ? '${time!.hour}:${time!.minute}' : null,
        'duration': duration?.inMinutes,
        'label': label,
        'days': days,
      };

  factory IrrigationSchedule.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String?)?.split(':');
    return IrrigationSchedule(
      id: json['id'] != null ? json['id'] as int : null,
      type: json['type'],
      time: timeParts != null
          ? TimeOfDay(
              hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]))
          : null,
      duration:
          json['duration'] != null ? Duration(minutes: json['duration']) : null,
      label: json['label'] as String?,
      days: (json['days'] as List?)!.cast<String>(),
    );
  }
}

class IrrigationSettingsContent extends ConsumerStatefulWidget {
  final int plotId;
  final String initialIrrigationType;
  final Map<String, dynamic> selectedPlot;
  final IrrigationSchedule? schedule;
  final bool isEditing;
  final bool isCopy;

  const IrrigationSettingsContent({
    super.key,
    required this.plotId,
    required this.initialIrrigationType,
    required this.selectedPlot,
    this.schedule,
    this.isEditing = false,
    this.isCopy = false,
  });

  @override
  ConsumerState<IrrigationSettingsContent> createState() =>
      _IrrigationSettingsContentState();
}

class _IrrigationSettingsContentState
    extends ConsumerState<IrrigationSettingsContent> {
  Duration selectedDuration = const Duration(minutes: 30);
  String selectedType = '';
  TimeOfDay? selectedTime;
  List<String> selectedDays = [];
  bool isCreatingNewSchedule = false;

  int? editingScheduleId;
  final TextEditingController nameController = TextEditingController();

  final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> fullDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  @override
  void initState() {
    super.initState();
    selectedType = widget.schedule?.type ?? widget.initialIrrigationType;
    selectedDuration = widget.schedule?.duration ?? const Duration(minutes: 30);
    selectedTime = widget.schedule?.time;
    selectedDays = widget.schedule?.days ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void pickTime() {
    Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(
            hour: selectedTime?.hour ?? 8, minute: selectedTime?.minute ?? 0),
        onChange: (Time newTime) {
          setState(() => selectedTime =
              TimeOfDay(hour: newTime.hour, minute: newTime.minute));
        },
        blurredBackground: true,
        is24HrFormat: false,
        cancelStyle:
            const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        okText: 'Set Time',
        okStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  void pickDuration() async {
    final result = await showDurationPicker(
      context: context,
      initialTime: selectedDuration,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    if (result != null) setState(() => selectedDuration = result);
  }

  @override
  Widget build(BuildContext context) {
    final soilDashboardState = ref.watch(soilDashboardProvider);
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

    final irrigationState = ref.watch(irrigationNotifierProvider);
    final irrigationNotifier = ref.read(irrigationNotifierProvider.notifier);

    final selectedPlot = soilDashboardState.userPlots.firstWhere(
      (plot) => plot['plot_id'] == widget.plotId,
      orElse: () => {},
    );
    final List<dynamic> rawSchedules =
        selectedPlot['irrigation_schedule'] ?? [];

    final List<IrrigationSchedule> existingSchedules = rawSchedules.map((s) {
      final timeParts = (s['start_time'] as String).split(':');
      return IrrigationSchedule(
        id: s['schedule_id'] != null ? s['schedule_id'] as int : null,
        type: 'Scheduled Irrigation',
        time: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
        duration: Duration(minutes: s['duration_minutes']),
        label: s['schedule_label'] as String?,
        days: List<String>.from(s['days_of_week']),
      );
    }).toList();

    final List<Widget> scheduleCards = existingSchedules.map((schedule) {
      return DynamicContainer(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextHeader(
                  text: schedule.label ?? 'Irrigation Schedule',
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      editingScheduleId = schedule.id;
                      selectedTime = schedule.time;
                      selectedDuration =
                          schedule.duration ?? const Duration(minutes: 30);
                      selectedDays = List.from(schedule.days);
                      nameController.text = schedule.label ?? '';
                    });
                  },
                  child: DynamicContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 5.0,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () async {
                    showCustomBottomSheet(
                      context: context,
                      title: 'Delete selected schedule?',
                      icon: Icons.delete,
                      buttonText: 'Continue',
                      onPressed: () async {
                        if (context.mounted) Navigator.of(context).pop();
                        await irrigationNotifier.deleteSchedule(
                            context, schedule.id!);
                      },
                    );
                  },
                  child: DynamicContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 5.0,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.delete_forever,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            if (schedule.time != null)
              Text('Time: ${schedule.time!.format(context)}'),
            if (schedule.duration != null)
              Text('Duration: ${schedule.duration!.inMinutes} min'),
            if (schedule.days.isNotEmpty)
              Text('Days: ${schedule.days.join(", ")}'),
          ],
        ),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IrrigationTypeToggle(
          plotId: widget.plotId,
          irrigationType: selectedType,
          onChanged: (newType) => setState(() => selectedType = newType),
        ),
        const SizedBox(height: 5),
        if (selectedType == 'Automated Irrigation')
          CropThresholdWidget(plotDetails: widget.selectedPlot),
        if (selectedType == 'Scheduled Irrigation' &&
            existingSchedules.isNotEmpty &&
            editingScheduleId == null &&
            !isCreatingNewSchedule)
          Column(children: [
            SizedBox(
              height: 500,
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: scheduleCards,
              ),
            ),
            FilledCustomButton(
                buttonText: 'Add New Schedule',
                onPressed: () {
                  setState(() {
                    isCreatingNewSchedule = true;
                    editingScheduleId = null;
                    selectedTime = null;
                    selectedDuration = const Duration(minutes: 30);
                    selectedDays.clear();
                    nameController.clear();
                  });
                }),
          ]),
        if (selectedType == 'Scheduled Irrigation' &&
            (existingSchedules.isEmpty ||
                editingScheduleId != null ||
                isCreatingNewSchedule))
          _buildScheduleForm(context, soilDashboardNotifier),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScheduleForm(BuildContext context, soilDashboardNotifier) {
    return Column(
      children: [
        Wrap(
          spacing: 1,
          children: List.generate(days.length, (index) {
            final isSelected = selectedDays.contains(fullDays[index]);
            return FilterChip(
              label: Text(
                days[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.black,
                ),
              ),
              showCheckmark: false,
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.onSecondary,
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.grey.shade400,
                ),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedDays.add(fullDays[index]);
                  } else {
                    selectedDays.remove(fullDays[index]);
                  }
                });
              },
            );
          }),
        ),
        const SizedBox(height: 10),
        TextFieldWidget(
          label: 'Label for your schedule',
          controller: nameController,
          padding: EdgeInsets.all(0),
          fontSize: 14,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: pickTime,
          child: DynamicContainer(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Row(
              children: [
                Text('Start Time: ${selectedTime?.format(context) ?? "--:--"}'),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.access_time), onPressed: pickTime),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: pickDuration,
          child: DynamicContainer(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Row(
              children: [
                Text(
                    'Duration: ${selectedDuration.inHours}h ${selectedDuration.inMinutes.remainder(60)}m'),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.timer), onPressed: pickDuration),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlineCustomButton(
                buttonText: 'Cancel',
                onPressed: () {
                  if (editingScheduleId != null) {
                    setState(() {
                      editingScheduleId = null;
                      selectedTime = null;
                      selectedDuration = const Duration(minutes: 30);
                      selectedDays.clear();
                      nameController.clear();
                    });
                  } else {
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledCustomButton(
                buttonText: editingScheduleId != null
                    ? 'Update Schedule'
                    : 'Save Changes',
                onPressed: () async {
                  if (selectedType == 'Scheduled Irrigation' &&
                      (selectedDays.isEmpty || selectedTime == null)) {
                    NotifierHelper.showErrorToast(
                        context, 'Please select a day and time.');
                    return;
                  }

                  final formattedTime = selectedTime != null
                      ? '${selectedTime!.hour}:${selectedTime!.minute}'
                      : '00:00';

                  await soilDashboardNotifier.saveIrrigationSchedule(
                    context: context,
                    formattedTime: formattedTime,
                    plotId: widget.plotId,
                    timeDuration: selectedDuration,
                    irrigationType: selectedType,
                    scheduleLabel: nameController.text,
                    selectedDays: selectedDays,
                    scheduleId: editingScheduleId ?? 0,
                    savingType: editingScheduleId != null ? 'update' : 'create',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
