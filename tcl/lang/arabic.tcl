# arabic.tcl
# Text for menu names and status bar help messages in Arabic.
# First created for scidCommunitiy by Hugh Whelan

proc setLanguage_Q {} {

# File menu:
menuText Q File "ملف" 0
menuText Q FileNew "جديد..." 0 {إنشاء قاعدة بيانات Scid جديدة}
menuText Q FileOpen "يفتح..." 0 {افتح قاعدة بيانات Scid الموجودة}
menuText Q FileClose "يغلق" 0 {أغلق قاعدة بيانات Scid النشطة}
menuText Q FileFinder "مكتشف" 0 {افتح نافذة الباحث عن الملفات}
menuText Q FileBookmarks "الإشارات المرجعية" 0 {قائمة الإشارات المرجعية}
menuText Q FileBookmarksAdd "إضافة إشارة مرجعية" 0 \
  {قم بوضع إشارة مرجعية على لعبة قاعدة البيانات الحالية وموقعها}
menuText Q FileBookmarksFile "إشارة مرجعية للملف" 0 \
  {قم بتقديم إشارة مرجعية للعبة الحالية والموقع الحالي}
menuText Q FileBookmarksEdit "تحرير الإشارات المرجعية..." 0 \
  {تحرير قوائم الإشارات المرجعية}
menuText Q FileBookmarksList "عرض المجلدات كقائمة واحدة" 0 \
  {عرض مجلدات الإشارات المرجعية كقائمة واحدة، وليس قوائم فرعية}
menuText Q FileBookmarksSub "عرض المجلدات كقوائم فرعية" 0 \
  {عرض مجلدات الإشارات المرجعية كقوائم فرعية، وليس قائمة واحدة}
menuText Q FileMaint "صيانة" 0 {أدوات صيانة قاعدة البيانات Scid}
menuText Q FileMaintWin "نافذة الصيانة" 0 \
  {افتح/أغلق نافذة صيانة قاعدة بيانات Scid}
menuText Q FileMaintCompact "قاعدة بيانات مضغوطة..." 0 \
  {ضغط ملفات قاعدة البيانات وإزالة الألعاب المحذوفة والأسماء غير المستخدمة}
menuText Q FileMaintClass "ألعاب التصنيف البيئي..." 2 \
  {إعادة حساب رمز ECO لجميع الألعاب}
menuText Q FileMaintSort "فرز قاعدة البيانات..." 0 \
  {فرز كافة الألعاب في قاعدة البيانات}
menuText Q FileMaintDelete "حذف الألعاب التوأم..." 0 \
  {ابحث عن الألعاب المزدوجة وقم بتعيينها ليتم حذفها}
menuText Q FileMaintTwin "نافذة المدقق المزدوج" 0 \
  {فتح/تحديث نافذة المدقق المزدوج}
menuText Q FileMaintName "تهجئة الاسم" 0 {أدوات تحرير الأسماء والتهجئة}
menuText Q FileMaintNameEditor "محرر الاسم" 0 \
  {فتح/إغلاق نافذة محرر الأسماء}
menuText Q FileMaintNamePlayer "التدقيق الإملائي لأسماء اللاعبين..." 11 \
  {أسماء مشغلات التدقيق الإملائي باستخدام ملف التدقيق الإملائي}
menuText Q FileMaintNameEvent "التدقيق الإملائي لأسماء الأحداث..." 11 \
  {أسماء أحداث التدقيق الإملائي باستخدام ملف التدقيق الإملائي}
menuText Q FileMaintNameSite "أسماء مواقع التدقيق الإملائي..." 11 \
  {أسماء مواقع التدقيق الإملائي باستخدام ملف التدقيق الإملائي}
menuText Q FileMaintNameRound "التدقيق الإملائي لأسماء الجولة..." 11 \
  {التدقيق الإملائي للأسماء المستديرة باستخدام ملف التدقيق الإملائي}
menuText Q FileReadOnly "للقراءة فقط..." 0 \
  {التعامل مع قاعدة البيانات الحالية على أنها للقراءة فقط، مما يمنع التغييرات}
menuText Q FileSwitch "التبديل إلى قاعدة البيانات" 0 \
  {التبديل إلى قاعدة بيانات مفتوحة مختلفة}
menuText Q FileOpenLichessTournament "بطولة Lichess المفتوحة" 0 {قم بتنزيل وفتح مباريات البث المباشر لبطولات Lichess}
menuText Q FileImportLichess "قم باستيراد Lichess الخاص بي" 0 {قم باستيراد الألعاب من حساب Lichess الخاص بك}
menuText Q FileImportChessCom "قم باستيراد موقع chess.com الخاص بي" 0 {قم باستيراد الألعاب من حسابك على موقع chess.com}
menuText Q FileExit "مخرج" 1 {خروج سكيد}
menuText Q FileMaintFixBase "قاعدة الإصلاح" 0 {حاول إصلاح القاعدة التالفة}

# Edit menu:
menuText Q Edit "يحرر" 0
menuText Q EditAdd "إضافة الاختلاف" 0 {أضف شكلاً مختلفًا في هذه الخطوة في اللعبة}
menuText Q EditDelete "حذف الاختلاف" 0 {حذف صيغة لهذه الخطوة}
menuText Q EditFirst "قم بإجراء الاختلاف الأول" 5 \
  {قم بترقية أحد الأشكال ليكون الأول في القائمة}
menuText Q EditMain "تعزيز الاختلاف إلى الخط الرئيسي" 21 \
  {قم بترويج الاختلاف ليكون الخط الرئيسي}
menuText Q EditTrial "حاول الاختلاف" 0 \
  {بدء/إيقاف الوضع التجريبي، لاختبار فكرة ما على السبورة}
menuText Q EditStrip "يجرد" 3 {إزالة التعليقات أو الاختلافات من هذه اللعبة}
menuText Q EditUndo "تراجع" 0 {التراجع عن التغيير الأخير في اللعبة}
menuText Q EditRedo "إعادة" 0 {إعادة آخر تغيير في اللعبة}
menuText Q EditStripComments "تعليقات" 0 \
  {تجريد جميع التعليقات والشروح من هذه اللعبة}
menuText Q EditStripVars "الاختلافات" 0 {تجريد كافة الاختلافات من هذه اللعبة}
menuText Q EditStripBegin "يتحرك من البداية" 1 \
  {يتحرك الشريط من بداية اللعبة}
menuText Q EditStripEnd "ينتقل إلى النهاية" 0 \
  {يتحرك الشريط إلى نهاية اللعبة}
menuText Q EditReset "قاعدة الحافظة فارغة" 0 \
  {إعادة تعيين قاعدة الحافظة لتكون فارغة تماما}
menuText Q EditCopy "انسخ هذه اللعبة إلى Clipbase" 0 \
  {انسخ هذه اللعبة إلى قاعدة بيانات Clipbase}
menuText Q EditPaste "لعبة لصق Clipbase الأخيرة" 0 \
  {الصق لعبة Clipbase النشطة هنا}
menuText Q EditPastePGN "لصق نص الحافظة كلعبة PGN..." 18 \
  {قم بتفسير نص الحافظة على أنه لعبة في تدوين PGN والصقه هنا}
menuText Q EditSetup "إعداد لوحة البدء..." 0 \
  {قم بتعيين موضع البداية لهذه اللعبة}
menuText Q EditCopyBoard "نسخ الموقف" 6 \
  {انسخ اللوحة الحالية بتدوين FEN إلى تحديد النص (الحافظة)}
menuText Q EditPasteBoard "لصق لوحة البداية" 12 \
  {تعيين لوحة البداية من تحديد النص الحالي (الحافظة)}
menuText Q ConfigureScid "التفضيلات..." 0 {قم بتكوين كافة الخيارات لـ SCID}

# Game menu:
menuText Q Game "لعبة" 0
menuText Q GameNew "لعبة جديدة" 0 {إعادة التعيين إلى لعبة فارغة}
menuText Q GameFirst "تحميل اللعبة الأولى" 5 {قم بتحميل اللعبة الأولى التي تمت تصفيتها}
menuText Q GamePrev "تحميل اللعبة السابقة" 5 {قم بتحميل اللعبة التي تمت تصفيتها السابقة}
menuText Q GameReload "إعادة تحميل اللعبة الحالية" 3 \
  {أعد تحميل هذه اللعبة، وتجاهل أي تغييرات تم إجراؤها}
menuText Q GameNext "تحميل اللعبة التالية" 7 {قم بتحميل اللعبة المصفاة التالية}
menuText Q GameLast "تحميل اللعبة الاخيرة" 8 {قم بتحميل آخر لعبة تمت تصفيتها}
menuText Q GameRandom "تحميل لعبة عشوائية" 8 {تحميل لعبة تمت تصفيتها بشكل عشوائي}
menuText Q GameNumber "تحميل رقم اللعبة..." 5 \
  {قم بتحميل اللعبة عن طريق إدخال رقمها}
menuText Q GameReplace "حفظ: استبدال اللعبة..." 6 \
  {احفظ هذه اللعبة لتحل محل الإصدار القديم}
menuText Q GameAdd "حفظ: إضافة لعبة جديدة..." 6 \
  {احفظ هذه اللعبة كلعبة جديدة في قاعدة البيانات}
menuText Q GameDeepest "تحديد الفتح" 0 \
  {انتقل إلى أعمق موضع للعبة مدرج في كتاب ECO}
menuText Q GameGotoMove "الانتقال إلى رقم النقل..." 5 \
  {انتقل إلى رقم الحركة المحدد في اللعبة الحالية}
menuText Q GameNovelty "البحث عن الجدة..." 7 \
  {ابحث عن الخطوة الأولى في هذه اللعبة التي لم يتم لعبها من قبل}

# Search Menu:
menuText Q Search "يبحث" 0
menuText Q SearchReset "إعادة تعيين عامل التصفية" 0 {أعد ضبط الفلتر بحيث يتم تضمين كافة الألعاب}
menuText Q SearchNegate "نفي التصفية" 0 {قم بإلغاء عامل التصفية ليشمل الألعاب المستبعدة فقط}
menuText Q SearchCurrent "المجلس الحالي..." 0 {البحث عن موقف مجلس الإدارة الحالي}
menuText Q SearchHeader "رأس..." 0 {البحث حسب معلومات الرأس (اللاعب، الحدث، إلخ).}
menuText Q SearchMaterial "المادة/النمط..." 0 {ابحث عن أنماط المواد أو اللوحة}
menuText Q SearchUsing "استخدام ملف البحث..." 0 {البحث باستخدام ملف SearchOptions}

# Windows menu:
menuText Q Windows "ويندوز" 0
menuText Q WindowsComment "محرر التعليق" 0 {فتح/إغلاق محرر التعليقات}
menuText Q WindowsGList "قائمة اللعبة" 0 {فتح/إغلاق نافذة قائمة الألعاب}
menuText Q WindowsPGN "نافذة بي جي إن" 0 \
  {افتح/أغلق نافذة PGN (تدوين اللعبة).}
menuText Q WindowsPList "مكتشف اللاعب" 2 {فتح/إغلاق مكتشف اللاعب}
menuText Q WindowsTmt "مكتشف البطولة" 2 {فتح/إغلاق مكتشف البطولة}
menuText Q WindowsSwitcher "مبدل قاعدة البيانات" 0 \
  {افتح/أغلق نافذة مبدل قاعدة البيانات}
menuText Q WindowsMaint "نافذة الصيانة" 0 \
  {افتح/أغلق نافذة الصيانة}
menuText Q WindowsECO "متصفح ايكو" 0 {فتح/إغلاق نافذة متصفح ECO}
menuText Q WindowsStats "نافذة الإحصائيات" 0 \
  {فتح/إغلاق نافذة إحصائيات التصفية}
menuText Q WindowsTree "نافذة الشجرة" 0 {فتح/إغلاق نافذة الشجرة}
menuText Q WindowsBook "نافذة الكتاب" 0 {فتح/إغلاق نافذة الكتاب}
menuText Q WindowsCorrChess "نافذة المراسلة" 0 {فتح/إغلاق نافذة المراسلات}
menuText Q WindowsGraph "الرسم البياني للتحليل" 0 {افتح نافذة الرسم البياني بأوقات التحركات وتقييماتها}

# Tools menu:
menuText Q Tools "أدوات" 0
menuText Q ToolsConfigureEngines "تكوين المحركات" 10 {إدارة تكوين المحركات}
menuText Q ToolsAnalysis "محرك التحليل..." 0 \
  {تشغيل/إيقاف محرك تحليل الشطرنج}
menuText Q ToolsAnalysis2 "محرك التحليل رقم 2..." 17 \
  {تشغيل/إيقاف محرك تحليل الشطرنج الثاني}
menuText Q ToolsCross "طاولة متقاطعة" 0 {عرض البطولة crosstable لهذه اللعبة}
menuText Q ToolsFilterGraph "Rel. الرسم البياني للتصفية" 12 {فتح/إغلاق نافذة الرسم البياني للتصفية للقيم النسبية}
menuText Q ToolsAbsFilterGraph "القيمة المطلقة. الرسم البياني للتصفية" 7 {فتح/إغلاق نافذة الرسم البياني للتصفية للقيم المطلقة}
menuText Q ToolsOpReport "تقرير الافتتاح" 0 {إنشاء تقرير افتتاحي للموقف الحالي}
menuText Q ToolsOpenBaseAsTree "قاعدة مفتوحة كالشجرة..." 0   {افتح قاعدة واستخدمها في نافذة الشجرة}
menuText Q ToolsOpenRecentBaseAsTree "افتح القاعدة الأخيرة كشجرة" 0   {افتح قاعدة حديثة واستخدمها في نافذة الشجرة}
menuText Q ToolsTracker "تعقب القطعة"  6 {افتح نافذة تعقب القطعة}
menuText Q ToolsTraining "تمرين"  0 {أدوات التدريب (التكتيكات، الافتتاحيات،...)}
menuText Q ToolsTacticalGame "لعبة تكتيكية"  0 {العب لعبة بالتكتيكات}
menuText Q ToolsSeriousGame "لعبة خطيرة"  0 {العب لعبة جدية}
menuText Q ToolsTrainOpenings "الفتحات"  0 {تدريب مع ذخيرة}
menuText Q ToolsTrainReviewGame "لعبة المراجعة"  0 {تخمين التحركات لعبت في لعبة}
menuText Q ToolsTrainTactics "التكتيكات"  0 {حل التكتيكات}
menuText Q ToolsTrainCalvar "حساب الاختلافات"  0 {حساب التدريب على الاختلافات}
menuText Q ToolsTrainFindBestMove "العثور على أفضل خطوة"  0 {العثور على أفضل خطوة}
menuText Q ToolsTrainFics "العب على FICS"  0 {العب على freechess.org}
menuText Q ToolsEngineTournament "بطولة المحرك"  0 {بدء البطولة بين محركات الشطرنج}
menuText Q ToolsTimeAnalysis "تحليل الوقت" 0 {عرض الرسم البياني للوقت على مدار الساعة للعبة الحالية}
menuText Q ToolsBookTuning "ضبط الكتاب" 0 {ضبط الكتاب}
menuText Q ToolsDownloadTWIC "تحميل العاب تويك" 0 {قم بتنزيل أحدث ألعاب The Week In Chess (TWIC).}
menuText Q ToolsConnectHardware "قم بتوصيل الأجهزة" 8 {قم بتوصيل الأجهزة الخارجية}
menuText Q ToolsConnectHardwareConfigure "تكوين..." 0 {تكوين الأجهزة الخارجية والاتصال}
menuText Q ToolsConnectHardwareNovagCitrineConnect "قم بتوصيل نوفاج سيترين" 8 {قم بتوصيل Novag Citrine مع Scid}
menuText Q ToolsConnectHardwareInputEngineConnect "ربط محرك الإدخال" 8 {قم بتوصيل محرك الإدخال (مثل لوحة DGT) بـ Scid}

menuText Q ToolsPInfo "معلومات اللاعب"  0 \
  {فتح/تحديث نافذة معلومات اللاعب}
menuText Q ToolsPlayerReport "تقرير اللاعب..." 3 \
  {إنشاء تقرير لاعب}
menuText Q ToolsRating "الرسم البياني التقييم" 0 \
  {رسم بياني لتاريخ التصنيف للاعبين الحاليين في اللعبة}
menuText Q ToolsExpCurrent "تصدير اللعبة الحالية" 8 \
  {كتابة اللعبة الحالية إلى ملف نصي}
menuText Q ToolsExpCurrentPGN "تصدير اللعبة إلى ملف PGN..." 15 \
  {اكتب اللعبة الحالية إلى ملف PGN}
menuText Q ToolsExpCurrentHTML "تصدير اللعبة إلى ملف HTML..." 15 \
  {كتابة اللعبة الحالية إلى ملف HTML}
menuText Q ToolsExpCurrentHTMLJS "تصدير اللعبة إلى ملف HTML وJavaScript..." 15 {اكتب اللعبة الحالية إلى ملف HTML وJavaScript}
menuText Q ToolsExpFilter "تصدير جميع ألعاب التصفية" 1 \
  {كتابة كافة الألعاب التي تمت تصفيتها إلى ملف نصي}
menuText Q ToolsExpFilterPGN "تصدير الفلتر إلى ملف PGN..." 17 \
  {اكتب جميع الألعاب التي تمت تصفيتها في ملف PGN}
menuText Q ToolsExpFilterHTML "تصدير عامل التصفية إلى ملف HTML..." 17 \
  {اكتب جميع الألعاب التي تمت تصفيتها في ملف HTML}
menuText Q ToolsExpFilterHTMLJS "تصدير عامل التصفية إلى ملف HTML وJavaScript..." 17 {اكتب جميع الألعاب التي تمت تصفيتها في ملف HTML وJavaScript}
menuText Q ToolsImportOne "استيراد لعبة PGN واحدة..." 0 \
  {استيراد لعبة من نص PGN}
menuText Q ToolsImportFile "استيراد الألعاب من ملفات PGN..." 7 {استيراد الألعاب من ملف (ملفات) PGN}
menuText Q ToolsStartEngine1 "تشغيل المحرك 1" 13  {تشغيل المحرك 1}
menuText Q ToolsStartEngine2 "تشغيل المحرك 2" 13  {تشغيل المحرك 2}
menuText Q ToolsCaptureBoard "التقاط اللوحة الحالية..." 5  {احفظ اللوحة الحالية كصورة.}

# Play menu
menuText Q Play "يلعب" 0

# --- Correspondence Chess
menuText Q CCResign "استقالة" 1 {الاستقالة (ليس عبر البريد الإلكتروني)}
menuText Q CCClaimDraw "رسم المطالبة" 6 {أرسل النقل والمطالبة بالسحب (وليس عبر البريد الإلكتروني)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText Q Options "خيارات" 0
menuText Q OptionsBoardGraphics "المربعات..." 0 {حدد القوام للمربعات}
translate Q OptionsBGW {حدد الملمس للمربعات}
translate Q OptionsBoardGraphicsText {حدد ملفات الرسوم للمربعات البيضاء والسوداء:}
menuText Q OptionsBoardNames "اسماء اللاعبين..." 0 {تحرير أسماء اللاعبين}
menuText Q OptionsExport "تصدير" 0 {تغيير خيارات تصدير النص}
menuText Q OptionsFonts "الخطوط" 0 {تغيير الخطوط}
menuText Q OptionsFontsRegular "عادي" 0 {تغيير الخط العادي}
menuText Q OptionsFontsMenu "قائمة طعام" 0 {تغيير خط القائمة}
menuText Q OptionsFontsSmall "صغير" 0 {تغيير الخط الصغير}
menuText Q OptionsFontsTiny "صغير الحجم" 0 {تغيير الخط الصغير}
menuText Q OptionsFontsFixed "مُثَبَّت" 0 {تغيير الخط ذو العرض الثابت}
menuText Q OptionsGInfo "معلومات اللعبة" 0 {خيارات معلومات اللعبة}
menuText Q OptionsLanguage "لغة" 0 {اختر لغة القائمة}
menuText Q OptionsMovesTranslatePieces "ترجمة القطع" 0 {ترجمة الحرف الأول من القطع}
menuText Q OptionsMovesHighlightLastMove "تسليط الضوء على الخطوة الأخيرة" 0 {تسليط الضوء على الخطوة الأخيرة}
menuText Q OptionsMovesHighlightLastMoveDisplay "ساحة العرض" 0 {عرض تسليط الضوء على الخطوة الأخيرة}
menuText Q OptionsMovesHighlightLastMoveWidth "عرض" 0 {سمك الخط}
menuText Q OptionsMovesHighlightLastMoveColor "لون" 0 {لون الخط}
menuText Q OptionsMovesHighlightLastMoveArrow "عرض السهم" 0 {إظهار السهم مع التمييز}
menuText Q OptionsMovesHighlightLastMoveNag "إظهار رموز التعليقات التوضيحية" 0
menuText Q OptionsMovesHighlightLastMoveEval "إظهار رموز التقييم" 0
menuText Q OptionsMoves "التحركات" 0 {نقل خيارات الدخول}
menuText Q OptionsMovesAnimate "وقت الرسوم المتحركة" 1 \
  {اضبط مقدار الوقت المستخدم لتحريك التحركات}
menuText Q OptionsMovesDelay "تأخير وقت التشغيل التلقائي..." 1 \
  {اضبط التأخير الزمني لوضع التشغيل التلقائي}
menuText Q OptionsMovesCoord "تنسيق إدخال الحركة" 0 \
  {قبول إدخال النقل بنمط الإحداثيات (على سبيل المثال، "g1f3")}
menuText Q OptionsMovesSuggest "عرض التحركات المقترحة" 0 \
  {تشغيل/إيقاف اقتراح التحرك}
menuText Q OptionsShowVarPopup "إظهار نافذة الاختلافات" 0 {قم بتشغيل/إيقاف عرض نافذة الاختلافات}
menuText Q OptionsMovesSpace "أضف مسافات بعد رقم النقل" 0 {أضف مسافات بعد رقم النقل}
menuText Q OptionsMovesLichess "تنسيق Lichess/ChessBase للتعليقات التوضيحية" 0 {استخدم تنسيق Lichess/ChessBase للعلامات المربعة والأسهم}
menuText Q OptionsMovesKey "إكمال لوحة المفاتيح" 0 \
  {تشغيل/إيقاف الإكمال التلقائي لتحريك لوحة المفاتيح}
menuText Q OptionsMovesShowVarArrows "إظهار الأسهم للاختلافات" 0 {تشغيل/إيقاف تشغيل الأسهم التي توضح التحركات في الأشكال المختلفة}
menuText Q OptionsMovesShowEngineVariationArrows "إظهار الأسهم لأشكال المحرك المختلفة" 0 {تشغيل/إيقاف تشغيل الأسهم التي توضح خطوط اختلاف المحرك في وضع multiPV}
menuText Q OptionsMovesGlossOfDanger "لون مرمز لمعان الخطر" 0 {تشغيل/إيقاف لمعان الخطر المرمز بالألوان}
translate Q OptionsMovesTreeDepth {نافذة الشجرة الافتراضية تحرك العمق}
menuText Q OptionsNumbers "تنسيق الرقم" 0 {حدد تنسيق الأرقام}
menuText Q OptionsTheme "سمة" 0 {تغيير شكل الواجهة}
menuText Q OptionsWindows "ويندوز" 0 {خيارات النافذة}
menuText Q OptionsSounds "يبدو" 2 {تكوين أصوات إعلان التحرك}
menuText Q OptionsResources "موارد..." 0 {اختر ملفات ومجلدات الموارد}
menuText Q OptionsWindowsDock "نوافذ قفص الاتهام" 0 {نوافذ الإرساء (يحتاج إلى إعادة التشغيل)}
menuText Q OptionsWindowsSaveLayout "حفظ التخطيط" 0 {حفظ التخطيط}
menuText Q OptionsWindowsRestoreLayout "استعادة التخطيط" 0 {استعادة التخطيط}
menuText Q OptionsWindowsShowGameInfo "عرض معلومات اللعبة" 0 {عرض معلومات اللعبة}
menuText Q OptionsWindowsAutoLoadLayout "تحميل تلقائي للتخطيط الأول" 0 {التحميل التلقائي للتخطيط الأول عند بدء التشغيل}
menuText Q OptionsECO "ملف منظمة التعاون الاقتصادي" 7 {قم بتحميل ملف تصنيف ECO}
menuText Q OptionsSpell "ملف التدقيق الإملائي" 11 \
  {قم بتحميل ملف التدقيق الإملائي Scid}
menuText Q OptionsTable "دليل قاعدة الجدول" 10 \
  {حدد ملف قاعدة الجدول؛ سيتم استخدام جميع قواعد الجداول الموجودة في الدليل الخاص بها}
menuText Q OptionsRecent "الملفات الأخيرة" 0 {قم بتغيير عدد الملفات الحديثة المعروضة في قائمة "ملف".}
menuText Q OptionsBooksDir "دليل الكتب" 0 {يضبط دليل الكتب الافتتاحية}
menuText Q OptionsTacticsBasesDir "دليل القواعد" 0 {يحدد دليل قواعد التكتيكات (التدريب).}
menuText Q OptionsPhotosDir "دليل الصور" 0 {يضبط دليل قواعد الصور}
menuText Q OptionsThemeDir "ملف الموضوع (الموضوعات)."  0 {قم بتحميل ملف حزمة سمة واجهة المستخدم الرسومية}
menuText Q OptionsSave "حفظ الخيارات" 0 "Save all settable options to the file $::optionsFile"
menuText Q OptionsAutoSave "خيارات الحفظ التلقائي عند الخروج" 0 \
  {حفظ جميع الخيارات تلقائيًا عند الخروج من Scid}

# Help menu:
menuText Q Help "يساعد" 0
menuText Q HelpContents "محتويات" 0 {إظهار صفحة محتويات المساعدة}
menuText Q HelpIndex "فِهرِس" 0 {إظهار صفحة فهرس المساعدة}
menuText Q HelpGuide "دليل سريع" 0 {إظهار صفحة تعليمات الدليل السريع}
menuText Q HelpHints "تلميحات" 0 {إظهار صفحة المساعدة الخاصة بالتلميحات}
menuText Q HelpContact "معلومات الاتصال" 1 {إظهار صفحة المساعدة الخاصة بمعلومات الاتصال}
menuText Q HelpTip "نصيحة اليوم" 0 {عرض نصيحة Scid مفيدة}
menuText Q HelpStartup "نافذة بدء التشغيل" 0 {إظهار نافذة بدء التشغيل}
menuText Q HelpAbout "عن" 0 {معلومات عن مجتمع Scid}

# Toolbar tooltips:
menuText Q RotateBoard "تدوير اللوحة" 0 {تدوير اللوحة}

# Game info box popup menu:
menuText Q GInfoHideNext "إخفاء الخطوة التالية" 0
menuText Q GInfoMaterial "إظهار قيم المواد" 0
menuText Q GInfoFEN "عرض الفين" 5
menuText Q GInfoMarks "إظهار المربعات الملونة والسهام" 5
menuText Q GInfoWrap "لف الخطوط الطويلة" 0
menuText Q GInfoFullComment "عرض التعليق الكامل" 10
menuText Q GInfoPhotos "عرض الصور" 5
menuText Q GInfoTBNothing "قواعد الطاولة: لا شيء" 12
menuText Q GInfoTBResult "قواعد الجدول: النتيجة فقط" 12
menuText Q GInfoTBAll "قواعد الطاولة: النتيجة وأفضل التحركات" 19
menuText Q GInfoDelete "(الامم المتحدة) حذف هذه اللعبة" 4
menuText Q GInfoMark "(الامم المتحدة) ضع علامة على هذه اللعبة" 4
menuText Q GInfoInformant "تكوين قيم المخبرين" 0

# General buttons:
translate Q Back {خلف}
translate Q Browse {تصفح}
translate Q Cancel {يلغي}
translate Q Continue {يكمل}
translate Q Clear {واضح}
translate Q Close {يغلق}
translate Q Contents {محتويات}
translate Q Defaults {الافتراضيات}
translate Q InvertSearch {عكس البحث}
translate Q Delete {يمسح}
translate Q Graph {رسم بياني}
translate Q Help {يساعد}
translate Q Hide {يخفي}
translate Q Import {يستورد}
translate Q Index {فِهرِس}
translate Q LoadGame {تحميل لعبة}
translate Q BrowseGame {تصفح اللعبة}
translate Q MergeGame {لعبة الدمج}
translate Q MergeGames {العاب دمج}
translate Q Preview {معاينة}
translate Q Revert {يرجع}
translate Q Save {يحفظ}
translate Q Search {يبحث}
translate Q Stop {قف}
translate Q Store {محل}
translate Q Update {تحديث}
translate Q ChangeOrient {تغيير اتجاه النافذة}
translate Q ShowIcons {إظهار الأيقونات}
translate Q None {لا أحد}
translate Q First {أولاً}
translate Q Current {حاضِر}
translate Q Last {آخر}

# General messages:
translate Q game {لعبة}
translate Q games {ألعاب}
translate Q move {يتحرك}
translate Q moves {التحركات}
translate Q all {الجميع}
translate Q Yes {نعم}
translate Q No {لا}
translate Q Both {كلاهما}
translate Q King {ملِك}
translate Q Queen {ملكة}
translate Q Rook {الرخ}
translate Q Bishop {أسقف}
translate Q Knight {فارس}
translate Q Pawn {البيدق}
translate Q White {أبيض}
translate Q Black {أسود}
translate Q Player {لاعب}
translate Q Rating {تصنيف}
translate Q RatingDiff {فرق التقييم (أبيض - أسود)}
translate Q AverageRating {متوسط ​​التقييم}
translate Q Event {حدث}
translate Q Site {موقع}
translate Q Country {دولة}
translate Q IgnoreColors {تجاهل الألوان}
translate Q Date {تاريخ}
translate Q EventDate {تاريخ الحدث}
translate Q Decade {عقد}
translate Q Year {سنة}
translate Q Month {شهر}
translate Q Months {يناير فبراير مارس أبريل مايو يونيو يوليو أغسطس سبتمبر أكتوبر نوفمبر ديسمبر}
translate Q Days {الأحد، الإثنين، الثلاثاء، الأربعاء، الخميس، الجمعة، السبت}
translate Q YearToToday {-1Y}
translate Q YearToTodayTooltip {تحديد التاريخ من سنة واحدة إلى اليوم}
translate Q Result {نتيجة}
translate Q Round {دائري}
translate Q Length {طول}
translate Q ECOCode {رمز منظمة التعاون الاقتصادي}
translate Q ECO {سابقة بمعنى البِيْئَة}
translate Q Deleted {تم الحذف}
translate Q SearchResults {نتائج البحث}
translate Q OpeningTheDatabase {فتح قاعدة البيانات}
translate Q Database {قاعدة البيانات}
translate Q Filter {فلتر}
translate Q noGames {لا توجد ألعاب}
translate Q allGames {جميع الألعاب}
translate Q empty {فارغ}
translate Q clipbase {قاعدة القصاصات}
translate Q score {نتيجة}
translate Q StartPos {وضع البداية}
translate Q Total {المجموع}
translate Q readonly {للقراءة فقط}

# Standard error messages:
translate Q ErrNotOpen {هذه ليست قاعدة بيانات مفتوحة.}
translate Q ErrReadOnly {قاعدة البيانات هذه للقراءة فقط؛ لا يمكن تغييره.}
translate Q ErrSearchInterrupted {تمت مقاطعة البحث. النتائج غير مكتملة.}
translate Q ErrNoClockComments {لم يتم العثور على تعليقات على مدار الساعة [%clk] في هذه اللعبة.  أضف أوقات الساعة عبر نافذة التعليقات (Ctrl+E) لاستخدام هذه الميزة.}
translate Q ErrFileInUse {خطأ: الملف قيد الاستخدام بالفعل. الرجاء إغلاق أي تطبيق آخر يستخدم قاعدة البيانات هذه. إذا تم إغلاق البرنامج بشكل غير متوقع، فقد تحتاج إلى حذف ملف .lock المرتبط بقاعدة البيانات.}




# Game information:
translate Q twin {التوأم}
translate Q deleted {تم حذفه}
translate Q comment {تعليق}
translate Q hidden {مختفي}
translate Q LastMove {الخطوة الأخيرة}
translate Q NextMove {التالي}
translate Q GameStart {بداية اللعبة}
translate Q LineStart {بداية السطر}
translate Q GameEnd {نهاية اللعبة}
translate Q LineEnd {نهاية السطر}

# Player information:
translate Q PInfoAll {نتائج <b>جميع</b> الألعاب}
translate Q PInfoFilter {نتائج لألعاب <b>التصفية</b>}
translate Q PInfoAgainst {النتائج ضد}
translate Q PInfoMostWhite {الفتحات الأكثر شيوعًا باللون الأبيض}
translate Q PInfoMostBlack {الفتحات الأكثر شيوعًا باللون الأسود}
translate Q PInfoRating {تاريخ التقييم}
translate Q PInfoBio {سيرة}
translate Q PInfoEditRatings {تحرير التقييمات}
translate Q PInfoEloFile {ملف}

# Tablebase information:
translate Q Draw {يرسم}
translate Q with {مع}
translate Q only {فقط}
translate Q lose {يخسر}
translate Q loses {يخسر}

# Tip of the day:
translate Q Tip {نصيحة}
translate Q TipAtStartup {نصيحة عند بدء التشغيل}
translate Q TipConvertPGN {يمكنك الحصول على أداء أفضل عن طريق تحويل ملفات PGN}

# Tree window menus:
menuText Q TreeFile "ملف" 0
menuText Q TreeFileFillWithBase "املأ ذاكرة التخزين المؤقت بالقاعدة" 0 {املأ ملف ذاكرة التخزين المؤقت بجميع الألعاب الموجودة في القاعدة الحالية}
menuText Q TreeFileFillWithGame "املأ ذاكرة التخزين المؤقت باللعبة" 0 {املأ ملف ذاكرة التخزين المؤقت باللعبة الحالية في القاعدة الحالية}
menuText Q TreeFileSetCacheSize "حجم ذاكرة التخزين المؤقت" 0 {ضبط حجم ذاكرة التخزين المؤقت}
menuText Q TreeFileCacheInfo "معلومات ذاكرة التخزين المؤقت" 0 {الحصول على معلومات حول استخدام ذاكرة التخزين المؤقت}
menuText Q TreeFileSave "حفظ ملف ذاكرة التخزين المؤقت" 0 {احفظ ملف شجرة التخزين المؤقت (.stc).}
menuText Q TreeFileFill "ملء ملف ذاكرة التخزين المؤقت" 0 \
  {املأ ملف ذاكرة التخزين المؤقت بمواضع الفتح الشائعة}
menuText Q TreeFileBest "قائمة أفضل الألعاب" 0 {عرض قائمة أفضل ألعاب الشجرة}
menuText Q TreeFileGraph "نافذة الرسم البياني" 0 {اعرض الرسم البياني لفرع الشجرة هذا}
menuText Q TreeFileCopy "انسخ نص الشجرة إلى الحافظة" 1 \
  {انسخ إحصائيات الشجرة إلى الحافظة}
menuText Q TreeFileClose "إغلاق نافذة الشجرة" 0 {أغلق نافذة الشجرة}
menuText Q TreeMask "قناع" 0
menuText Q TreeMaskNew "جديد" 0 {قناع جديد}
menuText Q TreeMaskOpen "يفتح" 0 {قناع مفتوح}
menuText Q TreeMaskOpenRecent "فتح الأخيرة" 0 {افتح القناع الأخير}
menuText Q TreeMaskSave "يحفظ" 0 {حفظ القناع}
menuText Q TreeMaskClose "يغلق" 0 {إغلاق القناع}
menuText Q TreeMaskFillWithGame "املأ باللعبة" 0 {املأ القناع باللعبة}
menuText Q TreeMaskFillWithBase "املأ بالقاعدة" 0 {املأ القناع بجميع الألعاب في القاعدة}
menuText Q TreeMaskInfo "معلومات" 0 {عرض إحصائيات القناع الحالي}
menuText Q TreeMaskDisplay "عرض خريطة القناع" 0 {إظهار بيانات القناع في شكل شجرة}
menuText Q TreeMaskSearch "يبحث" 0 {البحث في القناع الحالي}
menuText Q TreeSort "نوع" 0
menuText Q TreeSortAlpha "أبجديا" 0
menuText Q TreeSortECO "رمز منظمة التعاون الاقتصادي" 0
menuText Q TreeSortFreq "تكرار" 0
menuText Q TreeSortScore "نتيجة" 0
menuText Q TreeOpt "خيارات" 0
menuText Q TreeOptSlowmode "الوضع البطيء" 0 {الوضع البطيء للتحديثات (دقة عالية)}
menuText Q TreeOptFastmode "الوضع السريع" 0 {الوضع السريع للتحديثات (بدون نقل الحركة)}
menuText Q TreeOptFastAndSlowmode "الوضع السريع والبطيء" 0 {الوضع السريع ثم الوضع البطيء للتحديثات}
menuText Q TreeOptStartStop "التحديث التلقائي" 0 {تبديل التحديث التلقائي لنافذة الشجرة}
menuText Q TreeOptLock "قفل" 0 {قفل/فتح الشجرة لقاعدة البيانات الحالية}
menuText Q TreeOptTraining "تمرين" 0 {تشغيل/إيقاف وضع تدريب الشجرة}
menuText Q TreeOptDepth "تحرك العمق" 0 {عدد أنصاف الحركات المراد عرضها في الشجرة (1-4)}
menuText Q TreeOptAutosave "الحفظ التلقائي لملف ذاكرة التخزين المؤقت" 0 \
  {حفظ ملف ذاكرة التخزين المؤقت تلقائيًا عند إغلاق نافذة الشجرة}
menuText Q TreeHelp "يساعد" 0
menuText Q TreeHelpTree "مساعدة الشجرة" 0
menuText Q TreeHelpIndex "مؤشر المساعدة" 0
translate Q SaveCache {حفظ ذاكرة التخزين المؤقت}
translate Q Training {تمرين}
translate Q LockTree {قفل}
translate Q TreeDepth {عمق الشجرة (نصف التحركات):}
translate Q TreeLocked {مغلق}
translate Q TreeBest {أفضل}
translate Q TreeBestGames {أفضل ألعاب الشجرة}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate Q TreeTitleRow \
  {الحركة (التحركات) نقاط تردد ECO AvElo Perf AvYear %Draws %Win}
translate Q TreeTotal {المجموع}
translate Q DoYouWantToSaveFirst {هل تريد الحفظ أولا}
translate Q AddToMask {أضف إلى القناع}
translate Q RemoveFromMask {إزالة من القناع}
translate Q AddThisMoveToMask {أضف هذه الحركة إلى القناع}
translate Q SearchMask {البحث في القناع}
translate Q DisplayMask {قناع العرض}
translate Q Nag {رمز ناج}
translate Q Marker {علامة}
translate Q Include {يشمل}
translate Q Exclude {استبعاد}
translate Q MainLine {الخط الرئيسي}
translate Q Bookmark {إشارة مرجعية}
translate Q NewLine {خط جديد}
translate Q ToBeVerified {ليتم التحقق منها}
translate Q ToTrain {لتدريب}
translate Q Dubious {مشكوك فيه}
translate Q ToRemove {لإزالة}
translate Q NoMarker {لا علامة}
translate Q ColorMarker {لون}
translate Q WhiteMark {أبيض}
translate Q GreenMark {أخضر}
translate Q YellowMark {أصفر}
translate Q BlueMark {أزرق}
translate Q RedMark {أحمر}
translate Q CommentMove {تحرك التعليق}
translate Q CommentPosition {موقف التعليق}
translate Q AddMoveToMaskFirst {أضف الحركة إلى القناع أولاً}
translate Q OpenAMaskFileFirst {افتح ملف القناع أولاً}
translate Q Positions {المواقف}
translate Q Moves {التحركات}

# Finder window:
menuText Q FinderFile "ملف" 0
menuText Q FinderFileSubdirs "ابحث في الدلائل الفرعية" 0
menuText Q FinderFileClose "أغلق مكتشف الملفات" 0
menuText Q FinderSort "نوع" 0
menuText Q FinderSortType "يكتب" 0
menuText Q FinderSortSize "مقاس" 0
menuText Q FinderSortMod "معدل" 0
menuText Q FinderSortName "اسم" 0
menuText Q FinderSortPath "طريق" 0
menuText Q FinderTypes "أنواع" 0
menuText Q FinderTypesScid "قواعد بيانات Scid" 0
menuText Q FinderTypesOld "قواعد بيانات Scid ذات التنسيق القديم" 0
menuText Q FinderTypesPGN "ملفات PGN" 0
menuText Q FinderTypesEPD "ملفات EPD" 0
menuText Q FinderTypesRep "ملفات المرجع" 0
menuText Q FinderHelp "يساعد" 0
menuText Q FinderHelpFinder "مساعدة في البحث عن الملفات" 0
menuText Q FinderHelpIndex "مؤشر المساعدة" 0
translate Q FileFinder {مكتشف الملفات}
translate Q FinderDir {دليل}
translate Q FinderDirs {الدلائل}
translate Q FinderFiles {ملفات}
translate Q FinderUpDir {أعلى}
translate Q FinderCtxOpen {يفتح}
translate Q FinderCtxBackup {النسخ الاحتياطي}
translate Q FinderCtxCopy {ينسخ}
translate Q FinderCtxMove {يتحرك}
translate Q FinderCtxDelete {يمسح}

# Player finder:
menuText Q PListFile "ملف" 0
menuText Q PListFileUpdate "تحديث" 0
menuText Q PListFileClose "إغلاق الباحث عن اللاعب" 0
menuText Q PListSort "نوع" 0
menuText Q PListSortName "اسم" 0
menuText Q PListSortElo "إيلو" 0
menuText Q PListSortGames "ألعاب" 0
menuText Q PListSortOldest "الأقدم" 0
menuText Q PListSortNewest "الأحدث" 2

# Tournament finder:
menuText Q TmtFile "ملف" 0
menuText Q TmtFileUpdate "تحديث" 0
menuText Q TmtFileClose "إغلاق مكتشف البطولة" 0
menuText Q TmtSort "نوع" 0
menuText Q TmtSortDate "تاريخ" 0
menuText Q TmtSortPlayers "اللاعبين" 0
menuText Q TmtSortGames "ألعاب" 0
menuText Q TmtSortElo "إيلو" 0
menuText Q TmtSortSite "موقع" 0
menuText Q TmtSortEvent "حدث" 1
menuText Q TmtSortWinner "الفائز" 0
translate Q TmtLimit "حد القائمة"
translate Q TmtMeanElo "يعني ايلو"
translate Q TmtNone "لم يتم العثور على بطولات مطابقة."

# Graph windows:
menuText Q GraphFile "ملف" 0
menuText Q GraphFileColor "حفظ كـ بوستسكريبت ملون..." 8
menuText Q GraphFileGrey "حفظ كـ PostScript بتدرج رمادي..." 8
menuText Q GraphFileClose "إغلاق النافذة" 6
menuText Q GraphOptions "خيارات" 0
menuText Q GraphOptionsWhite "أبيض" 0
menuText Q GraphOptionsBlack "أسود" 0
menuText Q GraphOptionsBoth "كلاهما" 1
menuText Q GraphOptionsPInfo "معلومات اللاعب" 0
menuText Q GraphOptionsEloFile "Elo من ملف التصنيف" 0
menuText Q GraphOptionsEloDB "ايلو من قاعدة البيانات" 0
translate Q GraphFilterTitle "الرسم البياني للتصفية: التكرار لكل 1000 لعبة"
translate Q GraphAbsFilterTitle "الرسم البياني للتصفية: تكرار الألعاب"
translate Q ConfigureFilter "قم بتكوين المحاور X للسنة والتصنيف والتحركات"
translate Q FilterEstimate "تقدير"
translate Q TitleFilterGraph "Scid: تصفية الرسم البياني"

# Analysis window:
translate Q AddVariation {إضافة الاختلاف}
translate Q AddAllVariations {إضافة كافة الاختلافات}
translate Q AddMove {أضف نقل}
translate Q Annotate {علق}
translate Q ShowAnalysisBoard {عرض لوحة التحليل}
translate Q ShowInfo {عرض معلومات المحرك}
translate Q FinishGame {إنهاء اللعبة}
translate Q StopEngine {أوقف المحرك}
translate Q StartEngine {تشغيل المحرك}
translate Q LockEngine {قفل المحرك إلى الوضع الحالي}
translate Q AnalysisCommand {أمر التحليل}
translate Q PreviousChoices {الاختيارات السابقة}
translate Q AnnotateTime {الوقت لكل حركة بالثواني}
translate Q AnnotateWhich {إضافة الاختلافات}
translate Q AnnotateAll {للتحركات من كلا الجانبين}
translate Q AnnotateAllMoves {قم بتعليق كافة التحركات}
translate Q AnnotateWhite {للتحركات البيضاء فقط}
translate Q AnnotateBlack {للتحركات السوداء فقط}
translate Q AnnotateBlundersOnly {عندما تكون حركة اللعبة خطأً فادحًا}
translate Q AnnotateBlundersOnlyScoreChange {تقارير التحليل خطأ فادح، مع تغيير النتيجة من/إلى:}
translate Q BlundersThreshold {عتبة}
translate Q ScoreAllMoves {يسجل جميع التحركات}
translate Q LowPriority {أولوية منخفضة لوحدة المعالجة المركزية}
translate Q ClickHereToSeeMoves {انقر هنا لرؤية التحركات}
translate Q ConfigureInformant {القيم المخبرية}
translate Q Informant!? {خطوة مثيرة للاهتمام}
translate Q Informant? {حركة سيئة}
translate Q Informant?? {خطأ فادح}
translate Q Informant?! {خطوة مشكوك فيها}
translate Q Informant+= {الأبيض لديه ميزة طفيفة}
translate Q Informant+/- {الأبيض لديه ميزة واضحة}
translate Q Informant+- {الأبيض لديه ميزة حاسمة}
translate Q Informant+-- {الأبيض لديه ميزة ساحقة}
translate Q AutoComment {التعليق التلقائي}
translate Q AutoCommentTooltip {قم بإنشاء تعليق AI للمنصب الحالي}
translate Q AnalysisAutoCommentTooltip {قم بإنشاء تعليق AI للعبة بأكملها}

# Book window
translate Q Book {كتاب}
translate Q OtherBookMoves {كتاب الخصم}
translate Q OtherBookMovesTooltip {التحركات التي لدى الخصم الرد عليها}

# Analysis Engine open dialog:
translate Q EngineList {قائمة محركات التحليل}
translate Q EngineName {اسم}
translate Q EngineCmd {يأمر}
translate Q EngineArgs {حدود}
translate Q EngineDir {دليل}
translate Q EngineElo {إيلو}
translate Q EngineTime {تاريخ}
translate Q EngineNew {جديد}
translate Q EngineEdit {يحرر}
translate Q EngineRequired {الحقول بالخط العريض مطلوبة؛ والبعض الآخر اختياري}
translate Q EngineProtocol {بروتوكول الاتصالات}
translate Q EngineNotation {تدوين الحركات}
translate Q EngineFlipEvaluation {الوجه منظور التقييم}
translate Q EngineShowLog {عرض سجل الاتصالات}
translate Q EngineNetworkd {قبول الاتصالات عن بعد}
translate Q EngineSelect {حدد المحرك الحالي}
translate Q EngineAddLocal {إضافة محرك محلي}
translate Q EngineAddRemote {إضافة محرك بعيد}
translate Q EngineReload {أعد تحميل المحرك الحالي}
translate Q EngineClone {إنشاء نسخة من المحرك الحالي}
translate Q EngineDelete {احذف المحرك الحالي}

# PGN window menus:
menuText Q PgnFile "ملف" 0
menuText Q PgnFileCopy "انسخ اللعبة إلى الحافظة" 0
menuText Q PgnFilePrint "طباعة إلى ملف..." 0
menuText Q PgnFileClose "أغلق نافذة PGN" 10
menuText Q PgnOpt "عرض" 0
menuText Q PgnOptColor "عرض اللون" 0
menuText Q PgnOptShort "رأس قصير (3 أسطر)." 0
menuText Q PgnOptSymbols "الحواشي الرمزية" 1
menuText Q PgnOptIndentC "التعليقات البادئة" 0
menuText Q PgnOptIndentV "اختلافات المسافة البادئة" 7
menuText Q PgnOptColumn "نمط العمود (حركة واحدة لكل سطر)" 1
menuText Q PgnOptSpace "المسافة بعد نقل الأرقام" 1
menuText Q PgnOptStripMarks "قم بإزالة رموز المربع/السهم الملونة" 1
menuText Q PgnOptBoldMainLine "استخدم النص الغامق لتحركات الخط الرئيسي" 4
menuText Q PgnColor "الألوان" 0
menuText Q PgnColorHeader "رأس..." 0
menuText Q PgnColorAnno "التعليقات التوضيحية..." 0
menuText Q PgnColorComments "تعليقات..." 0
menuText Q PgnColorVars "الاختلافات..." 0
menuText Q PgnColorBackground "خلفية..." 0
menuText Q PgnColorMain "الخط الرئيسي..." 0
menuText Q PgnColorCurrent "خلفية التحرك الحالي..." 1
menuText Q PgnHelp "يساعد" 0
menuText Q PgnHelpPgn "مساعدة بي جي إن" 0
menuText Q PgnHelpIndex "فِهرِس" 0
translate Q PgnWindowTitle {التدوين - اللعبة %u}

# Crosstable window menus:
menuText Q CrosstabFile "ملف" 0
menuText Q CrosstabFileText "طباعة إلى ملف نصي..." 9
menuText Q CrosstabFileHtml "الطباعة إلى ملف HTML..." 9
menuText Q CrosstabFileClose "إغلاق نافذة Crosstable" 0
menuText Q CrosstabEdit "يحرر" 0
menuText Q CrosstabEditEvent "حدث" 0
menuText Q CrosstabEditSite "موقع" 0
menuText Q CrosstabEditDate "تاريخ" 0
menuText Q CrosstabOpt "عرض" 0
menuText Q CrosstabOptAll "الكل يلعب الكل" 0
menuText Q CrosstabOptSwiss "سويسري" 0
menuText Q CrosstabOptKnockout "قصا" 0
menuText Q CrosstabOptAuto "آلي" 1
menuText Q CrosstabOptAges "الأعمار بالسنوات" 8
menuText Q CrosstabOptNats "الجنسيات" 0
menuText Q CrosstabOptRatings "التقييمات" 0
menuText Q CrosstabOptTitles "العناوين" 0
menuText Q CrosstabOptBreaks "نتائج الشوط الفاصل" 4
menuText Q CrosstabOptDeleted "تضمين الألعاب المحذوفة" 8
menuText Q CrosstabOptColors "الألوان (الجدول السويسري فقط)" 0
menuText Q CrosstabOptColumnNumbers "الأعمدة المرقمة (جدول الكل تشغيل الكل فقط)" 2
menuText Q CrosstabOptGroup "نتائج المجموعة" 0
menuText Q CrosstabSort "نوع" 0
menuText Q CrosstabSortName "اسم" 0
menuText Q CrosstabSortRating "تصنيف" 0
menuText Q CrosstabSortScore "نتيجة" 0
menuText Q CrosstabColor "لون" 0
menuText Q CrosstabColorPlain "نص عادي" 0
menuText Q CrosstabColorHyper "نص تشعبي" 0
menuText Q CrosstabHelp "يساعد" 0
menuText Q CrosstabHelpCross "مساعدة في الجدول المتقاطع" 0
menuText Q CrosstabHelpIndex "مؤشر المساعدة" 0
translate Q SetFilter {تعيين عامل التصفية}
translate Q AddToFilter {أضف إلى التصفية}
translate Q Swiss {سويسري}
translate Q Category {فئة}

# Opening report window menus:
menuText Q OprepFile "ملف" 0
menuText Q OprepFileText "طباعة إلى ملف نصي..." 9
menuText Q OprepFileHtml "الطباعة إلى ملف HTML..." 9
menuText Q OprepFileOptions "خيارات..." 0
menuText Q OprepFileClose "إغلاق نافذة التقرير" 0
menuText Q OprepFavorites "المفضلة" 1
menuText Q OprepFavoritesAdd "إضافة تقرير..." 0
menuText Q OprepFavoritesEdit "تحرير مفضلة التقرير..." 0
menuText Q OprepFavoritesGenerate "إنشاء التقارير..." 0
menuText Q OprepHelp "يساعد" 0
menuText Q OprepHelpReport "فتح تعليمات التقرير" 0
menuText Q OprepHelpIndex "مؤشر المساعدة" 0

# Header search:
translate Q HeaderSearch {بحث الرأس}
translate Q EndSideToMove {جانب للتحرك في نهاية اللعبة}
translate Q GamesWithNoECO {ألعاب بدون ECO؟}
translate Q GameLength {طول اللعبة}
translate Q FindGamesWith {البحث عن الألعاب مع الأعلام}
translate Q StdStart {بداية غير قياسية}
translate Q Promotions {الترقيات}
translate Q Comments {تعليقات}
translate Q Variations {الاختلافات}
translate Q Annotations {الشروح}
translate Q DeleteFlag {حذف العلم}
translate Q WhiteOpFlag {فتح الأبيض}
translate Q BlackOpFlag {فتحه سوداء}
translate Q MiddlegameFlag {لعبة متوسطة}
translate Q EndgameFlag {نهاية اللعبة}
translate Q NoveltyFlag {بدعة}
translate Q PawnFlag {هيكل البيدق}
translate Q TacticsFlag {التكتيكات}
translate Q QsideFlag {مسرحية كوينزايد}
translate Q KsideFlag {اللعب على جانب الملك}
translate Q BrilliancyFlag {تألق}
translate Q BlunderFlag {خطأ فادح}
translate Q UserFlag {مستخدم}
translate Q PgnContains {يحتوي PGN على نص}
translate Q PgnTag {علامة}
translate Q TagContains {يتضمن}
translate Q Variant {البديل}
translate Q Annotator {الحواشي}
translate Q Cmnts {الألعاب المشروحة فقط}

# Game list window:
translate Q GlistNumber {رقم}
translate Q GlistWhite {أبيض}
translate Q GlistBlack {أسود}
translate Q GlistWElo {دبليو-إيلو}
translate Q GlistBElo {ب-إيلو}
translate Q GlistEvent {حدث}
translate Q GlistSite {موقع}
translate Q GlistRound {دائري}
translate Q GlistDate {تاريخ}
translate Q GlistYear {سنة}
translate Q GlistEDate {تاريخ_الحدث}
translate Q GlistResult {نتيجة}
translate Q GlistLength {طول}
translate Q GlistCountry {دولة}
translate Q GlistECO {سابقة بمعنى البِيْئَة}
translate Q GlistOpening {افتتاح}
translate Q GlistEndMaterial {المادة النهائية}
translate Q GlistDeleted {تم الحذف}
translate Q GlistFlags {أعلام}
translate Q GlistVars {الاختلافات}
translate Q GlistComments {تعليقات}
translate Q GlistAnnos {الشروح}
translate Q GlistStart {يبدأ}
translate Q GlistGameNumber {رقم اللعبة}
translate Q GlistAverageElo {متوسط ​​إيلو}
translate Q GlistRating {تصنيف}
translate Q GlistFindText {ابحث عن النص}
translate Q GlistMoveField {يتحرك}
translate Q GlistEditField {تكوين}
translate Q GlistAddField {يضيف}
translate Q GlistDeleteField {يزيل}
translate Q GlistWidth {عرض}
translate Q GlistAlign {محاذاة}
translate Q GlistAlignL {محاذاة: اليسار}
translate Q GlistAlignR {محاذاة: حق}
translate Q GlistAlignC {محاذاة: المركز}
translate Q GlistColor {لون}
translate Q GlistSep {فاصل}
translate Q GlistCurrentSep {-- حاضِر --}
translate Q GlistNewSort {جديد}
translate Q GlistAddToSort {يضيف}

# base sorting
translate Q GsortSort {نوع...}
translate Q GsortDate {تاريخ}
translate Q GsortYear {سنة}
translate Q GsortEvent {حدث}
translate Q GsortSite {موقع}
translate Q GsortRound {دائري}
translate Q GsortWhiteName {الاسم الأبيض}
translate Q GsortBlackName {الاسم الأسود}
translate Q GsortECO {سابقة بمعنى البِيْئَة}
translate Q GsortResult {نتيجة}
translate Q GsortMoveCount {عدد التحركات}
translate Q GsortAverageElo {متوسط ​​إيلو}
translate Q GsortCountry {دولة}
translate Q GsortDeleted {تم الحذف}
translate Q GsortEventDate {تاريخ الحدث}
translate Q GsortWhiteElo {وايت إيلو}
translate Q GsortBlackElo {بلاك إيلو}
translate Q GsortComments {تعليقات}
translate Q GsortVariations {الاختلافات}
translate Q GsortNAGs {تذمر}
translate Q GsortAscending {تصاعدي}
translate Q GsortDescending {تنازلي}
translate Q GsortAdd {يضيف}
translate Q GsortStore {محل}
translate Q GsortLoad {حمولة}

# menu shown with right mouse button down on game list.
translate Q GlistRemoveThisGameFromFilter  {قم بإزالة هذه اللعبة من عامل التصفية}
translate Q GlistRemoveGameAndAboveFromFilter  {قم بإزالة اللعبة (وكل ما فوقها) من عامل التصفية}
translate Q GlistRemoveGameAndBelowFromFilter  {قم بإزالة اللعبة (وكل ما تحتها) من عامل التصفية}
translate Q GlistDeleteGame {(الأمم المتحدة) حذف هذه اللعبة}
translate Q GlistDeleteAllGames {احذف جميع الألعاب في الفلتر}
translate Q GlistUndeleteAllGames {قم بإلغاء حذف جميع الألعاب في الفلتر}
translate Q GlistMergeGameInBase {دمج اللعبة في}

# Maintenance window:
translate Q DatabaseName {اسم قاعدة البيانات:}
translate Q TypeIcon {نوع الرمز:}
translate Q NumOfGames {ألعاب:}
translate Q NumDeletedGames {الألعاب المحذوفة:}
translate Q NumFilterGames {الألعاب في الفلتر:}
translate Q YearRange {نطاق السنة:}
translate Q RatingRange {نطاق التقييم:}
translate Q Description {وصف}
translate Q Flag {علَم}
translate Q CustomFlags {أعلام مخصصة}
translate Q DeleteCurrent {حذف اللعبة الحالية}
translate Q DeleteFilter {حذف ألعاب التصفية}
translate Q DeleteAll {حذف جميع الألعاب}
translate Q UndeleteCurrent {إلغاء حذف اللعبة الحالية}
translate Q UndeleteFilter {إلغاء حذف ألعاب التصفية}
translate Q UndeleteAll {إلغاء حذف كافة الألعاب}
translate Q DeleteTwins {حذف الألعاب التوأم}
translate Q MarkCurrent {وضع علامة على اللعبة الحالية}
translate Q MarkFilter {العاب مارك فلتر}
translate Q MarkAll {ضع علامة على جميع الألعاب}
translate Q UnmarkCurrent {قم بإلغاء تحديد اللعبة الحالية}
translate Q UnmarkFilter {قم بإلغاء تحديد ألعاب التصفية}
translate Q UnmarkAll {قم بإلغاء تحديد كافة الألعاب}
translate Q Spellchecking {التدقيق الإملائي}
translate Q Players {اللاعبين}
translate Q Events {الأحداث}
translate Q Sites {مواقع}
translate Q Rounds {جولات}
translate Q DatabaseOps {عمليات قاعدة البيانات}
translate Q ReclassifyGames {ألعاب مصنفة بيئيًا}
translate Q CompactDatabase {قاعدة بيانات مدمجة}
translate Q SortDatabase {فرز قاعدة البيانات}
translate Q AddEloRatings {إضافة تقييمات إيلو}
translate Q AutoloadGame {تحميل رقم اللعبة تلقائيًا}
translate Q StripTags {تجريد علامات PGN}
translate Q StripTag {علامة الشريط}
translate Q Cleaner {منظف}
translate Q CleanerHelp {سيقوم Scid Cleaner بتنفيذ جميع إجراءات الصيانة التي تحددها من القائمة أدناه، على قاعدة البيانات الحالية.
سيتم تطبيق الإعدادات الحالية في تصنيف ECO ومربعات حوار الحذف المزدوج إذا قمت بتحديد هذه الوظائف.}
translate Q CleanerConfirm {بمجرد بدء صيانة المنظف، لا يمكن مقاطعتها!

قد يستغرق ذلك وقتًا طويلاً في قاعدة بيانات كبيرة، اعتمادًا على الوظائف التي حددتها وإعداداتها الحالية.

هل أنت متأكد أنك تريد بدء وظائف الصيانة التي حددتها؟}
# Twinchecker
translate Q TwinCheckUndelete {لقلب؛ "u" يلغي حذف كليهما)}
translate Q TwinCheckprevPair {الزوج السابق}
translate Q TwinChecknextPair {الزوج التالي}
translate Q TwinChecker {Scid: مدقق اللعبة المزدوج}
translate Q TwinCheckTournament {المباريات في البطولة:}
translate Q TwinCheckNoTwin {لا توأم}
translate Q TwinCheckNoTwinfound {لم يتم اكتشاف أي توأم لهذه اللعبة.\nلإظهار التوائم باستخدام هذه النافذة، يجب عليك أولاً استخدام الوظيفة "حذف الألعاب التوأم...".}
translate Q TwinCheckTag {مشاركة العلامات...}
translate Q TwinCheckFound1 {عثر Scid على ألعاب مزدوجة نتيجة $}
translate Q TwinCheckFound2 {وتعيين علامات الحذف الخاصة بهم}
translate Q TwinCheckNoDelete {لا توجد ألعاب في قاعدة البيانات هذه لحذفها.}
translate Q TwinCriteria1 {من المحتمل أن تؤدي إعداداتك الخاصة بالعثور على ألعاب توأم إلى وضع علامة على ألعاب غير توأم ذات حركات مماثلة على أنها توائم.}
translate Q TwinCriteria2 {من المستحسن أنه إذا قمت بتحديد "لا" لـ "نفس التحركات"، فيجب عليك تحديد "نعم" للألوان والحدث والموقع وإعدادات الجولة والسنة والشهر.\nهل تريد المتابعة وحذف التوائم على أية حال؟}
translate Q TwinCriteria3 {من المستحسن تحديد "نعم" لاثنين على الأقل من إعدادات "نفس الموقع" و"نفس الجولة" و"نفس العام".\nهل تريد المتابعة وحذف التوائم على أية حال؟}
translate Q TwinCriteriaConfirm {Scid: قم بتأكيد إعدادات التوأم}
translate Q TwinChangeTag "قم بتغيير علامات اللعبة التالية:\n\n"
translate Q AllocRatingDescription "سيستخدم هذا الأمر ملف التدقيق الإملائي الحالي لإضافة تقييمات Elo إلى الألعاب الموجودة في قاعدة البيانات هذه. عندما لا يكون لدى اللاعب تقييم حالي ولكن تقييمه في وقت اللعبة مدرج في ملف التدقيق الإملائي، ستتم إضافة هذا التقييم."
translate Q RatingOverride "الكتابة فوق التصنيفات غير الصفرية الموجودة"
translate Q AddRatings "إضافة التقييمات إلى:"
translate Q AddedRatings {أضاف Scid تقييمات $r Elo في ألعاب $g.}

#Bookmark editor
translate Q NewSubmenu "قائمة فرعية جديدة"

# Comment editor:
translate Q AnnotationSymbols  {رموز التعليقات التوضيحية:}
translate Q Comment {تعليق:}
translate Q InsertMark {أدخل علامة}
translate Q InsertMarkHelp {إدراج/إزالة العلامة: حدد اللون، النوع، المربع.
إدراج/إزالة السهم: انقر بزر الماوس الأيمن على مربعين.}

# Nag buttons in comment editor:
translate Q GoodMove {خطوة جيدة}
translate Q PoorMove {حركة سيئة}
translate Q ExcellentMove {خطوة ممتازة}
translate Q Blunder {خطأ فادح}
translate Q InterestingMove {خطوة مثيرة للاهتمام}
translate Q DubiousMove {خطوة مشكوك فيها}
translate Q WhiteDecisiveAdvantage {الأبيض لديه ميزة حاسمة}
translate Q BlackDecisiveAdvantage {الأسود لديه ميزة حاسمة}
translate Q WhiteClearAdvantage {الأبيض لديه ميزة واضحة}
translate Q BlackClearAdvantage {الأسود لديه ميزة واضحة}
translate Q WhiteSlightAdvantage {الأبيض لديه ميزة طفيفة}
translate Q BlackSlightAdvantage {الأسود لديه ميزة طفيفة}
translate Q WhiteCrushing {الأبيض لديه ميزة ساحقة}
translate Q BlackCrushing {الأسود لديه ميزة ساحقة}
translate Q Equality {المساواة}
translate Q Unclear {غير واضح}
translate Q Diagram {رسم بياني}

# Board search:
translate Q BoardSearch {بحث المجلس}
translate Q FilterOperation {التشغيل على الفلتر الحالي:}
translate Q FilterAnd {و (تقييد عامل التصفية)}
translate Q FilterOr {أو (إضافة إلى التصفية)}
translate Q FilterIgnore {تجاهل (إعادة ضبط عامل التصفية)}
translate Q SearchType {نوع البحث:}
translate Q SearchBoardExact {الموضع الدقيق (جميع القطع في نفس المربعات)}
translate Q SearchBoardPawns {البيادق (نفس المادة، كل البيادق على نفس المربعات)}
translate Q SearchBoardFiles {الملفات (نفس المادة، كل البيادق على نفس الملفات)}
translate Q SearchBoardAny {أي (نفس المادة والبيادق والقطع في أي مكان)}
translate Q SearchInRefDatabase {البحث في قاعدة البيانات المرجعية}
translate Q LookInVars {انظر في الاختلافات}

# Material search:
translate Q MaterialSearch {بحث المواد}
translate Q Material {مادة}
translate Q Patterns {أنماط}
translate Q Zero {صفر}
translate Q Any {أي}
translate Q CurrentBoard {المجلس الحالي}
translate Q CommonEndings {النهايات المشتركة}
translate Q CommonPatterns {الأنماط الشائعة}
translate Q MaterialDiff {الفرق المادي}
translate Q squares {المربعات}
translate Q SameColor {نفس اللون}
translate Q OppColor {اللون المعاكس}
translate Q Either {أيضاً}
translate Q MoveNumberRange {نقل نطاق الأرقام}
translate Q MatchForAtLeast {تطابق على الأقل}
translate Q HalfMoves {نصف التحركات}

# Common endings in material search:
translate Q EndingPawns {نهايات البيدق}
translate Q EndingRookVsPawns {الرخ مقابل البيدق (البيادق)}
translate Q EndingRookPawnVsRook {الرخ والبيدق 1 مقابل الرخ}
translate Q EndingRookPawnsVsRook {الرخ والبيدق (ق) مقابل الرخ}
translate Q EndingRooks {نهايات الرخ مقابل الرخ}
translate Q EndingRooksPassedA {الرخ مقابل الرخ ينتهي ببيدق تم تمريره}
translate Q EndingRooksDouble {نهايات Double Rook}
translate Q EndingBishops {نهايات الأسقف مقابل الأسقف}
translate Q EndingBishopVsKnight {نهايات الأسقف ضد الفارس}
translate Q EndingKnights {نهايات الفارس مقابل الفارس}
translate Q EndingQueens {نهايات الملكة ضد الملكة}
translate Q EndingQueenPawnVsQueen {الملكة و1 بيدق ضد الملكة}
translate Q BishopPairVsKnightPair {لعبة Two Bishops vs. Two Knights في منتصف اللعبة}

# Common patterns in material search:
translate Q PatternWhiteIQP {وايت آي كيو بي}
translate Q PatternWhiteIQPBreakE6 {IQP الأبيض: استراحة d4-d5 مقابل e6}
translate Q PatternWhiteIQPBreakC6 {IQP الأبيض: استراحة d4-d5 مقابل c6}
translate Q PatternBlackIQP {بلاك آي كيو بي}
translate Q PatternWhiteBlackIQP {White IQP مقابل Black IQP}
translate Q PatternCoupleC3D4 {الأبيض c3+d4 البيدق المعزول للزوجين}
translate Q PatternHangingC5D5 {بيادق سوداء معلقة على c5 وd5}
translate Q PatternMaroczy {مركز Maroczy (مع البيادق على c4 وe4)}
translate Q PatternRookSacC3 {تضحية الرخ على c3}
translate Q PatternKc1Kg8 {O-O-O مقابل O-O (Kc1 مقابل Kg8)}
translate Q PatternKg1Kc8 {O-O مقابل O-O-O (Kg1 مقابل Kc8)}
translate Q PatternLightFian {Fianchettos المربع الضوئي (Bishop-g2 vs. Bishop-b7)}
translate Q PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 ضد Bishop-g7)}
translate Q PatternFourFian {أربعة Fianchettos (الأساقفة على b2،g2،b7،g7)}

