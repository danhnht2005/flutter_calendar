# Source Index

Index nhanh cho toàn bộ source chính của repo `flutter_calendar`.

## 1. Tổng quan repo

- `calendar/`: app Flutter chính.
- `database/`: mock backend bằng `json-server`, dữ liệu nằm trong `database.json`.

Những thư mục sau chủ yếu là file sinh tự động hoặc dependency, không cần đọc khi tìm business logic:

- `database/node_modules/`
- `calendar/.dart_tool/`
- `calendar/build/`
- `calendar/android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/` nếu chỉ đang đọc logic app Flutter

## 2. Luồng chạy chính

1. App khởi động từ `calendar/lib/main.dart`.
2. `MaterialApp.router` dùng cấu hình trong `calendar/lib/router/router.dart`.
3. Router kiểm tra token bằng `calendar/lib/helpers/token.dart`.
4. Nếu chưa đăng nhập thì vào `LoginScreen`, nếu đã có token thì vào `HomeScreen`.
5. `HomeScreen` gọi `task_service.dart` để lấy task từ mock API.
6. Drawer bên trái tải user hiện tại, danh sách category, và mở bottom sheet để thêm/sửa/xóa category.

## 3. Backend/mock data

### `database/`

- `database/package.json`: chạy mock server bằng lệnh `npm start`, port `3002`.
- `database/database.json`: dữ liệu giả cho:
  - `users`
  - `categories`
  - `tasks`
  - `colors`

### API base đang dùng

- `calendar/lib/utils/request.dart`
  - `ApiService.apiDomain = "http://192.168.80.1:3002/"`
  - Bọc các hàm `get`, `post`, `put`, `del`

## 4. Flutter app index

### Entry, theme, router

- `calendar/lib/main.dart`
  - Entry point của app.
  - Gắn `AppTheme.lightTheme` và `router`.

- `calendar/lib/theme/app_theme.dart`
  - Theme sáng, Material 3.
  - Tùy chỉnh `AppBar`, `Drawer`, `Card`.

- `calendar/lib/router/router.dart`
  - Định nghĩa route:
    - `/`
    - `/login`
    - `/register`
    - `/settings`
    - `/details-category/:id`
  - Redirect theo trạng thái đăng nhập bằng token lưu local.

### Helpers

- `calendar/lib/helpers/token.dart`
  - Lưu/xóa `user_token` và `user_id` bằng `SharedPreferences`.
  - Đây là chỗ app giữ trạng thái đăng nhập.

- `calendar/lib/helpers/get_color.dart`
  - Chuyển mã màu hex dạng chuỗi sang `Color`.

- `calendar/lib/helpers/generrate_teken.dart`
  - Sinh token ngẫu nhiên khi đăng ký user mới.
  - Tên file đang bị typo: `generrate_teken`.

### Models

- `calendar/lib/models/user.dart`
  - Model user: `id`, `fullName`, `email`, `password`, `token`.

- `calendar/lib/models/categories.dart`
  - Model category: `id`, `userId`, `name`, `description`, `color`, `isActive`.
  - Có parse linh hoạt cho `isActive`.

- `calendar/lib/models/task.dart`
  - Model task lịch: `id`, `categoryId`, `eventName`, `from`, `to`, `background`, `isAllDay`.

- `calendar/lib/models/color_category.dart`
  - Model danh sách màu cho category.

- `calendar/lib/models/meeting_data_source.dart`
  - Adapter từ dữ liệu app sang `Syncfusion Calendar`.
  - Chứa:
    - `MeetingDataSource`
    - `Meeting`

### Services

- `calendar/lib/services/user_services.dart`
  - `login(email, password)`
  - `getUser(id)`
  - `register(fullName, email, password)`

- `calendar/lib/services/categori_service.dart`
  - `getListCategories(id)`
  - `getCategory(id)`
  - `createCategory(...)`
  - `editCategory(...)`
  - `deleteCategory(id)`
  - Tên file cũng đang bị typo: `categori`.

- `calendar/lib/services/task_service.dart`
  - `getListTasks(id)`

- `calendar/lib/services/color_service.dart`
  - `getListColor()`

### Screens

- `calendar/lib/screens/login_screen/login_screen.dart`
  - Form đăng nhập.
  - Gọi `login()`, lưu token + user id, rồi `context.go('/')`.

- `calendar/lib/screens/register_screen/register_screen.dart`
  - Form đăng ký.
  - Gọi `register()`, sau đó điều hướng về `/login`.

