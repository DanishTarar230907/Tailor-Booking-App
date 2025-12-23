import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A cell that displays a measurement value and becomes editable on tap
class EditableMeasurementCell extends StatefulWidget {
  final String label;
  final double? value;
  final Function(double?) onChanged;
  final bool enabled;

  const EditableMeasurementCell({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<EditableMeasurementCell> createState() => _EditableMeasurementCellState();
}

class _EditableMeasurementCellState extends State<EditableMeasurementCell> {
  bool _isEditing = false;
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(EditableMeasurementCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveValue() async {
    if (!_isEditing) return;

    setState(() {
      _isSaving = true;
      _isEditing = false;
    });

    try {
      final newValue = double.tryParse(_controller.text.trim());
      await widget.onChanged(newValue);
    } catch (e) {
      // Revert on error
      _controller.text = widget.value?.toString() ?? '';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_isEditing) {
      return TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
        ),
        onSubmitted: (_) => _saveValue(),
        onTapOutside: (_) => _saveValue(),
      );
    }

    return InkWell(
      onTap: widget.enabled
          ? () {
              setState(() => _isEditing = true);
            }
          : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(4),
          color: widget.enabled ? Colors.white : Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Row(
              children: [
                Text(
                  widget.value?.toStringAsFixed(1) ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.value != null ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
                if (widget.enabled) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.edit, size: 14, color: Colors.grey.shade400),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
