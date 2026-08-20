import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  String get appTitle => isArabic ? 'متابعة انتخابات المجلس التشريعي' : 'PLC Election Tracker';
  String get brief => isArabic ? 'الملخص' : 'Brief';
  String get polling => isArabic ? 'الاستطلاعات' : 'Polling';
  String get parties => isArabic ? 'القوائم' : 'Parties';
  String get baseline => isArabic ? 'الأساس' : 'Baseline';
  String get scenarios => isArabic ? 'السيناريوهات' : 'Scenarios';
  String get news => isArabic ? 'الأخبار' : 'News';
  String get reports => isArabic ? 'التقارير' : 'Reports';
  String get arabic => isArabic ? 'English' : 'العربية';
  String get scheduled => isArabic ? 'موعد الانتخابات المقرر' : 'Scheduled election';
  String get daysUntil => isArabic ? 'يوم حتى موعد التصويت' : 'days until the scheduled vote';
  String get unresolved => isArabic ? 'أسئلة معلقة' : 'Unresolved';
  String get switchLanguage => isArabic ? 'Switch to English' : 'التبديل إلى العربية';
  String get reportCenter => isArabic ? 'مركز التقارير' : 'Report center';
  String get reportSubtitle => isArabic ? 'أنشئ تقارير قابلة للطباعة من آخر بيانات موثقة.' : 'Create printable reports from the latest attributed data.';
  String get printReport => isArabic ? 'طباعة التقرير' : 'Print report';
  String get fullBrief => isArabic ? 'الملخص الكامل' : 'Full election brief';
  String get partyReport => isArabic ? 'القوائم والأحزاب' : 'Parties and lists';
  String get candidateReport => isArabic ? 'كل المرشحين' : 'All candidates';
  String get cityReport => isArabic ? 'المرشحون حسب المدينة' : 'Candidates by city';
  String get sourceReport => isArabic ? 'سجل المصادر' : 'Source ledger';
  String get chooseCity => isArabic ? 'اختر مدينة أو قرية' : 'Choose a city or village';
  String get noCityData => isArabic ? 'لا توجد بيانات موثقة عن المرشحين لهذه المنطقة.' : 'No verified candidate data exists for this locality.';
  String get leadershipNote => isArabic ? 'تنبيه: قائد الحزب أو الرئيس ليس بالضرورة مرشحاً انتخابياً.' : 'Note: a party leader or president is not automatically an election candidate.';
  String get overviewEyebrow => isArabic ? 'موجز تنفيذي' : 'EXECUTIVE BRIEF';
  String get overviewTitle => isArabic ? 'ما المهم الآن' : 'What matters right now';
  String get overviewSubtitle => isArabic ? 'قراءة سريعة للمشهد الانتخابي قبل استكشاف التفاصيل.' : 'A fast read of the election picture before you explore the detail.';
  String get currentLeader => isArabic ? 'المتقدم حالياً' : 'Current leader';
  String get likelyTurnout => isArabic ? 'المشاركة المتوقعة' : 'Likely turnout';
  String get undecided => isArabic ? 'لم يحسموا' : 'Undecided';
  String get openConditions => isArabic ? 'الشروط المعلقة' : 'Open conditions';
  String get latestPollInput => isArabic ? 'من أحدث استطلاع' : 'latest poll input';
  String get largestUnknown => isArabic ? 'أكبر عنصر مجهول' : 'largest unknown';
  String get needMonitoring => isArabic ? 'تحتاج متابعة' : 'need monitoring';
  String get decisionPath => isArabic ? 'مسار القرار' : 'DECISION PATH';
  String get goDeeper => isArabic ? 'تعمق حسب السؤال' : 'Go deeper by question';
  String get goDeeperSubtitle => isArabic ? 'كل شاشة تجيب عن سؤال مختلف.' : 'Each view answers a different question.';
  String get pollingEvidence => isArabic ? 'ما قوة دليل الاستطلاعات؟' : 'How strong is the polling evidence?';
  String get listsFormation => isArabic ? 'ما القوائم التي قد تتشكل؟' : 'Which lists could actually form?';
  String get scenarioQuestion => isArabic ? 'ما الذي يتغير مع اختلاف الشروط؟' : 'What changes under different conditions?';
  String get localReporting => isArabic ? 'ماذا تقول المصادر المحلية؟' : 'What are local sources reporting?';
  String get watchlist => isArabic ? 'قائمة المتابعة' : 'WATCHLIST';
  String get pollingTitle => isArabic ? 'حصة التصويت: آنذاك والآن' : 'Party vote share: then vs. now';
  String get pollingDisclaimer => isArabic ? 'نتائج 2006 هي آخر نتيجة فعلية. الأشرطة الحالية تقديرات استطلاعية وليست توقعاً للنتيجة.' : '2006 is the last real result. Current bars are poll estimates, not a vote forecast.';
  String get contenderTreatment => isArabic ? 'طريقة التعامل مع المتنافسين' : 'Contender treatment';
  String get contenderDisclaimer => isArabic ? 'لا تظهر النسب المنفصلة إلا عندما يقدم المصدر تقديراً مستقلاً. لا نخترع نسباً للمتنافسين الآخرين.' : 'Only source-provided standalone estimates are separated. We do not invent percentages for other contenders.';
  String get latestPollInputs => isArabic ? 'مدخلات أحدث استطلاع' : 'Latest poll inputs';
  String get confidenceTitle => isArabic ? 'الثقة في تمثيل الفلسطينيين' : 'Confidence to represent Palestinians';
  String get relatedAttitude => isArabic ? 'سؤال متعلق بالاتجاهات، وليس حصة التصويت التشريعي.' : 'Related attitude question, not legislative vote share.';
  String get baselineTitle => isArabic ? '2006: آخر نتيجة فعلية' : '2006: the last real result';
  String get localTitle => isArabic ? 'انتخابات أبريل 2026 المحلية' : 'April 2026 local elections';
  String get nationalTurnout => isArabic ? 'المشاركة الوطنية، 403 هيئة محلية' : 'National turnout, 403 localities';
  String get regionTurnout => isArabic ? 'المشاركة: الضفة الغربية / غزة' : 'Turnout: West Bank / Gaza';
  String get partiesTitle => isArabic ? 'الأحزاب والقوائم المتوقعة' : 'Parties and expected lists';
  String get partiesSubtitle => isArabic ? 'يمكن إضافة القوائم أو دمجها أو تغييرها أو سحبها مع تطور التسجيل.' : 'Lists can be added, merged, renamed or withdrawn as registration develops.';
  String get alignment => isArabic ? 'التوجه' : 'Alignment';
  String get leadershipReference => isArabic ? 'قيادة الحزب / المرجع' : 'Party leadership / reference';
  String get relatedParties => isArabic ? 'الأحزاب المرتبطة' : 'Related parties';
  String get peopleToVerify => isArabic ? 'أشخاص بحاجة إلى تحقق' : 'People to verify';
  String get noEstimate => isArabic ? 'لا يوجد تقدير' : 'No estimate';
  String get origin => isArabic ? 'الأصل' : 'Origin';
  String get geographySignal => isArabic ? 'الإشارة الجغرافية' : 'Geography signal';
  String get roleWork => isArabic ? 'الدور / العمل' : 'Role / work';
  String get profile => isArabic ? 'الملف العام' : 'Profile';
  String get electoralBase => isArabic ? 'القاعدة الانتخابية' : 'Electoral base';
  String get estimateBasis => isArabic ? 'أساس التقدير' : 'Estimate basis';
  String get newsSignals => isArabic ? 'إشارات الأخبار' : 'News signals';
  String get newsDisclaimer => isArabic ? 'الأخبار لا تستبدل الاستطلاعات، بل تعدل إشارات المخاطر.' : 'News does not replace polling; it adjusts risk signals.';
  String get coverageMix => isArabic ? 'مزيج التغطية' : 'Coverage mix';
  String get modelFactors => isArabic ? 'عوامل النموذج' : 'Model factors';
  String get whatIf => isArabic ? 'ماذا لو؟ الشروط المفتوحة' : 'What-if: open questions';
  String get gazaVotes => isArabic ? 'تصويت غزة' : 'Gaza Strip votes';
  String get jerusalemVotes => isArabic ? 'تصويت القدس الشرقية' : 'East Jerusalem votes';
  String get coalitionForms => isArabic ? 'تشكّل ائتلاف مُبلغ عنه' : 'Reported coalition forms';
  String get coalition => isArabic ? 'الائتلاف' : 'Coalition';
  String get otherUndecided => isArabic ? 'أخرى / لم تحسم' : 'Other / undecided';
  String get impact => isArabic ? 'التأثير' : 'impact';
  String get candidateMethodology => isArabic ? 'منظور المرشح: نسجل الأصل والمنطقة والمهنة والملف العام والدعم الجغرافي كأدلة. المدينة الأكبر لا تعني تلقائياً أصواتاً شخصية أكثر؛ فهذا انتخاب بالقوائم النسبية، ويتوقف تأثير المرشح على القائمة النهائية والمشاركة والتنظيم والاستطلاعات الموثقة. تبقى المعلومات المجهولة غير محسومة حتى توثيقها.' : 'Candidate lens: origin, locality, profession, public profile and geographic support are tracked as evidence. A larger city does not automatically equal personal votes: this is a proportional list election, so candidate influence depends on the final list, turnout, organization and verified polling. Unknowns stay unknown until sourced.';

  String t(String english, String arabic) => isArabic ? arabic : english;

  static AppStrings of(BuildContext context) => Localizations.of<AppStrings>(context, AppStrings)!;
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
