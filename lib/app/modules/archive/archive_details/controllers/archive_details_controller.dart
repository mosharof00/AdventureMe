import 'package:get/get.dart';
import 'package:adventureme/app/modules/archive/controllers/archive_controller.dart';

class ArchiveSummaryItem {
  const ArchiveSummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class ArchiveStorySection {
  const ArchiveStorySection({
    required this.title,
    this.dateTime,
    this.tag,
    this.body,
    this.quote,
    this.images = const [],
    this.caption,
  });

  final String title;
  final String? dateTime;
  final String? tag;
  final String? body;
  final String? quote;
  final List<String> images;
  final String? caption;
}

class ArchiveDetailsController extends GetxController {
  ArchiveStory? story;

  final isSummaryExpanded = true.obs;

  bool isVerified = true;

  String get authorName => story?.authorName ?? 'Jack Kargille';
  String get authorAvatar =>
      story?.authorAvatar ?? 'https://randomuser.me/api/portraits/men/32.jpg';

  final summaryItems = const [
    ArchiveSummaryItem(
      label: 'Location Explored',
      value:
          'Total of 6 location has been explored. Canggu, Seminyak, Legian, Kuta, Uluwatu, Sanur',
    ),
    ArchiveSummaryItem(
      label: 'Miles Traveled',
      value: 'Total of 143 miles traveled from Canggu to Sanur.',
    ),
    ArchiveSummaryItem(
      label: 'Most Photographed Location',
      value: 'Seminyak | 32 Photo',
    ),
    ArchiveSummaryItem(
      label: 'Total Duration',
      value: 'From March 10 to March 17, 2026',
    ),
  ];

  final sections = const [
    ArchiveStorySection(
      dateTime: 'Mar 11, 2026, 10:30 PM - 12:00 AM',
      title: 'Arrival in Bali',
      body:
          'We arrived before the island had fully woken. The air at the airport smelled of incense and frangipani, a combination I would come to associate with every waking morning. Our driver, Made, spoke little but pointed out landmarks with a kind of reverent pride — temples half-swallowed by banyan trees, roadside shrines adorned with fresh offerings of rice and marigold. By the time we reached Ubud, I understood that Bali does not reveal itself all at once. It asks you to slow down.',
    ),
    ArchiveStorySection(
      tag: 'BEST MOMENT',
      title: 'The moment we found, Bali beach is glittering!',
      quote:
          '"With friends and foe, Bali makes all of you enjoy the scenic view and make you more than friend!"',
      images: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
        'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?w=800',
      ],
      caption:
          "A temple ceremony in Ubud — Bali's spiritual calendar means there is always something sacred happening somewhere.",
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ArchiveStory) story = args;
  }

  void toggleSummary() => isSummaryExpanded.toggle();

  void onShare() {}
  void onScan() {}
  void onViewLocations() {}
  void onViewDetails() {}
}
