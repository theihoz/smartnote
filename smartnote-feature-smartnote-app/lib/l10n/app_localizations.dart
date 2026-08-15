import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'SmartNote'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @greeting.
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn 👋'**
  String get greeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại điều quan trọng hôm nay.'**
  String get homeSubtitle;

  /// No description provided for @taskCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} việc'**
  String taskCount(int count);

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @study.
  ///
  /// In vi, this message translates to:
  /// **'Học tập'**
  String get study;

  /// No description provided for @project.
  ///
  /// In vi, this message translates to:
  /// **'Dự án'**
  String get project;

  /// No description provided for @idea.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng'**
  String get idea;

  /// No description provided for @personal.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get personal;

  /// No description provided for @recentNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú gần đây'**
  String get recentNotes;

  /// No description provided for @saved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu'**
  String get saved;

  /// No description provided for @inspirationLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm một chút cảm hứng...'**
  String get inspirationLoading;

  /// No description provided for @inspirationError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được câu nói. Thử lại nhé.'**
  String get inspirationError;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @emptyNotesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có ghi chú nào'**
  String get emptyNotesTitle;

  /// No description provided for @emptyNotesBody.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn nút + để ghi lại ý tưởng đầu tiên.'**
  String get emptyNotesBody;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tiêu đề hoặc nội dung...'**
  String get searchHint;

  /// No description provided for @noSearchResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy ghi chú phù hợp.'**
  String get noSearchResults;

  /// No description provided for @emptyFavorites.
  ///
  /// In vi, this message translates to:
  /// **'Những ghi chú bạn yêu thích sẽ xuất hiện ở đây.'**
  String get emptyFavorites;

  /// No description provided for @themeSection.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeSection;

  /// No description provided for @themeMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ màu'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get system;

  /// No description provided for @light.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @storageSection.
  ///
  /// In vi, this message translates to:
  /// **'Lưu trữ và đồng bộ'**
  String get storageSection;

  /// No description provided for @cloudSync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ đám mây'**
  String get cloudSync;

  /// No description provided for @cloudReady.
  ///
  /// In vi, this message translates to:
  /// **'Đã sẵn sàng • SQLite vẫn là nguồn offline'**
  String get cloudReady;

  /// No description provided for @cloudUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thiết lập • Ứng dụng đang chạy cục bộ'**
  String get cloudUnavailable;

  /// No description provided for @sync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ'**
  String get sync;

  /// No description provided for @localStorage.
  ///
  /// In vi, this message translates to:
  /// **'Lưu trên thiết bị'**
  String get localStorage;

  /// No description provided for @localStorageDescription.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú và ảnh được lưu an toàn trên điện thoại'**
  String get localStorageDescription;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng'**
  String get about;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản 1.0.0 • vn.edu.smartnote'**
  String get version;

  /// No description provided for @newNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú mới'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get editNote;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get done;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @titleHint.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề'**
  String get titleHint;

  /// No description provided for @text.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get text;

  /// No description provided for @taskList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách việc'**
  String get taskList;

  /// No description provided for @bodyHint.
  ///
  /// In vi, this message translates to:
  /// **'Viết điều bạn đang nghĩ...'**
  String get bodyHint;

  /// No description provided for @imageCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm {count} ảnh'**
  String imageCount(int count);

  /// No description provided for @camera.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh'**
  String get gallery;

  /// No description provided for @addLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhãn'**
  String get addLabel;

  /// No description provided for @chooseColor.
  ///
  /// In vi, this message translates to:
  /// **'Chọn màu'**
  String get chooseColor;

  /// No description provided for @savedOnDevice.
  ///
  /// In vi, this message translates to:
  /// **'Tự động lưu trên thiết bị'**
  String get savedOnDevice;

  /// No description provided for @taskHint.
  ///
  /// In vi, this message translates to:
  /// **'Việc cần làm'**
  String get taskHint;

  /// No description provided for @addTask.
  ///
  /// In vi, this message translates to:
  /// **'Thêm việc'**
  String get addTask;

  /// No description provided for @favorite.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get share;

  /// No description provided for @deleteNote.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ghi chú'**
  String get deleteNote;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ghi chú này?'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteContent.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể hoàn tác ngay sau khi xóa.'**
  String get deleteNoteContent;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @deletedNote.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa ghi chú'**
  String get deletedNote;

  /// No description provided for @updatedNote.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật ghi chú'**
  String get updatedNote;

  /// No description provided for @createdNote.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu ghi chú'**
  String get createdNote;

  /// No description provided for @undo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// No description provided for @addTag.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhãn'**
  String get addTag;

  /// No description provided for @checklistTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cần chuẩn bị'**
  String get checklistTitle;

  /// No description provided for @completedCount.
  ///
  /// In vi, this message translates to:
  /// **'{done}/{total} hoàn thành'**
  String completedCount(int done, int total);

  /// No description provided for @untitled.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú không tiêu đề'**
  String get untitled;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày trước'**
  String daysAgo(int count);

  /// No description provided for @emptyNoteError.
  ///
  /// In vi, this message translates to:
  /// **'Hãy nhập tiêu đề hoặc nội dung.'**
  String get emptyNoteError;

  /// No description provided for @emptyChecklistError.
  ///
  /// In vi, this message translates to:
  /// **'Hãy thêm ít nhất một mục danh sách việc.'**
  String get emptyChecklistError;

  /// No description provided for @quoteAuthor.
  ///
  /// In vi, this message translates to:
  /// **'— {author}'**
  String quoteAuthor(String author);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