# Game saving:
translate Q Today {اليوم}
translate Q ClassifyGame {لعبة التصنيف}

# Setup position:
translate Q EmptyBoard {لوحة فارغة}
translate Q InitialBoard {اللوحة الأولية}
translate Q SideToMove {الجانب للتحرك}
translate Q MoveNumber {نقل الرقم}
translate Q Castling {التبييت}
translate Q EnPassantFile {أون ملف باسانت}
translate Q ClearFen {مسح الفين}
translate Q PasteFen {لصق الفين}

translate Q SaveAndContinue {حفظ والمتابعة}
translate Q DiscardChangesAndContinue {تجاهل التغييرات والمتابعة}
translate Q GoBack {عُد}

# Replace move dialog:
translate Q ReplaceMove {استبدال التحرك}
translate Q AddNewVar {إضافة صيغة جديدة}
translate Q NewMainLine {الخط الرئيسي الجديد}
translate Q ReplaceMoveMessage {هناك خطوة موجودة بالفعل هنا.

يمكنك استبدالها، أو التخلص من كل الحركات التي تليها، أو إضافة حركتك كشكل جديد.

(يمكنك تجنب رؤية هذه الرسالة في المستقبل عن طريق إيقاف تشغيل خيار "السؤال قبل استبدال الحركات" في قائمة الخيارات: التحركات.)}

