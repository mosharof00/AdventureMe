import 'package:get/get.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final bool isUnread;
}

class NotificationSection {
  const NotificationSection({
    required this.label,
    required this.items,
  });

  final String label;
  final List<AppNotification> items;
}

class NotificationsController extends GetxController {
  final sections = const <NotificationSection>[
    NotificationSection(
      label: 'Today',
      items: [
        AppNotification(
          id: 'n1',
          title: 'Turn on Tracker',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
          isUnread: true,
        ),
        AppNotification(
          id: 'n2',
          title: '2 Views on Bali Tour',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
        ),
        AppNotification(
          id: 'n3',
          title: 'Itinerary Notification',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
        ),
      ],
    ),
    NotificationSection(
      label: 'Yesterday',
      items: [
        AppNotification(
          id: 'n4',
          title: 'Turn on Tracker',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
          isUnread: true,
        ),
        AppNotification(
          id: 'n5',
          title: '2 Views on Bali Tour',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
        ),
        AppNotification(
          id: 'n6',
          title: 'Itinerary Notification',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
        ),
        AppNotification(
          id: 'n7',
          title: '2 Views on Bali Tour',
          body: 'Turn on your location to let the tracking happen!',
          timeAgo: '18 minutes ago',
        ),
      ],
    ),
  ];

  void onNotificationTap(AppNotification notification) {
    // UI only for now
  }
}
