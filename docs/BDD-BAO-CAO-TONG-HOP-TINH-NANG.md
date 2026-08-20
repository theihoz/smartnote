# BDD – BÁO CÁO TỔNG HỢP YÊU CẦU TÍNH NĂNG SMARTNOTE

## 1. Mục tiêu nghiệp vụ và bối cảnh

SmartNote là ứng dụng ghi chú cá nhân dành cho người dùng Android. Ứng dụng
giúp người dùng ghi lại ý tưởng, công việc và thông tin quan trọng; đồng thời
hỗ trợ tìm kiếm, nhắc việc, bảo vệ nội dung và chia sẻ ghi chú.

Mục tiêu của sản phẩm:

- Giúp người dùng ghi chú nhanh và dễ sử dụng.
- Hạn chế mất dữ liệu khi thiết bị mất kết nối mạng.
- Cho phép người dùng sử dụng nhanh với tư cách khách hoặc bằng tài khoản.
- Giúp người dùng sắp xếp và tìm lại ghi chú thuận tiện.
- Bảo vệ những ghi chú có nội dung riêng tư.
- Tạo trải nghiệm nhất quán về giao diện và ngôn ngữ.

Tài liệu mô tả yêu cầu theo BDD với cấu trúc **Given – When – Then**, tương ứng
với **Điều kiện ban đầu – Hành động – Kết quả mong đợi**. Mỗi User Story đại
diện cho một nhu cầu hoàn chỉnh của người dùng.

---

## 2. Phạm vi người dùng

| Nhóm người dùng | Mô tả |
|---|---|
| Khách | Sử dụng ứng dụng nhanh mà chưa cần tạo tài khoản. |
| Người dùng có tài khoản | Đăng nhập bằng email và mật khẩu để sử dụng dữ liệu theo tài khoản. |
| Người dùng đang offline | Tiếp tục xem và chỉnh sửa dữ liệu đã có trên thiết bị. |

---

## 3. Chi tiết User Stories

### US1: Đăng ký và đăng nhập

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn đăng ký hoặc đăng nhập để sử
dụng ghi chú theo tài khoản của mình.

**Quy tắc nghiệp vụ:**

- Email phải đúng định dạng thông thường.
- Mật khẩu phải có từ 8 đến 72 ký tự.
- Mỗi email chỉ được đăng ký một tài khoản.
- Phiên bản demo không yêu cầu nhập mã OTP.
- Đăng ký thành công sẽ đưa người dùng vào ứng dụng ngay.

**Tiêu chí chấp nhận:**

#### Scenario 1.1: Đăng ký thành công

- **Given – Điều kiện:** Người dùng chưa có tài khoản và thiết bị có thể kết
  nối tới máy chủ SmartNote.
- **When – Hành động:** Người dùng nhập email hợp lệ, mật khẩu hợp lệ và chọn
  “Đăng ký”.
- **Then – Kết quả:** Tài khoản được tạo và người dùng được chuyển vào màn hình
  chính mà không phải xác minh OTP.

#### Scenario 1.2: Email không hợp lệ

- **Given – Điều kiện:** Người dùng đang ở màn hình đăng ký.
- **When – Hành động:** Người dùng nhập email thiếu tên miền hoặc thiếu ký tự
  `@` rồi chọn “Đăng ký”.
- **Then – Kết quả:** Hệ thống không tạo tài khoản và hiển thị thông báo email
  không hợp lệ.

#### Scenario 1.3: Đăng nhập sai mật khẩu

- **Given – Điều kiện:** Email đã được đăng ký.
- **When – Hành động:** Người dùng nhập sai mật khẩu và chọn “Đăng nhập”.
- **Then – Kết quả:** Hệ thống từ chối đăng nhập và hiển thị thông báo phù hợp,
  không tiết lộ email hay mật khẩu nào bị sai.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất quy tắc email, mật khẩu và thông báo lỗi.
2. Chuẩn bị các trường hợp đăng ký/đăng nhập thành công và thất bại.
3. Hoàn thiện luồng đăng ký, đăng nhập và đăng xuất.
4. Kiểm tra toàn bộ luồng trên thiết bị Android.

---

### US2: Tiếp tục với tư cách Khách

