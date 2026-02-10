# Excel AI Assistant (Flutter)

تطبيق Flutter ثنائي اللغة (عربي/إنجليزي) يحتوي على:

- Splash Screen + Onboarding مع حفظ حالة الإكمال
- Authentication (Login / Signup / Guest) مع تحقق حقول وإظهار كلمة المرور
- Custom Animated Loader
- Home Workspace لرفع ملفات Excel بصيغ متعددة
- محرر جداول (Spreadsheet Editor) يشبه تجربة Excel مع تعديل الخلايا والصيغ الأساسية
- معاينة مبدئية للملف (خاصة CSV حالياً)
- Autopilot Mode: يدمج خطة AI + إنشاء ملف Excel تجريبي
- Smart Web Search عبر Google Custom Search API
- صفحات إضافية مهمة: مركز التقارير + الإعدادات + مراجعة فريق الخبراء + مركز القوالب + مركز المساعدة
- تكامل Gemini API لكل ميزات الذكاء الاصطناعي عبر `google_generative_ai`
- دعم خطوط Google Fonts وأنيميشن مكثفة

## Run

> ملاحظة أمنية: لا تقم بوضع المفاتيح داخل الكود. استخدم `dart-define`.

```bash
flutter pub get
flutter run \
  --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY \
  --dart-define=SEARCH_API_KEY=YOUR_GOOGLE_SEARCH_API_KEY \
  --dart-define=SEARCH_ENGINE_CX=YOUR_SEARCH_ENGINE_CX
```

## Notes

- لا يوجد ربط Backend في هذه المرحلة (حسب الطلب).
- دعم Excel الحالي يشمل: رفع ملفات، معاينة CSV، إنشاء ملفات CSV/XLSX جديدة، تحرير الخلايا مع صيغ أساسية مثل SUM، وتوليد قوالب جاهزة (ميزانية/فاتورة).
- يمكن توسيع قراءة صيغ Excel الداخلية وتحليلها المتقدم في المرحلة القادمة.