# Make database read-only dialog:
translate Q ReadOnlyDialog {إذا جعلت قاعدة البيانات هذه للقراءة فقط، فلن يُسمح بإجراء أي تغييرات.
لا يمكن حفظ أي ألعاب أو استبدالها، ولا يمكن تغيير علامات الحذف.
أي نتائج فرز أو تصنيف بيئي ستكون مؤقتة.

يمكنك بسهولة جعل قاعدة البيانات قابلة للكتابة مرة أخرى، عن طريق إغلاقها وإعادة فتحها.

هل تريد حقًا جعل قاعدة البيانات هذه للقراءة فقط؟}

# Clear game dialog:
translate Q ClearGameDialog {لقد تم تغيير هذه اللعبة.

هل تريد حقًا المتابعة وتجاهل التغييرات التي تم إجراؤها عليها؟}

# Exit dialog:
translate Q ExitDialog {هل تريد حقًا الخروج من Scid؟}
translate Q ExitUnsaved {تحتوي قواعد البيانات التالية على تغييرات غير محفوظة في اللعبة. إذا قمت بالخروج الآن، سيتم فقدان هذه التغييرات.}

# Import window:
translate Q PasteCurrentGame {لصق اللعبة الحالية}
translate Q ImportHelp1 {أدخل أو الصق لعبة بتنسيق PGN في الإطار أعلاه.}
translate Q ImportHelp2 {سيتم عرض أي أخطاء أثناء استيراد اللعبة هنا.}
translate Q OverwriteExistingMoves {الكتابة فوق التحركات الموجودة؟}

