import 'package:flutter/material.dart';

class ExperiencePackage {
  const ExperiencePackage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.rating,
    required this.durationMinutes,
    required this.imageAsset,
    required this.tags,
  });

  final String id;
  final String title;
  final String subtitle;
  final double price;
  final double rating;
  final int durationMinutes;
  final String imageAsset;
  final List<String> tags;
}

class ExperienceBundle {
  const ExperienceBundle({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageAsset;
}

class OrderProgressStep {
  const OrderProgressStep({
    required this.label,
    required this.description,
    required this.timestamp,
  });

  final String label;
  final String description;
  final DateTime timestamp;
}

class LiveOrder {
  LiveOrder({
    required this.orderNumber,
    required this.status,
    required this.eta,
    required this.progress,
    required this.steps,
    required this.courierName,
    required this.courierVehicle,
    required this.courierRating,
  });

  final String orderNumber;
  final String status;
  final DateTime eta;
  final double progress;
  final List<OrderProgressStep> steps;
  final String courierName;
  final String courierVehicle;
  final double courierRating;
}

class MerchantKpi {
  const MerchantKpi({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
  });

  final String label;
  final String value;
  final String trend;
  final IconData icon;
}

class MerchantOrderSummary {
  const MerchantOrderSummary({
    required this.orderNumber,
    required this.customer,
    required this.total,
    required this.items,
    required this.status,
  });

  final String orderNumber;
  final String customer;
  final String total;
  final int items;
  final String status;
}

class CourierAssignment {
  const CourierAssignment({
    required this.id,
    required this.pickup,
    required this.dropOff,
    required this.distanceKm,
    required this.eta,
    required this.status,
  });

  final String id;
  final String pickup;
  final String dropOff;
  final double distanceKm;
  final DateTime eta;
  final String status;
}

class AdminInsight {
  const AdminInsight({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.highlight,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String highlight;
}

class SampleData {
  static List<ExperiencePackage> featuredExperiences() => const [
        ExperiencePackage(
          id: 'exp-aurora',
          title: 'Aurora Canopy Dining',
          subtitle: 'Taste bioluminescent cuisine under northern lights.',
          price: 42,
          rating: 4.9,
          durationMinutes: 90,
          imageAsset: 'assets/images/app.jpg',
          tags: ['signature', 'immersive'],
        ),
        ExperiencePackage(
          id: 'exp-savannah',
          title: 'Savannah Sunrise Safari',
          subtitle: 'Ride with our AI ranger through sunrise migrations.',
          price: 36,
          rating: 4.8,
          durationMinutes: 75,
          imageAsset: 'assets/images/lion.jpg',
          tags: ['family', 'live'],
        ),
        ExperiencePackage(
          id: 'exp-reef',
          title: 'Coral Reef Chef\'s Table',
          subtitle: 'Interactive cooking with ocean conservation stories.',
          price: 28,
          rating: 4.7,
          durationMinutes: 60,
          imageAsset: 'assets/images/placeholder3.jpg',
          tags: ['sustainable'],
        ),
      ];

  static List<ExperienceBundle> curatedBundles() => const [
        ExperienceBundle(
          id: 'bundle-family',
          name: 'Family Discovery Trio',
          description: 'Evening safari + kid-friendly tasting menu + VR keeper chat.',
          price: 68,
          imageAsset: 'assets/images/tiger.jpg',
        ),
        ExperienceBundle(
          id: 'bundle-chef',
          name: 'Chef\'s Field Notes',
          description: 'Progressive dinner with behind-the-scenes kitchen stream.',
          price: 54,
          imageAsset: 'assets/images/elephant.jpg',
        ),
        ExperienceBundle(
          id: 'bundle-night',
          name: 'Night Habitat Immersion',
          description: 'Nocturnal expedition with sensory dining pairing.',
          price: 61,
          imageAsset: 'assets/images/giraffe.jpg',
        ),
      ];

  static LiveOrder activeOrder() {
    final now = DateTime.now();
    return LiveOrder(
      orderNumber: '#VW-2048',
      status: 'En route',
      eta: now.add(const Duration(minutes: 24)),
      progress: 0.68,
      steps: [
        OrderProgressStep(
          label: 'Order confirmed',
          description: 'VR safari pack locked in with Jungle Feast.',
          timestamp: now.subtract(const Duration(minutes: 14)),
        ),
        OrderProgressStep(
          label: 'Kitchen prepping',
          description: 'Chef Armand plating bioluminescent amuse-bouche.',
          timestamp: now.subtract(const Duration(minutes: 9)),
        ),
        OrderProgressStep(
          label: 'Courier picked up',
          description: 'Amelia scanned smart locker at Riverside hub.',
          timestamp: now.subtract(const Duration(minutes: 4)),
        ),
        OrderProgressStep(
          label: 'Arriving soon',
          description: 'Estimated arrival in under 10 minutes.',
          timestamp: now.add(const Duration(minutes: 6)),
        ),
      ],
      courierName: 'Amelia Chen',
      courierVehicle: 'E-bike',
      courierRating: 4.9,
    );
  }

  static List<MerchantKpi> merchantKpis() => const [
        MerchantKpi(
          label: 'Revenue',
          value: '\$12.4k',
          trend: '+18% vs last week',
          icon: Icons.payments_outlined,
        ),
        MerchantKpi(
          label: 'Avg. prep time',
          value: '14 min',
          trend: '-2 min vs target',
          icon: Icons.timer_outlined,
        ),
        MerchantKpi(
          label: 'Live orders',
          value: '8',
          trend: '3 high-priority',
          icon: Icons.local_fire_department_outlined,
        ),
      ];

  static List<MerchantOrderSummary> merchantOrders() => const [
        MerchantOrderSummary(
          orderNumber: '#VW-2041',
          customer: 'Noah R.',
          total: '\$32.00',
          items: 3,
          status: 'Ready',
        ),
        MerchantOrderSummary(
          orderNumber: '#VW-2042',
          customer: 'Priya S.',
          total: '\$58.00',
          items: 4,
          status: 'Preparing',
        ),
        MerchantOrderSummary(
          orderNumber: '#VW-2043',
          customer: 'Liam K.',
          total: '\$24.50',
          items: 2,
          status: 'Scheduled',
        ),
      ];

  static List<CourierAssignment> courierAssignments() {
    final now = DateTime.now();
    return [
      CourierAssignment(
        id: '#DEL-981',
        pickup: 'Riverfront Cloud Kitchen',
        dropOff: 'Vision Week Dome 3',
        distanceKm: 4.2,
        eta: now.add(const Duration(minutes: 12)),
        status: 'In progress',
      ),
      CourierAssignment(
        id: '#DEL-982',
        pickup: 'Wildlife Bistro',
        dropOff: 'Habitat Lab 2',
        distanceKm: 3.1,
        eta: now.add(const Duration(minutes: 28)),
        status: 'Queued',
      ),
      CourierAssignment(
        id: '#DEL-983',
        pickup: 'Botanical Test Kitchen',
        dropOff: 'Admin HQ',
        distanceKm: 5.6,
        eta: now.add(const Duration(minutes: 42)),
        status: 'Queued',
      ),
    ];
  }

  static List<AdminInsight> adminInsights() => const [
        AdminInsight(
          title: 'Platform health',
          subtitle: '99.96% uptime over last 24h with 2 minor incidents.',
          icon: Icons.health_and_safety_outlined,
          highlight: 'SLA on track',
        ),
        AdminInsight(
          title: 'Engagement pulse',
          subtitle: 'Explorer NPS 68 (+6). Seller churn down 3% week-over-week.',
          icon: Icons.analytics_outlined,
          highlight: 'Growth sprint ready',
        ),
        AdminInsight(
          title: 'Security posture',
          subtitle: 'All secrets rotated. 0 outstanding high-risk findings.',
          icon: Icons.shield_moon_outlined,
          highlight: 'Green',
        ),
      ];
}
