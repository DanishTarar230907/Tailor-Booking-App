import 'package:flutter/material.dart';
import '../models/measurement.dart' as models;

class MeasurementDummy extends StatefulWidget {
  final models.Measurement? measurement;
  final bool isEditable;
  final Function(models.Measurement)? onMeasurementUpdated;

  const MeasurementDummy({
    super.key,
    this.measurement,
    this.isEditable = false,
    this.onMeasurementUpdated,
  });

  @override
  State<MeasurementDummy> createState() => _MeasurementDummyState();
}

class _MeasurementDummyState extends State<MeasurementDummy> {
  String? _hoveredPart;

  void _showReadOnlyInfo(String part, String label, double? value) {
    // For non-editable mode, show a bottom sheet with the current value.
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.straighten, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value != null
                    ? '${value.toStringAsFixed(1)} inches'
                    : 'Not measured yet',
                style: TextStyle(
                  fontSize: 16,
                  color: value != null ? Colors.green[700] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tip: On desktop/web you can also hover different body parts '
                'to preview their values.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMeasurementDialog(String part, String label, double? value) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '$label (inches)',
            hintText: 'Enter measurement',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (widget.onMeasurementUpdated != null && widget.measurement != null) {
                // Map part id to measurement name
                String key = label; 
                // Adjust keys if label differs in standard set
                // The widget calls _showMeasurementDialog with label 'Bicep', 'Thigh', etc.
                // This matches our keys generally.
                
                final Map<String, double> newMap = Map.from(widget.measurement!.measurements);
                if (newValue != null) {
                  newMap[key] = newValue;
                }
                
                final updated = widget.measurement!.copyWith(measurements: newMap);
                widget.onMeasurementUpdated!(updated);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Body Measurements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                // Dummy figure
                Center(
                  child: CustomPaint(
                    size: const Size(200, 400),
                    painter: DummyPainter(
                      hoveredPart: _hoveredPart,
                      measurement: widget.measurement,
                    ),
                  ),
                ),
                // Interactive areas
                ..._buildInteractiveAreas(),
                // Measurement tooltip
                if (_hoveredPart != null && widget.measurement != null)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildMeasurementTooltip(_hoveredPart!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInteractiveAreas() {
    return [
      // Head/Neck
      _buildHoverArea(100, 50, 40, 30, 'neck', 'Neck', widget.measurement?.measurements['Neck']),
      // Chest
      _buildHoverArea(80, 120, 80, 60, 'chest', 'Chest', widget.measurement?.chest),
      // Shoulder
      _buildHoverArea(60, 100, 100, 30, 'shoulder', 'Shoulder', widget.measurement?.shoulder),
      // Waist
      _buildHoverArea(85, 180, 60, 40, 'waist', 'Waist', widget.measurement?.waist),
      // Hips
      _buildHoverArea(80, 220, 70, 40, 'hips', 'Hips', widget.measurement?.hips),
      // Left Arm - Sleeve
      _buildHoverArea(20, 120, 30, 100, 'sleeve', 'Sleeve Length', widget.measurement?.sleeveLength),
      // Right Arm - Sleeve
      _buildHoverArea(150, 120, 30, 100, 'sleeve', 'Sleeve Length', widget.measurement?.sleeveLength),
      // Left Bicep
      _buildHoverArea(25, 140, 20, 30, 'bicep', 'Bicep', widget.measurement?.measurements['Bicep']),
      // Right Bicep
      _buildHoverArea(155, 140, 20, 30, 'bicep', 'Bicep', widget.measurement?.measurements['Bicep']),
      // Left Wrist
      _buildHoverArea(20, 210, 15, 15, 'wrist', 'Wrist', widget.measurement?.measurements['Wrist']),
      // Right Wrist
      _buildHoverArea(165, 210, 15, 15, 'wrist', 'Wrist', widget.measurement?.measurements['Wrist']),
      // Shirt Length
      _buildHoverArea(85, 100, 50, 120, 'shirt', 'Shirt Length', widget.measurement?.shirtLength),
      // Left Leg - Pant Length
      _buildHoverArea(70, 260, 25, 120, 'pant', 'Trouser Length', widget.measurement?.pantLength),
      // Right Leg - Pant Length
      _buildHoverArea(105, 260, 25, 120, 'pant', 'Trouser Length', widget.measurement?.pantLength),
      // Left Thigh
      _buildHoverArea(70, 280, 25, 40, 'thigh', 'Thigh', widget.measurement?.measurements['Thigh']),
      // Right Thigh
      _buildHoverArea(105, 280, 25, 40, 'thigh', 'Thigh', widget.measurement?.measurements['Thigh']),
      // Left Inseam
      _buildHoverArea(75, 300, 15, 80, 'inseam', 'Inseam', widget.measurement?.inseam),
      // Right Inseam
      _buildHoverArea(110, 300, 15, 80, 'inseam', 'Inseam', widget.measurement?.inseam),
      // Left Calf
      _buildHoverArea(72, 340, 20, 30, 'calf', 'Calf', widget.measurement?.measurements['Calf']),
      // Right Calf
      _buildHoverArea(108, 340, 20, 30, 'calf', 'Calf', widget.measurement?.measurements['Calf']),
    ];
  }

  Widget _buildHoverArea(
    double left,
    double top,
    double width,
    double height,
    String part,
    String label,
    double? value,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          if (widget.isEditable) {
            _showMeasurementDialog(part, label, value);
          } else {
            _showReadOnlyInfo(part, label, value);
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoveredPart = part),
          onHover: (_) => setState(() => _hoveredPart = part),
          onExit: (_) => setState(() => _hoveredPart = null),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _hoveredPart == part
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.transparent,
              border: _hoveredPart == part
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementTooltip(String part) {
    final measurement = widget.measurement;
    if (measurement == null) return const SizedBox();

    String label;
    double? value;

    switch (part) {
      case 'neck':
        label = 'Neck';
        value = measurement.measurements['Neck'];
        break;
      case 'chest':
        label = 'Chest';
        value = measurement.chest; // Helper exists
        break;
      case 'shoulder':
        label = 'Shoulder';
        value = measurement.shoulder;
        break;
      case 'waist':
        label = 'Waist';
        value = measurement.waist;
        break;
      case 'hips':
        label = 'Hips';
        value = measurement.hips;
        break;
      case 'sleeve':
        label = 'Sleeve Length';
        value = measurement.sleeveLength;
        break;
      case 'shirt':
        label = 'Shirt Length';
        value = measurement.shirtLength;
        break;
      case 'pant':
        label = 'Trouser Length';
        value = measurement.pantLength;
        break;
      case 'inseam':
        label = 'Inseam';
        value = measurement.inseam;
        break;
      case 'bicep':
        label = 'Bicep';
        value = measurement.measurements['Bicep'];
        break;
      case 'wrist':
        label = 'Wrist';
        value = measurement.measurements['Wrist'];
        break;
      case 'thigh':
        label = 'Thigh';
        value = measurement.measurements['Thigh'];
        break;
      case 'calf':
        label = 'Calf';
        value = measurement.measurements['Calf'];
        break;
      default:
        return const SizedBox();
    }

    return Card(
      elevation: 8,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value != null ? '${value.toStringAsFixed(1)} inches' : 'Not measured',
              style: TextStyle(
                fontSize: 16,
                color: value != null ? Colors.green[700] : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isEditable)
              const SizedBox(height: 4),
            if (widget.isEditable)
              const Text(
                'Click to edit',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}

class DummyPainter extends CustomPainter {
  final String? hoveredPart;
  final models.Measurement? measurement;

  DummyPainter({this.hoveredPart, this.measurement});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Head
    canvas.drawCircle(Offset(size.width / 2, 30), 20, paint);
    canvas.drawCircle(Offset(size.width / 2, 30), 20, strokePaint);

    // Neck
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 10, 50, 20, 20),
      hoveredPart == 'neck'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );

    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 30, 70, 60, 120),
        const Radius.circular(10),
      ),
      hoveredPart == 'chest' || hoveredPart == 'waist' || hoveredPart == 'hips'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );

    // Shoulders
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 50, 70, 100, 20),
        const Radius.circular(10),
      ),
      hoveredPart == 'shoulder'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );

    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 90, 25, 100),
        const Radius.circular(10),
      ),
      hoveredPart == 'sleeve' || hoveredPart == 'bicep' || hoveredPart == 'wrist'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 35, 90, 25, 100),
        const Radius.circular(10),
      ),
      hoveredPart == 'sleeve' || hoveredPart == 'bicep' || hoveredPart == 'wrist'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );

    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 35, 190, 30, 150),
        const Radius.circular(10),
      ),
      hoveredPart == 'pant' || hoveredPart == 'thigh' || hoveredPart == 'inseam' || hoveredPart == 'calf'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 + 5, 190, 30, 150),
        const Radius.circular(10),
      ),
      hoveredPart == 'pant' || hoveredPart == 'thigh' || hoveredPart == 'inseam' || hoveredPart == 'calf'
          ? (Paint()..color = Colors.blue.withOpacity(0.3))
          : paint,
    );

    // Draw outline
    canvas.drawCircle(Offset(size.width / 2, 30), 20, strokePaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 10, 50, 20, 20),
      strokePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 30, 70, 60, 120),
        const Radius.circular(10),
      ),
      strokePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 50, 70, 100, 20),
        const Radius.circular(10),
      ),
      strokePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 90, 25, 100),
        const Radius.circular(10),
      ),
      strokePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 35, 90, 25, 100),
        const Radius.circular(10),
      ),
      strokePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 35, 190, 30, 150),
        const Radius.circular(10),
      ),
      strokePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 + 5, 190, 30, 150),
        const Radius.circular(10),
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