# ECO Browser:
translate Q ECOAllSections {جميع أقسام ECO}
translate Q ECOSection {قسم منظمة التعاون الاقتصادي}
translate Q ECOSummary {ملخص ل}
translate Q ECOFrequency {تردد الرموز الفرعية لـ}

# Opening Report:
translate Q OprepTitle {تقرير الافتتاح}
translate Q OprepReport {تقرير}
translate Q OprepGenerated {تم إنشاؤها بواسطة}
translate Q OprepStatsHist {الإحصاء والتاريخ}
translate Q OprepStats {إحصائيات}
translate Q OprepStatAll {جميع تقارير الألعاب}
translate Q OprepStatBoth {كلاهما مصنف}
translate Q OprepStatSince {منذ}
translate Q OprepOldest {أقدم الألعاب}
translate Q OprepNewest {أحدث الألعاب}
translate Q OprepPopular {الشعبية الحالية}
translate Q OprepFreqAll {التكرار في جميع السنوات:}
translate Q OprepFreq1   {في العام الأول حتى اليوم:}
translate Q OprepFreq5   {خلال 5 سنوات حتى اليوم:}
translate Q OprepFreq10  {خلال 10 سنوات حتى اليوم:}
translate Q OprepEvery {مرة واحدة كل %u مباراة}
translate Q OprepUp {ما يصل %u%s من جميع السنوات}
translate Q OprepDown {بانخفاض %u%s عن كل السنوات}
translate Q OprepSame {لا تغيير من جميع السنوات}
translate Q OprepMostFrequent {اللاعبين الأكثر تكرارا}
translate Q OprepMostFrequentOpponents {المعارضين الأكثر شيوعا}
translate Q OprepRatingsPerf {التقييمات والأداء}
translate Q OprepAvgPerf {متوسط ​​التقييمات والأداء}
translate Q OprepWRating {تصنيف الأبيض}
translate Q OprepBRating {تصنيف أسود}
translate Q OprepWPerf {الأداء الأبيض}
translate Q OprepBPerf {أداء أسود}
translate Q OprepHighRating {الألعاب الحاصلة على أعلى متوسط ​​تقييم}
translate Q OprepTrends {اتجاهات النتيجة}
translate Q OprepResults {أطوال النتيجة والترددات}
translate Q OprepLength {طول اللعبة}
translate Q OprepFrequency {تكرار}
translate Q OprepWWins {الأبيض يفوز:}
translate Q OprepBWins {انتصارات الأسود:}
translate Q OprepDraws {يرسم:}
translate Q OprepWholeDB {قاعدة البيانات بأكملها}
translate Q OprepShortest {أقصر الانتصارات}
translate Q OprepMovesThemes {التحركات والموضوعات}
translate Q OprepMoveOrders {نقل الأوامر التي تصل إلى موضع التقرير}
translate Q OprepMoveOrdersOne \
  {لم يكن هناك سوى أمر نقل واحد يصل إلى هذا الموضع:}
