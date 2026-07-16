import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name.
  ///
  /// In en, this message translates to:
  /// **'Qalam'**
  String get appTitle;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get navWrite;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @connectivityOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing saved content.'**
  String get connectivityOffline;

  /// No description provided for @connectivityRestored.
  ///
  /// In en, this message translates to:
  /// **'Back online.'**
  String get connectivityRestored;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that just now. Please try again.'**
  String get errorGenericBody;

  /// No description provided for @errorOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline.'**
  String get errorOfflineTitle;

  /// No description provided for @errorOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorOfflineBody;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'That page has wandered off.'**
  String get errorNotFoundBody;

  /// No description provided for @errorUnauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in.'**
  String get errorUnauthorizedTitle;

  /// No description provided for @errorUnauthorizedBody.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to see that.'**
  String get errorUnauthorizedBody;

  /// No description provided for @errorForbiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Not allowed.'**
  String get errorForbiddenTitle;

  /// No description provided for @errorForbiddenBody.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to that.'**
  String get errorForbiddenBody;

  /// Support correlation id shown on error screens.
  ///
  /// In en, this message translates to:
  /// **'Reference: {requestId}'**
  String errorRequestIdLabel(String requestId);

  /// No description provided for @emptyGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get emptyGenericTitle;

  /// No description provided for @emptyGenericBody.
  ///
  /// In en, this message translates to:
  /// **'When there\'s something to show, it\'ll appear here.'**
  String get emptyGenericBody;

  /// No description provided for @unknownRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost the thread.'**
  String get unknownRouteTitle;

  /// No description provided for @unknownRouteBody.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist.'**
  String get unknownRouteBody;

  /// No description provided for @comingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later chapter.'**
  String get comingSoonLabel;

  /// No description provided for @placeholderFeedBody.
  ///
  /// In en, this message translates to:
  /// **'Your feed will live here.'**
  String get placeholderFeedBody;

  /// No description provided for @placeholderSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search will live here.'**
  String get placeholderSearchBody;

  /// No description provided for @placeholderWriteBody.
  ///
  /// In en, this message translates to:
  /// **'The editor will live here.'**
  String get placeholderWriteBody;

  /// No description provided for @placeholderNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications will live here.'**
  String get placeholderNotificationsBody;

  /// No description provided for @placeholderProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile will live here.'**
  String get placeholderProfileBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsBody.
  ///
  /// In en, this message translates to:
  /// **'A protected surface — settings arrive in a later chapter.'**
  String get settingsBody;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Design gallery'**
  String get galleryTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'A place for your words'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Qalam is a quiet writing sanctuary — warm paper and ink, for Hindi and Urdu writers first.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Read and write, beautifully'**
  String get onboardingFeaturesTitle;

  /// No description provided for @onboardingFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'Follow writers you love, save what moves you, and publish prose that reads the way it should.'**
  String get onboardingFeaturesBody;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your words, your control'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'You decide what you share. We keep only what we need, and never sell your writing.'**
  String get onboardingPrivacyBody;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue writing.'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a sanctuary for writers.'**
  String get authRegisterSubtitle;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a link to set a new one.'**
  String get authForgotSubtitle;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a strong password you\'ll remember.'**
  String get authResetSubtitle;

  /// No description provided for @authVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyTitle;

  /// No description provided for @fieldEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmailLabel;

  /// No description provided for @fieldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPasswordLabel;

  /// No description provided for @fieldUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsernameLabel;

  /// No description provided for @fieldNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get fieldNewPasswordLabel;

  /// No description provided for @fieldConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPasswordLabel;

  /// No description provided for @fieldEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get fieldEmailHint;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers, and underscores.'**
  String get authUsernameHint;

  /// No description provided for @authUsernamePermanent.
  ///
  /// In en, this message translates to:
  /// **'Your username is permanent — choose it with care.'**
  String get authUsernamePermanent;

  /// No description provided for @actionSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get actionSignIn;

  /// No description provided for @actionCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get actionCreateAccount;

  /// No description provided for @actionSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get actionSendResetLink;

  /// No description provided for @actionResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get actionResetPassword;

  /// No description provided for @actionResend.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get actionResend;

  /// No description provided for @actionForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get actionForgotPassword;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get actionSignOut;

  /// No description provided for @actionSignOutEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere'**
  String get actionSignOutEverywhere;

  /// No description provided for @actionShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get actionShowPassword;

  /// No description provided for @actionHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get actionHidePassword;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get authRememberMe;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Qalam?'**
  String get authNoAccount;

  /// No description provided for @authCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateOne;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToLogin;

  /// No description provided for @authOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// Social sign-in button label.
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String authContinueWith(String provider);

  /// Shown when a social provider seam is not wired.
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in isn\'t available in this build yet.'**
  String authSocialUnavailable(String provider);

  /// Accessible label for the password strength meter.
  ///
  /// In en, this message translates to:
  /// **'Password strength: {level}'**
  String pwStrengthLabel(String level);

  /// No description provided for @pwStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'weak'**
  String get pwStrengthWeak;

  /// No description provided for @pwStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'fair'**
  String get pwStrengthFair;

  /// No description provided for @pwStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get pwStrengthGood;

  /// No description provided for @pwStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'strong'**
  String get pwStrengthStrong;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationUsernameFormat.
  ///
  /// In en, this message translates to:
  /// **'Use only lowercase letters, numbers, and underscores.'**
  String get validationUsernameFormat;

  /// No description provided for @validationUsernameLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be 3–30 characters.'**
  String get validationUsernameLength;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 10 characters.'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordTooLong.
  ///
  /// In en, this message translates to:
  /// **'That\'s too long — 128 characters at most.'**
  String get validationPasswordTooLong;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Those passwords don\'t match.'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered.'**
  String get validationEmailTaken;

  /// No description provided for @validationUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is already taken.'**
  String get validationUsernameTaken;

  /// No description provided for @validationPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password.'**
  String get validationPasswordWeak;

  /// No description provided for @validationTokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'This link is invalid or has expired.'**
  String get validationTokenInvalid;

  /// No description provided for @authForgotSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authForgotSentTitle;

  /// Enumeration-safe confirmation after requesting a reset.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a reset link is on its way.'**
  String authForgotSentBody(String email);

  /// No description provided for @authResetDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authResetDoneTitle;

  /// No description provided for @authResetDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your new password.'**
  String get authResetDoneBody;

  /// No description provided for @authVerifyingLabel.
  ///
  /// In en, this message translates to:
  /// **'Verifying your email…'**
  String get authVerifyingLabel;

  /// No description provided for @authVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get authVerifiedTitle;

  /// No description provided for @authVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you — your email is confirmed.'**
  String get authVerifiedBody;

  /// Verify-email body when the address is known.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Open it to confirm your account.'**
  String authVerifySentToBody(String email);

  /// No description provided for @authVerifyGenericBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email. Open it to confirm your account.'**
  String get authVerifyGenericBody;

  /// No description provided for @authVerifyWhyBody.
  ///
  /// In en, this message translates to:
  /// **'You can keep using Qalam — some actions need a verified email.'**
  String get authVerifyWhyBody;

  /// No description provided for @authResentBody.
  ///
  /// In en, this message translates to:
  /// **'Sent. Check your inbox again.'**
  String get authResentBody;

  /// Account surface header with the current username.
  ///
  /// In en, this message translates to:
  /// **'Signed in as @{username}'**
  String accountSignedInAs(String username);

  /// No description provided for @accountSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in.'**
  String get accountSignedIn;

  /// No description provided for @accountEmailUnverified.
  ///
  /// In en, this message translates to:
  /// **'Your email isn\'t verified yet.'**
  String get accountEmailUnverified;

  /// No description provided for @verifyBannerText.
  ///
  /// In en, this message translates to:
  /// **'Verify your email to unlock everything.'**
  String get verifyBannerText;

  /// No description provided for @verifyBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyBannerAction;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This ends every active session on all your devices.'**
  String get signOutConfirmBody;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search writers, pieces, tags…'**
  String get searchHint;

  /// No description provided for @searchClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearTooltip;

  /// Hint shown when the query is below the minimum length.
  ///
  /// In en, this message translates to:
  /// **'Type at least {min} letters to search.'**
  String searchTooShortHint(int min);

  /// No description provided for @searchTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTabAll;

  /// No description provided for @searchTabPieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get searchTabPieces;

  /// No description provided for @searchTabWriters.
  ///
  /// In en, this message translates to:
  /// **'Writers'**
  String get searchTabWriters;

  /// No description provided for @searchTabTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get searchTabTags;

  /// No description provided for @searchTabGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get searchTabGenres;

  /// No description provided for @searchTabLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get searchTabLanguages;

  /// No description provided for @searchSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get searchSeeAll;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched.'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different word, or loosen your filters.'**
  String get searchEmptyBody;

  /// No description provided for @searchOfflineResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Showing your last results — you\'re offline.'**
  String get searchOfflineResultsBody;

  /// No description provided for @searchRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentTitle;

  /// No description provided for @searchRecentClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchRecentClear;

  /// No description provided for @searchClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear search history?'**
  String get searchClearHistoryTitle;

  /// No description provided for @searchClearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every recent search on this device.'**
  String get searchClearHistoryBody;

  /// No description provided for @searchTrendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending searches'**
  String get searchTrendingTitle;

  /// No description provided for @searchTrendingTags.
  ///
  /// In en, this message translates to:
  /// **'Trending tags'**
  String get searchTrendingTags;

  /// No description provided for @searchSuggestWriters.
  ///
  /// In en, this message translates to:
  /// **'Writers'**
  String get searchSuggestWriters;

  /// No description provided for @searchSuggestTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get searchSuggestTags;

  /// No description provided for @searchSuggestGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get searchSuggestGenres;

  /// No description provided for @searchSuggestPieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get searchSuggestPieces;

  /// No description provided for @searchFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFiltersTitle;

  /// No description provided for @searchFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFiltersButton;

  /// No description provided for @searchFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get searchFilterReset;

  /// No description provided for @searchFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get searchFilterApply;

  /// No description provided for @searchFilterSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get searchFilterSortLabel;

  /// No description provided for @searchFilterLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get searchFilterLanguageLabel;

  /// No description provided for @searchFilterGenreLabel.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get searchFilterGenreLabel;

  /// No description provided for @searchFilterTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get searchFilterTagLabel;

  /// No description provided for @searchFilterReadingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reading time'**
  String get searchFilterReadingTimeLabel;

  /// No description provided for @searchSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Most relevant'**
  String get searchSortRelevance;

  /// No description provided for @searchSortLatest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get searchSortLatest;

  /// No description provided for @searchSortTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get searchSortTrending;

  /// No description provided for @searchSortMostClapped.
  ///
  /// In en, this message translates to:
  /// **'Most clapped'**
  String get searchSortMostClapped;

  /// No description provided for @searchSortMostCommented.
  ///
  /// In en, this message translates to:
  /// **'Most discussed'**
  String get searchSortMostCommented;

  /// No description provided for @searchReadingAny.
  ///
  /// In en, this message translates to:
  /// **'Any length'**
  String get searchReadingAny;

  /// No description provided for @searchReadingShort.
  ///
  /// In en, this message translates to:
  /// **'Under 5 min'**
  String get searchReadingShort;

  /// No description provided for @searchReadingMedium.
  ///
  /// In en, this message translates to:
  /// **'5–15 min'**
  String get searchReadingMedium;

  /// No description provided for @searchReadingLong.
  ///
  /// In en, this message translates to:
  /// **'Over 15 min'**
  String get searchReadingLong;

  /// No description provided for @searchDiscoverFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get searchDiscoverFeatured;

  /// No description provided for @searchDiscoverRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently published'**
  String get searchDiscoverRecent;

  /// No description provided for @searchDiscoverPopularWriters.
  ///
  /// In en, this message translates to:
  /// **'Popular writers'**
  String get searchDiscoverPopularWriters;

  /// No description provided for @searchDiscoverPopularGenres.
  ///
  /// In en, this message translates to:
  /// **'Popular genres'**
  String get searchDiscoverPopularGenres;

  /// No description provided for @searchDiscoverContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue discovering'**
  String get searchDiscoverContinue;

  /// No description provided for @searchDiscoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'A quiet beginning.'**
  String get searchDiscoverEmptyTitle;

  /// No description provided for @searchDiscoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Search above, or come back as the community publishes.'**
  String get searchDiscoverEmptyBody;

  /// No description provided for @searchWriterPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private account'**
  String get searchWriterPrivate;

  /// Count of pieces on a tag/genre/language result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pieces} =1{1 piece} other{{count} pieces}}'**
  String searchPieceCount(int count);

  /// Follower count on a writer result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No followers} =1{1 follower} other{{count} followers}}'**
  String searchFollowerCount(int count);

  /// No description provided for @followFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followFollow;

  /// No description provided for @followFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followFollowing;

  /// No description provided for @followRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get followRequested;

  /// No description provided for @followSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to follow writers.'**
  String get followSignInPrompt;

  /// No description provided for @socialActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t go through. Please try again.'**
  String get socialActionFailed;

  /// No description provided for @socialQueuedOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — we\'ll sync this when you reconnect.'**
  String get socialQueuedOffline;

  /// Banner text for queued offline social actions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String socialPendingSync(int count);

  /// No description provided for @followersTitle.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersTitle;

  /// No description provided for @followingTitle.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingTitle;

  /// No description provided for @followRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow requests'**
  String get followRequestsTitle;

  /// No description provided for @followRequestsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending requests.'**
  String get followRequestsEmptyTitle;

  /// No description provided for @followRequestsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When someone asks to follow you, they\'ll appear here.'**
  String get followRequestsEmptyBody;

  /// No description provided for @followRequestAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get followRequestAccept;

  /// No description provided for @followRequestReject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get followRequestReject;

  /// No description provided for @followersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No followers yet.'**
  String get followersEmptyTitle;

  /// No description provided for @followersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Followers will appear here.'**
  String get followersEmptyBody;

  /// No description provided for @followingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet.'**
  String get followingEmptyTitle;

  /// No description provided for @followingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Writers this reader follows will appear here.'**
  String get followingEmptyBody;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// Comment count header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No comments} =1{1 comment} other{{count} comments}}'**
  String commentsCount(int count);

  /// No description provided for @commentComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get commentComposerHint;

  /// No description provided for @commentReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get commentReplyHint;

  /// No description provided for @commentSend.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get commentSend;

  /// No description provided for @commentReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commentReply;

  /// No description provided for @commentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commentEdit;

  /// No description provided for @commentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentDelete;

  /// No description provided for @commentEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get commentEdited;

  /// No description provided for @commentDeletedTombstone.
  ///
  /// In en, this message translates to:
  /// **'This comment has been deleted.'**
  String get commentDeletedTombstone;

  /// Expand-replies affordance.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{View 1 reply} other{View {count} replies}}'**
  String commentViewReplies(int count);

  /// No description provided for @commentHideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get commentHideReplies;

  /// No description provided for @commentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get commentsEmptyTitle;

  /// No description provided for @commentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a thought.'**
  String get commentsEmptyBody;

  /// No description provided for @commentSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to join the conversation.'**
  String get commentSignInPrompt;

  /// No description provided for @commentDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete comment?'**
  String get commentDeleteConfirmTitle;

  /// No description provided for @commentDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. Replies stay visible.'**
  String get commentDeleteConfirmBody;

  /// No description provided for @commentSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get commentSortNewest;

  /// No description provided for @commentSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get commentSortOldest;

  /// No description provided for @responsesTitle.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get responsesTitle;

  /// Response count header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No responses} =1{1 response} other{{count} responses}}'**
  String responsesCount(int count);

  /// No description provided for @responseWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a response'**
  String get responseWrite;

  /// No description provided for @responsesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No responses yet.'**
  String get responsesEmptyTitle;

  /// No description provided for @responsesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation with your own piece.'**
  String get responsesEmptyBody;

  /// No description provided for @responseSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to write a response.'**
  String get responseSignInPrompt;

  /// No description provided for @collectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsTitle;

  /// No description provided for @collectionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No collections yet.'**
  String get collectionsEmptyTitle;

  /// No description provided for @collectionsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a collection to gather pieces you love.'**
  String get collectionsEmptyBody;

  /// No description provided for @collectionCreate.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get collectionCreate;

  /// No description provided for @collectionCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get collectionCreateTitle;

  /// No description provided for @collectionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get collectionRename;

  /// No description provided for @collectionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get collectionDelete;

  /// No description provided for @collectionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get collectionNameLabel;

  /// No description provided for @collectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rainy-day ghazals'**
  String get collectionNameHint;

  /// No description provided for @collectionDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get collectionDescriptionLabel;

  /// No description provided for @collectionMakePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get collectionMakePrivate;

  /// No description provided for @collectionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get collectionSave;

  /// No description provided for @collectionDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete collection?'**
  String get collectionDeleteConfirmTitle;

  /// No description provided for @collectionDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The pieces stay published — only this collection is removed.'**
  String get collectionDeleteConfirmBody;

  /// No description provided for @collectionEmptyPiecesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet.'**
  String get collectionEmptyPiecesTitle;

  /// No description provided for @collectionEmptyPiecesBody.
  ///
  /// In en, this message translates to:
  /// **'Pieces you add to this collection will appear here.'**
  String get collectionEmptyPiecesBody;

  /// Piece count on a collection card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Empty} =1{1 piece} other{{count} pieces}}'**
  String collectionPieceCount(int count);

  /// No description provided for @collectionRemovePiece.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get collectionRemovePiece;

  /// No description provided for @collectionPrivateLabel.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get collectionPrivateLabel;

  /// No description provided for @saveToCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Save to collection'**
  String get saveToCollectionTitle;

  /// Snackbar after adding a piece to a collection.
  ///
  /// In en, this message translates to:
  /// **'Saved to {name}.'**
  String saveToCollectionAdded(String name);

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportPieceTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this piece'**
  String get reportPieceTitle;

  /// No description provided for @reportCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this comment'**
  String get reportCommentTitle;

  /// No description provided for @reportUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this account'**
  String get reportUserTitle;

  /// No description provided for @reportResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this response'**
  String get reportResponseTitle;

  /// No description provided for @reportReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this?'**
  String get reportReasonPrompt;

  /// No description provided for @reportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add any details (optional)'**
  String get reportDetailsHint;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks — our team will take a look.'**
  String get reportSubmitted;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonHateSpeech.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get reportReasonHateSpeech;

  /// No description provided for @reportReasonViolence.
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get reportReasonViolence;

  /// No description provided for @reportReasonSexualContent.
  ///
  /// In en, this message translates to:
  /// **'Sexual content'**
  String get reportReasonSexualContent;

  /// No description provided for @reportReasonSelfHarm.
  ///
  /// In en, this message translates to:
  /// **'Self-harm'**
  String get reportReasonSelfHarm;

  /// No description provided for @reportReasonMisinformation.
  ///
  /// In en, this message translates to:
  /// **'Misinformation'**
  String get reportReasonMisinformation;

  /// No description provided for @reportReasonCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get reportReasonCopyright;

  /// No description provided for @reportReasonImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get reportReasonImpersonation;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