**Nhu cầu nghiệp vụ:** Là người dùng mới, tôi muốn dùng thử ứng dụng mà chưa
cần đăng ký tài khoản.

**Quy tắc nghiệp vụ:**

- Mỗi thiết bị có một hồ sơ Khách riêng.
- Dữ liệu Khách không được hiển thị cho Khách trên thiết bị khác.
- Người dùng có thể chuyển dữ liệu Khách sang tài khoản sau khi đăng nhập.

**Tiêu chí chấp nhận:**

#### Scenario 2.1: Bắt đầu bằng tài khoản Khách

- **Given – Điều kiện:** Người dùng mở ứng dụng lần đầu và có kết nối tới máy
  chủ SmartNote.
- **When – Hành động:** Người dùng chọn “Tiếp tục với Guest”.
- **Then – Kết quả:** Hệ thống tạo hồ sơ Khách và mở màn hình ghi chú.

#### Scenario 2.2: Không kết nối được máy chủ

- **Given – Điều kiện:** Thiết bị chưa từng tạo hồ sơ Khách và đang không kết
  nối được máy chủ.
- **When – Hành động:** Người dùng chọn “Tiếp tục với Guest”.
- **Then – Kết quả:** Hệ thống thông báo chưa thể tạo hồ sơ và hướng dẫn người
  dùng kiểm tra kết nối.

#### Scenario 2.3: Chuyển dữ liệu Khách sang tài khoản

- **Given – Điều kiện:** Hồ sơ Khách đã có ghi chú và người dùng có tài khoản.
- **When – Hành động:** Người dùng đăng nhập tài khoản.
- **Then – Kết quả:** Ghi chú Khách được chuyển sang tài khoản, không tạo bản
  sao trùng lặp và không làm mất ghi chú mới hơn.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất cách nhận diện và phân tách dữ liệu Khách.
2. Xác định quy tắc chuyển dữ liệu Khách sang tài khoản.
3. Hoàn thiện nút “Tiếp tục với Guest” và luồng chuyển dữ liệu.
4. Kiểm tra dữ liệu giữa các hồ sơ không bị lẫn nhau.

---

### US3: Tạo và chỉnh sửa ghi chú

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn tạo và chỉnh sửa ghi chú để lưu
lại ý tưởng hoặc công việc cá nhân.

**Quy tắc nghiệp vụ:**

- Ghi chú có thể là văn bản hoặc danh sách công việc.
- Người dùng có thể thêm tiêu đề, nội dung, ảnh, màu và trạng thái yêu thích.
- Nội dung đang soạn được lưu tạm để hạn chế mất dữ liệu.
- Mỗi lần lưu sẽ tạo một phiên bản để hỗ trợ xem lại lịch sử.

**Tiêu chí chấp nhận:**

#### Scenario 3.1: Tạo ghi chú mới

- **Given – Điều kiện:** Người dùng đã vào màn hình chính.
- **When – Hành động:** Người dùng nhập tiêu đề, nội dung và chọn “Lưu”.
- **Then – Kết quả:** Ghi chú mới xuất hiện trong danh sách và vẫn còn sau khi
  mở lại ứng dụng.

#### Scenario 3.2: Tiếp tục soạn khi mất mạng

- **Given – Điều kiện:** Người dùng đã có hồ sơ trên thiết bị nhưng đang mất
  mạng.
- **When – Hành động:** Người dùng tạo hoặc chỉnh sửa ghi chú.
- **Then – Kết quả:** Thay đổi vẫn được lưu trên thiết bị và chờ cập nhật khi
  có mạng trở lại.

#### Scenario 3.3: Ứng dụng đóng khi đang soạn

- **Given – Điều kiện:** Người dùng đã nhập nội dung nhưng chưa hoàn tất.
- **When – Hành động:** Ứng dụng bị đóng ngoài ý muốn và được mở lại.
- **Then – Kết quả:** Bản nháp gần nhất được khôi phục để người dùng tiếp tục.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất các loại ghi chú và thông tin cần lưu.
2. Xác định thời điểm lưu bản nháp và tạo lịch sử phiên bản.
3. Hoàn thiện màn hình tạo/chỉnh sửa ghi chú.
4. Kiểm tra lưu dữ liệu khi có mạng, mất mạng và mở lại ứng dụng.

