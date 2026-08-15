# ابدأ التشغيل هنا (اقرأ هذا أولًا)

## خطوة واحدة مطلوبة منك قبل أول تشغيل

بيئة العمل التي أنشأت فيها هذا المشروع **لا تملك Flutter SDK ولا اتصال إنترنت**، لذلك
لم أستطع توليد 3 ملفات ثنائية (Binary) خاصة بأداة Gradle Wrapper (`gradlew`,
`gradlew.bat`, `gradle-wrapper.jar`) — هذه الملفات لا يمكن كتابتها كنص، بل يجب أن
تُولَّد من نسخة Flutter/Gradle الفعلية المثبتة على جهازك.

**الحل بسيط وآمن ولا يمس كودك إطلاقًا:**

```bash
cd pepsi_runner
flutter create . --platforms=android --org com.pepsirunner
```

هذا الأمر:
- يفحص مجلد `android/` الموجود بالفعل (بكل ملفات build.gradle وAndroidManifest
  و MainActivity.kt التي أعددتها) ويكمل فقط الملفات الثنائية الناقصة
  (`gradlew`, `gradlew.bat`, `gradle-wrapper.jar`) لتطابق نسخة Flutter لديك بالضبط.
- **لا يحذف ولا يعدّل** `lib/`, `test/`, `assets/`, أو أي كود كتبته.
- إذا سألك عن الكتابة فوق ملفات (pubspec.yaml مثلاً) اختر **لا/n** حتى لا يفقد أي إعداد — لن يحتاج ذلك عادةً لأن `pubspec.yaml` جاهز أصلًا.

## بعد ذلك، التشغيل العادي

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run          # للتجربة المباشرة على جهاز/محاكي
flutter build apk --release   # لبناء APK نهائي
```

## ما الذي جاهز فعليًا في هذا الـ zip بدون أي خطوة إضافية

- كل أكواد Dart (67 ملفًا) مكتملة ومترابطة، بدون TODO.
- `android/` كامل (Gradle files, AndroidManifest, MainActivity.kt, أيقونات
  التطبيق بكل الدقات، الثيمات) — ناقصة فقط الملفات الثلاثة المذكورة أعلاه.
- **كل الصور والأصوات موجودة فعليًا** كملفات مؤقتة (Placeholder) مولّدة تلقائيًا:
  53 صورة PNG ملوّنة ومكتوب عليها اسمها، و22 ملف MP3 صامت — بنفس الأسماء
  والمسارات المطلوبة تمامًا، حتى لا يفشل البناء بسبب مجلدات فارغة. استبدلها
  بفنك الخاص متى شئت (راجع `ASSETS_GUIDE.md`).
- 5 ملفات اختبار (`test/`) تغطي الفيزياء، التصادم، النقاط، نظام المراحل،
  وحفظ التقدم، بالإضافة إلى اختبارين جديدين لمحركي العوائق والعناصر
  (Object Pooling والحركة).

## ماذا لو ظهر خطأ Gradle/AGP version mismatch؟

إصدارات Android Gradle Plugin وKotlin المذكورة في `android/settings.gradle`
(AGP 8.1.0 / Kotlin 1.9.10) متوافقة مع أغلب نسخ Flutter الحديثة، لكن إذا كانت
نسخة Flutter لديك أحدث أو أقدم بكثير وظهرت رسالة توافق، فقط عدّل الأرقام في
`android/settings.gradle` حسب ما تقترحه رسالة الخطأ، أو اسمح لـ
`flutter create .` بتحديثها تلقائيًا معك.
