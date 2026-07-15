// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qalam';

  @override
  String get navFeed => 'Feed';

  @override
  String get navSearch => 'Search';

  @override
  String get navWrite => 'Write';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get actionClose => 'Close';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionOk => 'OK';

  @override
  String get actionContinue => 'Continue';

  @override
  String get connectivityOffline => 'You\'re offline — showing saved content.';

  @override
  String get connectivityRestored => 'Back online.';

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get errorGenericTitle => 'Something went wrong.';

  @override
  String get errorGenericBody =>
      'We couldn\'t complete that just now. Please try again.';

  @override
  String get errorOfflineTitle => 'You\'re offline.';

  @override
  String get errorOfflineBody => 'Check your connection and try again.';

  @override
  String get errorNotFoundTitle => 'Not found.';

  @override
  String get errorNotFoundBody => 'That page has wandered off.';

  @override
  String get errorUnauthorizedTitle => 'Please sign in.';

  @override
  String get errorUnauthorizedBody => 'You need to be signed in to see that.';

  @override
  String get errorForbiddenTitle => 'Not allowed.';

  @override
  String get errorForbiddenBody => 'You don\'t have access to that.';

  @override
  String errorRequestIdLabel(String requestId) {
    return 'Reference: $requestId';
  }

  @override
  String get emptyGenericTitle => 'Nothing here yet.';

  @override
  String get emptyGenericBody =>
      'When there\'s something to show, it\'ll appear here.';

  @override
  String get unknownRouteTitle => 'Lost the thread.';

  @override
  String get unknownRouteBody => 'This page doesn\'t exist.';

  @override
  String get comingSoonLabel => 'Coming in a later chapter.';

  @override
  String get placeholderFeedBody => 'Your feed will live here.';

  @override
  String get placeholderSearchBody => 'Search will live here.';

  @override
  String get placeholderWriteBody => 'The editor will live here.';

  @override
  String get placeholderNotificationsBody => 'Notifications will live here.';

  @override
  String get placeholderProfileBody => 'Your profile will live here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBody =>
      'A protected surface — settings arrive in a later chapter.';

  @override
  String get galleryTitle => 'Design gallery';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingWelcomeTitle => 'A place for your words';

  @override
  String get onboardingWelcomeBody =>
      'Qalam is a quiet writing sanctuary — warm paper and ink, for Hindi and Urdu writers first.';

  @override
  String get onboardingFeaturesTitle => 'Read and write, beautifully';

  @override
  String get onboardingFeaturesBody =>
      'Follow writers you love, save what moves you, and publish prose that reads the way it should.';

  @override
  String get onboardingPrivacyTitle => 'Your words, your control';

  @override
  String get onboardingPrivacyBody =>
      'You decide what you share. We keep only what we need, and never sell your writing.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to continue writing.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle => 'Join a sanctuary for writers.';

  @override
  String get authForgotTitle => 'Reset your password';

  @override
  String get authForgotSubtitle => 'We\'ll send a link to set a new one.';

  @override
  String get authResetTitle => 'Choose a new password';

  @override
  String get authResetSubtitle => 'Set a strong password you\'ll remember.';

  @override
  String get authVerifyTitle => 'Verify your email';

  @override
  String get fieldEmailLabel => 'Email';

  @override
  String get fieldPasswordLabel => 'Password';

  @override
  String get fieldUsernameLabel => 'Username';

  @override
  String get fieldNewPasswordLabel => 'New password';

  @override
  String get fieldConfirmPasswordLabel => 'Confirm password';

  @override
  String get fieldEmailHint => 'you@example.com';

  @override
  String get authUsernameHint => 'Lowercase letters, numbers, and underscores.';

  @override
  String get authUsernamePermanent =>
      'Your username is permanent — choose it with care.';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get actionSendResetLink => 'Send reset link';

  @override
  String get actionResetPassword => 'Reset password';

  @override
  String get actionResend => 'Resend email';

  @override
  String get actionForgotPassword => 'Forgot password?';

  @override
  String get actionSignOut => 'Log out';

  @override
  String get actionSignOutEverywhere => 'Sign out everywhere';

  @override
  String get actionShowPassword => 'Show password';

  @override
  String get actionHidePassword => 'Hide password';

  @override
  String get authRememberMe => 'Keep me signed in';

  @override
  String get authNoAccount => 'New to Qalam?';

  @override
  String get authCreateOne => 'Create an account';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authBackToLogin => 'Back to sign in';

  @override
  String get authOrDivider => 'or';

  @override
  String authContinueWith(String provider) {
    return 'Continue with $provider';
  }

  @override
  String authSocialUnavailable(String provider) {
    return '$provider sign-in isn\'t available in this build yet.';
  }

  @override
  String pwStrengthLabel(String level) {
    return 'Password strength: $level';
  }

  @override
  String get pwStrengthWeak => 'weak';

  @override
  String get pwStrengthFair => 'fair';

  @override
  String get pwStrengthGood => 'good';

  @override
  String get pwStrengthStrong => 'strong';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationUsernameFormat =>
      'Use only lowercase letters, numbers, and underscores.';

  @override
  String get validationUsernameLength => 'Username must be 3–30 characters.';

  @override
  String get validationPasswordTooShort => 'Use at least 10 characters.';

  @override
  String get validationPasswordTooLong =>
      'That\'s too long — 128 characters at most.';

  @override
  String get validationPasswordsMismatch => 'Those passwords don\'t match.';

  @override
  String get validationEmailTaken => 'That email is already registered.';

  @override
  String get validationUsernameTaken => 'That username is already taken.';

  @override
  String get validationPasswordWeak => 'Please choose a stronger password.';

  @override
  String get validationTokenInvalid => 'This link is invalid or has expired.';

  @override
  String get authForgotSentTitle => 'Check your inbox';

  @override
  String authForgotSentBody(String email) {
    return 'If an account exists for $email, a reset link is on its way.';
  }

  @override
  String get authResetDoneTitle => 'Password updated';

  @override
  String get authResetDoneBody => 'Sign in with your new password.';

  @override
  String get authVerifyingLabel => 'Verifying your email…';

  @override
  String get authVerifiedTitle => 'Email verified';

  @override
  String get authVerifiedBody => 'Thank you — your email is confirmed.';

  @override
  String authVerifySentToBody(String email) {
    return 'We sent a verification link to $email. Open it to confirm your account.';
  }

  @override
  String get authVerifyGenericBody =>
      'We sent a verification link to your email. Open it to confirm your account.';

  @override
  String get authVerifyWhyBody =>
      'You can keep using Qalam — some actions need a verified email.';

  @override
  String get authResentBody => 'Sent. Check your inbox again.';

  @override
  String accountSignedInAs(String username) {
    return 'Signed in as @$username';
  }

  @override
  String get accountSignedIn => 'You\'re signed in.';

  @override
  String get accountEmailUnverified => 'Your email isn\'t verified yet.';

  @override
  String get verifyBannerText => 'Verify your email to unlock everything.';

  @override
  String get verifyBannerAction => 'Verify';

  @override
  String get signOutConfirmTitle => 'Sign out everywhere?';

  @override
  String get signOutConfirmBody =>
      'This ends every active session on all your devices.';
}
