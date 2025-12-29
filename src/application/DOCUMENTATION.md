# Tài Liệu Dự Án PetCareX Management

Tài liệu này mô tả cách cài đặt và các chức năng chính của dự án PetCareX Management nằm trong thư mục `src/application`.

## 1. Hướng Dẫn Cài Đặt (Installation)

Dự án được cấu trúc theo dạng Monorepo với `client` và `server` riêng biệt.

### Yêu cầu hệ thống
- **Node.js**: Phiên bản LTS mới nhất (Khuyên dùng v18+).
- **npm**: Trình quản lý gói.

### Các lệnh chính
Các lệnh sau nên được chạy tại thư mục `src/application`:

1.  **Cài đặt toàn bộ dependencies (Install)**:
    ```bash
    npm run install-all
    ```
    Lệnh này sẽ tự động cài dặt dependencies cho cả root, folder `client` và folder `server`.

2.  **Chạy môi trường phát triển (Development)**:
    ```bash
    npm run dev
    ```
    Lệnh này sử dụng `concurrently` để chạy song song:
    - **Server**: Tại cổng `5000` (có thể giám sát qua `node --watch`).
    - **Client**: Tại cổng mặc định của Vite (thường là `5173`).

3.  **Build dự án (Build)**:
    ```bash
    npm run build
    ```
    Lệnh này sẽ cài đặt và build client (Sử dụng Vite), đồng thời chuẩn bị cho server.

4.  **Chạy môi trường Production (Start)**:
    ```bash
    npm start
    ```
    Lệnh này sẽ khởi động server (chạy `server/index.js`). Trong môi trường này, server cũng sẽ serve các file tĩnh của client đã được build.

## 2. Công Nghệ Sử Dụng (Tech Stack)

### Client (Frontend)
- **Framework**: React (Vite)
- **Styling**: TailwindCSS, Material UI (MUI), Radix UI.
- **State/Data**: Axios, React Query (hoặc useEffect cơ bản).

### Server (Backend)
- **Runtime**: Node.js & Express.js
- **Database**: PostgreSQL (Supabase)
- **ORM**: Drizzle ORM
- **Authentication**: JWT/Supabase Auth (tùy cấu hình).

## 3. Các Chức Năng Chính (Features)

Dựa trên cấu trúc routes và client features, dự án bao gồm các module chức năng sau:

1.  **Dashboard (Bảng điều khiển)**
    - Xem tổng quan các chỉ số hoạt động.
    - Đường dẫn API: `/api/dashboard`

2.  **Quản lý Khách Hàng (Customers)**
    - Chức năng: Thêm, sửa, xóa, tìm kiếm thông tin khách hàng.
    - Đường dẫn API: `/api/customers`

3.  **Quản lý Thú Cưng (Pets)**
    - Chức năng: Quản lý hồ sơ thú cưng, lịch sử khám bệnh, tiêm phòng.
    - Đường dẫn API: `/api/pets`

4.  **Quản lý Sản Phẩm (Products)**
    - Chức năng: Quản lý kho hàng, danh sách sản phẩm, bán lẻ.
    - Đường dẫn API: `/api/products`

5.  **Quản lý Dịch Vụ (Services)**
    - Chức năng: Quản lý danh mục dịch vụ (Spa, khám bệnh, grooming).
    - Đường dẫn API: `/api/services`

6.  **Quản lý Nhân Sự (HR / Staff)**
    - Chức năng: Quản lý danh sách bác sĩ, nhân viên, phân quyền.
    - Đường dẫn API: `/api/staff`

7.  **Hệ Thống Xác Thực (Authentication)**
    - Chức năng: Đăng nhập, đăng ký, quản lý phiên làm việc.
    - Đường dẫn API: `/api/auth`
