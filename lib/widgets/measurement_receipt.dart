import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../models/measurement.dart';
import '../utils/saver.dart'; // Cross-platform saver

class MeasurementReceipt extends StatefulWidget {
  final Measurement measurement;
  final String? tailorName;
  final String? tailorPhone;

  const MeasurementReceipt({
    super.key,
    required this.measurement,
    this.tailorName,
    this.tailorPhone,
  });

  @override
  State<MeasurementReceipt> createState() => _MeasurementReceiptState();
}

class _MeasurementReceiptState extends State<MeasurementReceipt> {
  final GlobalKey _boundaryKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Take a screenshot to save',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Receipt Container
              RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  width: 400, // Fixed width for receipt-like feel
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0), // Sharp edges like paper receipts usually have? Or rounded per requirement? Req says rounded.
                    // Req: Centered card, Rounded corners, Soft shadow.
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Rounded as requested
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                          ),
                          child: Column(
                            children: [
                              // Logo/Name
                              Icon(Icons.content_cut, size: 40, color: Colors.teal[800]),
                              const SizedBox(height: 12),
                              Text(
                                widget.tailorName ?? 'Grace Tailor Studio',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[900],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'MEASUREMENT RECEIPT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.now()),
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        
                        // Dashed Separator
                        _buildDashedLine(),

                        // Customer Info
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('CUSTOMER', widget.measurement.customerName),
                              const SizedBox(height: 8),
                              if (widget.measurement.customerPhone != null)
                                _buildInfoRow('PHONE', widget.measurement.customerPhone!),
                              const SizedBox(height: 8),
                              _buildInfoRow('STATUS', widget.measurement.status.toUpperCase(), isStatus: true),
                            ],
                          ),
                        ),

                        // Measurements
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          color: Colors.purple[50]!.withOpacity(0.5),
                          child: Text(
                            'MEASUREMENT DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: widget.measurement.measurements.entries.map((e) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${e.value.toStringAsFixed(1)} in',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Notes
                        if (widget.measurement.notes != null && widget.measurement.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NOTES', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.measurement.notes!,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[800], fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Footer
                        Container(
                          color: Colors.grey[50],
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Thank you for choosing us!',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800]),
                              ),
                              const SizedBox(height: 8),
                              if (widget.tailorPhone != null)
                                Text(
                                  'Contact: ${widget.tailorPhone}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              const SizedBox(height: 16),
                              Container(
                                height: 4,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        isStatus 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: value == 'PENDING' ? Colors.orange[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: value == 'PENDING' ? Colors.orange[800] : Colors.green[800],
                ),
              ),
            )
          : Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey[300]),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
