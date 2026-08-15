// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'SmartNote';

  @override
  String get home => 'Trang chủ';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get settings => 'Cài đặt';

  @override
  String get greeting => 'Chào bạn 👋';

  @override
  String get homeSubtitle => 'Ghi lại điều quan trọng hôm nay.';

  @override
  String taskCount(int count) {
    return '$count việc';
  }

  @override
  String get all => 'Tất cả';

  @override
  String get study => 'Học tập';

  @override
  String get project => 'Dự án';

  @override
  String get idea => 'Ý tưởng';

  @override
  String get personal => 'Cá nhân';

  @override
  String get recentNotes => 'Ghi chú gần đây';

  @override
  String get saved => 'Đã lưu';

  @override
  String get inspirationLoading => 'Đang tìm một chút cảm hứng...';

  @override
  String get inspirationError => 'Chưa tải được câu nói. Thử lại nhé.';

  @override
  String get retry => 'Thử lại';

  @override
  String get emptyNotesTitle => 'Bạn chưa có ghi chú nào';

  @override
  String get emptyNotesBody => 'Nhấn nút + để ghi lại ý tưởng đầu tiên.';

  @override
  String get searchHint => 'Tìm theo tiêu đề hoặc nội dung...';

  @override
  String get noSearchResults => 'Không tìm thấy ghi chú phù hợp.';

  @override
  String get emptyFavorites =>
      'Những ghi chú bạn yêu thích sẽ xuất hiện ở đây.';

  @override
  String get themeSection => 'Giao diện';

  @override
  String get themeMode => 'Chế độ màu';

  @override
  String get system => 'Theo hệ thống';

  @override
  String get light => 'Sáng';

  @override
  String get dark => 'Tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get storageSection => 'Lưu trữ và đồng bộ';

  @override
  String get cloudSync => 'Đồng bộ đám mây';

  @override
  String get cloudReady => 'Đã sẵn sàng • SQLite vẫn là nguồn offline';

  @override
  String get cloudUnavailable => 'Chưa thiết lập • Ứng dụng đang chạy cục bộ';

  @override
  String get sync => 'Đồng bộ';

  @override
  String get localStorage => 'Lưu trên thiết bị';

  @override
  String get localStorageDescription =>
      'Ghi chú và ảnh được lưu an toàn trên điện thoại';

  @override
  String get about => 'Ứng dụng';

  @override
  String get version => 'Phiên bản 1.0.0 • vn.edu.smartnote';

  @override
  String get newNote => 'Ghi chú mới';

  @override
  String get editNote => 'Chỉnh sửa';

  @override
  String get done => 'Xong';

  @override
  String get save => 'Lưu';

  @override
  String get titleHint => 'Tiêu đề';

  @override
  String get text => 'Ghi chú';

  @override
  String get taskList => 'Danh sách việc';

  @override
  String get bodyHint => 'Viết điều bạn đang nghĩ...';

  @override
  String imageCount(int count) {
    return 'Đã thêm $count ảnh';
  }

  @override
  String get camera => 'Chụp ảnh';

  @override
  String get gallery => 'Chọn ảnh';

  @override
  String get addLabel => 'Thêm nhãn';

  @override
  String get chooseColor => 'Chọn màu';

  @override
  String get savedOnDevice => 'Tự động lưu trên thiết bị';

  @override
  String get taskHint => 'Việc cần làm';

  @override
  String get addTask => 'Thêm việc';

  @override
  String get favorite => 'Yêu thích';

  @override
  String get share => 'Chia sẻ';

  @override
  String get deleteNote => 'Xóa ghi chú';

  @override
  String get deleteNoteTitle => 'Xóa ghi chú này?';

  @override
  String get deleteNoteContent => 'Bạn có thể hoàn tác ngay sau khi xóa.';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get deletedNote => 'Đã xóa ghi chú';

  @override
  String get updatedNote => 'Đã cập nhật ghi chú';

  @override
  String get createdNote => 'Đã lưu ghi chú';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get addTag => 'Thêm nhãn';

  @override
  String get checklistTitle => 'Cần chuẩn bị';

  @override
  String completedCount(int done, int total) {
    return '$done/$total hoàn thành';
  }

  @override
  String get untitled => 'Ghi chú không tiêu đề';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String daysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get emptyNoteError => 'Hãy nhập tiêu đề hoặc nội dung.';

  @override
  String get emptyChecklistError => 'Hãy thêm ít nhất một mục danh sách việc.';

  @override
  String quoteAuthor(String author) {
    return '— $author';
  }
}