translate Q OprepMoveOrdersAll \
  {كان هناك %u أوامر نقل تصل إلى هذا الموضع:}
translate Q OprepMoveOrdersMany \
  {كان هناك %u أوامر نقل تصل إلى هذا الموضع. أعلى %u هي:}
translate Q OprepMovesFrom {ينتقل من موضع التقرير}
translate Q OprepMostFrequentEcoCodes {رموز ECO الأكثر شيوعًا}
translate Q OprepThemes {المواضيع الموضعية}
translate Q OprepThemeDescription {تكرار المواضيع في أول %u نقلات من كل لعبة}
translate Q OprepThemeSameCastling {التبييت من نفس الجانب}
translate Q OprepThemeOppCastling {مقابل القلاع}
translate Q OprepThemeNoCastling {كلا الملكين غير محصنين}
translate Q OprepThemeKPawnStorm {عاصفة البيدق Kingside}
translate Q OprepThemeQueenswap {تبادلت الملكات}
translate Q OprepThemeWIQP {الأبيض., عزل عزل, ملكة, البيدق}
translate Q OprepThemeBIQP {الأسود، عزل عزل، ملكة، البيدق}
translate Q OprepThemeWP567 {البيدق الأبيض في المرتبة 5/6/7}
translate Q OprepThemeBP234 {البيدق الأسود في المرتبة 2/3/4}
translate Q OprepThemeOpenCDE {افتح ملف c/d/e}
translate Q OprepTheme1BishopPair {جانب واحد فقط لديه زوج أسقف}
translate Q OprepEndgames {نهاية اللعبة}
translate Q OprepReportGames {الإبلاغ عن الألعاب}
translate Q OprepAllGames    {جميع الألعاب}
translate Q OprepEndClass {المادة في نهاية كل مباراة}
translate Q OprepTheoryTable {جدول النظرية}
translate Q OprepTableComment {تم إنشاؤها من %u الألعاب الأعلى تقييمًا.}
translate Q OprepExtraMoves {ملاحظة إضافية تتحرك في جدول النظرية}
translate Q OprepMaxGames {الحد الأقصى من الألعاب في الجدول النظري}
translate Q OprepMergeMoves {حد الحركة للألعاب المدمجة}
translate Q OprepMergeUnique {دمج الألعاب الفريدة فقط}
translate Q OprepViewHTML {عرض HTML}

