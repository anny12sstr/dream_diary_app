abstract class AppStrings {
  const AppStrings._(); // Приватний конструктор

  // --- Загальні ---
  static const String appTitle = 'Dream Diary';

  // --- Навігація / Header ---
  static const String navDashboard = 'Dashboard';
  static const String navAddDream = 'Add Dream';
  static const String navAnalytics = 'Analytics';
  static const String navViewDream = 'View Dream';
  static const String navEditDream = 'Edit Dream';
  static const String titleLabel = 'Dream Title';

  // --- Екран логіну ---
  static const String loginTitle = 'Log In';
  static const String loginWelcome = 'Welcome back! Please sign in to your account';
  static const String loginButton = 'Log In';
  static const String rememberMe = 'Remember me';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account? ";
  static const String signUpLink = 'Sign up';
  static const String orContinueWith = 'Or continue with';
  static const String googleButton = 'Google';
  static const String appleButton = 'Apple';
  static const String loginErrorGoogleCancelled = 'Sign-in cancelled.';
  static const String loginErrorGoogleFailed = 'Google sign-in failed. Please try again.';
  

  // --- Екран реєстрації ---
  static const String signUpTitle = 'Sign Up';
  static const String signUpButton = 'Register';
  static const String hasAccount = 'Already have an account? ';
  static const String loginLink = 'Log in';

  // --- Екран "Забули пароль" ---
  static const String forgotPasswordTitle = 'Reset Password';
  static const String forgotPasswordSubtitle = 'Enter your email and we will send a link to reset it.';
  static const String forgotPasswordSendButton = 'Send Reset Link';
  static const String forgotPasswordBackButton = 'Back to Login';
  static const String forgotPasswordSuccessTitle = 'Link Sent';
  static const String forgotPasswordSuccessContent = 'We sent a password reset link to {email}. Please check your inbox (and spam folder).';
  static const String forgotPasswordErrorUserNotFound = 'No account found with this email.';
  static const String forgotPasswordErrorGeneric = 'An error occurred. Please try again.';


  // --- Загальні поля форм ---
  static const String emailLabel = 'Email';
  static const String emailHint = 'Enter your email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String nameLabel = 'Name';
  static const String nameHint = 'Enter your name';

  // --- Помилки валідації ---
  static const String errorEmailEmpty = 'Please enter an email';
  static const String errorEmailInvalid = 'Please enter a valid email';
  static const String errorPasswordEmpty = 'Please enter a password';
  static const String errorPasswordLength = 'Password must be at least 6 characters';
  static const String errorNameEmpty = 'Please enter a name';
  static const String errorDreamDescEmpty = 'Please describe your dream';
  static const String errorCategoryEmpty = 'Please select a category';
  static const String errorEmotionEmpty = 'Please select an emotional state';

  // --- Повідомлення (SnackBars / Dialogs) ---
  static const String authRequiredTitle = 'Authentication Required';
  static const String authRequiredContent = 'Please log in or sign up to access this feature.';
  static const String okButton = 'OK';
  static const String accountOptionsTitle = 'Account Options';
  static const String loggedInAs = 'Logged in as:';
  static const String noEmailAvailable = 'No email available';
  static const String logOutButton = 'Log Out';
  static const String signUpButtonDialog = 'Sign Up';
  static const String loginErrorInvalid = 'Invalid login or password.';
  static const String errorGeneric = 'An unknown error occurred';
  static const String signUpErrorWeakPassword = 'The password is too weak.';
  static const String signUpErrorEmailInUse = 'An account with this email already exists.';
  static const String signUpErrorGeneric = 'Registration error';
  static const String dreamSavedSuccess = 'Dream saved!';
  
  // --- Рядки для верифікації ---
  static const String verifyEmailTitle = 'Verify Your Email';
  static const String verifyEmailContent = 'A verification email has been sent to your inbox. Please follow the link to complete your registration.'; // Цей рядок більше не використовується, але залишаю
  static const String verifyEmailSubtitle = 'We sent a confirmation email to {email}. Please follow the link in the email (check your "Spam" folder).';
  static const String verifyEmailCheckButton = 'I confirmed, check';
  static const String verifyEmailCancelButton = 'Cancel and Sign Out';
  static const String verifyEmailErrorNotConfirmed = 'Email not yet confirmed. Please check your "Spam" folder or try again in a minute.';
  static const String verifyEmailErrorGeneric = 'Error checking: {error}';
  static const String verifyEmailPrompt = 'Your email is not yet verified. Please check your inbox or resend the verification email.';
  static const String resendButton = 'Resend Email';
  static const String verificationEmailSent = 'Verification email sent.';

  // *** НОВІ РЯДКИ ДЛЯ ЗВ'ЯЗУВАННЯ АКАУНТІВ ***
  static const String linkAccountTitle = 'Link Account';
  static const String linkAccountContent = 'An account already exists with this email ({email}). Please enter your password to link your Google account.';
  static const String linkAccountButton = 'Link and Sign In';
  static const String linkAccountError = 'Failed to link accounts. Please check your password.';
  // ***********************************************

  // --- Екран "Add Dream" ---
  static const String addDreamTitle = '+ Add New Dream';
  static const String addDreamSubtitle = 'Capture and categorize your dream experience';
  static const String descLabel = 'Dream Description';
  static const String descHint = 'Describe your dream in detail... What did you see, feel, or experience?';
  static const String categoryLabel = 'Category';
  static const String categoryHint = 'Select a category';
  static const String emotionLabel = 'Emotional State';
  static const String emotionHint = 'Select emotional state';
  static const String tagsLabel = 'Tags (Optional)';
  static const String tagsHint = 'Enter tags separated by commas (e.g., flying, water, family)';
  static const String tagsHelpText = 'Add relevant keywords to help categorize and search your dreams';
  static const String cancelButton = 'Cancel'; // Додано, якщо його не було
  static const String saveDraftButton = 'Save as Draft';
  static const String saveDreamButton = 'Save Dream';
  static const String tipsTitle = 'Dream Recording Tips';
  static const String tip1 = '• Record your dream as soon as you wake up for better accuracy.';
  static const String tip2 = '• Include emotions, colors, people, and locations you remember.';
  static const String tip3 = "• Don't worry about logical consistency - dreams are often surreal.";

  // --- Екран "Dashboard" (Home) ---
  static const String dashboardTitle = 'Dream Dashboard';
  static const String dashboardSubtitle = 'Explore and analyze your dream journey';
  static const String testSentryButton = 'Test Sentry (Crash)';
  static const String exportButton = 'Export';
  static const String newDreamButton = 'New Dream';
  static const String filterDateRange = 'Date Range:';
  static const String filterDateTo = 'to';
  static const String filterCategory = 'Category:';
  static const String filterCategoryAll = 'All Categories';
  static const String filterEmotion = 'Emotional State:';
  static const String filterEmotionAll = 'All Emotions';
  static const String filterHintStartDate = 'Select Start Date'; 
  static const String filterHintEndDate = 'Select End Date'; 

  // --- Екран "Analytics" ---
  static const String analyticsTitle = 'Dream Statistics';
  static const String analyticsSubtitle = 'Analyze your dream patterns and discover insights about your subconscious mind';
  static const String timePeriodLabel = 'Time Period';
  static const String timePeriodWeek = 'Week';
  static const String timePeriodMonth = 'Month';
  static const String timePeriodYear = 'Year';
  static const String chartCategoryTitle = 'Dreams by Category';
  static const String metricTotalDreams = 'Total Dreams';
  static const String metricAvgDuration = 'Avg Duration';
  static const String metricLucidDreams = 'Lucid Dreams';
  static const String metricNightmares = 'Nightmares';
  static const String chartQualityTitle = 'Dream Quality Distribution';
  static const String qualityPositive = 'Positive';
  static const String qualityNeutral = 'Neutral';
  static const String qualityNegative = 'Negative';
}