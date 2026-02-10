import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(l10n != null, 'AppLocalizations not found in widget tree');
    return l10n!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'appTitle': 'مساعد إكسل الذكي',
      'onboarding1': 'حلّل ملفاتك بسرعة باستخدام الذكاء الاصطناعي',
      'onboarding2': 'أنشئ تقارير ولوحات تحكم تلقائياً',
      'onboarding3': 'اقرأ وصدّر ملفات Excel بصيغ متعددة',
      'next': 'التالي',
      'start': 'ابدأ الآن',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'guest': 'الدخول كضيف',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'name': 'الاسم',
      'home': 'الرئيسية',
      'upload': 'رفع ملف',
      'analyze': 'تحليل',
      'aiPrompt': 'اكتب طلبك للذكاء الاصطناعي',
      'generate': 'تنفيذ الطلب',
      'toggleLanguage': 'تغيير اللغة',
      'workspaceTitle': 'مساحة عمل Excel + AI',
      'noFileSelected': 'لم يتم اختيار ملف بعد',
      'aiOutputPlaceholder': 'سيظهر ناتج الذكاء الاصطناعي هنا...',
      'signinSuccess': 'تم تسجيل الدخول بنجاح',
      'signupSuccess': 'تم إنشاء الحساب بنجاح',
      'guestSuccess': 'تم الدخول كضيف',
      'invalidEmail': 'الرجاء إدخال بريد إلكتروني صحيح',
      'shortPassword': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'requiredField': 'هذا الحقل مطلوب',
      'signOut': 'تسجيل الخروج',
      'authRequired': 'يجب تسجيل الدخول أو اختيار الدخول كضيف أولاً',
      'searchHint': 'مثال: حلل المبيعات الشهرية وأنشئ تقرير PDF',
      'createDemoReport': 'إنشاء تقرير تجريبي Excel',
      'demoCreated': 'تم إنشاء تقرير تجريبي في التخزين المؤقت للتطبيق',
      'geminiMissing': 'مفتاح Gemini غير مضاف. استخدم --dart-define=GEMINI_API_KEY=...',
      'welcomeBack': 'مرحباً بك',
      'modeGuest': 'وضع الضيف',
      'modeUser': 'مستخدم مسجل',
    },
    'en': {
      'appTitle': 'Excel AI Assistant',
      'onboarding1': 'Analyze your sheets fast with AI assistance',
      'onboarding2': 'Auto-build reports and smart dashboards',
      'onboarding3': 'Read & export Excel-compatible formats',
      'next': 'Next',
      'start': 'Get Started',
      'login': 'Login',
      'signup': 'Create Account',
      'guest': 'Continue as Guest',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'home': 'Home',
      'upload': 'Upload File',
      'analyze': 'Analyze',
      'aiPrompt': 'Write your AI request',
      'generate': 'Run Request',
      'toggleLanguage': 'Toggle Language',
      'workspaceTitle': 'Excel + AI Workspace',
      'noFileSelected': 'No file selected yet',
      'aiOutputPlaceholder': 'AI output will appear here...',
      'signinSuccess': 'Signed in successfully',
      'signupSuccess': 'Account created successfully',
      'guestSuccess': 'Continued as guest',
      'invalidEmail': 'Please enter a valid email address',
      'shortPassword': 'Password must be at least 6 characters',
      'requiredField': 'This field is required',
      'signOut': 'Sign out',
      'authRequired': 'Please login or continue as guest first',
      'searchHint': 'Example: Analyze monthly sales and create a PDF report',
      'createDemoReport': 'Create Excel Demo Report',
      'demoCreated': 'Demo report generated in app temporary storage',
      'geminiMissing': 'Gemini key is missing. Use --dart-define=GEMINI_API_KEY=...',
      'welcomeBack': 'Welcome back',
      'modeGuest': 'Guest mode',
      'modeUser': 'Signed-in user',
    },
  };

  String t(String key) => _localizedValues[locale.languageCode]?[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