# Player Report:
translate Q PReportTitle {تقرير اللاعب}
translate Q PReportColorWhite {مع القطع البيضاء}
translate Q PReportColorBlack {مع القطع السوداء}
translate Q PReportMoves {بعد %s}
translate Q PReportOpenings {الفتحات}
translate Q PReportClipbase {قاعدة بيانات فارغة وانسخ الألعاب المطابقة إليها}

# Piece Tracker window:
translate Q TrackerSelectSingle {زر الفأرة الأيسر يختار هذه القطعة.}
translate Q TrackerSelectPair {زر الفأرة الأيسر يختار هذه القطعة؛ الزر الأيمن يختار أيضًا شقيقه.}
translate Q TrackerSelectPawn {زر الفأرة الأيسر يختار هذا البيدق؛ الزر الأيمن يختار جميع البيادق الثمانية.}
translate Q TrackerStat {إحصائية}
translate Q TrackerGames {% الألعاب مع الانتقال إلى المربع}
translate Q TrackerTime {% من الوقت في كل مربع}
translate Q TrackerMoves {التحركات}
translate Q TrackerMovesStart {أدخل رقم النقل حيث يجب أن يبدأ التتبع.}
translate Q TrackerMovesStop {أدخل رقم النقل حيث يجب أن يتوقف التتبع.}

# Game selection dialogs:
translate Q SelectAllGames {جميع الألعاب في قاعدة البيانات}
translate Q SelectFilterGames {الألعاب فقط في التصفية}
translate Q SelectTournamentGames {المباريات فقط في البطولة الحالية}
translate Q SelectOlderGames {الألعاب القديمة فقط}

# Delete Twins window:
translate Q TwinsNote {لكي تكونا توأمين، يجب أن تضم لعبتان على الأقل نفس اللاعبين، والمعايير التي يمكنك تحديدها أدناه. عندما يتم العثور على زوج من التوائم، يتم حذف اللعبة الأقصر. تلميح: من الأفضل إجراء التدقيق الإملائي لقاعدة البيانات قبل حذف التوائم، حيث أن ذلك يعمل على تحسين اكتشاف التوائم.}
translate Q TwinsCriteria {المعايير: يجب أن تحتوي الألعاب التوأم على...}
translate Q TwinsWhich {فحص أي الألعاب}
translate Q TwinsColors {نفس ألوان اللاعبين}
translate Q TwinsEvent {نفس الحدث}
translate Q TwinsSite {نفس الموقع}
translate Q TwinsRound {نفس الجولة}
translate Q TwinsYear {نفس العام}
translate Q TwinsMonth {نفس الشهر}
translate Q TwinsDay {نفس اليوم}
translate Q TwinsResult {نفس النتيجة}
translate Q TwinsECO {نفس رمز ECO}
translate Q TwinsMoves {نفس التحركات}
translate Q TwinsPlayers {مقارنة أسماء اللاعبين}
translate Q TwinsPlayersExact {تطابق تام}
translate Q TwinsPlayersPrefix {أول 4 أحرف فقط}
translate Q TwinsWhen {عند حذف الألعاب التوأم}
translate Q TwinsSkipShort {تجاهل جميع الألعاب التي يقل طولها عن 5 حركات}
translate Q TwinsUndelete {قم بإلغاء حذف جميع الألعاب أولاً}
translate Q TwinsSetFilter {اضبط الفلتر على جميع الألعاب التوأم المحذوفة}
translate Q TwinsComments {احتفظ دائمًا بالألعاب مع التعليقات}
translate Q TwinsVars {احتفظ دائمًا بالألعاب ذات الاختلافات}
translate Q TwinsDeleteWhich {حذف اللعبة}
translate Q TwinsDeleteShorter {لعبة أقصر}
translate Q TwinsDeleteOlder {رقم لعبة أصغر}
translate Q TwinsDeleteNewer {رقم اللعبة أكبر}
translate Q TwinsDelete {حذف الألعاب}

