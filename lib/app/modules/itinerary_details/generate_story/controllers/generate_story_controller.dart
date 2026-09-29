import 'package:get/get.dart';

class StorySection {
  const StorySection({
    required this.title,
    this.body,
    this.quote,
    this.images = const [],
  });

  final String title;
  final String? body;
  final String? quote;
  final List<String> images;
}

class GenerateStoryController extends GetxController {
  final authorName = 'Abu Ryan';
  final daywiseItinerary = true.obs;

  final heroImages = const [
    'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400',
    'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=400',
    'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
  ];

  final placeVisited =
      'Bali, Indonesia has been my main... Canggu, Keramas, yes, Bali is a lovely Place';
  final mostVisited = 'I visited botanical garden near Bedugul, Bali.';
  final totalDistance = 'Between 10 - 20 km';
  final totalDuration = 'June 14, 2021 to March 16, 2021';

  final sections = const [
    StorySection(
      title: 'Arrival in Bali',
      body:
          'Landing in Bali felt like stepping into a postcard. The warm air, the scent of incense, and the soft chaos of arrivals set the tone for days of discovery ahead.',
    ),
    StorySection(
      title: 'The moment we found, Bali beach is glittering!',
      quote: 'The ocean painted silver under the sunset while laughter filled the shore.',
      images: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800',
      ],
    ),
    StorySection(
      title: 'Cycle ride by the bay of Bali',
      quote: 'Pedaling past palm trees, every turn revealed another quiet pocket of paradise.',
      images: [
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      ],
    ),
    StorySection(
      title: 'A sudden cultural glimpse of Bali!',
      quote: 'Colors, chants, and ceremony — Bali shared its heart without saying a word.',
      images: [
        'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=800',
      ],
    ),
    StorySection(
      title: 'Enjoying forest view from Mocha...',
      quote: 'Through a wooden circle, green hills rolled endlessly into the mist.',
      images: [
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      ],
    ),
  ];

  void toggleDaywise(bool value) => daywiseItinerary.value = value;

  void onShare() {}
  void onCalendar() {}
  void onStories() {}
  void onPreview() {}
  void onRegenerateStory() {}
}
