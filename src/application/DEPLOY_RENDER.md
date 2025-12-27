# Hướng Dẫn Deploy Lên Render (Tích Hợp Một Dịch Vụ)

Tài liệu này hướng dẫn cách deploy cả Client và Server trong cùng **một Web Service** duy nhất lên [Render](https://render.com). Phương pháp này giúp quản lý đơn giản hơn, không cần cấu hình CORS hay link variable phức tạp.

## 1. Cấu Trúc Deploy Mới

Thay vì deploy 2 dịch vụ, chúng ta sử dụng cơ chế:
1.  **Server (Node.js)**: Chịu trách nhiệm chạy API **VÀ** phục vụ các file giao diện (Static files) của React sau khi build.
2.  **Client (React)**: Được build thành file tĩnh (`index.html`, `js`, `css`) và đặt vào thư mục mà Server có thể đọc được.

Tôi đã cấu hình lại:
*   File `package.json` gốc: Có lệnh `build` để tự động cài đặt thư viện và build Client.
*   Server: Tự động trỏ tới thư mục `client/dist` để hiển thị web.

## 2. Các Bước Thực Hiện

### Bước 1: Tạo Database (Supabase)
*   Như cũ, bạn cần có kết nối PostgreSQL từ Supabase.

### Bước 2: Tạo Mới Web Service trên Render

Bạn có thể dùng Blueprint (`render.yaml`) hoặc tạo thủ công (Manual). Cách dùng Blueprint là nhanh nhất.

**Cách 1: Sử dụng Blueprint (Khuyên dùng)**
1.  Vào [Render Dashboard](https://dashboard.render.com).
2.  Chọn **New +** -> **Blueprint**.
3.  Chọn repo `petcarex-management`.
4.  Render tìm thấy file `render.yaml` và sẽ đề xuất tạo service `petcarex-app`.
5.  Nhập giá trị cho biến môi trường `DATABASE_URL` (Connection string từ Supabase).
6.  Nhấn **Apply**.

**Cách 2: Cấu hình Thủ Công (Manual)**
Nếu bạn muốn tạo thủ công, hãy chọn **New Web Service** và điền:
*   **Name**: `petcarex-app`
*   **Root Directory**: `src/application` (Quan trọng!)
*   **Environment**: `Node`
*   **Build Command**: `npm run build`
*   **Start Command**: `npm start`
*   **Environment Variables**:
    *   `DATABASE_URL`: [Your Connection String]
    *   `NODE_ENV`: `production`

### Bước 3: Kiểm Tra

1.  Chờ Render chạy lệnh Build (sẽ mất vài phút để install và build React).
2.  Khi hoàn tất, truy cập vào đường link `https://[your-app].onrender.com`.
3.  Bạn sẽ thấy giao diện React hiện lên. Khi đăng nhập/gọi API, nó sẽ gọi trực tiếp vào chính domain đó (ví dụ `/api/auth/login`) và Server sẽ xử lý thành công.

## Giải Thích Thay Đổi

*   **Server Code**: Đã sửa để đọc file tĩnh từ thư mục `../client/dist`.
*   **Package.json**: Script `build` sẽ chạy lần lượt: `npm install` (client) -> `npm run build` (client) -> `npm install` (server).
*   **Routing**: Mọi đường dẫn không phải API sẽ trả về `index.html` của React, giúp React Router hoạt động bình thường kể cả khi reload trang.