---

### US4: Đồng bộ dữ liệu khi có mạng

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn các thay đổi khi offline được cập
nhật khi có mạng để dữ liệu không bị thất lạc.

**Quy tắc nghiệp vụ:**

- Thay đổi phải được lưu trên thiết bị trước khi gửi lên máy chủ.
- Chỉ đánh dấu hoàn tất khi máy chủ xác nhận thành công.
- Nếu cùng một ghi chú được thay đổi nhiều nơi, phiên bản cập nhật mới hơn được
  ưu tiên.
- Ghi chú đã xóa phải được đồng bộ dưới trạng thái đã xóa.

**Tiêu chí chấp nhận:**

#### Scenario 4.1: Đồng bộ thành công

- **Given – Điều kiện:** Người dùng đã chỉnh sửa ghi chú khi offline.
- **When – Hành động:** Thiết bị kết nối mạng trở lại.
- **Then – Kết quả:** Các thay đổi đang chờ được gửi lên máy chủ và dữ liệu mới
  từ máy chủ được cập nhật về thiết bị.

#### Scenario 4.2: Đồng bộ thất bại

- **Given – Điều kiện:** Thiết bị có thay đổi đang chờ nhưng máy chủ gặp lỗi.
- **When – Hành động:** Ứng dụng thực hiện đồng bộ.
- **Then – Kết quả:** Dữ liệu trên thiết bị vẫn được giữ nguyên và hệ thống sẽ
  thử lại sau.

#### Scenario 4.3: Phiên đăng nhập hết hạn

- **Given – Điều kiện:** Dữ liệu tài khoản vẫn còn trên thiết bị nhưng phiên
  đăng nhập đã hết hạn.
- **When – Hành động:** Ứng dụng đồng bộ dữ liệu.
- **Then – Kết quả:** Dữ liệu không bị xóa và người dùng được yêu cầu đăng nhập
  lại trước khi tiếp tục đồng bộ.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất quy tắc ưu tiên dữ liệu khi có xung đột.
2. Xác định trạng thái thành công, đang chờ và thất bại.
3. Hoàn thiện luồng gửi và nhận dữ liệu.
4. Kiểm tra đồng bộ thành công, mất mạng và phiên hết hạn.

---

### US5: Tìm kiếm, nhãn, lọc và sắp xếp

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn nhanh chóng tìm được ghi chú cần
thiết khi số lượng ghi chú tăng lên.

**Quy tắc nghiệp vụ:**

- Người dùng có thể tìm theo từ khóa.
- Có thể lọc theo nhãn và trạng thái yêu thích cùng lúc.
- Có thể sắp xếp theo mới nhất hoặc cũ nhất.
- Bộ lọc không được làm thay đổi nội dung ghi chú.

**Tiêu chí chấp nhận:**

#### Scenario 5.1: Tìm và lọc ghi chú

- **Given – Điều kiện:** Người dùng có nhiều ghi chú với các nhãn khác nhau.
- **When – Hành động:** Người dùng nhập từ khóa, chọn nhãn và bật “Yêu thích”.
- **Then – Kết quả:** Chỉ những ghi chú thỏa tất cả điều kiện được hiển thị.

#### Scenario 5.2: Không có kết quả

- **Given – Điều kiện:** Không có ghi chú phù hợp với điều kiện tìm kiếm.
- **When – Hành động:** Người dùng áp dụng bộ lọc.
- **Then – Kết quả:** Ứng dụng hiển thị trạng thái không có kết quả và cho phép
  xóa bộ lọc.

#### Scenario 5.3: Sắp xếp ghi chú

- **Given – Điều kiện:** Danh sách có nhiều ghi chú được cập nhật ở các thời
  điểm khác nhau.
- **When – Hành động:** Người dùng chọn “Cũ nhất”.
- **Then – Kết quả:** Ghi chú cũ nhất được hiển thị trước.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất các điều kiện tìm kiếm và sắp xếp.
2. Chuẩn bị dữ liệu mẫu cho từng trường hợp lọc.
3. Hoàn thiện khu vực tìm kiếm và bộ lọc.
4. Kiểm tra kết hợp nhiều điều kiện cùng lúc.

---

