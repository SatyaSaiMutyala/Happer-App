class CodeCredit {
  final int credits;
  final String? code;

  CodeCredit({
    required this.credits,
    this.code,
  });

  factory CodeCredit.fromJson(Map<String, dynamic> json) {
    return CodeCredit(
      credits: json['credits'] ?? 0,
      code: json['code'],
    );
  }
}
