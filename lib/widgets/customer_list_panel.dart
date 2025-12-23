import 'package:flutter/material.dart';
import '../models/measurement.dart';
import 'package:intl/intl.dart';

class CustomerListPanel extends StatefulWidget {
  final List<Measurement> measurements;
  final String? selectedId;
  final Function(String) onSelect;

  const CustomerListPanel({
    super.key,
    required this.measurements,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<CustomerListPanel> createState() => _CustomerListPanelState();
}

class _CustomerListPanelState extends State<CustomerListPanel> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  List<Measurement> get _filteredCustomers {
    // 1. Group by customer (email/phone/id key) to show unique customers
    // The requirement is "Customer List". If a customer has multiple measurements, 
    // we likely want the most recent one or a summary.
    // For simplicity, let's show all *Measurement* entries if they represent active requests,
    // OR deduplicate by CustomerName/Email.
    // Let's deduplicate by CustomerEmail or Phone, preferring the most recent update.
    
    final Map<String, Measurement> unique = {};
    for (var m in widget.measurements) {
      final key = m.customerEmail.isNotEmpty ? m.customerEmail : m.customerName;
      if (!unique.containsKey(key)) {
        unique[key] = m;
      } else {
        // Keep the one with more recent activity
        final existing = unique[key]!;
        final newDate = m.updatedAt ?? m.createdAt;
        final existingDate = existing.updatedAt ?? existing.createdAt;
        if (newDate.isAfter(existingDate)) {
           unique[key] = m;
        }
      }
    }
    
    var list = unique.values.toList();

    // 2. Filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((m) => 
        m.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        m.customerEmail.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // 3. Sort by last active
    list.sort((a, b) {
       // Priority: Update Requested -> Recent Date
       if (a.updateRequested && !b.updateRequested) return -1;
       if (!a.updateRequested && b.updateRequested) return 1;
       
       final da = a.updatedAt ?? a.createdAt;
       final db = b.updatedAt ?? b.createdAt;
       return db.compareTo(da);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final primaryColor = Colors.indigo;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search ...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final m = _filteredCustomers[index];
                final isSelected = widget.selectedId == m.docId; // Using docId of the representative measurement
                final lastActive = m.updatedAt ?? m.createdAt;
                final dateStr = DateFormat('MMM d, h:mm a').format(lastActive);

                return Material(
                  color: isSelected ? Colors.indigo.withOpacity(0.05) : Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onSelect(m.docId!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isSelected ? primaryColor : Colors.grey.shade200,
                                foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
                                child: Text(
                                  m.customerName.isNotEmpty ? m.customerName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (m.updateRequested)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.customerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isSelected ? primaryColor : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    // Status Badge (Mini)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getStatusColor(m.status),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      m.status,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _timeAgo(lastActive),
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.amber;
      case 'accepted': return Colors.green;
      case 'completed': return Colors.blue;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  String _timeAgo(DateTime d) {
    return DateFormat('MMM d').format(d); // Simplified for now
  }
}
