# Excel AI Assistant (Flutter)

تطبيق Flutter ثنائي اللغة (عربي/إنجليزي) يحتوي على:

- Splash Screen + Onboarding مع حفظ حالة الإكمال
- Authentication (Login / Signup / Guest) مع تحقق حقول وإظهار كلمة المرور
- Custom Animated Loader
- Home Workspace لرفع ملفات Excel بصيغ متعددة
- إنشاء ملف Excel تجريبي تلقائياً داخل التطبيق (بدون باك إند)
- تكامل Gemini API لكل ميزات الذكاء الاصطناعي عبر `google_generative_ai`
- دعم خطوط Google Fonts وأنيميشن مكثفة

## Run

> ملاحظة أمنية: لا تقم بوضع المفاتيح داخل الكود. استخدم `dart-define`.

```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

## Notes

- لا يوجد ربط Backend في هذه المرحلة (حسب الطلب).
- تم تجهيز بنية تسمح بإضافة خدمات AI أوسع لاحقًا (تقارير، أتمتة، تعديل ملفات).
- دعم Excel حالياً يشمل الرفع وتوليد نموذج تقرير أولي لاختبار المسار.
