class ApiEndPoints {
  static const String baseUrl = "https://friend-circle-new.vercel.app";
  static const String dashboardEndpoint = '/male-user/dashboard';

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
  static const String maleBlockList = "/male-user/block-list";
  static const String maleUnblock = "/male-user/unblock";
  static const String maleBlock = "/male-user/block";
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
}
