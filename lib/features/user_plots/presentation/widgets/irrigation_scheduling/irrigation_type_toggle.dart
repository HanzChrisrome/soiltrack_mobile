import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class IrrigationTypeToggle extends ConsumerStatefulWidget {
  final int plotId;
  final String irrigationType;
  final void Function(String)? onChanged;

  const IrrigationTypeToggle({
    super.key,
    required this.plotId,
    required this.irrigationType,
    this.onChanged,
  });

  @override
  ConsumerState<IrrigationTypeToggle> createState() =>
      _IrrigationTypeToggleState();
}

class _IrrigationTypeToggleState extends ConsumerState<IrrigationTypeToggle> {
  late String _selectedIrrigationType;

  @override
  void initState() {
    super.initState();
    _selectedIrrigationType = widget.irrigationType;
  }

  void _handleSelection(String newType) {
    if (newType == _selectedIrrigationType) return;

    showCustomBottomSheet(
      context: context,
      title: 'Change irrigation type?',
      icon: Icons.change_circle,
      buttonText: 'Continue',
      onPressed: () async {
        final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

        await soilDashboardNotifier.changeIrrigationStatus(
          context,
          widget.plotId,
          newType,
        );

        Navigator.of(context).pop();
        setState(() {
          _selectedIrrigationType = newType;
        });

        if (widget.onChanged != null) {
          widget.onChanged!(newType);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicContainer(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      borderColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildOption('Automated Irrigation'),
          _buildOption('Scheduled Irrigation'),
        ],
      ),
    );
  }

  Widget _buildOption(String label) {
    final isSelected = _selectedIrrigationType == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleSelection(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