### US6: Nhắc việc theo ngày giờ

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn nhận thông báo nhắc việc từ ghi
chú để không bỏ lỡ công việc quan trọng.

**Quy tắc nghiệp vụ:**

- Mỗi ghi chú có thể có lịch nhắc theo ngày và giờ.
- Người dùng có thể chọn lặp lại hoặc không lặp lại.
- Người dùng có thể thay đổi hoặc xóa lịch nhắc.
- Thông báo cần quyền cho phép của Android.

**Tiêu chí chấp nhận:**

#### Scenario 6.1: Tạo lịch nhắc thành công

- **Given – Điều kiện:** Người dùng đang xem một ghi chú và ứng dụng đã được
  cấp quyền thông báo.
- **When – Hành động:** Người dùng chọn ngày giờ và lưu lịch nhắc.
- **Then – Kết quả:** Lịch nhắc được hiển thị trong ghi chú và thông báo xuất
  hiện vào thời điểm đã chọn.

#### Scenario 6.2: Xóa lịch nhắc

- **Given – Điều kiện:** Ghi chú đang có lịch nhắc.
- **When – Hành động:** Người dùng chọn “Xóa nhắc việc”.
- **Then – Kết quả:** Lịch nhắc được xóa và thông báo đã lên lịch được hủy.

#### Scenario 6.3: Chưa cấp quyền thông báo

- **Given – Điều kiện:** Android chưa cấp quyền thông báo cho SmartNote.
- **When – Hành động:** Người dùng tạo lịch nhắc.
- **Then – Kết quả:** Ứng dụng không bị dừng bất thường và hướng dẫn người dùng
  kiểm tra quyền thông báo.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất cách chọn ngày giờ và lặp lại.
2. Xác định nội dung thông báo và trường hợp thiếu quyền.
3. Hoàn thiện màn hình tạo, sửa và xóa nhắc việc.
4. Kiểm tra thông báo trên các phiên bản Android được hỗ trợ.

---

### US7: Thùng rác 30 ngày

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn khôi phục ghi chú bị xóa nhầm
trong một khoảng thời gian hợp lý.

**Quy tắc nghiệp vụ:**

- Xóa ghi chú sẽ chuyển ghi chú vào Thùng rác thay vì xóa ngay.
- Ghi chú có thể được khôi phục trong vòng 30 ngày.
- Ghi chú quá 30 ngày sẽ bị xóa vĩnh viễn.
- Ghi chú trong Thùng rác không xuất hiện trong danh sách thông thường.

**Tiêu chí chấp nhận:**

#### Scenario 7.1: Khôi phục ghi chú

- **Given – Điều kiện:** Ghi chú đã nằm trong Thùng rác chưa quá 30 ngày.
- **When – Hành động:** Người dùng chọn “Khôi phục”.
- **Then – Kết quả:** Ghi chú trở lại danh sách chính với đầy đủ nội dung.

#### Scenario 7.2: Ghi chú quá thời hạn

- **Given – Điều kiện:** Ghi chú đã nằm trong Thùng rác quá 30 ngày.
- **When – Hành động:** Hệ thống thực hiện dọn dẹp dữ liệu.
- **Then – Kết quả:** Ghi chú bị xóa vĩnh viễn và không thể khôi phục.

#### Scenario 7.3: Thùng rác trống

- **Given – Điều kiện:** Người dùng không có ghi chú đã xóa.
- **When – Hành động:** Người dùng mở Thùng rác.
- **Then – Kết quả:** Ứng dụng hiển thị trạng thái Thùng rác trống.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất thời điểm bắt đầu và kết thúc thời hạn 30 ngày.
2. Xác định hành vi khôi phục và xóa vĩnh viễn.
3. Hoàn thiện màn hình Thùng rác.
4. Kiểm tra các mốc trước, đúng và sau 30 ngày.

---

### US8: Khóa ghi chú bằng PIN

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn khóa ghi chú riêng tư để người
khác cầm thiết bị không thể đọc nội dung.

**Quy tắc nghiệp vụ:**

- PIN gồm từ 4 đến 6 chữ số.
- Người dùng phải nhập lại PIN khi tạo mới.
- PIN được dùng chung cho các ghi chú khóa trên thiết bị.
- Sau 5 lần nhập sai, người dùng phải chờ 30 giây trước khi thử lại.

