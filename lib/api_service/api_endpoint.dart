class ApiEndPoints {
  static const String startCall = '/male-user/calls/start';
  static const String checkCallStatus =
      '/male-user/calls'; // Will append /:callId/status
  static const String endCall = '/male-user/calls/end';
  static const String callHistory = '/male-user/calls/history';
  static const String callStats = '/male-user/calls/stats';
  static const String baseUrls = "https://friend-circle-new.vercel.app";
  static const String dashboardEndpoint = '/male-user/dashboard';
  static const String chatRooms = "/chat/rooms";
  static const String chatStart = "/chat/start";
  static const String chatRoom = "/chat/room";
  static const String chatSend = "/chat/send";
  static const String chatUpload = "/chat/upload";
  static const String chatMessages = "/chat"; // Will append /:chatRoomId/messages
  static const String chatClear = "/chat/room"; // Will append /:roomId/clear
  static const String chatMessage = "/chat/message"; // For single message delete
  static const String chatMarkRead = "/chat/mark-as-read";
  static const String chatDisappearing = "/chat"; // Will append /:roomId/disappearing
  static const String maleBlockList = "/male-user/block-list";
  static const String maleBlockAction = "/male-user/block-list/block";
  static const String maleUnblockAction = "/male-user/block-list/unblock";

  // Male auth & profile
  static const String signupMale = "/male-user/register";
  static const String verifyOtpMale = "/male-user/verify-otp";
  static const String loginMale = "/male-user/login";
  static const String loginotpMale = "/male-user/verify-login-otp";
  static const String profiledetailsMale = "/male-user/add-info";
  static const String maleProfileDetails = "/male-user/profile-details";
  static const String uploadImageMale = "/male-user/upload-image";
  static const String deleteAccountMale = "/male-user/account";
  static const String maleMe = '/male-user/me';
  static const String maleUploadImages = '/male-user/upload-images';
  static const String maleInterests = "/male-user/interests";
  static const String maleLanguages = "/male-user/languages";
  static const String fetchfemaleusers = "/male-user/browse-females";

  // Male follow/unfollow
  static const String maleUnfollow = "/male-user/unfollow";
  static const String maleFollowing = "/male-user/following";
  static const String maleFollowers = "/male-user/followers";
  static const String maleAddFavourite = "/male-user/add-favourite";
  static const String maleRemoveFavourite = "/male-user/remove-favourite";
  static const String maleFollowSend = "/male-user/follow-request/send";
  static const String maleFollowCancel = "/male-user/follow-request/cancel";
  static const String maleFollowRequestsSent = "/male-user/follow-requests/sent";

  // Female auth & profile
  static const String signup = "/female-user/register";
  static const String verifyOtp = "/female-user/verify-otp";
  static const String login = "/female-user/login";
  static const String loginotp = "/female-user/verify-login-otp";
  static const String profiledetails = "/female-user/add-info";

  // Wallet/Payment
  static const String maleWalletRecharge = "/male-user/payment/wallet/order";

  static const String maleProfileAndImage = '/male-user/profile-and-image';

  // Male interests endpoints
  static const String maleSports = '/male-user/sports';
  static const String maleFilm = '/male-user/film';
  static const String maleMusic = '/male-user/music';
  static const String maleTravel = '/male-user/travel';
  
  // Payment
  static const String coinOrder = '/male-user/payment/coin/order';
  static const String paymentVerify = '/male-user/payment/verify';
  static const String paymentPackages = '/male-user/payment/packages';
  static const String walletTransactions = '/male-user/wallet/transactions';
}
