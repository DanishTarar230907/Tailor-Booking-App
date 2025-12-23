// Enhanced Customer Dashboard Helper Methods
// Add these methods to _EnhancedCustomerDashboardState class

// ENHANCED PICKUP SECTION WITH FORM
Widget _buildEnhancedPickupSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Pickup Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showPickupRequestDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Pickup requests list
        if (_myPickupRequests.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No pickup requests yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a request to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myPickupRequests.length,
            itemBuilder: (context, index) {
              final request = _myPickupRequests[index];
              return _buildEnhancedPickupCard(request);
            },
          ),
      ],
    ),
  );
}

Widget _buildEnhancedPickupCard(models.PickupRequest request) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    request.pickupType == 'online_order'
                        ? Icons.shopping_bag
                        : Icons.local_shipping,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    request.pickupType == 'online_order'
                        ? 'Online Order'
                        : 'Manual Delivery',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: request.status, type: 'pickup'),
            ],
          ),
          const SizedBox(height: 12),

          // Details
          if (request.description != null && request.description!.isNotEmpty) ...[
            Text(
              request.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tracking info
          if (request.courierName != null || request.trackingNumber != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.courierName != null) ...[
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Courier: ${request.courierName}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                  if (request.trackingNumber != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.qr_code, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Tracking: ${request.trackingNumber}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Dates
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Expected: ${DateFormat('MMM d, y').format(request.expectedDeliveryDate ?? request.requestedDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),

          // Tailor notes (if any)
          if (request.tailorNotes != null && request.tailorNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tailor Notes:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.tailorNotes!,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

void _showPickupRequestDialog() {
  String pickupType = 'manual_delivery';
  final courierController = TextEditingController();
  final trackingController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();
  DateTime? expectedDate;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'New Pickup Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Type Selection
              const Text(
                'Pickup Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Online Order', style: TextStyle(fontSize: 13)),
                      value: 'online_order',
                      groupValue: pickupType,
                      onChanged: (value) => setState(() => pickupType = value!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Manual', style: TextStyle(fontSize: 13)),
                      value: 'manual_delivery',
                      groupValue: pickupType,
                      onChanged: (value) => setState(() => pickupType = value!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Courier Name
              TextField(
                controller: courierController,
                decoration: InputDecoration(
                  labelText: 'Courier/Platform (e.g., Leopards, TCS)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.local_shipping),
                ),
              ),
              const SizedBox(height: 12),

              // Tracking Number
              TextField(
                controller: trackingController,
                decoration: InputDecoration(
                  labelText: 'Tracking Number (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 12),

              // Expected Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    setState(() => expectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expected Delivery Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    expectedDate != null
                        ? DateFormat('MMM d, y').format(expectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: expectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (e.g., "3-piece suit fabric")',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_customerName == null || _customerEmail == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer information not available')),
                );
                return;
              }

              final request = models.PickupRequest(
                customerName: _customerName!,
                customerEmail: _customerEmail!,
                customerPhone: _customerPhone ?? '',
                requestType: pickupType,
                pickupAddress: '', // Can be added if needed
                charges: 0.0,
                requestedDate: DateTime.now(),
                pickupType: pickupType,
                expectedDeliveryDate: expectedDate,
                courierName: courierController.text.isNotEmpty ? courierController.text : null,
                trackingNumber: trackingController.text.isNotEmpty ? trackingController.text : null,
                description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              );

              try {
                await _pickupService.addRequest(request);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Pickup request sent to tailor successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    ),
  );
}
