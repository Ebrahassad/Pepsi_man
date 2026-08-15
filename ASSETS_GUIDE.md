# مذكرة الأصول (Assets) — الصور والصوت

هذه المذكرة تشرح كل ملفات الصور والصوت التي يحتاجها المشروع: أين تُوضع، ما نوعها، وأبعادها المقترحة. **كل هذه المسارات موجودة بالفعل في المشروع بملفات مؤقتة (Placeholder) تم توليدها تلقائيًا** — التطبيق يعمل ويُبنى بدون أي نقص، ويمكنك استبدال أي ملف بفنك الخاص لاحقًا بنفس الاسم والمسار بالضبط دون تعديل أي سطر كود.

---

## 1. الصور (Images)

**النوع المطلوب لكل الصور: PNG بخلفية شفافة (Alpha Channel)**، إلا الخلفيات (Backgrounds) فهي PNG بخلفية معتمة (Opaque) لأنها تملأ الشاشة بالكامل.

### أ. الشخصية RunnerHero — `assets/images/characters/runner/`

| الملف | الأبعاد المقترحة | يُستخدم متى |
|---|---|---|
| runner_idle.png | 220×220 | قبل بدء الجري (شاشة البداية) |
| runner_run_01.png | 220×220 | إطار جري 1 (يتكرر مع 02 و03) |
| runner_run_02.png | 220×220 | إطار جري 2 |
| runner_run_03.png | 220×220 | إطار جري 3 |
| runner_jump.png | 220×220 | أثناء القفز |
| runner_slide.png | 220×220 | أثناء الانزلاق (أعرض وأقصر) |
| runner_hit.png | 220×220 | عند الاصطدام |
| runner_celebrate.png | 220×220 | عند إنهاء المرحلة بنجاح |

### ب. العوائق — `assets/images/obstacles/`

| الملف | الأبعاد المقترحة | ملاحظة |
|---|---|---|
| car.png | 180×220 | |
| truck.png | 220×280 | |
| bus.png | 240×300 | |
| barrier.png | 160×120 | يُقفز فوقها |
| cone.png | 80×90 | يُقفز فوقها |
| trash_bin.png | 110×130 | تظهر فجأة من الجانب |
| construction_barrier.png | 180×120 | يُقفز فوقها |
| container.png | 260×260 | |
| gate.png | 280×200 | يُنزلق تحتها |
| road_block.png | 200×110 | يُقفز فوقها |

### ج. العناصر القابلة للجمع والقوى الخاصة — `assets/images/items/`

| الملف | الأبعاد | النوع |
|---|---|---|
| energy_can.png | 88×88 | جمع أساسي |
| bonus_can.png | 88×88 | جمع بقيمة أعلى |
| coin.png | 88×88 | جمع |
| magnet.png | 88×88 | قوة خاصة |
| shield.png | 88×88 | قوة خاصة |
| speed_boost.png | 88×88 | قوة خاصة |
| invincibility.png | 88×88 | قوة خاصة |

### د. واجهة المستخدم — `assets/images/ui/`

| الملف | الأبعاد | الاستخدام |
|---|---|---|
| game_logo.png | 440×180 | شعار اللعبة (Splash + القائمة الرئيسية) |
| play_button.png | 240×90 | زر تشغيل بديل (اختياري، الأزرار الحالية مرسومة برمجيًا) |
| pause_button.png | 90×90 | |
| replay_button.png | 240×90 | |
| home_button.png | 240×90 | |
| next_button.png | 240×90 | |
| lock.png | 72×72 | قفل المرحلة |
| star.png | 56×56 | نجمة ممتلئة |
| star_empty.png | 56×56 | نجمة فارغة |
| coin_icon.png | 48×48 | أيقونة HUD |
| can_icon.png | 48×48 | أيقونة HUD |
| life_icon.png | 48×48 | أيقونة HUD |
| checkpoint.png | 56×56 | علامة نقطة تفتيش |

### هـ. الخلفيات — `assets/images/backgrounds/` (1080×1920 عمودي، معتمة)

splash_background.png · main_menu_background.png · world_map_background.png · city_background.png · highway_background.png · downtown_background.png · industrial_background.png · extreme_city_background.png · victory_background.png · game_over_background.png

### و. أيقونات العوالم — `assets/images/worlds/` (320×320، معتمة)

world_01.png (شوارع المدينة) · world_02.png (الطريق السريع) · world_03.png (وسط المدينة) · world_04.png (المنطقة الصناعية) · world_05.png (المدينة القصوى)

---

## 2. الصوت (Audio)

**النوع المطلوب: MP3**. الملفات الحالية صامتة (Placeholder) لتفادي أي خطأ عند البناء، ولا تُصدر أي صوت — استبدلها بنفس الاسم والمسار.

### أ. الموسيقى — `assets/audio/music/` (مقترح: 30–90 ثانية، قابلة للتكرار Loop)

| الملف | يُشغَّل في |
|---|---|
| menu_music.mp3 | القائمة الرئيسية / Splash |
| world_01_music.mp3 | عالم شوارع المدينة |
| world_02_music.mp3 | عالم الطريق السريع |
| world_03_music.mp3 | عالم وسط المدينة |
| world_04_music.mp3 | عالم المنطقة الصناعية |
| world_05_music.mp3 | عالم المدينة القصوى |
| victory_music.mp3 | شاشة الفوز / الفوز النهائي |
| game_over_music.mp3 | شاشة انتهاء اللعبة |

### ب. المؤثرات الصوتية (SFX) — `assets/audio/sfx/` (مقترح: أقل من ثانية واحدة لكل ملف)

| الملف | يُشغَّل عند |
|---|---|
| button_click.mp3 | الضغط على أي زر |
| can_collect.mp3 | جمع علبة طاقة |
| coin_collect.mp3 | جمع عملة |
| jump.mp3 | القفز |
| slide.mp3 | الانزلاق |
| player_hit.mp3 | الاصطدام بعائق |
| shield_break.mp3 | امتصاص الدرع لضربة |
| magnet_activate.mp3 | تفعيل المغناطيس |
| speed_boost.mp3 | تفعيل تعزيز السرعة |
| invincibility.mp3 | تفعيل الحصانة |
| checkpoint.mp3 | الوصول لنقطة تفتيش |
| level_start.mp3 | بداية المرحلة |
| level_complete.mp3 | إكمال المرحلة |
| game_over.mp3 | انتهاء الأرواح |

---

## 3. كيف تستبدل الأصول بفنك الخاص

1. لا تُغيّر أي اسم ملف أو مسار — فقط استبدل محتوى الملف بنفس الاسم بالضبط (استخدم أداة مثل `cp` أو اسحب وأفلت في مستكشف الملفات).
2. بعد الاستبدال شغّل:
   ```
   flutter clean
   flutter pub get
   ```
3. إن أضفت ملفًا بامتداد مختلف (مثلاً `.jpg` بدل `.png`، أو `.wav`/`.ogg` بدل `.mp3`) يجب تحديث المسار المطابق في:
   - `ASSET_MANIFEST.md` / `AUDIO_MANIFEST.md` (للتوثيق فقط)
   - مكان الاستخدام في الكود (`RunnerModel`, `ObstacleData`, `ItemData`, `AudioManager`, إلخ) — أو ببساطة أعد تسمية ملفك الجديد بنفس الامتداد `.png`/`.mp3` لتفادي أي تعديل كود.
4. إذا نسيت أو تأخرت في إضافة صورة، **لن يتعطل التطبيق** — كل صورة لها رسم بديل (Fallback Painter) مبرمج بـ Canvas يظهر تلقائيًا.
