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
          title: 'Brand + UI/UX Sprint',
          subtitle: 'Design a conversion-ready landing flow in 10 days.',
          price: 1200,
          rating: 5.0,
          durationMinutes: 600,
          imageAsset: 'assets/images/app.jpg',
          tags: ['strategy', 'ui/ux'],
        ),
        ExperiencePackage(
          id: 'exp-savannah',
          title: 'Full-stack MVP Build',
          subtitle: 'Ship a production-ready web app with analytics.',
          price: 3200,
          rating: 4.9,
          durationMinutes: 900,
          imageAsset: 'assets/images/lion.jpg',
          tags: ['flutter', 'backend'],
        ),
        ExperiencePackage(
          id: 'exp-reef',
          title: 'AI Workflow Automation',
          subtitle: 'Automate ops with smart agents and dashboards.',
          price: 1800,
          rating: 4.8,
          durationMinutes: 480,
          imageAsset: 'assets/images/placeholder3.jpg',
          tags: ['ai', 'automation'],
        ),
      ];

  static List<ExperienceBundle> curatedBundles() => const [
        ExperienceBundle(
          id: 'bundle-family',
          name: 'Launch Ready Bundle',
          description: 'Brand system, UX flows, and a responsive website.',
          price: 4200,
          imageAsset: 'assets/images/tiger.jpg',
        ),
        ExperienceBundle(
          id: 'bundle-chef',
          name: 'Product Growth Bundle',
          description: 'Growth experiments, analytics setup, and funnel copy.',
          price: 2600,
          imageAsset: 'assets/images/elephant.jpg',
        ),
        ExperienceBundle(
          id: 'bundle-night',
          name: 'Founder Support Retainer',
          description: 'Monthly design, dev, and rapid experimentation.',
          price: 3400,
          imageAsset: 'assets/images/giraffe.jpg',
        ),
      ];

  static LiveOrder activeOrder() {
    final now = DateTime.now();
    return LiveOrder(
      orderNumber: '#QEA-042',
      status: 'In delivery',
      eta: now.add(const Duration(days: 4)),
      progress: 0.72,
      steps: [
        OrderProgressStep(
          label: 'Discovery complete',
          description: 'Goals, constraints, and timeline aligned.',
          timestamp: now.subtract(const Duration(days: 6)),
        ),
        OrderProgressStep(
          label: 'Prototype delivered',
          description: 'Interactive Figma flow ready for review.',
          timestamp: now.subtract(const Duration(days: 4)),
        ),
        OrderProgressStep(
          label: 'Build sprint underway',
          description: 'Frontend + API integration in progress.',
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        OrderProgressStep(
          label: 'QA + launch plan',
          description: 'Hand-off docs and training scheduled.',
          timestamp: now.add(const Duration(days: 2)),
        ),
      ],
      courierName: 'Kevin B.',
      courierVehicle: 'Remote',
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