# Name editor window:
translate Q NameEditType {نوع الاسم المراد تعديله}
translate Q NameEditSelect {ألعاب للتحرير}
translate Q NameEditReplace {يستبدل}
translate Q NameEditWith {مع}
translate Q NameEditMatches {التطابقات: اضغط على Ctrl+1 إلى Ctrl+9 للتحديد}

# Check games window:
translate Q CheckGames {تحقق من الألعاب}
translate Q CheckGamesWhich {تحقق من الألعاب}
translate Q CheckAll {جميع الألعاب}
translate Q CheckSelectFilterGames {الألعاب فقط في الفلتر}

# Classify window:
translate Q Classify {تصنيف}
translate Q ClassifyWhich {التصنيف البيئي للألعاب}
translate Q ClassifyAll {جميع الألعاب (الكتابة فوق رموز ECO القديمة)}
translate Q ClassifyYear {جميع المباريات التي لعبت في العام الماضي}
translate Q ClassifyMonth {جميع المباريات التي لعبت في الشهر الماضي}
translate Q ClassifyNew {الألعاب الوحيدة التي لا تحتوي على رمز ECO حتى الآن}
translate Q ClassifyCodes {رموز ECO للاستخدام}
translate Q ClassifyBasic {الرموز الأساسية فقط ("B12"، ...)}
translate Q ClassifyExtended {ملحقات Scid ("B12j"، ...)}
translate Q ClassifyResult {اكتمل تصنيف ECO: تم تحديث لعبة (ألعاب) النتيجة $.}

# Compaction:
translate Q NameFile {اسم الملف}
translate Q GameFile {ملف اللعبة}
translate Q Names {الأسماء}
translate Q Unused {غير مستخدمة}
translate Q SizeKb {الحجم (كيلو بايت)}
translate Q CurrentState {الحالة الحالية}
translate Q AfterCompaction {بعد الضغط}
translate Q CompactNames {ملف الاسم المضغوط}
translate Q CompactGames {ملف اللعبة مضغوط}
translate Q NoUnusedNames "لا توجد أسماء غير مستخدمة، لذا فإن ملف الاسم مضغوط بالكامل بالفعل."
translate Q NoUnusedGames "ملف اللعبة مضغوط بالكامل بالفعل."
translate Q GameFileCompacted {تم ضغط ملف اللعبة لقاعدة البيانات.}

# Sorting:
translate Q SortCriteria {معايير}
translate Q AddCriteria {أضف معايير}
translate Q CommonSorts {الأنواع الشائعة}
translate Q Sort {نوع}

# Exporting:
translate Q AddToExistingFile {إضافة ألعاب إلى ملف موجود}
translate Q ExportComments {تصدير التعليقات}
translate Q ExportVariations {تصدير الاختلافات}
translate Q IndentComments {مسافة بادئة للتعليقات}
translate Q IndentVariations {اختلافات المسافة البادئة}
translate Q ExportColumnStyle {نمط العمود (حركة واحدة لكل سطر)}
translate Q ExportSymbolStyle {أسلوب التعليق الرمزي:}
translate Q ExportStripMarks {قم بإزالة رموز علامة المربع/السهم\nمن التعليقات}

# Goto game/move dialogs:
translate Q LoadGameNumber {أدخل رقم اللعبة للتحميل:}
translate Q GotoMoveNumber {انتقل إلى رقم النقل:}

# Copy games dialog:
translate Q CopyAllGames {انسخ جميع الألعاب إلى}
translate Q CopyGames {نسخ الألعاب}
translate Q CopyConfirm {هل تريد حقا نسخ
 الألعاب التي تمت تصفيتها [::utils::thousands $nGamesToCopy]
 في قاعدة البيانات "$fromName"
 إلى قاعدة البيانات "$targetName"؟}
translate Q CopyErr {لا يمكن نسخ الألعاب}
translate Q CopyErrSource {قاعدة البيانات المصدر}
translate Q CopyErrTarget {قاعدة البيانات الهدف}
translate Q CopyErrNoGames {ليس لديه أي ألعاب في مرشحه}
translate Q CopyErrReadOnly {للقراءة فقط}
translate Q CopyErrNotOpen {ليس مفتوحا}

# Colors:
translate Q LightSquares {المربعات الخفيفة}
translate Q DarkSquares {المربعات المظلمة}
translate Q SelectedSquares {المربعات المختارة}
translate Q SuggestedSquares {الساحات التحرك المقترحة}
translate Q WhitePieces {قطع بيضاء}
translate Q BlackPieces {قطع سوداء}
translate Q WhiteBorder {الحدود البيضاء}
translate Q BlackBorder {الحدود السوداء}

# Novelty window:
translate Q FindNovelty {البحث عن الجدة}
translate Q Novelty {بدعة}
translate Q NoveltyInterrupt {تمت مقاطعة البحث عن الجدة}
translate Q NoveltyNone {لم يتم العثور على أي حداثة لهذه اللعبة}
translate Q NoveltyHelp {سيجد Scid الخطوة الأولى في اللعبة الحالية التي تصل إلى موضع غير موجود في قاعدة البيانات المحددة أو في كتاب افتتاحيات ECO.}

# Sounds configuration:
translate Q SoundsFolder {مجلد ملفات الصوت}
translate Q SoundsFolderHelp {يجب أن يحتوي المجلد على الملفات King.wav، وa.wav، و1.wav، وما إلى ذلك}
translate Q SoundsAnnounceOptions {نقل خيارات الإعلان}
translate Q SoundsAnnounceNew {الإعلان عن التحركات الجديدة فور حدوثها}
translate Q SoundsMoveSoundOnly {نقل الصوت فقط (تعطيل الإعلانات)}
translate Q SoundsAnnounceForward {أعلن عن التحركات عند المضي قدما خطوة واحدة}
translate Q SoundsAnnounceBack {أعلن عند التراجع أو التراجع خطوة واحدة}
translate Q SoundsSoundDisabled {تعذر على Scid العثور على حزمة Snack الصوتية عند بدء التشغيل؛\nالصوت معطل.}

# Upgrading databases:
translate Q Upgrading {الترقية}
translate Q ConfirmOpenNew {هذه قاعدة بيانات ذات تنسيق قديم (Scid 3) لا يمكن فتحها في Scid 4، ولكن تم بالفعل إنشاء إصدار جديد (Scid 4).

هل تريد فتح الإصدار الجديد من قاعدة البيانات؟}
translate Q ConfirmUpgrade {هذه قاعدة بيانات ذات تنسيق قديم (Scid 3). يجب إنشاء إصدار جديد من قاعدة البيانات قبل استخدامه في Scid 4.

ستؤدي الترقية إلى إنشاء إصدار جديد من قاعدة البيانات وبعد ذلك إزالة الملفات الأصلية.

قد يستغرق هذا بعض الوقت، ولكن يجب القيام به مرة واحدة فقط. يمكنك الإلغاء إذا استغرق الأمر وقتًا طويلاً.

هل تريد ترقية قاعدة البيانات هذه الآن؟}

# Recent files options:
translate Q RecentFilesMenu {عدد الملفات الحديثة في قائمة "ملف".}
translate Q RecentFilesExtra {عدد الملفات الأخيرة في القائمة الفرعية الإضافية}

# My Player Names options:
translate Q MyPlayerNamesDescription {أدخل قائمة بأسماء اللاعبين المفضلين أدناه، اسم واحد في كل سطر. يُسمح باستخدام أحرف البدل (على سبيل المثال، "؟" لأي حرف فردي، و"*" لأي تسلسل من الأحرف).

في كل مرة يتم فيها تحميل لعبة بها لاعب في القائمة، سيتم تدوير نافذة رقعة الشطرنج الرئيسية إذا لزم الأمر لإظهار اللعبة من منظور هذا اللاعب.}

#Coach
translate Q showblunderexists {إظهار الخطأ موجود}
translate Q showblundervalue {إظهار قيمة الخطأ}
translate Q showscore {إظهار النتيجة}
translate Q coachgame {لعبة المدرب}
translate Q configurecoachgame {تكوين لعبة تكتيكية}
translate Q configuregame {تكوين اللعبة}
translate Q Phalanxengine {محرك الكتائب}
translate Q Coachengine {محرك المدرب}
translate Q difficulty {صعوبة}
translate Q hard {صعب}
translate Q easy {سهل}
translate Q Playwith {العب مع}
translate Q white {أبيض}
translate Q black {أسود}
translate Q both {كلاهما}
translate Q Play {يلعب}
translate Q Noblunder {لا خطأ فادح}
translate Q blunder {خطأ فادح}
translate Q Noinfo {-- لا يوجد معلومات --}
translate Q PhalanxOrTogaMissing {لم يتم العثور على الكتائب أو التوغا}
translate Q moveblunderthreshold {الخطوة خطأ إذا كانت الخسارة أكبر من}
translate Q limitanalysis {الحد من وقت تحليل المحرك}
translate Q seconds {ثواني}
translate Q Abort {إحباط}
translate Q Resume {سيرة ذاتية}
translate Q OutOfOpening {خارج الافتتاح}
translate Q NotFollowedLine {أنت لم تتبع الخط}
translate Q DoYouWantContinue {هل تريد الاستمرار؟}
translate Q CoachIsWatching {المدرب يراقب}
translate Q Ponder {التفكير الدائم}
translate Q LimitELO {الحد من قوة إيلو}
translate Q DubiousMovePlayedTakeBack {لعبت خطوة مشكوك فيها، هل تريد استعادة؟}
translate Q WeakMovePlayedTakeBack {خطوة ضعيفة لعبتها، هل تريد استرجاعها؟}
translate Q BadMovePlayedTakeBack {خطوة سيئة لعبتها، هل تريد استرجاعها؟}
translate Q Iresign {أنا أستقيل}
translate Q yourmoveisnotgood {حركتك ليست جيدة}
translate Q EndOfVar {نهاية الاختلاف}
translate Q Openingtrainer {مدرب الافتتاح}
translate Q DisplayCM {عرض تحركات المرشح}
translate Q DisplayCMValue {عرض قيمة تحركات المرشح}
translate Q DisplayOpeningStats {عرض الإحصائيات}
translate Q ShowReport {عرض التقرير}
translate Q NumberOfGoodMovesPlayed {لعبت التحركات الجيدة}
translate Q NumberOfDubiousMovesPlayed {لعبت التحركات المشكوك فيها}
translate Q NumberOfMovesPlayedNotInRepertoire {لعبت التحركات ليس في ذخيرة}
translate Q NumberOfTimesPositionEncountered {مرات مواجهة الموقف}
translate Q PlayerBestMove  {السماح فقط بأفضل التحركات}
translate Q OpponentBestMove {الخصم يلعب أفضل التحركات}
translate Q OnlyFlaggedLines {الخطوط التي تم وضع علامة عليها فقط}
translate Q resetStats {إعادة تعيين الإحصائيات}
translate Q Repertoiretrainingconfiguration {تكوين التدريب المرجع}
translate Q Loadingrepertoire {جارٍ تحميل الذخيرة}
translate Q Movesloaded {التحركات محملة}
translate Q Repertoirenotfound {لم يتم العثور على المرجع}
translate Q Openfirstrepertoirewithtype {افتح أولاً قاعدة بيانات المرجع مع تعيين الرمز/النوع على الجانب الأيمن}
translate Q Movenotinrepertoire {التحرك ليس في ذخيرة}
translate Q PositionsInRepertoire {المناصب في المرجع}
translate Q PositionsNotPlayed {المواقف لم تلعب}
translate Q PositionsPlayed {المواقف التي لعبت}
translate Q Success {نجاح}
translate Q DubiousMoves {تحركات مشكوك فيها}
translate Q OutOfRepertoire {خارج المرجع}
translate Q ConfigureTactics {تكوين التكتيكات}
translate Q ResetScores {إعادة ضبط النتائج}
translate Q LoadingBase {قاعدة التحميل}
translate Q Tactics {التكتيكات}
translate Q ShowSolution {عرض الحل}
translate Q NextExercise {التمرين التالي}
translate Q PrevExercise {التمرين السابق}
translate Q StopTraining {توقف عن التدريب}
translate Q Next {التالي}
translate Q ResettingScore {إعادة ضبط النتيجة}
translate Q LoadingGame {جارٍ تحميل اللعبة}
translate Q MateFound {تم العثور على رفيقة}
translate Q BestSolutionNotFound {لم يتم العثور على أفضل حل!}
translate Q MateNotFound {لم يتم العثور على زميله}
translate Q ShorterMateExists {رفيقة أقصر موجودة}
translate Q ScorePlayed {لعبت النتيجة}
translate Q Expected {مُتوقع}
translate Q ChooseTrainingBase {اختر قاعدة التدريب}
translate Q Thinking {التفكير}
translate Q AnalyzeDone {تم التحليل}
translate Q WinWonGame {لعبة الفوز فاز}
translate Q Lines {خطوط}
translate Q ConfigureUCIengine {تكوين محرك UCI}
translate Q SpecificOpening {فتح محدد}
translate Q StartNewGame {ابدأ لعبة جديدة}
translate Q FixedLevel {مستوى ثابت}
translate Q Opening {افتتاح}
translate Q RandomLevel {مستوى عشوائي}
translate Q StartFromCurrentPosition {ابدأ من الوضع الحالي}
translate Q FixedDepth {عمق ثابت}
translate Q Nodes {العقد}
translate Q Depth {عمق}
translate Q Time {وقت}
translate Q SecondsPerMove {ثانية لكل خطوة}
translate Q Engine {محرك}
translate Q TimeMode {وضع الوقت}
translate Q TimeBonus {الوقت + المكافأة}
translate Q TimeMin {دقيقة}
translate Q TimeSec {ثانية}
translate Q AllExercisesDone {تم تنفيذ جميع التمارين}
translate Q MoveOutOfBook {انتقل من الكتاب}
translate Q LastBookMove {نقل الكتاب الأخير}
translate Q AnnotateSeveralGames {من لعبة فعلية إلى أخرى:}
translate Q FindOpeningErrors {البحث عن أخطاء الافتتاح}
translate Q MarkTacticalExercises {ضع علامة على التدريبات التكتيكية}
translate Q UseBook {استخدم الكتاب}
translate Q MultiPV {اختلافات متعددة}
translate Q Hash {ذاكرة التجزئة}
translate Q OwnBook {استخدام كتاب المحرك}
translate Q BookFile {كتاب الافتتاح}
translate Q AnnotateVariations {علق الاختلافات}
translate Q ShortAnnotations {شروح قصيرة}
translate Q addAnnotatorTag {إضافة علامة التعليق التوضيحي}
translate Q AddScoreToShortAnnotations {إضافة النتيجة إلى التعليقات التوضيحية}
translate Q Export {يصدّر}
translate Q BookPartiallyLoaded {تم تحميل الكتاب جزئيا}
translate Q Calvar {حساب الاختلافات}
translate Q ConfigureCalvar {إعدادات}
# Opening names used in tacgame.tcl
translate Q Reti {ريتي}
translate Q English {إنجليزي}
translate Q d4Nf6Miscellaneous {1.d4 Nf6 متنوعة}
translate Q Trompowsky {ترومبوسكي}
translate Q Budapest {بودابست}
translate Q OldIndian {هندي قديم}
translate Q BenkoGambit {بينكو جامبيت}
translate Q ModernBenoni {بينوني الحديث}
translate Q DutchDefence {الدفاع الهولندي}
translate Q Scandinavian {الاسكندنافية}
translate Q AlekhineDefence {دفاع ألكين}
translate Q Pirc {بيرك}
translate Q CaroKann {كارو كان}
translate Q CaroKannAdvance {كارو كان أدفانس}
translate Q Sicilian {صقلية}
translate Q SicilianAlapin {ألابين الصقلية}
translate Q SicilianClosed {صقلية مغلقة}
translate Q SicilianRauzer {راوزر الصقلية}
translate Q SicilianDragon {التنين الصقلي}
translate Q SicilianScheveningen {شيفينينجن الصقلية}
translate Q SicilianNajdorf {نجدورف الصقلية}
translate Q OpenGame {لعبة مفتوحة}
translate Q Vienna {فيينا}
translate Q KingsGambit {مناورة الملك}
translate Q RussianGame {لعبة روسية}
translate Q ItalianTwoKnights {إيطالي / فرسان}
translate Q Spanish {الأسبانية}
translate Q SpanishExchange {التبادل الاسباني}
translate Q SpanishOpen {الاسبانية المفتوحة}
translate Q SpanishClosed {الاسبانية مغلقة}
translate Q FrenchDefence {الدفاع الفرنسي}
translate Q FrenchAdvance {التقدم الفرنسي}
translate Q FrenchTarrasch {تاراش الفرنسية}
translate Q FrenchWinawer {ويناور الفرنسية}
translate Q FrenchExchange {التبادل الفرنسي}
translate Q QueensPawn {بيدق الملكة}
translate Q Slav {سلاف}
translate Q QGA {QGA}
translate Q QGD {QGD}
translate Q QGDExchange {تبادل QGD}
translate Q SemiSlav {شبه سلافية}
translate Q QGDwithBg5 {QGD مع Bg5}
translate Q QGDOrthodox {QGD الأرثوذكسية}
translate Q Grunfeld {جرونفيلد}
translate Q GrunfeldExchange {تبادل جرونفيلد}
translate Q GrunfeldRussian {غرونفيلد روسي}
translate Q Catalan {الكاتالونية}
translate Q CatalanOpen {الكاتالونية المفتوحة}
translate Q CatalanClosed {الكاتالونية مغلقة}
translate Q QueensIndian {الملكة الهندية}
translate Q NimzoIndian {نيمزو هندي}
translate Q NimzoIndianClassical {نيمزو-الهندية الكلاسيكية}
translate Q NimzoIndianRubinstein {نيمزو-روبنشتاين الهندي}
translate Q KingsIndian {هندي الملك}
translate Q KingsIndianSamisch {الملك الهندي Sämisch}
translate Q KingsIndianMainLine {خط الملك الهندي الرئيسي}

