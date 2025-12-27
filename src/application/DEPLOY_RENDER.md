# Hướng Dẫn Deploy Lên Render

Tài liệu này hướng dẫn chi tiết cách deploy ứng dụng (Client & Server) lên [Render](https://render.com) sử dụng file cấu hình `render.yaml` đã được tạo sẵn.

## 1. Chuẩn Bị

*   **Tài khoản Render**: Đăng ký tại [render.com](https://dashboard.render.com).
*   **Git Repository**: Đảm bảo code của bạn đã được push lên GitHub hoặc GitLab/Bitbucket.
*   **Database**: Bạn đang sử dụng Supabase (PostgreSQL). Đảm bảo bạn có `DATABASE_URL` (Connection String) của database.

## 2. Cấu Trúc Deploy

Chúng ta sẽ deploy 2 dịch vụ riêng biệt được định nghĩa trong file `render.yaml` tại thư mục gốc của dự án:

1.  **petcarex-server (Web Service)**: Backend Node.js.
2.  **petcarex-client (Static Site)**: Frontend React/Vite.

Render sẽ tự động liên kết biến môi trường `VITE_API_URL` của Client trỏ tới URL của Server.

## 3. Các Bước Thực Hiện

### Bước 1: Kết nối Repository với Render

1.  Truy cập [Render Dashboard](https://dashboard.render.com).
2.  Chọn **New +** -> **Blueprint**.
3.  Kết nối với tài khoản GitHub/GitLab của bạn và chọn repository chứa code này (`petcarex-management`).
4.  Đặt tên cho Service instance (ví dụ: `petcarex-app`).

### Bước 2: Cấu hình Biến Môi Trường

Render sẽ tự động phát hiện file `render.yaml` và hiển thị các dịch vụ sẽ được tạo.
Bạn sẽ thấy mục yêu cầu nhập **Environment Variables** cho `petcarex-server`:

*   **DATABASE_URL**: Dán chuỗi kết nối PostgreSQL của bạn vào đây.
    *   *Lưu ý*: Lấy giá trị này từ file `.env` hiện tại của bạn (`src/application/server/.env`).
    *   Ví dụ: `postgresql://postgres.[user]:[password]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres`

### Bước 3: Apply Blueprint

*   Nhấn **Apply** hoặc **Create Blueprint**.
*   Render sẽ bắt đầu build cả 2 dịch vụ cùng lúc.

## 4. Kiểm Tra Trạng Thái

### Server (`petcarex-server`)
*   Theo dõi Logs của server để đảm bảo nó khởi động thành công (`Server running on port 10000`).
*   Nếu có lỗi kết nối Database, kiểm tra lại `DATABASE_URL`.

### Client (`petcarex-client`)
*   Client sẽ được build (`npm run build`) và publish thư mục `dist`.
*   Sau khi hoàn tất, Render sẽ cung cấp một URL (ví dụ: `https://petcarex-client.onrender.com`).

## 5. Truy Cập Ứng Dụng

*   Truy cập vào URL của **Client** do Render cung cấp.
*   Client sẽ tự động gọi API tới Server thông qua cấu hình `VITE_API_URL` đã được setup tự động.

## Lưu Ý Quan Trọng

*   **CORS**: Server đã được cấu hình `cors({ origin: '*' })` nên Client có thể gọi API bình thường.
*   **Build Lỗi**: Nếu Client build lỗi "Permission denied" với Vite, đoạn script build trong `package.json` đã được tôi sửa lại thành `vite build` chuẩn để khắc phục vấn đề này.
*   **Routes**: Nếu bạn refresh trang ở Client và gặp lỗi 404, hãy đảm bảo cấu hình "Rewrite Rules" trên Render (cho Static Site) nếu cần thiết. Tuy nhiên, với Vite SPA mặc định, thường Render xử lý khá tốt. Nếu cần, vào tab **Redirects/Rewrites** của service Client trên Render:
    *   Source: `/*`
    *   Destination: `/index.html`
    *   Status: `200`
    *   Action: `Rewrite`
