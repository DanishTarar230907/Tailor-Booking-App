import '../database_helper.dart';
import '../models/tailor.dart' as models;
import '../models/design.dart' as models;
import '../models/complaint.dart' as models;
import '../models/booking.dart' as models;

class SeedDataService {
  static Future<void> seedData() async {
    final db = DatabaseHelper.instance.database;
    
    // Check if data already exists
    final existingTailor = await db.getTailor();
    if (existingTailor != null) {
      // Data already seeded
      return;
    }

    // Seed Tailor
    final tailor = models.Tailor(
      name: 'John Tailor',
      photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      description: 'Professional tailor with 10+ years of experience. Specializing in custom suits, dresses, and alterations.',
    );
    await db.insertOrUpdateTailor(tailor);

    // Seed Designs
    final designs = [
      models.Design(
        title: 'Classic Business Suit',
        photo: 'https://images.unsplash.com/photo-1594938291221-94f18cbb7080?w=400',
        price: 299.99,
      ),
      models.Design(
        title: 'Elegant Evening Dress',
        photo: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
        price: 399.99,
      ),
      models.Design(
        title: 'Casual Blazer',
        photo: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        price: 199.99,
      ),
      models.Design(
        title: 'Wedding Gown',
        photo: 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=400',
        price: 599.99,
      ),
      models.Design(
        title: 'Formal Tuxedo',
        photo: 'https://images.unsplash.com/photo-1624378515193-8e47799b0d3a?w=400',
        price: 349.99,
      ),
    ];

    for (final design in designs) {
      await db.insertDesign(design);
    }

    // Seed Complaints with replies
    final complaints = [
      models.Complaint(
        customerName: 'Alice Smith',
        customerEmail: 'alice@example.com',
        message: 'The suit I ordered arrived with a small tear. Can this be fixed?',
        reply: 'We apologize for the inconvenience. Please bring it to our shop and we will fix it free of charge.',
        isResolved: true,
      ),
      models.Complaint(
        customerName: 'Bob Johnson',
        customerEmail: 'bob@example.com',
        message: 'The dress size was slightly off. Can I get it adjusted?',
        reply: 'Absolutely! We offer free alterations within 30 days of purchase. Please visit us at your convenience.',
        isResolved: true,
      ),
      models.Complaint(
        customerName: 'Charlie Brown',
        customerEmail: 'charlie@example.com',
        message: 'When will my custom suit be ready?',
        reply: null,
        isResolved: false,
      ),
    ];

    for (final complaint in complaints) {
      await db.insertComplaint(complaint);
    }

    // Seed Bookings
    final bookings = [
      models.Booking(
        customerName: 'Alice Smith',
        customerEmail: 'alice@example.com',
        customerPhone: '+1234567890',
        bookingDate: DateTime.now().add(const Duration(days: 3)),
        timeSlot: '09:00-11:00',
        suitType: 'Formal Suit',
        isUrgent: false,
        charges: 299.99,
        status: 'approved',
        tailorNotes: 'Ready for fitting',
      ),
      models.Booking(
        customerName: 'Bob Johnson',
        customerEmail: 'bob@example.com',
        customerPhone: '+1234567891',
        bookingDate: DateTime.now().add(const Duration(days: 5)),
        timeSlot: '11:00-13:00',
        suitType: 'Wedding Suit',
        isUrgent: true,
        charges: 449.99,
        status: 'pending',
        specialInstructions: 'Need it before wedding on Saturday',
      ),
      models.Booking(
        customerName: 'Charlie Brown',
        customerEmail: 'charlie@example.com',
        customerPhone: '+1234567892',
        bookingDate: DateTime.now().add(const Duration(days: 7)),
        timeSlot: '13:00-15:00',
        suitType: 'Tuxedo',
        isUrgent: false,
        charges: 299.99,
        status: 'pending',
      ),
    ];

    for (final booking in bookings) {
      await db.insertBooking(booking);
    }
  }
}