- `calendar/lib/screens/home_screen/home_screen.dart`
  - Màn hình chính.
  - Tải task theo `user_id`.
  - Chuyển `Task` sang `Meeting` để render bằng `SfCalendar`.
  - Có `AppDrawer` và `SheetBottom`.

- `calendar/lib/screens/add_category/add_catetory.dart`
  - Bottom sheet thêm category.
  - Tải danh sách màu, nhập tên/mô tả, gọi `createCategory`.
  - Tên file/class path đang typo: `catetory`.

- `calendar/lib/screens/detail_category/detail_category.dart`
  - Bottom sheet chi tiết category.
  - Tải category theo `id`, hỗ trợ sửa và xóa.

- `calendar/lib/screens/settings_screen/settings_screen.dart`
  - Trang cài đặt placeholder, chưa có logic thật.

### Widgets dùng chung

- `calendar/lib/widget/drawer/app_draw.dart`
  - Drawer chính.
  - Gồm `ProfileHeader`, `MyCalendar`, nút thêm category, `Logout`.

- `calendar/lib/widget/profile_header/profile_header.dart`
  - Tải user hiện tại và hiển thị avatar chữ cái đầu, tên, email.
  - Có nút đi tới `/settings`.

- `calendar/lib/widget/my_calendar/my_calendar.dart`
  - Tải danh sách category của user.
  - Hiển thị từng category trong drawer.
  - Chạm vào category để mở `DetailCategoryScreen`.

- `calendar/lib/widget/sheet_bottom/sheet_bottom.dart`
  - Bottom panel dưới cùng của `HomeScreen`.
  - Hiện đang là UI tĩnh, chưa có logic thêm appointment.

- `calendar/lib/widget/logout/logout.dart`
  - Xóa token + user id, rồi điều hướng về `/login`.

- `calendar/lib/widget/back_home/back_home.dart`
  - Nút quay về home bằng `context.go('/')`.

- `calendar/lib/widget/drag_handle/drag_handle.dart`
  - Thanh kéo nhỏ dùng cho các bottom sheet.

## 5. Map tính năng theo file

### Authentication

- `calendar/lib/screens/login_screen/login_screen.dart`
- `calendar/lib/screens/register_screen/register_screen.dart`
- `calendar/lib/services/user_services.dart`
- `calendar/lib/helpers/token.dart`
- `calendar/lib/router/router.dart`

### Calendar/task display

- `calendar/lib/screens/home_screen/home_screen.dart`
- `calendar/lib/models/task.dart`
- `calendar/lib/models/meeting_data_source.dart`
- `calendar/lib/services/task_service.dart`
- `calendar/lib/helpers/get_color.dart`

### Category management

- `calendar/lib/widget/my_calendar/my_calendar.dart`
- `calendar/lib/screens/add_category/add_catetory.dart`
- `calendar/lib/screens/detail_category/detail_category.dart`
- `calendar/lib/services/categori_service.dart`
- `calendar/lib/services/color_service.dart`
- `calendar/lib/models/categories.dart`
- `calendar/lib/models/color_category.dart`

### Shared UI

- `calendar/lib/widget/drawer/app_draw.dart`
- `calendar/lib/widget/profile_header/profile_header.dart`
- `calendar/lib/widget/logout/logout.dart`
- `calendar/lib/widget/back_home/back_home.dart`
- `calendar/lib/widget/drag_handle/drag_handle.dart`
- `calendar/lib/widget/sheet_bottom/sheet_bottom.dart`

## 6. Điểm cần lưu ý khi đọc source

- App đang phụ thuộc vào IP cứng `192.168.80.1:3002`, nên đổi mạng là có thể gọi API lỗi.
- Có nhiều typo trong tên file/package nội bộ như `calender`, `catetory`, `generrate_teken`, `categori_service`.
- `settings_screen.dart` mới là placeholder.
- `sheet_bottom.dart` chưa có chức năng tạo lịch thật.
- Repo hiện có thay đổi sẵn trong `database/node_modules`; đó không phải phần source business chính.

## 7. File nên đọc đầu tiên

Nếu muốn onboard nhanh, nên đọc theo thứ tự:

1. `calendar/lib/main.dart`
2. `calendar/lib/router/router.dart`
3. `calendar/lib/screens/login_screen/login_screen.dart`
4. `calendar/lib/screens/home_screen/home_screen.dart`
5. `calendar/lib/widget/drawer/app_draw.dart`
6. `calendar/lib/widget/my_calendar/my_calendar.dart`
7. `calendar/lib/screens/add_category/add_catetory.dart`
8. `calendar/lib/screens/detail_category/detail_category.dart`
9. `calendar/lib/utils/request.dart`
10. `database/database.json`
