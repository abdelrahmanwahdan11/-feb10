# Excel AI Assistant (Flutter)

تطبيق Flutter ثنائي اللغة (عربي/إنجليزي) يحتوي على:

- Splash Screen + Onboarding
- Authentication (Login / Signup / Guest)
- Custom Animated Loader
- Home Workspace لرفع ملفات Excel بصيغ متعددة
- تكامل Gemini API لكل ميزات الذكاء الاصطناعي عبر `google_generative_ai`
- دعم خطوط Google Fonts وأنيميشن مكثفة

## Run

> ملاحظة: لا تقم بوضع المفاتيح داخل الكود. استخدم `dart-define`.

```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

## Notes

- لا يوجد ربط Backend في هذه المرحلة (حسب الطلب).
- يمكن لاحقاً إضافة طبقة بيانات لحفظ المستخدم/الملفات وتوليد تقارير فعلية وملفات Excel معدلة.