**Tiêu chí chấp nhận:**

#### Scenario 8.1: Mở ghi chú bằng PIN đúng

- **Given – Điều kiện:** Ghi chú đã được khóa và người dùng đã tạo PIN.
- **When – Hành động:** Người dùng nhập đúng PIN.
- **Then – Kết quả:** Nội dung ghi chú được hiển thị.

#### Scenario 8.2: Nhập sai PIN năm lần

- **Given – Điều kiện:** Người dùng đang mở một ghi chú khóa.
- **When – Hành động:** Người dùng nhập sai PIN năm lần liên tiếp.
- **Then – Kết quả:** Hệ thống tạm khóa việc thử lại trong 30 giây.

#### Scenario 8.3: Tạo PIN không hợp lệ

- **Given – Điều kiện:** Người dùng đang tạo PIN.
- **When – Hành động:** PIN không đủ 4–6 chữ số hoặc hai lần nhập không giống
  nhau.
- **Then – Kết quả:** Hệ thống không lưu PIN và hiển thị hướng dẫn sửa lại.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất quy tắc tạo và nhập PIN.
2. Xác định thông báo cho từng trường hợp sai.
3. Hoàn thiện màn hình cài đặt PIN và mở khóa ghi chú.
4. Kiểm tra giới hạn năm lần sai và thời gian chờ 30 giây.

---

### US9: Xuất và chia sẻ ghi chú

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn xuất nhiều ghi chú thành một tài
liệu để lưu trữ hoặc chia sẻ cho người khác.

**Quy tắc nghiệp vụ:**

- Người dùng có thể chọn một hoặc nhiều ghi chú.
- Hỗ trợ định dạng PDF và Markdown.
- Chỉ xuất các ghi chú được người dùng chọn.
- Không tạo tài liệu rỗng khi chưa chọn ghi chú.

**Tiêu chí chấp nhận:**

#### Scenario 9.1: Xuất PDF thành công

- **Given – Điều kiện:** Người dùng đã chọn ít nhất một ghi chú.
- **When – Hành động:** Người dùng chọn “Xuất PDF”.
- **Then – Kết quả:** Ứng dụng tạo một tài liệu PDF và mở lựa chọn chia sẻ.

#### Scenario 9.2: Xuất Markdown thành công

- **Given – Điều kiện:** Người dùng đã chọn nhiều ghi chú.
- **When – Hành động:** Người dùng chọn “Xuất Markdown”.
- **Then – Kết quả:** Ứng dụng tạo một tài liệu tổng hợp đúng các ghi chú đã
  chọn và mở lựa chọn chia sẻ.

#### Scenario 9.3: Chưa chọn ghi chú

- **Given – Điều kiện:** Không có ghi chú nào được chọn.
- **When – Hành động:** Người dùng mở màn hình xuất dữ liệu.
- **Then – Kết quả:** Chức năng xuất chưa thể thực hiện và không tạo file rỗng.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất nội dung và thứ tự ghi chú trong tài liệu xuất.
2. Xác định trạng thái khi chưa có lựa chọn.
3. Hoàn thiện lựa chọn PDF/Markdown và chia sẻ.
4. Kiểm tra nội dung tài liệu với một và nhiều ghi chú.

---

### US10: Lưu giao diện và ngôn ngữ

**Nhu cầu nghiệp vụ:** Là người dùng, tôi muốn giao diện và ngôn ngữ đã chọn
được giữ lại để không phải cài đặt lại mỗi lần mở ứng dụng.

**Quy tắc nghiệp vụ:**

- Người dùng có thể chuyển giữa giao diện sáng và tối.
- Người dùng có thể chuyển giữa tiếng Việt và tiếng Anh.
- Lựa chọn phải áp dụng cho toàn bộ ứng dụng.
- Lựa chọn phải được giữ lại sau khi đóng ứng dụng.

**Tiêu chí chấp nhận:**

#### Scenario 10.1: Giữ giao diện tối

- **Given – Điều kiện:** Người dùng đã chọn giao diện tối.
- **When – Hành động:** Người dùng đóng và mở lại ứng dụng.
- **Then – Kết quả:** Toàn bộ ứng dụng tiếp tục sử dụng giao diện tối.

