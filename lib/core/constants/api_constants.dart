/// CosmoKundli API endpoints for the CosmoGuru app. Same server and
/// contracts as MyAcharyaji, but planner reports bought directly from
/// CosmoGuru live behind the `_Cosmo` endpoints, keyed by user only —
/// there is no Acharyaji code.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://software.cosmokundli.com/API/';

  // Auth
  static const String sendOtp = 'SendOTP';
  static const String verifyOtp = 'VerifyOTP';

  // Profile
  static const String profileDetails = 'ProfileDetails';
  static const String profileUpdate = 'ProfileUpdate';

  // Content
  static const String guideline = 'Guidline';
  static const String faq = 'FAQ';
  static const String generalPrediction = 'GenralPredction';

  // Planner (CV Planner 5D) — CosmoGuru direct purchases
  static const String monthlyData = 'GetMonthData_Cosmo';
  static const String weeklyData = 'GetWeekData_Cosmo';
  static const String dailyData = 'GetDailyData_Cosmo';
  static const String reportList = 'GetReportList_Cosmo';

  /// Contact-us form on cosmoguru.com (absolute URL, different host).
  /// Body: name, email, mobile_no, problem_type, message.
  /// Reply: {success: bool, message: String}.
  static const String addContact = 'https://cosmoguru.com/Cosmo_app_api/add_contact';
}

/// CosmoGuru contact details and links.
class Brand {
  Brand._();

  static const name = 'CosmoGuru';
  static const tagline = 'Guiding Life';
  static const phone = '+919727244666';
  static const phoneDisplay = '+91 97272 44666';
  static const whatsapp = '919727244666';
  static const email = 'Sampark@CosmoGuru.com';
  static const website = 'https://cosmoguru.com';
  static const websiteDisplay = 'CosmoGuru.com';
  static const termsUrl = 'https://cosmoguru.com/term-condition-mobile';
  static const reportsUrl = 'https://cosmoguru.com';
  static const coursesUrl = 'https://cosmoguru.com';
  static const youtubeCosmoGuru = 'https://www.youtube.com/@CosmoGuruGL';
  static const youtubeCvpt = 'https://www.youtube.com/@CVPTOfficial';

  /// Problem types accepted by the contact form (from the original app).
  static const problemTypes = [
    'App Problem',
    'Bug Found',
    'Wrong Data Showing',
    'App Crashes',
    'Subscription Related',
    'Other',
  ];
}
