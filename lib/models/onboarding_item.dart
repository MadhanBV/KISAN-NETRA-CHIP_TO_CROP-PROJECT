/// Model representing an individual onboarding screen's content.
class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final String imageSemanticLabel;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.imageSemanticLabel,
  });
}

