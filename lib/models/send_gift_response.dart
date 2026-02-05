class SendGiftResponse {
  final String message;
  final int maleCoinBalance;
  final int femaleWalletBalance;

  SendGiftResponse({
    required this.message,
    required this.maleCoinBalance,
    required this.femaleWalletBalance,
  });

  factory SendGiftResponse.fromJson(Map<String, dynamic> json) {
    return SendGiftResponse(
      message: json['message'] as String,
      maleCoinBalance: json['data']['maleCoinBalance'] as int,
      femaleWalletBalance: json['data']['femaleWalletBalance'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': {
        'maleCoinBalance': maleCoinBalance,
        'femaleWalletBalance': femaleWalletBalance,
      },
    };
  }
}