# FICS
translate Q ConfigureFics {تكوين FICS}
translate Q FICSGuest {تسجيل الدخول كضيف}
translate Q FICSServerPort {منفذ الخادم}
translate Q FICSServerAddress {عنوان IP}
translate Q FICSRefresh {ينعش}
translate Q FICSTimesealPort {ميناء الختم الزمني}
translate Q FICSSilence {مرشح وحدة التحكم}
translate Q FICSOffers {العروض}
translate Q FICSConsole {وحدة التحكم}
translate Q FICSGames {ألعاب}
translate Q FICSUnobserve {التوقف عن مراقبة اللعبة}
translate Q FICSProfile {عرض التاريخ والملف الشخصي الخاص بك}
translate Q FICSRelayedGames {العاب منقولة}
translate Q FICSFindOpponent {البحث عن الخصم}
translate Q FICSTakeback {الاسترجاع}
translate Q FICSTakeback2 {الاسترجاع 2}
translate Q FICSInitTime {الوقت الأولي (دقيقة)}
translate Q FICSIncrement {الزيادة (ثانية)}
translate Q FICSRatedGame {لعبة مصنفة}
translate Q FICSAutoColour {تلقائي}
translate Q FICSManualConfirm {تأكيد يدويا}
translate Q FICSFilterFormula {تصفية مع الصيغة}
translate Q FICSIssueSeek {قضية تسعى}
translate Q FICSChallenge {تحدي}
translate Q FICSAccept {هل تقبل ؟}
translate Q FICSDecline {انخفاض}
translate Q FICSColour {لون}
translate Q FICSSend {يرسل}
translate Q FICSConnect {يتصل}
translate Q FICSdefaultuservars {استخدم المتغيرات الافتراضية}
translate Q FICSObserveconfirm {هل تريد مراقبة اللعبة}
translate Q FICSpremove {تمكين قبل الإزالة}
translate Q FICSObserve {يراقب}
translate Q FICSRatedGames {الألعاب المقدرة}
translate Q FICSUnratedGames {ألعاب غير مصنفة}
translate Q FICSRated {تصنيف}
translate Q FICSUnrated {غير مصنف}
translate Q FICSRegisteredPlayer {لاعب مسجل فقط}
translate Q FICSFreePlayer {لاعب مجاني فقط}
translate Q FICSNetError {خطأ في الشبكة\لا يمكن الاتصال بها}

# Game review
translate Q GameReview {مراجعة اللعبة}
translate Q GameReviewTimeExtended {امتد الوقت}
translate Q GameReviewMargin {هامش الخطأ}
translate Q GameReviewAutoContinue {المتابعة التلقائية عندما تكون الحركة صحيحة}
translate Q GameReviewReCalculate {استخدم وقتًا ممتدًا}
translate Q GameReviewAnalyzingMovePlayedDuringTheGame {تحليل الحركة التي لعبت خلال المباراة}
translate Q GameReviewAnalyzingThePosition {تحليل الموقف}
translate Q GameReviewEnterYourMove {أدخل حركتك}
translate Q GameReviewCheckingYourMove {التحقق من تحركك}
translate Q GameReviewYourMoveWasAnalyzed {لقد تم تحليل حركتك}
translate Q GameReviewYouPlayedSameMove {لقد لعبت نفس الحركة كما في المباراة}
translate Q GameReviewScoreOfYourMove {النتيجة من التحرك الخاص بك}
translate Q GameReviewGameMoveScore {نتيجة تحرك اللعبة}
translate Q GameReviewEngineScore {درجة المحرك}
translate Q GameReviewYouPlayedLikeTheEngine {لقد لعبت جيدًا مثل المحرك}
translate Q GameReviewNotEngineMoveButGoodMove {ليست حركة المحرك، ولكنها أيضًا خطوة جيدة}
translate Q GameReviewMoveNotGood {هذه الخطوة ليست جيدة، والنتيجة هي}
translate Q GameReviewMovesPlayedLike {لعبت التحركات مثل}
translate Q GameReviewMovesPlayedEngine {لعبت التحركات مثل المحرك}

# Correspondence Chess Dialogs:
translate Q CCDlgCGeneraloptions {خيارات عامة}
translate Q CCDlgLoginName  {اسم تسجيل الدخول:}
translate Q CCDlgPassword   {كلمة المرور:}
translate Q CCDlgShowPassword {إظهار كلمة المرور}

# Connect Hardware dialogs
translate Q ExtHWConfigConnection {تكوين الأجهزة الخارجية}
translate Q ExtHWPort {ميناء}
translate Q ExtHWEngineCmd {أمر المحرك}
translate Q ExtHWEngineParam {معلمة المحرك}
translate Q ExtHWShowButton {زر إظهار}
translate Q ExtHWHardware {الأجهزة}
translate Q ExtHWNovag {نوفاج سيترين}
translate Q ExtHWInputEngine {محرك الإدخال}
translate Q ExtHWNoBoard {لا يوجد مجلس}
translate Q NovagReferee {الحكم}

# Input Engine dialogs
translate Q IEConsole {وحدة تحكم محرك الإدخال}
translate Q IESending {التحركات المرسلة ل}
translate Q IESynchronise {تزامن}
translate Q IERotate  {تناوب}
translate Q IEUnableToStart {غير قادر على بدء تشغيل محرك الإدخال:}

# Calculation of Variations
translate Q DoneWithPosition {انتهيت من الموقف}

translate Q Board {سبورة}
translate Q showGameInfo {عرض معلومات اللعبة}
translate Q autoResizeBoard {تغيير حجم اللوحة تلقائيًا}
translate Q DockTop {الانتقال إلى الأعلى}
translate Q DockBottom {الانتقال إلى الأسفل}
translate Q DockLeft {انتقل إلى اليسار}
translate Q DockRight {انتقل إلى اليمين}
translate Q Undock {إرساء}

# Switcher window
translate Q AboutDatabase {حول قاعدة البيانات هذه}
translate Q ChangeIcon {اختر أيقونة قاعدة البيانات...}
translate Q NewGameListWindow {نافذة قائمة الألعاب الجديدة}
translate Q LoadatStartup {تحميل عند بدء التشغيل}

# Gamelist window
translate Q ShowHideDB {إظهار/إخفاء قواعد البيانات}
translate Q ChangeFilter {تغيير الفلتر}
translate Q ChangeLayout {تحميل/حفظ/تغيير معايير الفرز وتخطيط العمود}
translate Q ShowHideStatistic {إظهار/إخفاء الإحصائيات}
translate Q BoardFilter {إظهار الألعاب التي تطابق موضع اللوحة الحالي فقط}
translate Q CopyGameTo {انسخ اللعبة إلى}
translate Q FindBar {البحث عن شريط}
translate Q FindCurrentGame {البحث عن اللعبة الحالية}
translate Q DeleteGame {حذف اللعبة}
translate Q UndeleteGame {لعبة الحذف}
translate Q ResetSort {إعادة تعيين النوع}

translate Q ConvertNullMove {تحويل التحركات الفارغة إلى التعليقات}
translate Q SetupBoard {لوحة الإعداد}
translate Q Rotate {تناوب}
translate Q SwitchColors {تبديل الألوان}
translate Q FlipBoard {الوجه المجلس}
translate Q ImportPGN {استيراد لعبة PGN}
translate Q ImportingFiles {استيراد ملفات PGN في}
translate Q ImportingFrom {الاستيراد من}
translate Q ImportingIn {استيراد الألعاب في}
translate Q UseLastTag {استخدم علامات\nاللعبة الأخيرة}
translate Q Random {عشوائي}
translate Q BackToMainline {العودة إلى الخط الرئيسي}
translate Q LeaveVariant {ترك البديل}
translate Q Autoplay {التشغيل التلقائي}
translate Q ShowHideCoords {إظهار/إخفاء التنسيق.}
translate Q ShowHideEvalBar {إظهار/إخفاء شريط التقييم}
translate Q ShowHideMaterial {إظهار/إخفاء المواد}
translate Q SelectMarker {حدد علامة}
translate Q FullScreen {شاشة كاملة}
translate Q FilterStatistic {إحصائيات التصفية}
translate Q MakeCorrections {إجراء التصحيحات}
translate Q Surnames {الألقاب}
translate Q Ambiguous {غامض}

#Preferences Dialog
translate Q OptionsToolbar "شريط الأدوات"
translate Q OptionsBoard "رقعة الشطرنج"
translate Q OptionsBoardSize "حجم اللوحة"
translate Q OptionsBoardPieces "نمط القطعة"
translate Q OptionsInternationalization "تدويل"
translate Q OptionsTablebaseDir "حدد ما يصل إلى 4 مجلدات أساسية للجدول:"

# Evaluation bar
translate Q BestMoveArrow "أفضل حركة السهم"
translate Q NewLocalEngine "+ محرك جديد ..."
}

