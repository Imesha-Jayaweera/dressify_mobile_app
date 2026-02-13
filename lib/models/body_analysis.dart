class BodyAnalysis {
  final String gender;
  final String skinColor;
  final String bodyType;
  final double? heightCm;
  final double? widthCm;

  BodyAnalysis({
    required this.gender,
    required this.skinColor,
    required this.bodyType,
    this.heightCm,
    this.widthCm,
  });

  factory BodyAnalysis.fromJson(Map<String, dynamic> json) {
    return BodyAnalysis(
      gender: json['gender'] ?? 'female',
      skinColor: json['skin_color'] ?? 'medium',
      bodyType: json['body_type'] ?? 'rectangle',
      heightCm: json['height_cm']?.toDouble(),
      widthCm: json['width_cm']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'skin_color': skinColor,
      'body_type': bodyType,
      'height_cm': heightCm,
      'width_cm': widthCm,
    };
  }
}