#### Scenario 10.2: Đổi ngôn ngữ

- **Given – Điều kiện:** Ứng dụng đang hiển thị tiếng Việt.
- **When – Hành động:** Người dùng chọn tiếng Anh.
- **Then – Kết quả:** Nội dung các màn hình chuyển sang tiếng Anh và lựa chọn
  vẫn được giữ sau khi mở lại.

#### Scenario 10.3: Chưa từng chọn cài đặt

- **Given – Điều kiện:** Người dùng mở ứng dụng lần đầu.
- **When – Hành động:** Ứng dụng tải cài đặt hiển thị.
- **Then – Kết quả:** Hệ thống dùng giao diện theo thiết bị và tiếng Việt làm
  ngôn ngữ mặc định.

**Công việc theo thứ tự phụ thuộc:**

1. Thống nhất giá trị mặc định của giao diện và ngôn ngữ.
2. Rà soát các màn hình cần thay đổi đồng thời.
3. Hoàn thiện chức năng lưu lựa chọn.
4. Kiểm tra sau khi đóng/mở lại và chuyển qua nhiều màn hình.

---

## 4. Kết quả đối chiếu với phần mềm

| Nhu cầu | Trạng thái | Bằng chứng chấp nhận |
|---|---|---|
| Đăng ký và đăng nhập | Đã đáp ứng | Có đăng ký, đăng nhập, đăng xuất, đổi mật khẩu và thông báo lỗi. |
| Dùng thử với Guest | Đã đáp ứng | Dữ liệu Guest được tách riêng và có thể chuyển sang tài khoản. |
| Tạo và chỉnh sửa ghi chú | Đã đáp ứng | Có tự lưu/khôi phục bản nháp và xem/khôi phục tối đa 20 phiên bản. |
| Đồng bộ khi có mạng | Đã đáp ứng trong phạm vi demo | Dữ liệu chờ được gửi khi mở lại ứng dụng, đổi tài khoản hoặc quay lại ứng dụng. |
| Tìm kiếm, nhãn, lọc và sắp xếp | Đã đáp ứng | Có thể kết hợp từ khóa, nhãn, yêu thích, loại ghi chú và thứ tự. |
| Nhắc việc | Đã đáp ứng | Có tạo, sửa, xóa lịch nhắc; nếu thiếu quyền sẽ hướng dẫn người dùng bật lại. |
| Thùng rác 30 ngày | Đã đáp ứng | Có khôi phục và tự xóa khi hết thời hạn. |
| Khóa ghi chú bằng PIN | Đã đáp ứng | Có PIN 4–6 số và tạm khóa sau năm lần nhập sai. |
| Xuất và chia sẻ | Đã đáp ứng | Có chọn nhiều ghi chú và xuất PDF hoặc Markdown. |
| Lưu giao diện và ngôn ngữ | Đã đáp ứng | Lựa chọn được áp dụng toàn ứng dụng và giữ lại sau khi mở lại. |

Các bước kiểm tra tự động được lưu cùng mã nguồn. Kiểm tra thông báo thực tế và
khả năng cài APK vẫn cần thực hiện trên thiết bị Android trước khi nghiệm thu.

## 5. Yêu cầu chung về chất lượng

- Giao diện phải dễ đọc và thao tác được trên điện thoại Android phổ biến.
- Không làm mất ghi chú khi mất mạng hoặc đồng bộ thất bại.
- Dữ liệu giữa Khách và các tài khoản không được hiển thị lẫn nhau.
- Thông báo lỗi phải dễ hiểu, không hiển thị thông tin kỹ thuật cho người dùng.
- Không ghi mật khẩu, PIN, nội dung ghi chú hoặc thông tin đăng nhập vào log.
- Ứng dụng hỗ trợ Android 7.0 trở lên.
- Các lựa chọn giao diện và ngôn ngữ phải được giữ sau khi mở lại ứng dụng.

## 6. Ngoài phạm vi bản demo

- Xác minh email bằng OTP.
- Quên và khôi phục mật khẩu qua email.
- Lưu trữ máy chủ lâu dài khi môi trường demo bị dừng hoặc tạo lại.
- Phát hành chính thức trên Google Play.
- Quản trị người dùng và phân quyền dành cho quản trị viên.
