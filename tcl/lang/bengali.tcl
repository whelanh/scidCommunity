### bengali.tcl:
#  
proc setLanguage_b {} {

# File menu:
menuText b File "ফাইল" 0
menuText b FileNew "নতুন..." 0 {একটি নতুন Scid ডাটাবেস তৈরি করুন}
menuText b FileOpen "খোলা..." 0 {একটি বিদ্যমান Scid ডাটাবেস খুলুন}
menuText b FileClose "বন্ধ" 0 {সক্রিয় Scid ডাটাবেস বন্ধ করুন}
menuText b FileFinder "ফাইন্ডার" 0 {ফাইল ফাইন্ডার উইন্ডো খুলুন}
menuText b FileBookmarks "বুকমার্ক" 0 {বুকমার্ক মেনু}
menuText b FileBookmarksAdd "বুকমার্ক যোগ করুন" 0 \
  {বর্তমান ডাটাবেস গেম এবং অবস্থান বুকমার্ক করুন}
menuText b FileBookmarksFile "ফাইল বুকমার্ক" 0 \
  {বর্তমান খেলা এবং অবস্থানের জন্য একটি বুকমার্ক ফাইল করুন}
menuText b FileBookmarksEdit "বুকমার্ক সম্পাদনা করুন..." 0 \
  {বুকমার্ক মেনু সম্পাদনা করুন}
menuText b FileBookmarksList "একক তালিকা হিসাবে ফোল্ডারগুলি প্রদর্শন করুন" 0 \
  {বুকমার্ক ফোল্ডারগুলিকে একক তালিকা হিসাবে প্রদর্শন করুন, সাবমেনু নয়}
menuText b FileBookmarksSub "সাবমেনাস হিসাবে ফোল্ডারগুলি প্রদর্শন করুন" 0 \
  {বুকমার্ক ফোল্ডারগুলিকে সাবমেনু হিসাবে প্রদর্শন করুন, একটি একক তালিকা নয়}
menuText b FileMaint "রক্ষণাবেক্ষণ" 0 {Scid ডাটাবেস রক্ষণাবেক্ষণ সরঞ্জাম}
menuText b FileMaintWin "রক্ষণাবেক্ষণ উইন্ডো" 0 \
  {Scid ডাটাবেস রক্ষণাবেক্ষণ উইন্ডো খুলুন/বন্ধ করুন}
menuText b FileMaintCompact "কমপ্যাক্ট ডাটাবেস..." 0 \
  {কমপ্যাক্ট ডাটাবেস ফাইল, মুছে ফেলা গেম এবং অব্যবহৃত নাম অপসারণ}
menuText b FileMaintClass "ECO-শ্রেণীবদ্ধ গেম..." 2 \
  {সমস্ত গেমের ECO কোড পুনরায় গণনা করুন}
menuText b FileMaintSort "ডাটাবেস সাজান..." 0 \
  {ডাটাবেসে সমস্ত গেম সাজান}
menuText b FileMaintDelete "টুইন গেম মুছুন..." 0 \
  {টুইন গেম খুঁজুন এবং সেগুলি মুছে ফেলার জন্য সেট করুন}
menuText b FileMaintTwin "টুইন চেকার উইন্ডো" 0 \
  {টুইন চেকার উইন্ডো খুলুন/আপডেট করুন}
menuText b FileMaintName "নামের বানান" 0 {নাম সম্পাদনা এবং বানান সরঞ্জাম}
menuText b FileMaintNameEditor "নাম সম্পাদক" 0 \
  {নাম সম্পাদক উইন্ডো খুলুন/বন্ধ করুন}
menuText b FileMaintNamePlayer "প্লেয়ারের নাম বানান..." 11 \
  {বানান চেক ফাইল ব্যবহার করে প্লেয়ারের নাম বানান চেক করুন}
menuText b FileMaintNameEvent "বানান পরীক্ষা ইভেন্টের নাম..." 11 \
  {বানান চেক ফাইল ব্যবহার করে ইভেন্টের নাম বানান পরীক্ষা করুন}
menuText b FileMaintNameSite "সাইটের নাম বানান পরীক্ষা করুন..." 11 \
  {বানান চেক ফাইল ব্যবহার করে সাইটের নাম বানান পরীক্ষা করুন}
menuText b FileMaintNameRound "বানান চেক রাউন্ড নাম..." 11 \
  {বানান চেক ফাইল ব্যবহার করে রাউন্ড নামের বানান পরীক্ষা করুন}
menuText b FileReadOnly "শুধুমাত্র পঠনযোগ্য..." 0 \
  {বর্তমান ডাটাবেসকে শুধুমাত্র পঠন হিসাবে বিবেচনা করুন, পরিবর্তনগুলি প্রতিরোধ করুন}
menuText b FileSwitch "ডাটাবেসে স্যুইচ করুন" 0 \
  {একটি ভিন্ন খোলা ডাটাবেসে স্যুইচ করুন}
menuText b FileOpenLichessTournament "ওপেন লিচেস টুর্নামেন্ট" 0 {লাইভ লিচেস টুর্নামেন্ট সম্প্রচার গেমগুলি ডাউনলোড করুন এবং খুলুন}
menuText b FileImportLichess "আমার Lichess আমদানি" 0 {আপনার Lichess অ্যাকাউন্ট থেকে গেম আমদানি করুন}
menuText b FileImportChessCom "আমার chess.com আমদানি করুন" 0 {আপনার chess.com অ্যাকাউন্ট থেকে গেম আমদানি করুন}
menuText b FileExit "প্রস্থান করুন" 1 {প্রস্থান করুন Scid}
menuText b FileMaintFixBase "মেরামত বেস" 0 {একটি দূষিত বেস মেরামত করার চেষ্টা করুন}

# Edit menu:
menuText b Edit "সম্পাদনা করুন" 0
menuText b EditAdd "বৈচিত্র যোগ করুন" 0 {গেমের এই পদক্ষেপে একটি বৈচিত্র যোগ করুন}
menuText b EditDelete "বৈচিত্র মুছুন" 0 {এই পদক্ষেপের জন্য একটি বৈচিত্র মুছুন}
menuText b EditFirst "প্রথম পরিবর্তন করুন" 5 \
  {তালিকায় প্রথম হওয়ার জন্য একটি বৈচিত্র প্রচার করুন}
menuText b EditMain "বৈচিত্র্যকে প্রধান লাইনে উন্নীত করুন" 21 \
  {প্রধান লাইন হতে একটি বৈচিত্র প্রচার করুন}
menuText b EditTrial "বৈচিত্র চেষ্টা করুন" 0 \
  {বোর্ডে একটি ধারণা পরীক্ষা করার জন্য ট্রায়াল মোড শুরু/স্টপ করুন}
menuText b EditStrip "স্ট্রিপ" 3 {এই গেম থেকে মন্তব্য বা তারতম্য ফালা}
menuText b EditUndo "পূর্বাবস্থায় ফেরান" 0 {শেষ খেলা পরিবর্তন পূর্বাবস্থায় ফেরান}
menuText b EditRedo "আবার করুন" 0 {শেষ খেলা পরিবর্তন পুনরায় করুন}
menuText b EditStripComments "মন্তব্য" 0 \
  {এই গেম থেকে সমস্ত মন্তব্য এবং টীকা ছিনিয়ে নিন}
menuText b EditStripVars "বৈচিত্র" 0 {এই গেম থেকে সমস্ত বৈচিত্র বাদ দিন}
menuText b EditStripBegin "শুরু থেকেই চলে" 1 \
  {খেলার শুরু থেকেই স্ট্রিপ মুভ করে}
menuText b EditStripEnd "শেষ পর্যন্ত চলে" 0 \
  {স্ট্রিপ খেলার শেষে চলে যায়}
menuText b EditReset "খালি ক্লিপবেস" 0 \
  {সম্পূর্ণ খালি হতে ক্লিপবেস রিসেট করুন}
menuText b EditCopy "এই গেমটি ক্লিপবেসে কপি করুন" 0 \
  {ক্লিপবেস ডাটাবেসে এই গেমটি কপি করুন}
menuText b EditPaste "শেষ ক্লিপবেস গেমটি আটকান" 0 \
  {সক্রিয় ক্লিপবেস গেমটি এখানে পেস্ট করুন}
menuText b EditPastePGN "PGN গেম হিসাবে ক্লিপবোর্ড পাঠ্য আটকান..." 18 \
  {PGN স্বরলিপিতে ক্লিপবোর্ড পাঠ্যটিকে একটি গেম হিসাবে ব্যাখ্যা করুন এবং এটি এখানে পেস্ট করুন}
menuText b EditSetup "স্টার্ট বোর্ড সেট আপ করুন..." 0 \
  {এই গেমের জন্য শুরুর অবস্থান সেট করুন}
menuText b EditCopyBoard "কপি অবস্থান" 6 \
  {পাঠ্য নির্বাচন (ক্লিপবোর্ড) এ FEN স্বরলিপিতে বর্তমান বোর্ডটি অনুলিপি করুন}
menuText b EditPasteBoard "স্টার্ট বোর্ড আটকান" 12 \
  {বর্তমান পাঠ্য নির্বাচন থেকে স্টার্ট বোর্ড সেট করুন (ক্লিপবোর্ড)}
menuText b ConfigureScid "পছন্দ..." 0 {SCID-এর জন্য সমস্ত বিকল্প কনফিগার করুন}

# Game menu:
menuText b Game "খেলা" 0
menuText b GameNew "নতুন খেলা" 0 {একটি খালি খেলা রিসেট}
menuText b GameFirst "প্রথম খেলা লোড করুন" 5 {প্রথম ফিল্টার করা খেলা লোড করুন}
menuText b GamePrev "আগের খেলা লোড করুন" 5 {আগের ফিল্টার করা গেমটি লোড করুন}
menuText b GameReload "বর্তমান গেমটি পুনরায় লোড করুন" 3 \
  {এই গেমটি পুনরায় লোড করুন, করা যেকোনো পরিবর্তন বাতিল করে}
menuText b GameNext "পরবর্তী গেম লোড করুন" 7 {পরবর্তী ফিল্টার করা গেমটি লোড করুন}
menuText b GameLast "শেষ খেলা লোড করুন" 8 {শেষ ফিল্টার করা খেলা লোড করুন}
menuText b GameRandom "লোড র্যান্ডম খেলা" 8 {একটি এলোমেলো ফিল্টার করা গেম লোড করুন}
menuText b GameNumber "গেম নম্বর লোড করুন..." 5 \
  {একটি গেম এর নম্বর লিখুন লোড করুন}
menuText b GameReplace "সংরক্ষণ করুন: গেমটি প্রতিস্থাপন করুন..." 6 \
  {পুরানো সংস্করণ প্রতিস্থাপন, এই গেম সংরক্ষণ করুন}
menuText b GameAdd "সংরক্ষণ করুন: নতুন গেম যোগ করুন..." 6 \
  {এই গেমটিকে ডাটাবেসে একটি নতুন গেম হিসাবে সংরক্ষণ করুন}
menuText b GameDeepest "খোলার সনাক্তকরণ" 0 \
  {ECO বইতে তালিকাভুক্ত গভীরতম গেমের অবস্থানে যান}
menuText b GameGotoMove "মুভ নম্বরে যান..." 5 \
  {বর্তমান গেমে একটি নির্দিষ্ট সরানো নম্বরে যান}
menuText b GameNovelty "নতুনত্ব খুঁজুন..." 7 \
  {এই গেমের প্রথম চালটি খুঁজুন যা আগে খেলেনি}

# Search Menu:
menuText b Search "অনুসন্ধান করুন" 0
menuText b SearchReset "ফিল্টার রিসেট করুন" 0 {ফিল্টার রিসেট করুন যাতে সমস্ত গেম অন্তর্ভুক্ত করা হয়}
menuText b SearchNegate "নেগেট ফিল্টার" 0 {শুধুমাত্র বাদ দেওয়া গেমগুলিকে অন্তর্ভুক্ত করতে ফিল্টারটি বাতিল করুন৷}
menuText b SearchCurrent "বর্তমান বোর্ড..." 0 {বর্তমান বোর্ড অবস্থানের জন্য অনুসন্ধান করুন}
menuText b SearchHeader "হেডার..." 0 {হেডার (প্লেয়ার, ইভেন্ট, ইত্যাদি) তথ্য দ্বারা অনুসন্ধান করুন}
menuText b SearchMaterial "উপাদান/প্যাটার্ন..." 0 {উপাদান বা বোর্ড নিদর্শন জন্য অনুসন্ধান}
menuText b SearchUsing "অনুসন্ধান ফাইল ব্যবহার করে..." 0 {একটি SearchOptions ফাইল ব্যবহার করে অনুসন্ধান করুন}

# Windows menu:
menuText b Windows "উইন্ডোজ" 0
menuText b WindowsComment "মন্তব্য সম্পাদক" 0 {মন্তব্য সম্পাদক খুলুন/বন্ধ করুন}
menuText b WindowsGList "খেলা তালিকা" 0 {গেম লিস্ট উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsPGN "পিজিএন উইন্ডো" 0 \
  {PGN (গেম নোটেশন) উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsPList "প্লেয়ার ফাইন্ডার" 2 {প্লেয়ার ফাইন্ডার খুলুন/বন্ধ করুন}
menuText b WindowsTmt "টুর্নামেন্ট ফাইন্ডার" 2 {টুর্নামেন্ট ফাইন্ডার খুলুন/বন্ধ করুন}
menuText b WindowsSwitcher "ডাটাবেস সুইচার" 0 \
  {ডাটাবেস সুইচার উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsMaint "রক্ষণাবেক্ষণ উইন্ডো" 0 \
  {রক্ষণাবেক্ষণ উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsECO "ECO ব্রাউজার" 0 {ECO ব্রাউজার উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsStats "পরিসংখ্যান উইন্ডো" 0 \
  {ফিল্টার পরিসংখ্যান উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsTree "গাছের জানালা" 0 {ট্রি উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsBook "বইয়ের জানালা" 0 {বইয়ের উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsCorrChess "চিঠিপত্র উইন্ডো" 0 {চিঠিপত্র উইন্ডো খুলুন/বন্ধ করুন}
menuText b WindowsGraph "বিশ্লেষণ গ্রাফ" 0 {মুভের সময় এবং মূল্যায়ন সহ গ্রাফ উইন্ডোটি খুলুন}

# Tools menu:
menuText b Tools "টুলস" 0
menuText b ToolsConfigureEngines "ইঞ্জিন কনফিগার করুন" 10 {ইঞ্জিনের কনফিগারেশন পরিচালনা করুন}
menuText b ToolsAnalysis "বিশ্লেষণ ইঞ্জিন..." 0 \
  {একটি দাবা বিশ্লেষণ ইঞ্জিন শুরু/বন্ধ করুন}
menuText b ToolsAnalysis2 "বিশ্লেষণ ইঞ্জিন #2..." 17 \
  {2য় দাবা বিশ্লেষণ ইঞ্জিন শুরু/বন্ধ করুন}
menuText b ToolsCross "ক্রসস্টেবল" 0 {এই গেমের জন্য টুর্নামেন্ট ক্রসটেবল দেখান}
menuText b ToolsFilterGraph "রিল ফিল্টার গ্রাফ" 12 {আপেক্ষিক মানগুলির জন্য ফিল্টার গ্রাফ উইন্ডো খুলুন/বন্ধ করুন}
menuText b ToolsAbsFilterGraph "অ্যাবস ফিল্টার গ্রাফ" 7 {পরম মানগুলির জন্য ফিল্টার গ্রাফ উইন্ডো খুলুন/বন্ধ করুন}
menuText b ToolsOpReport "উদ্বোধনী প্রতিবেদন" 0 {বর্তমান অবস্থানের জন্য একটি উদ্বোধনী প্রতিবেদন তৈরি করুন}
menuText b ToolsOpenBaseAsTree "গাছ হিসাবে খোলা ভিত্তি ..." 0   {একটি বেস খুলুন এবং এটি ট্রি উইন্ডোতে ব্যবহার করুন}
menuText b ToolsOpenRecentBaseAsTree "গাছ হিসাবে সাম্প্রতিক বেস খুলুন" 0   {একটি সাম্প্রতিক বেস খুলুন এবং এটি ট্রি উইন্ডোতে ব্যবহার করুন}
menuText b ToolsTracker "পিস ট্র্যাকার"  6 {পিস ট্র্যাকার উইন্ডো খুলুন}
menuText b ToolsTraining "প্রশিক্ষণ"  0 {প্রশিক্ষণের সরঞ্জাম (কৌশল, খোলা,...)}
menuText b ToolsTacticalGame "কৌশলগত খেলা"  0 {কৌশলের সাথে একটি খেলা খেলুন}
menuText b ToolsSeriousGame "গুরুতর খেলা"  0 {একটি গুরুতর খেলা খেলুন}
menuText b ToolsTrainOpenings "খোলা"  0 {একটি সংগ্রহশালা সঙ্গে ট্রেন}
menuText b ToolsTrainReviewGame "খেলা পর্যালোচনা"  0 {একটি খেলায় খেলা অনুমান চাল}
menuText b ToolsTrainTactics "কৌশল"  0 {কৌশল সমাধান করুন}
menuText b ToolsTrainCalvar "বৈচিত্র্যের গণনা"  0 {বৈচিত্র্য প্রশিক্ষণের গণনা}
menuText b ToolsTrainFindBestMove "সেরা পদক্ষেপ খুঁজুন"  0 {সেরা পদক্ষেপ খুঁজুন}
menuText b ToolsTrainFics "FICS এ খেলুন"  0 {freechess.org এ খেলুন}
menuText b ToolsEngineTournament "ইঞ্জিন টুর্নামেন্ট"  0 {দাবা ইঞ্জিনের মধ্যে একটি টুর্নামেন্ট শুরু করুন}
menuText b ToolsTimeAnalysis "সময় বিশ্লেষণ" 0 {বর্তমান গেমের জন্য ঘড়ির সময় গ্রাফ দেখান}
menuText b ToolsBookTuning "বই টিউনিং" 0 {বই টিউনিং}
menuText b ToolsDownloadTWIC "TWIC গেম ডাউনলোড করুন" 0 {সর্বশেষ দ্য উইক ইন চেস (TWIC) গেম ডাউনলোড করুন}
menuText b ToolsConnectHardware "হার্ডওয়্যার সংযোগ করুন" 8 {বাহ্যিক হার্ডওয়্যার সংযোগ করুন}
menuText b ToolsConnectHardwareConfigure "কনফিগার করুন..." 0 {বাহ্যিক হার্ডওয়্যার এবং সংযোগ কনফিগার করুন}
menuText b ToolsConnectHardwareNovagCitrineConnect "নোভাগ সিট্রিন সংযোগ করুন" 8 {Scid এর সাথে Novag Citrine সংযোগ করুন}
menuText b ToolsConnectHardwareInputEngineConnect "ইনপুট ইঞ্জিন সংযোগ করুন" 8 {Scid এর সাথে ইনপুট ইঞ্জিন (যেমন DGT বোর্ড) সংযুক্ত করুন}

menuText b ToolsPInfo "প্লেয়ার তথ্য"  0 \
  {প্লেয়ার তথ্য উইন্ডো খুলুন/আপডেট করুন}
menuText b ToolsPlayerReport "প্লেয়ার রিপোর্ট..." 3 \
  {একটি প্লেয়ার রিপোর্ট তৈরি করুন}
menuText b ToolsRating "রেটিং গ্রাফ" 0 \
  {বর্তমান গেম প্লেয়ারদের রেটিং ইতিহাস গ্রাফ করুন}
menuText b ToolsExpCurrent "বর্তমান খেলা রপ্তানি করুন" 8 \
  {একটি টেক্সট ফাইল বর্তমান খেলা লিখুন}
menuText b ToolsExpCurrentPGN "PGN ফাইলে গেম রপ্তানি করুন..." 15 \
  {একটি PGN ফাইলে বর্তমান গেমটি লিখুন}
menuText b ToolsExpCurrentHTML "HTML ফাইলে গেম রপ্তানি করুন..." 15 \
  {একটি HTML ফাইলে বর্তমান গেম লিখুন}
menuText b ToolsExpCurrentHTMLJS "HTML এবং JavaScript ফাইলে গেম রপ্তানি করুন..." 15 {একটি HTML এবং JavaScript ফাইলে বর্তমান গেমটি লিখুন}
menuText b ToolsExpFilter "সমস্ত ফিল্টার গেম রপ্তানি করুন" 1 \
  {সমস্ত ফিল্টার করা গেমগুলি একটি পাঠ্য ফাইলে লিখুন}
menuText b ToolsExpFilterPGN "PGN ফাইলে ফিল্টার রপ্তানি করুন..." 17 \
  {একটি PGN ফাইলে সমস্ত ফিল্টার করা গেম লিখুন}
menuText b ToolsExpFilterHTML "HTML ফাইলে ফিল্টার রপ্তানি করুন..." 17 \
  {সমস্ত ফিল্টার করা গেম একটি HTML ফাইলে লিখুন}
menuText b ToolsExpFilterHTMLJS "HTML এবং JavaScript ফাইলে ফিল্টার রপ্তানি করুন..." 17 {একটি HTML এবং JavaScript ফাইলে সমস্ত ফিল্টার করা গেম লিখুন}
menuText b ToolsImportOne "একটি PGN গেম আমদানি করুন..." 0 \
  {PGN পাঠ্য থেকে একটি গেম আমদানি করুন৷}
menuText b ToolsImportFile "PGN ফাইল থেকে গেম ইম্পোর্ট করুন..." 7 {PGN ফাইল(গুলি) থেকে গেম ইম্পোর্ট করুন}
menuText b ToolsStartEngine1 "স্টার্ট ইঞ্জিন ১" 13  {স্টার্ট ইঞ্জিন ১}
menuText b ToolsStartEngine2 "স্টার্ট ইঞ্জিন 2" 13  {স্টার্ট ইঞ্জিন 2}
menuText b ToolsCaptureBoard "বর্তমান বোর্ড ক্যাপচার করুন..." 5  {বর্তমান বোর্ডটিকে একটি চিত্র হিসাবে সংরক্ষণ করুন।}

# Play menu
menuText b Play "খেলা" 0

# --- Correspondence Chess
menuText b CCResign "পদত্যাগ করুন" 1 {পদত্যাগ করুন (ইমেলের মাধ্যমে নয়)}
menuText b CCClaimDraw "দাবি ড্র" 6 {সরানো পাঠান এবং একটি ড্র দাবি করুন (ইমেলের মাধ্যমে নয়)}

# menu in cc window:

#  B    GHiJKL    Q  TUV XYZ

# Options menu:
menuText b Options "অপশন" 0
menuText b OptionsBoardGraphics "বর্গক্ষেত্র..." 0 {বর্গক্ষেত্রের জন্য টেক্সচার নির্বাচন করুন}
translate b OptionsBGW {বর্গক্ষেত্রের জন্য টেক্সচার নির্বাচন করুন}
translate b OptionsBoardGraphicsText {সাদা এবং কালো স্কোয়ারের জন্য গ্রাফিক ফাইল নির্বাচন করুন:}
menuText b OptionsBoardNames "আমার খেলোয়াড়ের নাম..." 0 {আমার খেলোয়াড়ের নাম সম্পাদনা করুন}
menuText b OptionsExport "রপ্তানি হচ্ছে" 0 {টেক্সট এক্সপোর্ট বিকল্প পরিবর্তন করুন}
menuText b OptionsFonts "হরফ" 0 {ফন্ট পরিবর্তন করুন}
menuText b OptionsFontsRegular "নিয়মিত" 0 {নিয়মিত ফন্ট পরিবর্তন করুন}
menuText b OptionsFontsMenu "মেনু" 0 {মেনু ফন্ট পরিবর্তন করুন}
menuText b OptionsFontsSmall "ছোট" 0 {ছোট ফন্ট পরিবর্তন করুন}
menuText b OptionsFontsTiny "ক্ষুদ্র" 0 {ছোট ফন্ট পরিবর্তন করুন}
menuText b OptionsFontsFixed "স্থির" 0 {স্থির-প্রস্থের ফন্ট পরিবর্তন করুন}
menuText b OptionsGInfo "খেলা তথ্য" 0 {খেলা তথ্য বিকল্প}
menuText b OptionsLanguage "ভাষা" 0 {মেনু ভাষা নির্বাচন করুন}
menuText b OptionsMovesTranslatePieces "টুকরা অনুবাদ" 0 {টুকরা প্রথম অক্ষর অনুবাদ}
menuText b OptionsMovesHighlightLastMove "শেষ পদক্ষেপ হাইলাইট করুন" 0 {শেষ পদক্ষেপ হাইলাইট করুন}
menuText b OptionsMovesHighlightLastMoveDisplay "স্কোয়ার দেখান" 0 {শেষ মুভ হাইলাইট প্রদর্শন করুন}
menuText b OptionsMovesHighlightLastMoveWidth "প্রস্থ" 0 {লাইনের পুরুত্ব}
menuText b OptionsMovesHighlightLastMoveColor "রঙ" 0 {লাইনের রঙ}
menuText b OptionsMovesHighlightLastMoveArrow "তীর দেখান" 0 {হাইলাইট সহ একটি তীর দেখান}
menuText b OptionsMovesHighlightLastMoveNag "টীকা চিহ্ন দেখান" 0
menuText b OptionsMovesHighlightLastMoveEval "মূল্যায়ন চিহ্ন দেখান" 0
menuText b OptionsMoves "নড়াচড়া করে" 0 {প্রবেশের বিকল্পগুলি সরান}
menuText b OptionsMovesAnimate "অ্যানিমেশন সময়" 1 \
  {চালগুলি অ্যানিমেট করতে ব্যবহৃত সময়ের পরিমাণ সেট করুন}
menuText b OptionsMovesDelay "অটোপ্লে সময় বিলম্ব..." 1 \
  {অটোপ্লে মোডের জন্য সময় বিলম্ব সেট করুন}
menuText b OptionsMovesCoord "স্থানাঙ্ক সরানো এন্ট্রি" 0 \
  {স্থানাঙ্ক-শৈলী সরানো এন্ট্রি গ্রহণ করুন (যেমন "g1f3")}
menuText b OptionsMovesSuggest "প্রস্তাবিত পদক্ষেপগুলি দেখান৷" 0 \
  {সরানোর পরামর্শ চালু/বন্ধ করুন}
menuText b OptionsShowVarPopup "বৈচিত্র্যের উইন্ডো দেখান" 0 {একটি ভিন্নতা উইন্ডোর প্রদর্শন চালু/বন্ধ করুন}
menuText b OptionsMovesSpace "স্থানান্তর নম্বরের পরে স্পেস যোগ করুন" 0 {স্থানান্তর নম্বরের পরে স্পেস যোগ করুন}
menuText b OptionsMovesLichess "টীকাগুলির জন্য লিচেস/চেসবেস বিন্যাস" 0 {বর্গাকার মার্কার এবং তীরগুলির জন্য Lichess/ChessBase বিন্যাস ব্যবহার করুন}
menuText b OptionsMovesKey "কীবোর্ড সমাপ্তি" 0 \
  {চালু/বন্ধ কীবোর্ড সরানো স্বয়ংক্রিয়-সম্পূর্ণতা}
menuText b OptionsMovesShowVarArrows "বৈচিত্র্যের জন্য তীর দেখান" 0 {বৈচিত্র্যের চাল দেখানো তীরগুলি চালু/বন্ধ করুন}
menuText b OptionsMovesShowEngineVariationArrows "ইঞ্জিন বৈচিত্র্যের জন্য তীর দেখান" 0 {মাল্টিপিভি মোডে ইঞ্জিনের বৈচিত্র্যের লাইন দেখানো তীরগুলি চালু/বন্ধ করুন}
menuText b OptionsMovesGlossOfDanger "কালার কোডেড গ্লস অফ ডেঞ্জার" 0 {বিপদের রঙিন কোডেড গ্লস চালু/বন্ধ করুন}
translate b OptionsMovesTreeDepth {ডিফল্ট ট্রি উইন্ডো সরানোর গভীরতা}
menuText b OptionsNumbers "নম্বর বিন্যাস" 0 {নম্বর বিন্যাস নির্বাচন করুন}
menuText b OptionsTheme "থিম" 0 {ইন্টারফেসের চেহারা পরিবর্তন করুন}
menuText b OptionsWindows "উইন্ডোজ" 0 {উইন্ডো বিকল্প}
menuText b OptionsSounds "শব্দ" 2 {সরানো ঘোষণার শব্দ কনফিগার করুন}
menuText b OptionsResources "সম্পদ..." 0 {সম্পদ ফাইল এবং ফোল্ডার নির্বাচন করুন}
menuText b OptionsWindowsDock "ডক জানালা" 0 {ডক উইন্ডোজ (পুনরায় চালু করতে হবে)}
menuText b OptionsWindowsSaveLayout "বিন্যাস সংরক্ষণ করুন" 0 {বিন্যাস সংরক্ষণ করুন}
menuText b OptionsWindowsRestoreLayout "লেআউট পুনরুদ্ধার করুন" 0 {লেআউট পুনরুদ্ধার করুন}
menuText b OptionsWindowsShowGameInfo "খেলার তথ্য দেখান" 0 {খেলার তথ্য দেখান}
menuText b OptionsWindowsAutoLoadLayout "অটো লোড প্রথম লেআউট" 0 {স্টার্টআপে প্রথম লেআউট স্বয়ংক্রিয়ভাবে লোড করুন}
menuText b OptionsECO "ECO ফাইল" 7 {ECO শ্রেণীবিভাগ ফাইল লোড করুন}
menuText b OptionsSpell "বানান পরীক্ষা ফাইল" 11 \
  {Scid বানান পরীক্ষা ফাইলটি লোড করুন}
menuText b OptionsTable "টেবিলবেস ডিরেক্টরি" 10 \
  {একটি টেবিলবেস ফাইল নির্বাচন করুন; এর ডিরেক্টরির সমস্ত টেবিলবেস ব্যবহার করা হবে}
menuText b OptionsRecent "সাম্প্রতিক ফাইল" 0 {ফাইল মেনুতে প্রদর্শিত সাম্প্রতিক ফাইলের সংখ্যা পরিবর্তন করুন}
menuText b OptionsBooksDir "বই ডিরেক্টরি" 0 {খোলার বই ডিরেক্টরি সেট করে}
menuText b OptionsTacticsBasesDir "বেস ডিরেক্টরি" 0 {কৌশল (প্রশিক্ষণ) বেস ডিরেক্টরি সেট করে}
menuText b OptionsPhotosDir "ফটো ডিরেক্টরি" 0 {ফটো বেস ডিরেক্টরি সেট করে}
menuText b OptionsThemeDir "থিম(গুলি) ফাইল"  0 {একটি GUI থিম প্যাকেজ ফাইল লোড করুন}
menuText b OptionsSave "সেভ অপশন" 0 "Save all settable options to the file $::optionsFile"
menuText b OptionsAutoSave "প্রস্থান করার সময় স্বয়ংক্রিয় সংরক্ষণ বিকল্প" 0 \
  {Scid থেকে প্রস্থান করার সময় সমস্ত বিকল্প স্বয়ংক্রিয়ভাবে সংরক্ষণ করুন}

# Help menu:
menuText b Help "সাহায্য" 0
menuText b HelpContents "বিষয়বস্তু" 0 {সাহায্য বিষয়বস্তু পৃষ্ঠা দেখান}
menuText b HelpIndex "সূচক" 0 {সাহায্য সূচী পৃষ্ঠা দেখান}
menuText b HelpGuide "দ্রুত গাইড" 0 {দ্রুত গাইড সাহায্য পৃষ্ঠা দেখান}
menuText b HelpHints "ইঙ্গিত" 0 {ইঙ্গিত সাহায্য পৃষ্ঠা দেখান}
menuText b HelpContact "যোগাযোগের তথ্য" 1 {যোগাযোগ তথ্য সাহায্য পৃষ্ঠা দেখান}
menuText b HelpTip "দিনের টিপ" 0 {একটি দরকারী Scid টিপ দেখান}
menuText b HelpStartup "স্টার্টআপ উইন্ডো" 0 {স্টার্টআপ উইন্ডো দেখান}
menuText b HelpAbout "সম্পর্কে" 0 {ScidCommunity সম্পর্কে তথ্য}

# Toolbar tooltips:
menuText b RotateBoard "বোর্ড ঘোরান" 0 {বোর্ড ঘোরান}

# Game info box popup menu:
menuText b GInfoHideNext "পরবর্তী মুভ লুকান" 0
menuText b GInfoMaterial "উপাদান মান দেখান" 0
menuText b GInfoFEN "FEN দেখান" 5
menuText b GInfoMarks "রঙিন স্কোয়ার এবং তীর দেখান" 5
menuText b GInfoWrap "লম্বা লাইন মোড়ানো" 0
menuText b GInfoFullComment "সম্পূর্ণ মন্তব্য দেখান" 10
menuText b GInfoPhotos "ফটো দেখান" 5
menuText b GInfoTBNothing "টেবিলবেস: কিছুই না" 12
menuText b GInfoTBResult "টেবিলবেস: শুধুমাত্র ফলাফল" 12
menuText b GInfoTBAll "টেবিলবেস: ফলাফল এবং সেরা পদক্ষেপ" 19
menuText b GInfoDelete "(আন)এই গেমটি মুছুন" 4
menuText b GInfoMark "(আন)এই গেমটিকে চিহ্নিত করুন" 4
menuText b GInfoInformant "তথ্যদাতা মান কনফিগার করুন" 0

# General buttons:
translate b Back {ফিরে}
translate b Browse {ব্রাউজ করুন}
translate b Cancel {বাতিল করুন}
translate b Continue {চালিয়ে যান}
translate b Clear {পরিষ্কার}
translate b Close {বন্ধ}
translate b Contents {বিষয়বস্তু}
translate b Defaults {ডিফল্ট}
translate b InvertSearch {ইনভার্ট সার্চ}
translate b Delete {মুছে দিন}
translate b Graph {গ্রাফ}
translate b Help {সাহায্য}
translate b Hide {লুকান}
translate b Import {আমদানি}
translate b Index {সূচক}
translate b LoadGame {লোড গেম}
translate b BrowseGame {খেলা ব্রাউজ করুন}
translate b MergeGame {গেম মার্জ করুন}
translate b MergeGames {গেম মার্জ করুন}
translate b Preview {পূর্বরূপ}
translate b Revert {প্রত্যাবর্তন}
translate b Save {সংরক্ষণ করুন}
translate b Search {অনুসন্ধান করুন}
translate b Stop {থামো}
translate b Store {দোকান}
translate b Update {আপডেট}
translate b ChangeOrient {উইন্ডোর অভিযোজন পরিবর্তন করুন}
translate b ShowIcons {আইকন দেখান}
translate b None {কোনোটিই নয়}
translate b First {প্রথম}
translate b Current {কারেন্ট}
translate b Last {শেষ}

# General messages:
translate b game {খেলা}
translate b games {গেম}
translate b move {সরানো}
translate b moves {চলে}
translate b all {সব}
translate b Yes {হ্যাঁ}
translate b No {না}
translate b Both {উভয়}
translate b King {রাজা}
translate b Queen {রানী}
translate b Rook {রুক}
translate b Bishop {বিশপ}
translate b Knight {নাইট}
translate b Pawn {প্যান}
translate b White {সাদা}
translate b Black {কালো}
translate b Player {প্লেয়ার}
translate b Rating {রেটিং}
translate b RatingDiff {রেটিং পার্থক্য (সাদা - কালো)}
translate b AverageRating {গড় রেটিং}
translate b Event {ঘটনা}
translate b Site {সাইট}
translate b Country {দেশ}
translate b IgnoreColors {রং উপেক্ষা করুন}
translate b Date {তারিখ}
translate b EventDate {ইভেন্ট তারিখ}
translate b Decade {দশক}
translate b Year {বছর}
translate b Month {মাস}
translate b Months {জানুয়ারি ফেব্রুয়ারি মার্চ এপ্রিল মে জুন জুলাই আগস্ট সেপ্টেম্বর অক্টোবর নভেম্বর ডিসেম্বর}
translate b Days {রবি সোম মঙ্গল বুধ শুক্র শনি}
translate b YearToToday {-1Y}
translate b YearToTodayTooltip {1 বছর আগে থেকে আজ পর্যন্ত তারিখ সেট করুন}
translate b Result {ফলাফল}
translate b Round {গোলাকার}
translate b Length {দৈর্ঘ্য}
translate b ECOCode {ECO কোড}
translate b ECO {ইসিও}
translate b Deleted {মুছে ফেলা হয়েছে}
translate b SearchResults {অনুসন্ধান ফলাফল}
translate b OpeningTheDatabase {ডাটাবেস খোলা হচ্ছে}
translate b Database {ডাটাবেস}
translate b Filter {ফিল্টার}
translate b noGames {কোন খেলা নেই}
translate b allGames {সব গেম}
translate b empty {খালি}
translate b clipbase {ক্লিপবেস}
translate b score {স্কোর}
translate b StartPos {অবস্থান শুরু করুন}
translate b Total {মোট}
translate b readonly {শুধুমাত্র পড়ার জন্য}

# Standard error messages:
translate b ErrNotOpen {এটি একটি খোলা ডাটাবেস নয়।}
translate b ErrReadOnly {এই ডাটাবেস শুধুমাত্র পঠনযোগ্য; এটা পরিবর্তন করা যাবে না।}
translate b ErrSearchInterrupted {অনুসন্ধান ব্যাহত হয়েছিল; ফলাফল অসম্পূর্ণ।}
translate b ErrNoClockComments {এই গেমটিতে কোনো [%clk] ঘড়ির মন্তব্য পাওয়া যায়নি।  এই বৈশিষ্ট্যটি ব্যবহার করতে মন্তব্য উইন্ডো (Ctrl+E) এর মাধ্যমে ঘড়ির সময় যোগ করুন।}
translate b ErrFileInUse {ত্রুটি: ফাইলটি ইতিমধ্যেই ব্যবহার করা হচ্ছে৷ এই ডাটাবেস ব্যবহার করে অন্য কোনো অ্যাপ্লিকেশন বন্ধ করুন. প্রোগ্রামটি অপ্রত্যাশিতভাবে বন্ধ হয়ে গেলে, আপনাকে ডাটাবেসের সাথে যুক্ত .lock ফাইলটি মুছে ফেলতে হতে পারে।}




# Game information:
translate b twin {যমজ}
translate b deleted {মুছে ফেলা}
translate b comment {মন্তব্য}
translate b hidden {লুকানো}
translate b LastMove {শেষ চাল}
translate b NextMove {পরবর্তী}
translate b GameStart {খেলার শুরু}
translate b LineStart {লাইনের শুরু}
translate b GameEnd {খেলা শেষ}
translate b LineEnd {লাইনের শেষ}

# Player information:
translate b PInfoAll {<b>সমস্ত</b> গেমের ফলাফল}
translate b PInfoFilter {<b>ফিল্টার</b> গেমের ফলাফল}
translate b PInfoAgainst {বিরুদ্ধে ফলাফল}
translate b PInfoMostWhite {সাদা হিসাবে সবচেয়ে সাধারণ খোলার}
translate b PInfoMostBlack {কালো হিসাবে সবচেয়ে সাধারণ খোলার}
translate b PInfoRating {রেটিং ইতিহাস}
translate b PInfoBio {জীবনী}
translate b PInfoEditRatings {রেটিং সম্পাদনা করুন}
translate b PInfoEloFile {ফাইল}

# Tablebase information:
translate b Draw {আঁকা}
translate b with {সঙ্গে}
translate b only {শুধুমাত্র}
translate b lose {হারান}
translate b loses {হারায়}

# Tip of the day:
translate b Tip {টিপ}
translate b TipAtStartup {শুরুতে টিপ}
translate b TipConvertPGN {আপনি PGN ফাইলগুলিকে রূপান্তর করে আরও ভাল পারফরম্যান্স পেতে পারেন}

# Tree window menus:
menuText b TreeFile "ফাইল" 0
menuText b TreeFileFillWithBase "বেস দিয়ে ক্যাশে পূরণ করুন" 0 {বর্তমান বেসে সমস্ত গেম দিয়ে ক্যাশে ফাইলটি পূরণ করুন}
menuText b TreeFileFillWithGame "খেলা দিয়ে ক্যাশে পূরণ করুন" 0 {বর্তমান বেসে বর্তমান গেমের সাথে ক্যাশে ফাইলটি পূরণ করুন}
menuText b TreeFileSetCacheSize "ক্যাশে আকার" 0 {ক্যাশ সাইজ সেট করুন}
menuText b TreeFileCacheInfo "ক্যাশে তথ্য" 0 {ক্যাশে ব্যবহারের তথ্য পান}
menuText b TreeFileSave "ক্যাশে ফাইল সংরক্ষণ করুন" 0 {ট্রি ক্যাশে (.stc) ফাইলটি সংরক্ষণ করুন}
menuText b TreeFileFill "ক্যাশে ফাইল পূরণ করুন" 0 \
  {সাধারণ খোলার অবস্থানের সাথে ক্যাশে ফাইলটি পূরণ করুন}
menuText b TreeFileBest "সেরা গেম তালিকা" 0 {সেরা গাছ গেম তালিকা দেখান}
menuText b TreeFileGraph "গ্রাফ উইন্ডো" 0 {এই গাছের শাখার জন্য গ্রাফ দেখান}
menuText b TreeFileCopy "ট্রি টেক্সট ক্লিপবোর্ডে কপি করুন" 1 \
  {ক্লিপবোর্ডে গাছের পরিসংখ্যান কপি করুন}
menuText b TreeFileClose "গাছের জানালা বন্ধ করুন" 0 {গাছের জানালা বন্ধ করুন}
menuText b TreeMask "মুখোশ" 0
menuText b TreeMaskNew "নতুন" 0 {নতুন মুখোশ}
menuText b TreeMaskOpen "খোলা" 0 {মুখোশ খুলুন}
menuText b TreeMaskOpenRecent "সাম্প্রতিক খুলুন" 0 {সাম্প্রতিক মাস্ক খুলুন}
menuText b TreeMaskSave "সংরক্ষণ করুন" 0 {মাস্ক সংরক্ষণ করুন}
menuText b TreeMaskClose "বন্ধ" 0 {মুখোশ বন্ধ করুন}
menuText b TreeMaskFillWithGame "খেলা দিয়ে পূরণ করুন" 0 {খেলা দিয়ে মুখোশ পূরণ করুন}
menuText b TreeMaskFillWithBase "বেস দিয়ে পূরণ করুন" 0 {বেস সব গেম সঙ্গে মাস্ক পূরণ করুন}
menuText b TreeMaskInfo "তথ্য" 0 {বর্তমান মাস্কের পরিসংখ্যান দেখান}
menuText b TreeMaskDisplay "ডিসপ্লে মাস্ক ম্যাপ" 0 {একটি গাছ আকারে মাস্ক ডেটা দেখান}
menuText b TreeMaskSearch "অনুসন্ধান করুন" 0 {বর্তমান মাস্কে অনুসন্ধান করুন}
menuText b TreeSort "সাজান" 0
menuText b TreeSortAlpha "বর্ণানুক্রমিক" 0
menuText b TreeSortECO "ECO কোড" 0
menuText b TreeSortFreq "ফ্রিকোয়েন্সি" 0
menuText b TreeSortScore "স্কোর" 0
menuText b TreeOpt "অপশন" 0
menuText b TreeOptSlowmode "ধীর মোড" 0 {আপডেটের জন্য ধীর মোড (উচ্চ নির্ভুলতা)}
menuText b TreeOptFastmode "দ্রুত মোড" 0 {আপডেটের জন্য দ্রুত মোড (কোন সরানো স্থানান্তর নেই)}
menuText b TreeOptFastAndSlowmode "দ্রুত এবং ধীর মোড" 0 {আপডেটের জন্য দ্রুত মোড তারপর ধীর মোড}
menuText b TreeOptStartStop "স্বয়ংক্রিয় রিফ্রেশিং" 0 {ট্রি উইন্ডোর স্বয়ংক্রিয় রিফ্রেশিং টগল করে}
menuText b TreeOptLock "তালা" 0 {বর্তমান ডাটাবেসে গাছটিকে লক/আনলক করুন}
menuText b TreeOptTraining "প্রশিক্ষণ" 0 {ট্রি ট্রেনিং মোড চালু/বন্ধ করুন}
menuText b TreeOptDepth "গভীরতা সরান" 0 {গাছে প্রদর্শিত অর্ধেক চালের সংখ্যা (1-4)}
menuText b TreeOptAutosave "অটো-সেভ ক্যাশে ফাইল" 0 \
  {ট্রি উইন্ডো বন্ধ করার সময় ক্যাশে ফাইলটি স্বয়ংক্রিয়ভাবে সংরক্ষণ করুন}
menuText b TreeHelp "সাহায্য" 0
menuText b TreeHelpTree "গাছ সাহায্য" 0
menuText b TreeHelpIndex "সাহায্য সূচক" 0
translate b SaveCache {ক্যাশে সংরক্ষণ করুন}
translate b Training {প্রশিক্ষণ}
translate b LockTree {তালা}
translate b TreeDepth {গাছের গভীরতা (অর্ধেক চাল):}
translate b TreeLocked {তালাবদ্ধ}
translate b TreeBest {সেরা}
translate b TreeBestGames {সেরা গাছ গেম}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate b TreeTitleRow \
  {মুভ(গুলি) ECO ফ্রিকোয়েন্সি স্কোর AvElo Perf AvYear % Draws % Win}
translate b TreeTotal {মোট}
translate b DoYouWantToSaveFirst {আপনি প্রথমে সংরক্ষণ করতে চান}
translate b AddToMask {মাস্কে যোগ করুন}
translate b RemoveFromMask {মাস্ক থেকে সরান}
translate b AddThisMoveToMask {এই পদক্ষেপটি মাস্কে যুক্ত করুন}
translate b SearchMask {মাস্কে অনুসন্ধান করুন}
translate b DisplayMask {ডিসপ্লে মাস্ক}
translate b Nag {নাগ কোড}
translate b Marker {মার্কার}
translate b Include {অন্তর্ভুক্ত করুন}
translate b Exclude {বাদ দিন}
translate b MainLine {প্রধান লাইন}
translate b Bookmark {বুকমার্ক}
translate b NewLine {নতুন লাইন}
translate b ToBeVerified {যাচাই করতে হবে}
translate b ToTrain {প্রশিক্ষণ দিতে}
translate b Dubious {সন্দেহজনক}
translate b ToRemove {অপসারণ করতে}
translate b NoMarker {কোন মার্কার নেই}
translate b ColorMarker {রঙ}
translate b WhiteMark {সাদা}
translate b GreenMark {সবুজ}
translate b YellowMark {হলুদ}
translate b BlueMark {নীল}
translate b RedMark {লাল}
translate b CommentMove {মন্তব্য সরানো}
translate b CommentPosition {মন্তব্য অবস্থান}
translate b AddMoveToMaskFirst {প্রথমে মাস্কে সরানো যোগ করুন}
translate b OpenAMaskFileFirst {প্রথমে একটি মাস্ক ফাইল খুলুন}
translate b Positions {পদ}
translate b Moves {নড়াচড়া করে}

# Finder window:
menuText b FinderFile "ফাইল" 0
menuText b FinderFileSubdirs "সাবডিরেক্টরিতে দেখুন" 0
menuText b FinderFileClose "ফাইল ফাইন্ডার বন্ধ করুন" 0
menuText b FinderSort "সাজান" 0
menuText b FinderSortType "টাইপ" 0
menuText b FinderSortSize "আকার" 0
menuText b FinderSortMod "পরিবর্তিত" 0
menuText b FinderSortName "নাম" 0
menuText b FinderSortPath "পথ" 0
menuText b FinderTypes "প্রকারভেদ" 0
menuText b FinderTypesScid "Scid ডাটাবেস" 0
menuText b FinderTypesOld "পুরানো-ফরম্যাট Scid ডেটাবেস" 0
menuText b FinderTypesPGN "PGN ফাইল" 0
menuText b FinderTypesEPD "EPD ফাইল" 0
menuText b FinderTypesRep "সংগ্রহশালা ফাইল" 0
menuText b FinderHelp "সাহায্য" 0
menuText b FinderHelpFinder "ফাইল ফাইন্ডার সহায়তা" 0
menuText b FinderHelpIndex "সাহায্য সূচক" 0
translate b FileFinder {ফাইল ফাইন্ডার}
translate b FinderDir {ডিরেক্টরি}
translate b FinderDirs {ডিরেক্টরি}
translate b FinderFiles {ফাইল}
translate b FinderUpDir {আপ}
translate b FinderCtxOpen {খোলা}
translate b FinderCtxBackup {ব্যাকআপ}
translate b FinderCtxCopy {কপি}
translate b FinderCtxMove {সরান}
translate b FinderCtxDelete {মুছে দিন}

# Player finder:
menuText b PListFile "ফাইল" 0
menuText b PListFileUpdate "আপডেট" 0
menuText b PListFileClose "প্লেয়ার ফাইন্ডার বন্ধ করুন" 0
menuText b PListSort "সাজান" 0
menuText b PListSortName "নাম" 0
menuText b PListSortElo "এলো" 0
menuText b PListSortGames "গেমস" 0
menuText b PListSortOldest "প্রাচীনতম" 0
menuText b PListSortNewest "সবথেকে নতুন" 2

# Tournament finder:
menuText b TmtFile "ফাইল" 0
menuText b TmtFileUpdate "আপডেট" 0
menuText b TmtFileClose "টুর্নামেন্ট ফাইন্ডার বন্ধ করুন" 0
menuText b TmtSort "সাজান" 0
menuText b TmtSortDate "তারিখ" 0
menuText b TmtSortPlayers "খেলোয়াড়" 0
menuText b TmtSortGames "গেমস" 0
menuText b TmtSortElo "এলো" 0
menuText b TmtSortSite "সাইট" 0
menuText b TmtSortEvent "ঘটনা" 1
menuText b TmtSortWinner "বিজয়ী" 0
translate b TmtLimit "তালিকা সীমা"
translate b TmtMeanElo "মানে এলো"
translate b TmtNone "কোন ম্যাচিং টুর্নামেন্ট পাওয়া যায়নি."

# Graph windows:
menuText b GraphFile "ফাইল" 0
menuText b GraphFileColor "রঙিন পোস্টস্ক্রিপ্ট হিসাবে সংরক্ষণ করুন..." 8
menuText b GraphFileGrey "গ্রেস্কেল পোস্টস্ক্রিপ্ট হিসাবে সংরক্ষণ করুন..." 8
menuText b GraphFileClose "উইন্ডো বন্ধ করুন" 6
menuText b GraphOptions "অপশন" 0
menuText b GraphOptionsWhite "সাদা" 0
menuText b GraphOptionsBlack "কালো" 0
menuText b GraphOptionsBoth "উভয়" 1
menuText b GraphOptionsPInfo "প্লেয়ার ইনফো প্লেয়ার" 0
menuText b GraphOptionsEloFile "রেটিং ফাইল থেকে Elo" 0
menuText b GraphOptionsEloDB "ডাটাবেস থেকে Elo" 0
translate b GraphFilterTitle "ফিল্টার গ্রাফ: পজিশনে পৌঁছানোর গেমের শতাংশ"
translate b GraphAbsFilterTitle "ফিল্টার গ্রাফ: গেমের ফ্রিকোয়েন্সি"
translate b ConfigureFilter "বছর, রেটিং এবং মুভের জন্য X-অক্ষ কনফিগার করুন"
translate b FilterEstimate "অনুমান"
translate b TitleFilterGraph "Scid: ফিল্টার গ্রাফ"

# Analysis window:
translate b AddVariation {বৈচিত্র যোগ করুন}
translate b AddAllVariations {সমস্ত বৈচিত্র যোগ করুন}
translate b AddMove {সরান যোগ করুন}
translate b Annotate {টীকা}
translate b ShowAnalysisBoard {বিশ্লেষণ বোর্ড দেখান}
translate b ShowInfo {ইঞ্জিনের তথ্য দেখান}
translate b FinishGame {খেলা শেষ করুন}
translate b StopEngine {ইঞ্জিন বন্ধ করুন}
translate b StartEngine {ইঞ্জিন চালু করুন}
translate b LockEngine {বর্তমান অবস্থানে ইঞ্জিন লক করুন}
translate b AnalysisCommand {বিশ্লেষণ কমান্ড}
translate b PreviousChoices {পূর্ববর্তী পছন্দ}
translate b AnnotateTime {সেকেন্ডে প্রতি মুভ করার সময়।}
translate b AnnotateWhich {বৈচিত্র যোগ করুন}
translate b AnnotateAll {উভয় পক্ষের দ্বারা পদক্ষেপের জন্য}
translate b AnnotateAllMoves {সব চাল টীকা}
translate b AnnotateWhite {শুধুমাত্র সাদা চাল জন্য}
translate b AnnotateBlack {শুধুমাত্র কালো চাল জন্য}
translate b AnnotateBlundersOnly {যখন খেলা সরানো একটি ভুল}
translate b AnnotateBlundersOnlyScoreChange {বিশ্লেষণ ভুল রিপোর্ট করে, স্কোর পরিবর্তন থেকে/তে:}
translate b BlundersThreshold {থ্রেশহোল্ড}
translate b ScoreAllMoves {সব চাল স্কোর}
translate b LowPriority {কম সিপিইউ অগ্রাধিকার}
translate b ClickHereToSeeMoves {চলন দেখতে এখানে ক্লিক করুন}
translate b ConfigureInformant {তথ্যমূলক মান}
translate b Informant!? {আকর্ষণীয় পদক্ষেপ}
translate b Informant? {দরিদ্র পদক্ষেপ}
translate b Informant?? {ব্লন্ডার}
translate b Informant?! {সন্দেহজনক পদক্ষেপ}
translate b Informant+= {সাদা একটি সামান্য সুবিধা আছে}
translate b Informant+/- {সাদা একটি স্পষ্ট সুবিধা আছে}
translate b Informant+- {সাদা একটি নিষ্পত্তিমূলক সুবিধা আছে}
translate b Informant+-- {সাদা একটি নিষ্পেষণ সুবিধা আছে}
translate b AutoComment {স্বয়ংক্রিয় মন্তব্য}
translate b AutoCommentTooltip {বর্তমান অবস্থানের জন্য AI ভাষ্য তৈরি করুন}
translate b AnalysisAutoCommentTooltip {পুরো গেমের জন্য AI ধারাভাষ্য তৈরি করুন}
translate b GameComment {খেলা মন্তব্য}
translate b GameCommentTooltip {টীকাযুক্ত পদক্ষেপের জন্য গেম স্ক্যান করুন এবং এআই সারাংশ তৈরি করুন}
translate b TimeMs {সময়(ms)}


# Book window
translate b Book {বই}
translate b OtherBookMoves {প্রতিপক্ষের বই}
translate b OtherBookMovesTooltip {প্রতিপক্ষের একটি উত্তর আছে যা চালনা}

# Analysis Engine open dialog:
translate b EngineList {বিশ্লেষণ ইঞ্জিন তালিকা}
translate b EngineName {নাম}
translate b EngineCmd {আদেশ}
translate b EngineArgs {পরামিতি}
translate b EngineDir {ডিরেক্টরি}
translate b EngineElo {এলো}
translate b EngineTime {তারিখ}
translate b EngineNew {নতুন}
translate b EngineEdit {সম্পাদনা করুন}
translate b EngineRequired {গাঢ় ক্ষেত্র প্রয়োজন; অন্যরা ঐচ্ছিক}
translate b EngineProtocol {যোগাযোগ প্রোটোকল}
translate b EngineNotation {পদক্ষেপের স্বরলিপি}
translate b EngineFlipEvaluation {ফ্লিপ মূল্যায়ন দৃষ্টিকোণ}
translate b EngineShowLog {যোগাযোগ লগ দেখান}
translate b EngineNetworkd {দূরবর্তী সংযোগ গ্রহণ করুন}
translate b EngineSelect {বর্তমান ইঞ্জিন নির্বাচন করুন}
translate b EngineAddLocal {একটি স্থানীয় ইঞ্জিন যোগ করুন}
translate b EngineAddRemote {একটি দূরবর্তী ইঞ্জিন যোগ করুন}
translate b EngineReload {বর্তমান ইঞ্জিন পুনরায় লোড করুন}
translate b EngineClone {বর্তমান ইঞ্জিনের একটি অনুলিপি তৈরি করুন}
translate b EngineDelete {বর্তমান ইঞ্জিন মুছুন}

# PGN window menus:
menuText b PgnFile "ফাইল" 0
menuText b PgnFileCopy "ক্লিপবোর্ডে গেমটি অনুলিপি করুন" 0
menuText b PgnFilePrint "ফাইলে প্রিন্ট করুন..." 0
menuText b PgnFileClose "PGN উইন্ডো বন্ধ করুন" 10
menuText b PgnOpt "প্রদর্শন" 0
menuText b PgnOptColor "কালার ডিসপ্লে" 0
menuText b PgnOptShort "ছোট (3-লাইন) হেডার" 0
menuText b PgnOptSymbols "প্রতীকী টীকা" 1
menuText b PgnOptIndentC "ইন্ডেন্ট মন্তব্য" 0
menuText b PgnOptIndentV "ইন্ডেন্ট বৈচিত্র" 7
menuText b PgnOptColumn "কলাম শৈলী (প্রতি লাইনে এক মুভ)" 1
menuText b PgnOptSpace "স্থানান্তর নম্বর পরে স্থান" 1
menuText b PgnOptStripMarks "রঙিন স্কোয়ার/তীর কোডগুলি বের করুন" 1
menuText b PgnOptBoldMainLine "মেইন লাইন মুভের জন্য বোল্ড টেক্সট ব্যবহার করুন" 4
menuText b PgnColor "রং" 0
menuText b PgnColorHeader "হেডার..." 0
menuText b PgnColorAnno "টীকা..." 0
menuText b PgnColorComments "মন্তব্য..." 0
menuText b PgnColorVars "বৈচিত্র..." 0
menuText b PgnColorBackground "পটভূমি..." 0
menuText b PgnColorMain "প্রধান লাইন..." 0
menuText b PgnColorCurrent "বর্তমান সরানো পটভূমি..." 1
menuText b PgnHelp "সাহায্য" 0
menuText b PgnHelpPgn "PGN সাহায্য" 0
menuText b PgnHelpIndex "সূচক" 0
translate b PgnWindowTitle {স্বরলিপি - খেলা %u}

# Crosstable window menus:
menuText b CrosstabFile "ফাইল" 0
menuText b CrosstabFileText "টেক্সট ফাইলে প্রিন্ট করুন..." 9
menuText b CrosstabFileHtml "HTML ফাইলে প্রিন্ট করুন..." 9
menuText b CrosstabFileClose "ক্রসস্টেবল উইন্ডো বন্ধ করুন" 0
menuText b CrosstabEdit "সম্পাদনা করুন" 0
menuText b CrosstabEditEvent "ঘটনা" 0
menuText b CrosstabEditSite "সাইট" 0
menuText b CrosstabEditDate "তারিখ" 0
menuText b CrosstabOpt "প্রদর্শন" 0
menuText b CrosstabOptAll "অল-প্লে-সব" 0
menuText b CrosstabOptSwiss "সুইস" 0
menuText b CrosstabOptKnockout "নকআউট" 0
menuText b CrosstabOptAuto "অটো" 1
menuText b CrosstabOptAges "বছরের মধ্যে বয়স" 8
menuText b CrosstabOptNats "জাতীয়তা" 0
menuText b CrosstabOptRatings "রেটিং" 0
menuText b CrosstabOptTitles "শিরোনাম" 0
menuText b CrosstabOptBreaks "টাই-ব্রেক স্কোর" 4
menuText b CrosstabOptDeleted "মুছে ফেলা গেমগুলি অন্তর্ভুক্ত করুন" 8
menuText b CrosstabOptColors "রং (শুধুমাত্র সুইস টেবিল)" 0
menuText b CrosstabOptColumnNumbers "সংখ্যাযুক্ত কলাম (শুধুমাত্র সমস্ত-সকল টেবিল)" 2
menuText b CrosstabOptGroup "গ্রুপ স্কোর" 0
menuText b CrosstabSort "সাজান" 0
menuText b CrosstabSortName "নাম" 0
menuText b CrosstabSortRating "রেটিং" 0
menuText b CrosstabSortScore "স্কোর" 0
menuText b CrosstabColor "রঙ" 0
menuText b CrosstabColorPlain "প্লেইন টেক্সট" 0
menuText b CrosstabColorHyper "হাইপারটেক্সট" 0
menuText b CrosstabHelp "সাহায্য" 0
menuText b CrosstabHelpCross "ক্রসস্টেবল সাহায্য" 0
menuText b CrosstabHelpIndex "সাহায্য সূচক" 0
translate b SetFilter {ফিল্টার সেট করুন}
translate b AddToFilter {ফিল্টারে যোগ করুন}
translate b Swiss {সুইস}
translate b Category {শ্রেণী}

# Opening report window menus:
menuText b OprepFile "ফাইল" 0
menuText b OprepFileText "টেক্সট ফাইলে প্রিন্ট করুন..." 9
menuText b OprepFileHtml "HTML ফাইলে প্রিন্ট করুন..." 9
menuText b OprepFileOptions "বিকল্প..." 0
menuText b OprepFileClose "রিপোর্ট উইন্ডো বন্ধ করুন" 0
menuText b OprepFavorites "প্রিয়" 1
menuText b OprepFavoritesAdd "প্রতিবেদন যোগ করুন..." 0
menuText b OprepFavoritesEdit "প্রতিবেদন পছন্দ সম্পাদনা করুন..." 0
menuText b OprepFavoritesGenerate "প্রতিবেদন তৈরি করুন..." 0
menuText b OprepHelp "সাহায্য" 0
menuText b OprepHelpReport "খোলার রিপোর্ট সাহায্য" 0
menuText b OprepHelpIndex "সাহায্য সূচক" 0

# Header search:
translate b HeaderSearch {শিরোনাম অনুসন্ধান}
translate b EndSideToMove {খেলা শেষে সরানোর জন্য পাশ}
translate b GamesWithNoECO {কোন ECO সঙ্গে গেম?}
translate b GameLength {খেলার দৈর্ঘ্য}
translate b FindGamesWith {পতাকা সহ গেম খুঁজুন}
translate b StdStart {অ-মানক শুরু}
translate b Promotions {প্রচার}
translate b Comments {মন্তব্য}
translate b Variations {বৈচিত্র}
translate b Annotations {টীকা}
translate b DeleteFlag {পতাকা মুছুন}
translate b WhiteOpFlag {সাদা খোলার}
translate b BlackOpFlag {কালো খোলার}
translate b MiddlegameFlag {মিডলগেম}
translate b EndgameFlag {শেষ খেলা}
translate b NoveltyFlag {অভিনবত্ব}
translate b PawnFlag {প্যান গঠন}
translate b TacticsFlag {কৌশল}
translate b QsideFlag {কুইনসাইড খেলা}
translate b KsideFlag {কিংসাইড খেলা}
translate b BrilliancyFlag {উজ্জ্বলতা}
translate b BlunderFlag {ব্লন্ডার}
translate b UserFlag {ব্যবহারকারী}
translate b PgnContains {PGN তে পাঠ্য রয়েছে}
translate b PgnTag {ট্যাগ}
translate b TagContains {ধারণ করে}
translate b Variant {বৈকল্পিক}
translate b Annotator {টীকাকার}
translate b Cmnts {শুধুমাত্র টীকা খেলা}

# Game list window:
translate b GlistNumber {সংখ্যা}
translate b GlistWhite {সাদা}
translate b GlistBlack {কালো}
translate b GlistWElo {W-Elo}
translate b GlistBElo {বি-এলো}
translate b GlistEvent {ঘটনা}
translate b GlistSite {সাইট}
translate b GlistRound {গোলাকার}
translate b GlistDate {তারিখ}
translate b GlistYear {বছর}
translate b GlistEDate {ইভেন্ট তারিখ}
translate b GlistResult {ফলাফল}
translate b GlistLength {দৈর্ঘ্য}
translate b GlistCountry {দেশ}
translate b GlistECO {ইসিও}
translate b GlistOpening {খোলা হচ্ছে}
translate b GlistEndMaterial {শেষ উপাদান}
translate b GlistDeleted {মুছে ফেলা হয়েছে}
translate b GlistFlags {পতাকা}
translate b GlistVars {বৈচিত্র}
translate b GlistComments {মন্তব্য}
translate b GlistAnnos {টীকা}
translate b GlistStart {শুরু করুন}
translate b GlistGameNumber {গেম নম্বর}
translate b GlistAverageElo {গড় Elo}
translate b GlistRating {রেটিং}
translate b GlistFindText {পাঠ্য খুঁজুন}
translate b GlistMoveField {সরান}
translate b GlistEditField {কনফিগার করুন}
translate b GlistAddField {যোগ করুন}
translate b GlistDeleteField {সরান}
translate b GlistWidth {প্রস্থ}
translate b GlistAlign {সারিবদ্ধ}
translate b GlistAlignL {সারিবদ্ধ: বাম}
translate b GlistAlignR {সারিবদ্ধ: ডান}
translate b GlistAlignC {সারিবদ্ধ: কেন্দ্র}
translate b GlistColor {রঙ}
translate b GlistSep {বিভাজক}
translate b GlistCurrentSep {--বর্তমান --}
translate b GlistNewSort {নতুন}
translate b GlistAddToSort {যোগ করুন}

# base sorting
translate b GsortSort {সাজান...}
translate b GsortDate {তারিখ}
translate b GsortYear {বছর}
translate b GsortEvent {ঘটনা}
translate b GsortSite {সাইট}
translate b GsortRound {গোলাকার}
translate b GsortWhiteName {সাদা নাম}
translate b GsortBlackName {কালো নাম}
translate b GsortECO {ইসিও}
translate b GsortResult {ফলাফল}
translate b GsortMoveCount {গণনা সরান}
translate b GsortAverageElo {গড় Elo}
translate b GsortCountry {দেশ}
translate b GsortDeleted {মুছে ফেলা হয়েছে}
translate b GsortEventDate {ইভেন্টের তারিখ}
translate b GsortWhiteElo {সাদা ইলো}
translate b GsortBlackElo {কালো ইলো}
translate b GsortComments {মন্তব্য}
translate b GsortVariations {বৈচিত্র}
translate b GsortNAGs {এনএজি}
translate b GsortAscending {আরোহী}
translate b GsortDescending {অবরোহী}
translate b GsortAdd {যোগ করুন}
translate b GsortStore {দোকান}
translate b GsortLoad {লোড}

# menu shown with right mouse button down on game list.
translate b GlistRemoveThisGameFromFilter  {ফিল্টার থেকে এই গেমটি সরান}
translate b GlistRemoveGameAndAboveFromFilter  {ফিল্টার থেকে গেম (এবং এর উপরে সব) সরান}
translate b GlistRemoveGameAndBelowFromFilter  {ফিল্টার থেকে গেম (এবং এর নীচের সমস্ত) সরান}
translate b GlistDeleteGame {(আন)এই গেমটি মুছুন}
translate b GlistDeleteAllGames {ফিল্টারে থাকা সমস্ত গেম মুছুন}
translate b GlistUndeleteAllGames {ফিল্টারে থাকা সমস্ত গেম মুছে ফেলুন}
translate b GlistMergeGameInBase {গেমটি একত্রিত করুন}

# Maintenance window:
translate b DatabaseName {ডাটাবেসের নাম:}
translate b TypeIcon {টাইপ আইকন:}
translate b NumOfGames {গেম:}
translate b NumDeletedGames {মুছে ফেলা গেম:}
translate b NumFilterGames {ফিল্টারে গেম:}
translate b YearRange {বছরের পরিসীমা:}
translate b RatingRange {রেটিং পরিসীমা:}
translate b Description {বর্ণনা}
translate b Flag {পতাকা}
translate b CustomFlags {কাস্টম পতাকা}
translate b DeleteCurrent {বর্তমান গেম মুছুন}
translate b DeleteFilter {ফিল্টার গেম মুছুন}
translate b DeleteAll {সমস্ত গেম মুছুন}
translate b UndeleteCurrent {বর্তমান গেমটি মুছে ফেলুন}
translate b UndeleteFilter {ফিল্টার গেমগুলি মুছে ফেলুন}
translate b UndeleteAll {সমস্ত গেম মুছে ফেলুন}
translate b DeleteTwins {টুইন গেম মুছুন}
translate b MarkCurrent {বর্তমান খেলা চিহ্নিত করুন}
translate b MarkFilter {ফিল্টার গেম চিহ্নিত করুন}
translate b MarkAll {সমস্ত গেম চিহ্নিত করুন}
translate b UnmarkCurrent {বর্তমান গেমটি চিহ্নমুক্ত করুন}
translate b UnmarkFilter {ফিল্টার গেমগুলি চিহ্নমুক্ত করুন}
translate b UnmarkAll {সমস্ত গেম চিহ্নমুক্ত করুন}
translate b Spellchecking {বানান-পরীক্ষা}
translate b Players {খেলোয়াড়}
translate b Events {ঘটনা}
translate b Sites {সাইট}
translate b Rounds {বৃত্তাকার}
translate b DatabaseOps {ডাটাবেস অপারেশন}
translate b ReclassifyGames {ECO-শ্রেণীবদ্ধ গেম}
translate b CompactDatabase {কমপ্যাক্ট ডাটাবেস}
translate b SortDatabase {ডাটাবেস সাজান}
translate b AddEloRatings {Elo রেটিং যোগ করুন}
translate b AutoloadGame {অটোলোড গেম নম্বর}
translate b StripTags {স্ট্রিপ PGN ট্যাগ}
translate b StripTag {স্ট্রিপ ট্যাগ}
translate b Cleaner {ক্লিনার}
translate b CleanerHelp {Scid ক্লিনার বর্তমান ডাটাবেসে নীচের তালিকা থেকে আপনার নির্বাচন করা সমস্ত রক্ষণাবেক্ষণের কাজ সম্পাদন করবে।
আপনি যদি এই ফাংশনগুলি নির্বাচন করেন তবে ECO শ্রেণীবিভাগের বর্তমান সেটিংস এবং টুইন ডিলিট ডায়ালগগুলি প্রযোজ্য হবে৷}
translate b CleanerConfirm {একবার ক্লিনার রক্ষণাবেক্ষণ শুরু হলে, এটি বাধা দেওয়া যাবে না!

আপনার নির্বাচিত ফাংশন এবং তাদের বর্তমান সেটিংসের উপর নির্ভর করে এটি একটি বড় ডাটাবেসে দীর্ঘ সময় নিতে পারে।

আপনি কি আপনার নির্বাচিত রক্ষণাবেক্ষণ ফাংশনগুলি শুরু করার বিষয়ে নিশ্চিত?}
# Twinchecker
translate b TwinCheckUndelete {উল্টানো; "u" উভয়ই মুছে ফেলে)}
translate b TwinCheckprevPair {আগের জুটি}
translate b TwinChecknextPair {পরের জুটি}
translate b TwinChecker {Scid: টুইন গেম চেকার}
translate b TwinCheckTournament {টুর্নামেন্টে খেলা:}
translate b TwinCheckNoTwin {যমজ নেই}
translate b TwinCheckNoTwinfound {এই গেমটির জন্য কোন যমজ শনাক্ত করা হয়নি৷\nএই উইন্ডোটি ব্যবহার করে যমজ দেখান না, আপনাকে প্রথমে "যমজ গেম মুছুন..." ফাংশন ব্যবহার করতে হবে৷}
translate b TwinCheckTag {ট্যাগ শেয়ার করুন...}
translate b TwinCheckFound1 {Scid $result টুইন গেম খুঁজে পেয়েছে}
translate b TwinCheckFound2 {এবং তাদের মুছে ফেলা পতাকা সেট}
translate b TwinCheckNoDelete {মুছে ফেলার জন্য এই ডাটাবেসে কোন গেম নেই।}
translate b TwinCriteria1 {যমজ গেমগুলি খোঁজার জন্য আপনার সেটিংস সম্ভবত যমজ হিসাবে চিহ্নিত হওয়ার জন্য অনুরূপ চাল সহ নন-টুইন গেমগুলির কারণ হতে পারে৷}
translate b TwinCriteria2 {এটি সুপারিশ করা হয় যে আপনি যদি "একই চাল" এর জন্য "না" নির্বাচন করেন, তাহলে রং, ইভেন্ট, সাইট, রাউন্ড, বছর এবং মাসের সেটিংসের জন্য আপনাকে "হ্যাঁ" নির্বাচন করা উচিত।\nআপনি কি যাইহোক যমজ সন্তানকে চালিয়ে যেতে এবং মুছতে চান?}
translate b TwinCriteria3 {এটি বাঞ্ছনীয় যে আপনি "একই সাইট", "একই রাউন্ড" এবং "একই বছর" সেটিংসের অন্তত দুটির জন্য "হ্যাঁ" নির্দিষ্ট করুন৷\nআপনি কি যাইহোক যমজ সন্তানকে চালিয়ে যেতে এবং মুছতে চান?}
translate b TwinCriteriaConfirm {Scid: টুইন সেটিংস নিশ্চিত করুন}
translate b TwinChangeTag "নিম্নলিখিত গেম ট্যাগ পরিবর্তন করুন:\n\n"
translate b AllocRatingDescription "এই কমান্ডটি এই ডাটাবেসের গেমগুলিতে Elo রেটিং যোগ করতে বর্তমান বানান পরীক্ষা ফাইল ব্যবহার করবে। যেখানেই একজন খেলোয়াড়ের বর্তমান রেটিং নেই কিন্তু খেলার সময় তার রেটিং বানান পরীক্ষা ফাইলে তালিকাভুক্ত করা হয়েছে, সেই রেটিং যোগ করা হবে।"
translate b RatingOverride "বিদ্যমান নন-জিরো রেটিং ওভাররাইট করুন"
translate b AddRatings "এতে রেটিং যোগ করুন:"
translate b AddedRatings {Scid $g গেমগুলিতে $r Elo রেটিং যোগ করেছে।}

#Bookmark editor
translate b NewSubmenu "নতুন সাবমেনু"

# Comment editor:
translate b AnnotationSymbols  {টীকা চিহ্ন:}
translate b Comment {মন্তব্য:}
translate b InsertMark {চিহ্ন ঢোকান}
translate b InsertMarkHelp {চিহ্ন সন্নিবেশ/মুছে ফেলুন: রঙ, প্রকার, বর্গ নির্বাচন করুন।
তীর ঢোকান/সরান: দুটি বর্গক্ষেত্রে ডান-ক্লিক করুন।}

# Nag buttons in comment editor:
translate b GoodMove {ভাল পদক্ষেপ}
translate b PoorMove {দরিদ্র পদক্ষেপ}
translate b ExcellentMove {চমৎকার পদক্ষেপ}
translate b Blunder {ব্লন্ডার}
translate b InterestingMove {আকর্ষণীয় পদক্ষেপ}
translate b DubiousMove {সন্দেহজনক পদক্ষেপ}
translate b WhiteDecisiveAdvantage {সাদা একটি নিষ্পত্তিমূলক সুবিধা আছে}
translate b BlackDecisiveAdvantage {কালো একটি নিষ্পত্তিমূলক সুবিধা আছে}
translate b WhiteClearAdvantage {সাদা একটি স্পষ্ট সুবিধা আছে}
translate b BlackClearAdvantage {কালো একটি স্পষ্ট সুবিধা আছে}
translate b WhiteSlightAdvantage {সাদা একটি সামান্য সুবিধা আছে}
translate b BlackSlightAdvantage {কালো একটি সামান্য সুবিধা আছে}
translate b WhiteCrushing {সাদা একটি নিষ্পেষণ সুবিধা আছে}
translate b BlackCrushing {কালো একটি নিষ্পেষণ সুবিধা আছে}
translate b Equality {সমতা}
translate b Unclear {অস্পষ্ট}
translate b Diagram {ডায়াগ্রাম}

# Board search:
translate b BoardSearch {বোর্ড অনুসন্ধান}
translate b FilterOperation {বর্তমান ফিল্টার অপারেশন:}
translate b FilterAnd {এবং (ফিল্টার সীমাবদ্ধ)}
translate b FilterOr {বা (ফিল্টারে যোগ করুন)}
translate b FilterIgnore {উপেক্ষা করুন (ফিল্টার রিসেট করুন)}
translate b SearchType {অনুসন্ধানের ধরন:}
translate b SearchBoardExact {সঠিক অবস্থান (একই বর্গক্ষেত্রে সমস্ত টুকরা)}
translate b SearchBoardPawns {প্যানস (একই উপাদান, একই বর্গক্ষেত্রের সমস্ত প্যান)}
translate b SearchBoardFiles {ফাইল (একই উপাদান, একই ফাইলের সব প্যান)}
translate b SearchBoardAny {যে কোন (একই উপাদান, প্যান এবং টুকরা যে কোন জায়গায়)}
translate b SearchInRefDatabase {রেফারেন্স ডাটাবেস অনুসন্ধান করুন}
translate b LookInVars {বৈচিত্র দেখুন}

# Material search:
translate b MaterialSearch {উপাদান অনুসন্ধান}
translate b Material {উপাদান}
translate b Patterns {নিদর্শন}
translate b Zero {শূন্য}
translate b Any {যে কোন}
translate b CurrentBoard {বর্তমান বোর্ড}
translate b CommonEndings {কমন এন্ডিংস}
translate b CommonPatterns {সাধারণ নিদর্শন}
translate b MaterialDiff {উপাদান পার্থক্য}
translate b squares {বর্গক্ষেত্র}
translate b SameColor {একই রঙ}
translate b OppColor {বিপরীত রঙ}
translate b Either {হয়}
translate b MoveNumberRange {নম্বর পরিসীমা সরান}
translate b MatchForAtLeast {অন্তত জন্য ম্যাচ}
translate b HalfMoves {অর্ধেক চাল}

# Common endings in material search:
translate b EndingPawns {প্যান শেষ}
translate b EndingRookVsPawns {রুক বনাম প্যান(গুলি)}
translate b EndingRookPawnVsRook {রুক এবং 1 প্যান বনাম রুক}
translate b EndingRookPawnsVsRook {রুক এবং প্যান(গুলি) বনাম রুক}
translate b EndingRooks {রুক বনাম রুক শেষ}
translate b EndingRooksPassedA {রুক বনাম রুক শেষ হয় একটি পাস করা প্যান দিয়ে}
translate b EndingRooksDouble {ডাবল রুক শেষ}
translate b EndingBishops {বিশপ বনাম বিশপ শেষ}
translate b EndingBishopVsKnight {বিশপ বনাম নাইট শেষ}
translate b EndingKnights {নাইট বনাম নাইট শেষ}
translate b EndingQueens {রানী বনাম রানী শেষ}
translate b EndingQueenPawnVsQueen {রানী এবং 1 প্যান বনাম রানী}
translate b BishopPairVsKnightPair {দুই বিশপ বনাম দুই নাইট মধ্যম খেলা}

# Common patterns in material search:
translate b PatternWhiteIQP {সাদা আইকিউপি}
translate b PatternWhiteIQPBreakE6 {সাদা IQP: d4-d5 বিরতি বনাম e6}
translate b PatternWhiteIQPBreakC6 {সাদা IQP: d4-d5 বিরতি বনাম c6}
translate b PatternBlackIQP {কালো আইকিউপি}
translate b PatternWhiteBlackIQP {সাদা আইকিউপি বনাম কালো আইকিউপি}
translate b PatternCoupleC3D4 {সাদা c3+d4 বিচ্ছিন্ন প্যান দম্পতি}
translate b PatternHangingC5D5 {c5 এবং d5-এ কালো ঝুলন্ত প্যান}
translate b PatternMaroczy {Maroczy Center (c4 এবং e4 এ প্যান সহ)}
translate b PatternRookSacC3 {সি 3 তে রুক স্যাক্রিফাইস}
translate b PatternKc1Kg8 {O-O-O বনাম O-O (Kc1 বনাম Kg8)}
translate b PatternKg1Kc8 {O-O বনাম O-O-O (Kg1 বনাম Kc8)}
translate b PatternLightFian {লাইট-স্কোয়ার ফিয়ানচেটোস (বিশপ-জি২ বনাম বিশপ-বি৭)}
translate b PatternDarkFian {ডার্ক-স্কোয়ার ফিয়ানচেটোস (বিশপ-বি২ বনাম বিশপ-জি৭)}
translate b PatternFourFian {চার ফিয়ানচেটোস (বিশপস অন b2,g2,b7,g7)}

# Game saving:
translate b Today {আজ}
translate b ClassifyGame {খেলা শ্রেণীবদ্ধ করুন}

# Setup position:
translate b EmptyBoard {খালি বোর্ড}
translate b InitialBoard {প্রাথমিক বোর্ড}
translate b SideToMove {পাশ সরানো}
translate b MoveNumber {নম্বর সরান}
translate b Castling {কাসলিং}
translate b EnPassantFile {En Passant ফাইল}
translate b ClearFen {সাফ FEN}
translate b PasteFen {ফেন পেস্ট করুন}

translate b SaveAndContinue {সংরক্ষণ করুন এবং চালিয়ে যান}
translate b DiscardChangesAndContinue {পরিবর্তনগুলি বাতিল করুন এবং চালিয়ে যান}
translate b GoBack {ফিরে যান}

# Replace move dialog:
translate b ReplaceMove {সরান প্রতিস্থাপন}
translate b AddNewVar {নতুন বৈচিত্র যোগ করুন}
translate b NewMainLine {নতুন মেইন লাইন}
translate b ReplaceMoveMessage {একটি সরানো ইতিমধ্যেই এখানে বিদ্যমান.

আপনি এটিকে প্রতিস্থাপন করতে পারেন, এটির পরে সমস্ত চাল বাদ দিয়ে বা একটি নতুন পরিবর্তন হিসাবে আপনার পদক্ষেপ যোগ করতে পারেন৷

(আপনি বিকল্প: মুভস মেনুতে "চালগুলি প্রতিস্থাপন করার আগে জিজ্ঞাসা করুন" বিকল্পটি বন্ধ করে ভবিষ্যতে এই বার্তাটি দেখা এড়াতে পারেন।)}

# Make database read-only dialog:
translate b ReadOnlyDialog {আপনি যদি এই ডাটাবেসটিকে শুধুমাত্র পঠনযোগ্য করে তোলেন, তাহলে কোনো পরিবর্তন অনুমোদিত হবে না।
কোন গেম সংরক্ষণ বা প্রতিস্থাপন করা যাবে না, এবং কোন মুছে ফেলা পতাকা পরিবর্তন করা যাবে না.
কোনো বাছাই বা ECO-শ্রেণীবিভাগের ফলাফল অস্থায়ী হবে।

আপনি সহজেই ডাটাবেসটিকে আবার লেখার যোগ্য করে তুলতে পারেন, এটি বন্ধ এবং পুনরায় খোলার মাধ্যমে।

আপনি কি সত্যিই এই ডাটাবেস শুধুমাত্র পঠন করতে চান?}

# Clear game dialog:
translate b ClearGameDialog {এই খেলা পরিবর্তন করা হয়েছে.

আপনি কি সত্যিই এটিতে করা পরিবর্তনগুলি চালিয়ে যেতে এবং বাতিল করতে চান?}

# Exit dialog:
translate b ExitDialog {আপনি কি সত্যিই Scid প্রস্থান করতে চান?}
translate b ExitUnsaved {নিম্নলিখিত ডাটাবেসে অসংরক্ষিত গেম পরিবর্তন আছে। আপনি এখন প্রস্থান করলে, এই পরিবর্তনগুলি হারিয়ে যাবে।}

# Import window:
translate b PasteCurrentGame {বর্তমান খেলা আটকান}
translate b ImportHelp1 {উপরের ফ্রেমে একটি PGN-ফরম্যাট গেম লিখুন বা পেস্ট করুন।}
translate b ImportHelp2 {গেমটি আমদানি করার সময় যে কোনো ত্রুটি এখানে প্রদর্শিত হবে।}
translate b OverwriteExistingMoves {বিদ্যমান চালগুলি ওভাররাইট করবেন?}

# ECO Browser:
translate b ECOAllSections {সমস্ত ECO বিভাগ}
translate b ECOSection {ECO বিভাগ}
translate b ECOSummary {জন্য সারাংশ}
translate b ECOFrequency {এর জন্য সাবকোডের ফ্রিকোয়েন্সি}

# Opening Report:
translate b OprepReportFor {জন্য রিপোর্ট}
translate b OprepTitle {উদ্বোধনী প্রতিবেদন}
translate b OprepReport {রিপোর্ট}
translate b OprepGenerated {দ্বারা উত্পন্ন}
translate b OprepStatsHist {পরিসংখ্যান এবং ইতিহাস}
translate b OprepStats {পরিসংখ্যান}
translate b OprepStatAll {সমস্ত রিপোর্ট গেম}
translate b OprepStatBoth {উভয় রেট}
translate b OprepStatSince {যেহেতু}
translate b OprepOldest {প্রাচীনতম গেম}
translate b OprepNewest {নতুন গেম}
translate b OprepPopular {বর্তমান জনপ্রিয়তা}
translate b OprepFreqAll {সমস্ত বছরের ফ্রিকোয়েন্সি:}
translate b OprepFreq1   {আজ থেকে 1 বছরের মধ্যে:}
translate b OprepFreq5   {আজ থেকে 5 বছরে:}
translate b OprepFreq10  {আজ থেকে 10 বছরে:}
translate b OprepEvery {প্রতি %u গেমে একবার}
translate b OprepUp {সমস্ত বছর থেকে %u%s পর্যন্ত}
translate b OprepDown {সমস্ত বছর থেকে %u%s কম৷}
translate b OprepSame {সব বছর থেকে কোন পরিবর্তন}
translate b OprepMostFrequent {সবচেয়ে ঘন ঘন খেলোয়াড়}
translate b OprepMostFrequentOpponents {সবচেয়ে ঘন ঘন প্রতিপক্ষ}
translate b OprepRatingsPerf {রেটিং এবং কর্মক্ষমতা}
translate b OprepAvgPerf {গড় রেটিং এবং কর্মক্ষমতা}
translate b OprepWRating {সাদা রেটিং}
translate b OprepBRating {কালো রেটিং}
translate b OprepWPerf {সাদা কর্মক্ষমতা}
translate b OprepBPerf {কালো কর্মক্ষমতা}
translate b OprepHighRating {সর্বোচ্চ গড় রেটিং সহ গেম}
translate b OprepTrends {ফলাফল প্রবণতা}
translate b OprepResults {ফলাফলের দৈর্ঘ্য এবং ফ্রিকোয়েন্সি}
translate b OprepLength {খেলার দৈর্ঘ্য}
translate b OprepFrequency {ফ্রিকোয়েন্সি}
translate b OprepWWins {সাদা জয়:}
translate b OprepBWins {কালো জয়:}
translate b OprepDraws {ড্র:}
translate b OprepWholeDB {পুরো ডাটাবেস}
translate b OprepShortest {সংক্ষিপ্ততম জয়}
translate b OprepMovesThemes {চলন এবং থিম}
translate b OprepMoveOrders {রিপোর্ট অবস্থানে পৌঁছানোর আদেশ সরান}
translate b OprepMoveOrdersOne \
  {এই অবস্থানে পৌঁছানোর জন্য শুধুমাত্র একটি সরানোর আদেশ ছিল:}
translate b OprepMoveOrdersAll \
  {এই অবস্থানে পৌঁছানোর জন্য %u সরানোর আদেশ ছিল:}
translate b OprepMoveOrdersMany \
  {এই অবস্থানে পৌঁছানোর জন্য %u সরানোর আদেশ ছিল৷ শীর্ষ %u হল:}
translate b OprepMovesFrom {রিপোর্ট অবস্থান থেকে সরানো}
translate b OprepMostFrequentEcoCodes {সর্বাধিক ঘন ঘন ECO কোড}
translate b OprepThemes {অবস্থানগত থিম}
translate b OprepThemeDescription {প্রতিটি গেমের প্রথম %u চালে থিমের ফ্রিকোয়েন্সি}
translate b OprepThemeSameCastling {একই দিকের কাস্টলিং}
translate b OprepThemeOppCastling {বিপরীত castling}
translate b OprepThemeNoCastling {উভয় কিং uncastled}
translate b OprepThemeKPawnStorm {Kingside pawn storm}
translate b OprepThemeQueenswap {কুইন্স বিনিময়}
translate b OprepThemeWIQP {সাদা বিচ্ছিন্ন রানী প্যান}
translate b OprepThemeBIQP {কালো বিচ্ছিন্ন রানী প্যান}
translate b OprepThemeWP567 {5/6/7ম র‌্যাঙ্কে হোয়াইট প্যান}
translate b OprepThemeBP234 {2/3/4th র‌্যাঙ্কে ব্ল্যাক প্যান}
translate b OprepThemeOpenCDE {c/d/e ফাইল খুলুন}
translate b OprepTheme1BishopPair {শুধু এক পাশে বিশপ জুটি আছে}
translate b OprepEndgames {এন্ডগেমস}
translate b OprepReportGames {রিপোর্ট গেম}
translate b OprepAllGames    {সব গেম}
translate b OprepEndClass {প্রতিটি খেলা শেষে উপাদান}
translate b OprepTheoryTable {তত্ত্ব টেবিল}
translate b OprepTableComment {%u সর্বোচ্চ রেট দেওয়া গেমগুলি থেকে তৈরি করা হয়েছে৷}
translate b OprepExtraMoves {তত্ত্ব টেবিলে অতিরিক্ত নোট চলে}
translate b OprepMaxGames {তত্ত্ব টেবিলে সর্বাধিক গেম}
translate b OprepMergeMoves {মার্জ করা গেমের জন্য সরানোর সীমা}
translate b OprepMergeUnique {শুধুমাত্র অনন্য গেম মার্জ}
translate b OprepViewHTML {HTML দেখুন}

# Player Report:
translate b PReportTitle {প্লেয়ার রিপোর্ট}
translate b PReportColorWhite {সাদা টুকরা সঙ্গে}
translate b PReportColorBlack {কালো টুকরা সঙ্গে}
translate b PReportMoves {%s পরে}
translate b PReportOpenings {খোলা}
translate b PReportClipbase {খালি ক্লিপবেস এবং এটিতে ম্যাচিং গেম কপি করুন}

# Piece Tracker window:
translate b TrackerSelectSingle {বাম মাউস বোতাম এই টুকরা নির্বাচন করে.}
translate b TrackerSelectPair {বাম মাউস বোতাম এই টুকরা নির্বাচন করে; ডান বোতামটি তার ভাইবোনকেও নির্বাচন করে।}
translate b TrackerSelectPawn {বাম মাউস বোতাম এই প্যান নির্বাচন করে; ডান বোতাম সব 8 প্যান নির্বাচন করে.}
translate b TrackerStat {পরিসংখ্যান}
translate b TrackerGames {বর্গক্ষেত্রে সরানো সহ % গেম}
translate b TrackerTime {প্রতি বর্গক্ষেত্রে % সময়}
translate b TrackerMoves {নড়াচড়া করে}
translate b TrackerMovesStart {ট্র্যাকিং শুরু করা উচিত যেখানে সরানো নম্বর লিখুন.}
translate b TrackerMovesStop {সরানো নম্বর লিখুন যেখানে ট্র্যাকিং বন্ধ করা উচিত।}

# Game selection dialogs:
translate b SelectAllGames {ডাটাবেসের সমস্ত গেম}
translate b SelectFilterGames {ফিল্টারে শুধুমাত্র গেম}
translate b SelectTournamentGames {বর্তমান টুর্নামেন্টে শুধুমাত্র খেলা}
translate b SelectOlderGames {শুধুমাত্র পুরোনো গেম}

# Delete Twins window:
translate b TwinsNote {যমজ হওয়ার জন্য, দুটি গেমে কমপক্ষে একই দুই খেলোয়াড় থাকতে হবে, এবং মানদণ্ড আপনি নীচে সেট করতে পারেন। যখন এক জোড়া যমজ পাওয়া যায়, ছোট খেলাটি মুছে ফেলা হয়। ইঙ্গিত: যমজ মুছে ফেলার আগে ডাটাবেসের বানান পরীক্ষা করা ভাল, যেহেতু এটি যমজ সনাক্তকরণ উন্নত করে।}
translate b TwinsCriteria {মানদণ্ড: যমজ গেম থাকতে হবে...}
translate b TwinsWhich {কোন গেমগুলি পরীক্ষা করুন}
translate b TwinsColors {একই প্লেয়ার রং}
translate b TwinsEvent {একই ঘটনা}
translate b TwinsSite {একই সাইট}
translate b TwinsRound {একই গোলাকার}
translate b TwinsYear {একই বছর}
translate b TwinsMonth {একই মাস}
translate b TwinsDay {একই দিন}
translate b TwinsResult {একই ফলাফল}
translate b TwinsECO {একই ECO কোড}
translate b TwinsMoves {একই চাল}
translate b TwinsPlayers {খেলোয়াড়ের নাম তুলনা করা}
translate b TwinsPlayersExact {হুবহু মিল}
translate b TwinsPlayersPrefix {প্রথম 4টি অক্ষর মাত্র}
translate b TwinsWhen {টুইন গেম মুছে ফেলার সময়}
translate b TwinsSkipShort {5 মুভের নিচে সব গেম উপেক্ষা করুন}
translate b TwinsUndelete {প্রথমে সমস্ত গেম মুছে ফেলুন}
translate b TwinsSetFilter {সমস্ত মুছে ফেলা যমজ গেম ফিল্টার সেট করুন}
translate b TwinsComments {সবসময় মন্তব্য সহ গেম রাখুন}
translate b TwinsVars {সবসময় বৈচিত্র্য সহ গেম রাখুন}
translate b TwinsDeleteWhich {গেমটি মুছুন}
translate b TwinsDeleteShorter {ছোট খেলা}
translate b TwinsDeleteOlder {ছোট গেম নম্বর}
translate b TwinsDeleteNewer {বড় খেলা সংখ্যা}
translate b TwinsDelete {গেমগুলি মুছুন}

# Name editor window:
translate b NameEditType {সম্পাদনা করার জন্য নামের প্রকার}
translate b NameEditSelect {সম্পাদনা করার জন্য গেম}
translate b NameEditReplace {প্রতিস্থাপন করুন}
translate b NameEditWith {সঙ্গে}
translate b NameEditMatches {মিল: নির্বাচন করতে Ctrl+1 থেকে Ctrl+9 টিপুন}

# Check games window:
translate b CheckGames {গেম চেক করুন}
translate b CheckGamesWhich {গেম চেক করুন}
translate b CheckAll {সব গেম}
translate b CheckSelectFilterGames {ফিল্টার মধ্যে শুধুমাত্র গেম}

# Classify window:
translate b Classify {শ্রেণীবদ্ধ করুন}
translate b ClassifyWhich {ECO- শ্রেণীবদ্ধ করুন কোন গেম}
translate b ClassifyAll {সমস্ত গেম (পুরানো ECO কোডগুলি ওভাররাইট করুন)}
translate b ClassifyYear {গত বছরে সব খেলাই হয়েছে}
translate b ClassifyMonth {গত মাসে খেলা সব খেলা}
translate b ClassifyNew {এখনও কোন ECO কোড ছাড়া শুধুমাত্র গেম}
translate b ClassifyCodes {ব্যবহার করার জন্য ECO কোড}
translate b ClassifyBasic {শুধুমাত্র মৌলিক কোড ("B12", ...)}
translate b ClassifyExtended {Scid এক্সটেনশন ("B12j", ...)}
translate b ClassifyResult {ECO শ্রেণীবিভাগ সম্পূর্ণ: $result গেম(গুলি) আপডেট করা হয়েছে।}

# Compaction:
translate b NameFile {নাম ফাইল}
translate b GameFile {গেম ফাইল}
translate b Names {নাম}
translate b Unused {অব্যবহৃত}
translate b SizeKb {আকার (kb)}
translate b CurrentState {বর্তমান রাজ্য}
translate b AfterCompaction {কম্প্যাকশন পরে}
translate b CompactNames {কমপ্যাক্ট নামের ফাইল}
translate b CompactGames {কমপ্যাক্ট গেম ফাইল}
translate b NoUnusedNames "কোন অব্যবহৃত নাম নেই, তাই নামের ফাইলটি ইতিমধ্যেই সম্পূর্ণ সংকুচিত হয়েছে।"
translate b NoUnusedGames "গেমের ফাইলটি ইতিমধ্যেই সম্পূর্ণরূপে কম্প্যাক্ট করা হয়েছে।"
translate b GameFileCompacted {ডাটাবেসের জন্য গেম ফাইলটি কম্প্যাক্ট করা হয়েছিল।}

# Sorting:
translate b SortCriteria {মানদণ্ড}
translate b AddCriteria {মানদণ্ড যোগ করুন}
translate b CommonSorts {সাধারণ ধরনের}
translate b Sort {সাজান}

# Exporting:
translate b AddToExistingFile {একটি বিদ্যমান ফাইলে গেম যোগ করুন}
translate b ExportComments {মন্তব্য রপ্তানি}
translate b ExportVariations {রপ্তানি বৈচিত্র}
translate b IndentComments {ইন্ডেন্ট মন্তব্য}
translate b IndentVariations {ইন্ডেন্ট বৈচিত্র}
translate b ExportColumnStyle {কলাম শৈলী (প্রতি লাইনে এক মুভ)}
translate b ExportSymbolStyle {প্রতীকী টীকা শৈলী:}
translate b ExportStripMarks {স্ট্রিপ বর্গ/তীর চিহ্ন\nমন্তব্য থেকে কোড}

# Goto game/move dialogs:
translate b LoadGameNumber {লোড করতে গেম নম্বর লিখুন:}
translate b GotoMoveNumber {যান স্থানান্তর নম্বর:}

# Copy games dialog:
translate b CopyAllGames {সব গেম কপি করুন}
translate b CopyGames {কপি গেম}
translate b CopyConfirm {আপনি সত্যিই অনুলিপি করতে চান
 [::utils:: হাজার হাজার $nGamesToCopy] ফিল্টার করা গেম
 ডাটাবেসে "$fromName"
 ডাটাবেসে "$targetName"?}
translate b CopyErr {গেম কপি করা যাবে না}
translate b CopyErrSource {উৎস ডাটাবেস}
translate b CopyErrTarget {লক্ষ্য ডাটাবেস}
translate b CopyErrNoGames {এর ফিল্টারে কোন গেম নেই}
translate b CopyErrReadOnly {শুধুমাত্র পঠনযোগ্য}
translate b CopyErrNotOpen {খোলা হয় না}

# Colors:
translate b LightSquares {হালকা স্কোয়ার}
translate b DarkSquares {গাঢ় বর্গক্ষেত্র}
translate b SelectedSquares {নির্বাচিত বর্গক্ষেত্র}
translate b SuggestedSquares {প্রস্তাবিত সরানো বর্গক্ষেত্র}
translate b WhitePieces {সাদা টুকরা}
translate b BlackPieces {কালো টুকরা}
translate b WhiteBorder {সাদা সীমানা}
translate b BlackBorder {কালো সীমানা}

# Novelty window:
translate b FindNovelty {অভিনবত্ব খুঁজুন}
translate b Novelty {অভিনবত্ব}
translate b NoveltyInterrupt {অভিনবত্ব অনুসন্ধান বিঘ্নিত}
translate b NoveltyNone {এই গেমের জন্য কোন নতুনত্ব পাওয়া যায়নি}
translate b NoveltyHelp {Scid বর্তমান গেমের প্রথম পদক্ষেপটি খুঁজে পাবে যা নির্বাচিত ডাটাবেসে বা ECO খোলার বইতে পাওয়া যায় না এমন অবস্থানে পৌঁছেছে।}

# Sounds configuration:
translate b SoundsFolder {সাউন্ড ফাইল ফোল্ডার}
translate b SoundsFolderHelp {ফোল্ডারে King.wav, a.wav, 1.wav ইত্যাদি ফাইল থাকা উচিত}
translate b SoundsAnnounceOptions {ঘোষণার বিকল্পগুলি সরান৷}
translate b SoundsAnnounceNew {সেগুলি তৈরি হওয়ার সাথে সাথে নতুন পদক্ষেপগুলি ঘোষণা করুন}
translate b SoundsMoveSoundOnly {শুধুমাত্র শব্দ সরান (ঘোষণা নিষ্ক্রিয় করুন)}
translate b SoundsAnnounceForward {এক চাল এগিয়ে যাওয়ার সময় পদক্ষেপগুলি ঘোষণা করুন}
translate b SoundsAnnounceBack {এক চাল প্রত্যাহার বা সরানোর সময় ঘোষণা করুন}
translate b SoundsSoundDisabled {Scid স্টার্টআপে স্ন্যাক অডিও প্যাকেজ খুঁজে পায়নি;\nসাউন্ড নিষ্ক্রিয়।}

# Upgrading databases:
translate b Upgrading {আপগ্রেড হচ্ছে}
translate b ConfirmOpenNew {এটি একটি পুরানো-ফরম্যাট (Scid 3) ডাটাবেস যা Scid 4 এ খোলা যাবে না, তবে একটি নতুন-ফর্ম্যাট (Scid 4) সংস্করণ ইতিমধ্যেই তৈরি করা হয়েছে।

আপনি কি ডাটাবেসের নতুন ফর্ম্যাট সংস্করণ খুলতে চান?}
translate b ConfirmUpgrade {এটি একটি পুরানো ফর্ম্যাট (Scid 3) ডাটাবেস। Scid 4 এ ব্যবহার করার আগে ডাটাবেসের একটি নতুন ফর্ম্যাট সংস্করণ তৈরি করতে হবে।

আপগ্রেড করা ডাটাবেসের একটি নতুন সংস্করণ তৈরি করবে এবং তারপরে আসল ফাইলগুলি সরিয়ে ফেলবে।

এটি একটি সময় নিতে পারে, কিন্তু এটি শুধুমাত্র একবার করা প্রয়োজন। খুব বেশি সময় লাগলে আপনি বাতিল করতে পারেন।

আপনি কি এখন এই ডাটাবেস আপগ্রেড করতে চান?}

# Recent files options:
translate b RecentFilesMenu {ফাইল মেনুতে সাম্প্রতিক ফাইলের সংখ্যা}
translate b RecentFilesExtra {অতিরিক্ত সাবমেনুতে সাম্প্রতিক ফাইলের সংখ্যা}

# My Player Names options:
translate b MyPlayerNamesDescription {নিচে পছন্দের প্লেয়ারের নামের তালিকা লিখুন, প্রতি লাইনে একটি নাম। ওয়াইল্ডকার্ড (যেমন "?" যেকোনো একক অক্ষরের জন্য, "*" অক্ষরের যেকোনো অনুক্রমের জন্য) অনুমোদিত।

প্রতিবার তালিকার একজন খেলোয়াড়ের সাথে একটি খেলা লোড করা হলে, সেই খেলোয়াড়দের দৃষ্টিকোণ থেকে খেলাটি দেখানোর জন্য প্রয়োজনে মূল উইন্ডো চেসবোর্ডটি ঘোরানো হবে।}

#Coach
translate b showblunderexists {শো ভুল বিদ্যমান}
translate b showblundervalue {ভুল মান দেখান}
translate b showscore {স্কোর দেখান}
translate b coachgame {কোচ খেলা}
translate b configurecoachgame {কৌশলগত খেলা কনফিগার করুন}
translate b configuregame {গেম কনফিগারেশন}
translate b Phalanxengine {ফ্যালানক্স ইঞ্জিন}
translate b Coachengine {কোচ ইঞ্জিন}
translate b difficulty {অসুবিধা}
translate b hard {কঠিন}
translate b easy {সহজ}
translate b Playwith {সঙ্গে খেলা}
translate b white {সাদা}
translate b black {কালো}
translate b both {উভয়}
translate b Play {খেলা}
translate b Noblunder {কোন ভুল নেই}
translate b blunder {ভুল}
translate b Noinfo {-- কোন তথ্য নেই --}
translate b PhalanxOrTogaMissing {ফ্যালানক্স বা টোগা পাওয়া যায়নি}
translate b moveblunderthreshold {ক্ষতির চেয়ে বেশি হলে সরানো একটি ভুল}
translate b limitanalysis {ইঞ্জিন বিশ্লেষণের সময় সীমিত করুন}
translate b seconds {সেকেন্ড}
translate b Abort {গর্ভপাত}
translate b Resume {পুনরায় শুরু করুন}
translate b OutOfOpening {খোলার বাইরে}
translate b NotFollowedLine {আপনি লাইন অনুসরণ করেননি}
translate b DoYouWantContinue {আপনি কি চালিয়ে যেতে চান?}
translate b CoachIsWatching {কোচ দেখছেন}
translate b Ponder {স্থায়ী চিন্তা}
translate b LimitELO {ELO শক্তি সীমিত করুন}
translate b DubiousMovePlayedTakeBack {সন্দেহজনক পদক্ষেপ খেলেছে, আপনি কি ফিরিয়ে নিতে চান?}
translate b WeakMovePlayedTakeBack {দুর্বল পদক্ষেপ খেলেছে, আপনি কি ফিরিয়ে নিতে চান?}
translate b BadMovePlayedTakeBack {খারাপ চাল খেলেছে, ফিরিয়ে নিতে চান?}
translate b Iresign {আমি পদত্যাগ করি}
translate b yourmoveisnotgood {তোমার চাল ভালো না}
translate b EndOfVar {বৈচিত্র্যের সমাপ্তি}
translate b Openingtrainer {উদ্বোধনী প্রশিক্ষক}
translate b DisplayCM {প্রার্থীর চলন প্রদর্শন করুন}
translate b DisplayCMValue {ডিসপ্লে ক্যান্ডিডেট মুভ ভ্যালু}
translate b DisplayOpeningStats {পরিসংখ্যান দেখান}
translate b ShowReport {রিপোর্ট দেখান}
translate b NumberOfGoodMovesPlayed {ভালো চাল খেলেছে}
translate b NumberOfDubiousMovesPlayed {সন্দেহজনক চাল খেলেছে}
translate b NumberOfMovesPlayedNotInRepertoire {চালগুলি ভাণ্ডার মধ্যে খেলা না}
translate b NumberOfTimesPositionEncountered {বার অবস্থান সম্মুখীন}
translate b PlayerBestMove  {শুধুমাত্র সেরা পদক্ষেপের অনুমতি দিন}
translate b OpponentBestMove {প্রতিপক্ষ সেরা মুভ খেলে}
translate b OnlyFlaggedLines {শুধুমাত্র পতাকা লাগানো লাইন}
translate b resetStats {পরিসংখ্যান রিসেট করুন}
translate b Repertoiretrainingconfiguration {সংগ্রহশালা প্রশিক্ষণ কনফিগারেশন}
translate b Loadingrepertoire {ভাণ্ডার লোড হচ্ছে}
translate b Movesloaded {চালিত লোড}
translate b Repertoirenotfound {সংগ্রহশালা পাওয়া যায়নি}
translate b Openfirstrepertoirewithtype {প্রথমে ডানদিকে আইকন/টাইপ সেট সহ একটি রেপারটোয়ার ডাটাবেস খুলুন}
translate b Movenotinrepertoire {ভাণ্ডার মধ্যে সরানো না}
translate b PositionsInRepertoire {ভাণ্ডার মধ্যে অবস্থান}
translate b PositionsNotPlayed {পজিশন খেলা হয়নি}
translate b PositionsPlayed {পজিশন খেলেছে}
translate b Success {সফলতা}
translate b DubiousMoves {সন্দেহজনক চাল}
translate b OutOfRepertoire {OutOf Repertoire}
translate b ConfigureTactics {কৌশল কনফিগার করুন}
translate b ResetScores {স্কোর রিসেট করুন}
translate b LoadingBase {বেস লোড হচ্ছে}
translate b Tactics {কৌশল}
translate b ShowSolution {সমাধান দেখান}
translate b NextExercise {পরবর্তী ব্যায়াম}
translate b PrevExercise {আগের ব্যায়াম}
translate b StopTraining {প্রশিক্ষণ বন্ধ করুন}
translate b Next {পরবর্তী}
translate b ResettingScore {স্কোর রিসেট করা হচ্ছে}
translate b LoadingGame {খেলা লোড হচ্ছে}
translate b MateFound {সাথী পাওয়া গেছে}
translate b BestSolutionNotFound {সেরা সমাধান পাওয়া যায়নি!}
translate b MateNotFound {সাথী পাওয়া যায়নি}
translate b ShorterMateExists {খাটো সঙ্গী বিদ্যমান}
translate b ScorePlayed {স্কোর খেলেছে}
translate b Expected {প্রত্যাশিত}
translate b ChooseTrainingBase {প্রশিক্ষণ বেস চয়ন করুন}
translate b Thinking {ভাবছেন}
translate b AnalyzeDone {বিশ্লেষণ সম্পন্ন}
translate b WinWonGame {জয় জিতেছে খেলা}
translate b Lines {লাইন}
translate b ConfigureUCIengine {UCI ইঞ্জিন কনফিগার করুন}
translate b SpecificOpening {নির্দিষ্ট খোলার}
translate b StartNewGame {নতুন গেম শুরু করুন}
translate b FixedLevel {স্থির স্তর}
translate b Opening {খোলা হচ্ছে}
translate b RandomLevel {এলোমেলো স্তর}
translate b StartFromCurrentPosition {বর্তমান অবস্থান থেকে শুরু করুন}
translate b FixedDepth {স্থির গভীরতা}
translate b Nodes {নোড}
translate b Depth {গভীরতা}
translate b Time {সময়}
translate b SecondsPerMove {প্রতি পদক্ষেপে সেকেন্ড}
translate b Engine {ইঞ্জিন}
translate b TimeMode {সময় মোড}
translate b TimeBonus {সময় + বোনাস}
translate b TimeMin {মিনিট}
translate b TimeSec {সেকেন্ড}
translate b AllExercisesDone {সমস্ত ব্যায়াম সম্পন্ন}
translate b MoveOutOfBook {বইয়ের বাইরে সরান}
translate b LastBookMove {শেষ বই সরানো}
translate b AnnotateSeveralGames {প্রকৃত খেলা থেকে খেলা:}
translate b FindOpeningErrors {খোলার ত্রুটি খুঁজুন}
translate b MarkTacticalExercises {কৌশলগত অনুশীলন চিহ্নিত করুন}
translate b UseBook {বই ব্যবহার করুন}
translate b MultiPV {একাধিক বৈচিত্র}
translate b Hash {হ্যাশ মেমরি}
translate b OwnBook {ইঞ্জিন বই ব্যবহার করুন}
translate b BookFile {খোলা বই}
translate b AnnotateVariations {বৈচিত্র টীকা}
translate b ShortAnnotations {সংক্ষিপ্ত টীকা}
translate b addAnnotatorTag {টীকা ট্যাগ যোগ করুন}
translate b AddScoreToShortAnnotations {টীকাগুলিতে স্কোর যোগ করুন}
translate b Export {রপ্তানি}
translate b BookPartiallyLoaded {বই আংশিক লোড}
translate b Calvar {বৈচিত্র্যের গণনা}
translate b ConfigureCalvar {কনফিগারেশন}
# Opening names used in tacgame.tcl
translate b Reti {রেটি}
translate b English {ইংরেজি}
translate b d4Nf6Miscellaneous {1.d4 Nf6 বিবিধ}
translate b Trompowsky {ট্রম্পোস্কি}
translate b Budapest {বুদাপেস্ট}
translate b OldIndian {পুরাতন ভারতীয়}
translate b BenkoGambit {বেনকো গ্যাম্বিট}
translate b ModernBenoni {আধুনিক বেনোনি}
translate b DutchDefence {ডাচ প্রতিরক্ষা}
translate b Scandinavian {স্ক্যান্ডিনেভিয়ান}
translate b AlekhineDefence {আলেখাইন প্রতিরক্ষা}
translate b Pirc {পির}
translate b CaroKann {ক্যারো-কান}
translate b CaroKannAdvance {ক্যারো-কান অ্যাডভান্স}
translate b Sicilian {সিসিলিয়ান}
translate b SicilianAlapin {সিসিলিয়ান আলাপিন}
translate b SicilianClosed {সিসিলিয়ান বন্ধ}
translate b SicilianRauzer {সিসিলিয়ান রাউজার}
translate b SicilianDragon {সিসিলিয়ান ড্রাগন}
translate b SicilianScheveningen {সিসিলিয়ান শেভেনিঞ্জেন}
translate b SicilianNajdorf {সিসিলিয়ান নাজডর্ফ}
translate b OpenGame {ওপেন গেম}
translate b Vienna {ভিয়েনা}
translate b KingsGambit {রাজার গ্যাম্বিট}
translate b RussianGame {রাশিয়ান খেলা}
translate b ItalianTwoKnights {ইতালীয়/দুই নাইট}
translate b Spanish {স্প্যানিশ}
translate b SpanishExchange {স্প্যানিশ এক্সচেঞ্জ}
translate b SpanishOpen {স্প্যানিশ ওপেন}
translate b SpanishClosed {স্প্যানিশ বন্ধ}
translate b FrenchDefence {ফরাসি প্রতিরক্ষা}
translate b FrenchAdvance {ফরাসি অগ্রিম}
translate b FrenchTarrasch {ফরাসি টাররাশ}
translate b FrenchWinawer {ফরাসি উইনাওয়ার}
translate b FrenchExchange {ফরাসি এক্সচেঞ্জ}
translate b QueensPawn {রানীর প্যান}
translate b Slav {স্লাভ}
translate b QGA {কিউজিএ}
translate b QGD {QGD}
translate b QGDExchange {কিউজিডি এক্সচেঞ্জ}
translate b SemiSlav {আধা-স্লাভ}
translate b QGDwithBg5 {Bg5 সহ QGD}
translate b QGDOrthodox {QGD অর্থোডক্স}
translate b Grunfeld {গ্রুনফেল্ড}
translate b GrunfeldExchange {গ্রুনফেল্ড এক্সচেঞ্জ}
translate b GrunfeldRussian {গ্রুনফেল্ড রাশিয়ান}
translate b Catalan {কাতালান}
translate b CatalanOpen {কাতালান ওপেন}
translate b CatalanClosed {কাতালান বন্ধ}
translate b QueensIndian {রানীর ভারতীয়}
translate b NimzoIndian {নিমজো-ভারতীয়}
translate b NimzoIndianClassical {নিমজো-ইন্ডিয়ান ক্লাসিক্যাল}
translate b NimzoIndianRubinstein {নিমজো-ভারতীয় রুবিনস্টাইন}
translate b KingsIndian {রাজার ভারতীয়}
translate b KingsIndianSamisch {রাজার ভারতীয় Sämisch}
translate b KingsIndianMainLine {রাজার ভারতীয় প্রধান লাইন}

# FICS
translate b ConfigureFics {FICS কনফিগার করুন}
translate b FICSGuest {অতিথি হিসেবে লগইন করুন}
translate b FICSServerPort {সার্ভার পোর্ট}
translate b FICSServerAddress {আইপি ঠিকানা}
translate b FICSRefresh {রিফ্রেশ}
translate b FICSTimesealPort {টাইমসিল পোর্ট}
translate b FICSSilence {কনসোল ফিল্টার}
translate b FICSOffers {অফার করে}
translate b FICSConsole {কনসোল}
translate b FICSGames {গেমস}
translate b FICSUnobserve {খেলা পর্যবেক্ষণ বন্ধ করুন}
translate b FICSProfile {আপনার ইতিহাস এবং প্রোফাইল প্রদর্শন করুন}
translate b FICSRelayedGames {রিলেড গেম}
translate b FICSFindOpponent {প্রতিপক্ষ খুঁজুন}
translate b FICSTakeback {টেকব্যাক}
translate b FICSTakeback2 {টেকব্যাক 2}
translate b FICSInitTime {প্রাথমিক সময় (মিনিট)}
translate b FICSIncrement {বৃদ্ধি (সেকেন্ড)}
translate b FICSRatedGame {রেটেড গেম}
translate b FICSAutoColour {স্বয়ংক্রিয়}
translate b FICSManualConfirm {ম্যানুয়ালি নিশ্চিত করুন}
translate b FICSFilterFormula {সূত্র দিয়ে ফিল্টার করুন}
translate b FICSIssueSeek {ইস্যু খোঁজা}
translate b FICSChallenge {চ্যালেঞ্জ}
translate b FICSAccept {আপনি কি গ্রহণ করেন?}
translate b FICSDecline {হ্রাস}
translate b FICSColour {রঙ}
translate b FICSSend {পাঠান}
translate b FICSConnect {সংযোগ করুন}
translate b FICSdefaultuservars {ডিফল্ট ভেরিয়েবল ব্যবহার করুন}
translate b FICSObserveconfirm {আপনি খেলা পর্যবেক্ষণ করতে চান}
translate b FICSpremove {প্রিমুভ সক্ষম করুন}
translate b FICSObserve {পর্যবেক্ষণ করুন}
translate b FICSRatedGames {রেট করা গেম}
translate b FICSUnratedGames {রেটিংহীন গেম}
translate b FICSRated {রেট}
translate b FICSUnrated {মূল্যহীন}
translate b FICSRegisteredPlayer {শুধুমাত্র নিবন্ধিত খেলোয়াড়}
translate b FICSFreePlayer {শুধুমাত্র ফ্রি প্লেয়ার}
translate b FICSNetError {নেটওয়ার্ক ত্রুটি\কানেক্ট করা যাচ্ছে না}

# Game review
translate b GameReview {খেলা পর্যালোচনা}
translate b GameReviewTimeExtended {সময় বাড়ানো হয়েছে}
translate b GameReviewMargin {ত্রুটি মার্জিন}
translate b GameReviewAutoContinue {সরানো সঠিক হলে অটো চালিয়ে যান}
translate b GameReviewReCalculate {বর্ধিত সময় ব্যবহার করুন}
translate b GameReviewAnalyzingMovePlayedDuringTheGame {খেলা চলাকালীন খেলা বিশ্লেষণ}
translate b GameReviewAnalyzingThePosition {অবস্থান বিশ্লেষণ}
translate b GameReviewEnterYourMove {আপনার পদক্ষেপ লিখুন}
translate b GameReviewCheckingYourMove {আপনার পদক্ষেপ পরীক্ষা করা হচ্ছে}
translate b GameReviewYourMoveWasAnalyzed {আপনার পদক্ষেপ বিশ্লেষণ করা হয়েছে}
translate b GameReviewYouPlayedSameMove {আপনি ম্যাচের মতো একই চাল খেলেছেন}
translate b GameReviewScoreOfYourMove {আপনার পদক্ষেপের স্কোর}
translate b GameReviewGameMoveScore {গেম মুভ এর স্কোর}
translate b GameReviewEngineScore {ইঞ্জিনের স্কোর}
translate b GameReviewYouPlayedLikeTheEngine {আপনি ইঞ্জিনের মতোই ভাল খেলেছেন}
translate b GameReviewNotEngineMoveButGoodMove {ইঞ্জিন সরানো নয়, তবে এটি একটি ভাল পদক্ষেপ}
translate b GameReviewMoveNotGood {এই পদক্ষেপ ভাল না, স্কোর হয়}
translate b GameReviewMovesPlayedLike {চালনা মত খেলা}
translate b GameReviewMovesPlayedEngine {চালগুলি ইঞ্জিনের মতো খেলা হয়}

# Correspondence Chess Dialogs:
translate b CCDlgCGeneraloptions {সাধারণ বিকল্প}
translate b CCDlgLoginName  {লগইন নাম:}
translate b CCDlgPassword   {পাসওয়ার্ড:}
translate b CCDlgShowPassword {পাসওয়ার্ড দেখান}

# Connect Hardware dialogs
translate b ExtHWConfigConnection {বাহ্যিক হার্ডওয়্যার কনফিগার করুন}
translate b ExtHWPort {বন্দর}
translate b ExtHWEngineCmd {ইঞ্জিন কমান্ড}
translate b ExtHWEngineParam {ইঞ্জিন পরামিতি}
translate b ExtHWShowButton {বোতাম দেখান}
translate b ExtHWHardware {হার্ডওয়্যার}
translate b ExtHWNovag {নোভাগ সিট্রিন}
translate b ExtHWInputEngine {ইনপুট ইঞ্জিন}
translate b ExtHWNoBoard {বোর্ড নেই}
translate b NovagReferee {রেফারি}

# Input Engine dialogs
translate b IEConsole {ইনপুট ইঞ্জিন কনসোল}
translate b IESending {জন্য পাঠানো হয়েছে}
translate b IESynchronise {সিঙ্ক্রোনাইজ করুন}
translate b IERotate  {ঘোরান}
translate b IEUnableToStart {ইনপুট ইঞ্জিন শুরু করতে অক্ষম:}

# Calculation of Variations
translate b DoneWithPosition {অবস্থানের সঙ্গে সম্পন্ন}

translate b Board {বোর্ড}
translate b showGameInfo {খেলার তথ্য দেখান}
translate b autoResizeBoard {বোর্ডের স্বয়ংক্রিয় আকার পরিবর্তন}
translate b DockTop {উপরে সরান}
translate b DockBottom {নীচে সরান}
translate b DockLeft {বাম দিকে সরান}
translate b DockRight {ডানদিকে সরান}
translate b Undock {আনডক করুন}

# Switcher window
translate b AboutDatabase {এই ডাটাবেস সম্পর্কে}
translate b ChangeIcon {ডাটাবেস আইকন নির্বাচন করুন...}
translate b NewGameListWindow {নতুন গেম লিস্ট উইন্ডো}
translate b LoadatStartup {স্টার্টআপে লোড করুন}

# Gamelist window
translate b ShowHideDB {ডাটাবেস দেখান/লুকান}
translate b ChangeFilter {ফিল্টার পরিবর্তন করুন}
translate b ChangeLayout {সাজানোর মানদণ্ড এবং কলাম বিন্যাস লোড/সংরক্ষণ/পরিবর্তন করুন}
translate b ShowHideStatistic {পরিসংখ্যান দেখান/লুকান}
translate b BoardFilter {শুধুমাত্র বর্তমান বোর্ড অবস্থানের সাথে মেলে এমন গেমগুলি দেখান৷}
translate b CopyGameTo {গেম কপি করুন}
translate b FindBar {বার খুঁজুন}
translate b FindCurrentGame {বর্তমান খেলা খুঁজুন}
translate b DeleteGame {গেমটি মুছুন}
translate b UndeleteGame {খেলা অপসারণ}
translate b ResetSort {সাজানোর রিসেট করুন}

translate b ConvertNullMove {নাল চালগুলিকে মন্তব্যে রূপান্তর করুন}
translate b SetupBoard {সেটআপ বোর্ড}
translate b Rotate {ঘোরান}
translate b SwitchColors {রঙ পরিবর্তন করুন}
translate b FlipBoard {ফ্লিপ বোর্ড}
translate b ImportPGN {PGN গেম ইম্পোর্ট করুন}
translate b ImportingFiles {PGN ফাইল আমদানি করা হচ্ছে}
translate b ImportingFrom {থেকে আমদানি করা হচ্ছে}
translate b ImportingIn {গেম ইম্পোর্ট করুন}
translate b UseLastTag {শেষ\ngগেমের ট্যাগ ব্যবহার করুন}
translate b Random {এলোমেলো}
translate b BackToMainline {মেইনলাইনে ফিরে যান}
translate b LeaveVariant {বৈকল্পিক ছেড়ে}
translate b Autoplay {অটোপ্লে}
translate b ShowHideCoords {কর্ড দেখান/লুকান।}
translate b ShowHideEvalBar {মূল্যায়ন বার দেখান/লুকান}
translate b ShowHideMaterial {উপাদান দেখান/লুকান}
translate b SelectMarker {মার্কার নির্বাচন করুন}
translate b FullScreen {পূর্ণ পর্দা}
translate b FilterStatistic {ফিল্টার পরিসংখ্যান}
translate b MakeCorrections {সংশোধন করুন}
translate b Surnames {উপাধি}
translate b Ambiguous {অস্পষ্ট}

#Preferences Dialog
translate b OptionsToolbar "টুলবার"
translate b OptionsBoard "দাবাবোর্ড"
translate b OptionsBoardSize "বোর্ডের আকার"
translate b OptionsBoardPieces "টুকরা শৈলী"
translate b OptionsInternationalization "আন্তর্জাতিকীকরণ"
translate b OptionsTablebaseDir "4টি টেবিল বেস ফোল্ডার পর্যন্ত নির্বাচন করুন:"

# Evaluation bar
translate b BestMoveArrow "সেরা সরানো তীর"
translate b NewLocalEngine "+ নতুন ইঞ্জিন..."

# Batch Annotate
translate b BatchAnnotate {ব্যাচ টীকা}
translate b BatchEngineSelection {ইঞ্জিন নির্বাচন}
translate b BatchChessEngine {দাবা ইঞ্জিন:}
translate b BatchNumberOfInstances {দৃষ্টান্তের সংখ্যা:}
translate b BatchGameReview {গেম রিভিউ}
translate b BatchTimePerMove {প্রতি মুভ করার সময় (সেকেন্ড):}
translate b BatchAnnotateBlunders {শুধুমাত্র ভুলগুলো টীকা করুন}
translate b BatchBlunderThreshold {ভুল থ্রেশহোল্ড:}
translate b BatchVariationLength {পরিবর্তনের দৈর্ঘ্য (চালনা):}
translate b BatchOpeningBook {খোলা বই}
translate b BatchUseBook {বই ব্যবহার করুন}
translate b BatchAnnotateVariations {বৈচিত্র টীকা}
translate b BatchShortAnnotations {সংক্ষিপ্ত টীকা}
translate b BatchAddScoreToShort {সংক্ষিপ্ত টীকাগুলিতে স্কোর যোগ করুন}
translate b BatchClearOld {পুরানো মন্তব্য এবং বৈচিত্র পরিষ্কার করুন}
translate b BatchInitializingEngines {ইঞ্জিন শুরু করা হচ্ছে...}
translate b BatchAnalyzingGames {গেম বিশ্লেষণ করা হচ্ছে...}
translate b BatchProgress {ব্যাচ টীকা অগ্রগতি}
translate b BatchComplete {ব্যাচ টীকা সম্পূর্ণ!}
translate b BatchCancelled {ব্যাচ টীকা বাতিল করা হয়েছে}
}
# end of english.tcl
