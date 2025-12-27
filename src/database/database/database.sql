USE master;
GO

-- 1. XÓA DB CŨ NẾU TỒN TẠI (Làm sạch hoàn toàn)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'PetCareX')
BEGIN
    ALTER DATABASE PetCareX SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PetCareX;
END
GO

-- 2. TẠO DATABASE MỚI
CREATE DATABASE PetCareX;
GO
USE PetCareX;
GO

-----------------------------------------------------------
-- PHẦN 1: CÁC BẢNG DANH MỤC (MASTER DATA)
-----------------------------------------------------------

-- 1.1. Bảng Hạng Thành Viên
CREATE TABLE HANG_THANH_VIEN (
    MaHang INT IDENTITY(1,1) PRIMARY KEY,
    TenHang NVARCHAR(50) NOT NULL, -- Cơ bản, Thân thiết, VIP
    ChiTieuGiuHang DECIMAL(18,0) DEFAULT 0,
    ChiTieuDatHang DECIMAL(18,0) DEFAULT 0
);

-- 1.2. Bảng Chi Nhánh
CREATE TABLE CHI_NHANH (
    MaCN INT IDENTITY(1,1) PRIMARY KEY,
    TenCN NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255),
    SDT VARCHAR(15),
    TGMoCua TIME,
    TGDongCua TIME
);

-- 1.3. Bảng Dịch Vụ (Danh mục loại dịch vụ)
CREATE TABLE DICH_VU (
    MaDV INT IDENTITY(1,1) PRIMARY KEY,
    LoaiDV NVARCHAR(100) NOT NULL, -- Ví dụ: Khám bệnh, Tiêm phòng, Spa...
    MoTa NVARCHAR(255)
);

-- 1.4. Bảng Dịch Vụ Cung Cấp (Chi nhánh nào có dịch vụ nào)
CREATE TABLE DICH_VU_CUNG_CAP (
    MaCN INT,
    MaDV INT,
    TrangThai BIT DEFAULT 1, -- 1: Đang hoạt động, 0: Ngưng
    PRIMARY KEY (MaCN, MaDV),
    FOREIGN KEY (MaCN) REFERENCES CHI_NHANH(MaCN),
    FOREIGN KEY (MaDV) REFERENCES DICH_VU(MaDV)
);

-- 1.5. Bảng Gói Tiêm
CREATE TABLE GOI_TIEM (
    MaGoi INT IDENTITY(1,1) PRIMARY KEY,
    TenGoi NVARCHAR(100) NOT NULL,
    ThoiGian INT, -- Số tháng hiệu lực
    UuDai INT CHECK (UuDai >= 0 AND UuDai <= 100) -- Phần trăm ưu đãi
);

-- 1.6. Bảng Sản Phẩm
CREATE TABLE SAN_PHAM (
    MaSP INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    LoaiSP NVARCHAR(50), -- Thức ăn, Phụ kiện, Thuốc...
    GiaBan DECIMAL(18,0) NOT NULL CHECK (GiaBan >= 0),
    SoLuongTonKho INT DEFAULT 0 CHECK (SoLuongTonKho >= 0)
);

-----------------------------------------------------------
-- PHẦN 2: QUẢN LÝ NHÂN SỰ & KHÁCH HÀNG
-----------------------------------------------------------

-- 2.1. Bảng Nhân Viên (Gộp chung tất cả vai trò)
CREATE TABLE NHAN_VIEN (
    MaNV INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    SDT VARCHAR(15),
    NgayVaoLam DATE DEFAULT GETDATE(),
    LuongCoBan DECIMAL(18,0),
    -- Phân loại nhân viên để dễ dàng Partition sau này
    ChucVu NVARCHAR(50) CHECK (ChucVu IN (N'Bác sĩ', N'Tiếp tân', N'Bán hàng', N'Quản lý')), 
    MaCN INT,
    FOREIGN KEY (MaCN) REFERENCES CHI_NHANH(MaCN)
);

-- 2.2. Bảng Lịch Sử Điều Động
CREATE TABLE LICH_SU_DIEU_DONG (
    MaDD INT IDENTITY(1,1) PRIMARY KEY,
    NgayChuyen DATE DEFAULT GETDATE(),
    MaNV INT,
    MaCN_Cu INT,
    MaCN_Moi INT,
    LyDo NVARCHAR(255),
    FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV),
    FOREIGN KEY (MaCN_Cu) REFERENCES CHI_NHANH(MaCN),
    FOREIGN KEY (MaCN_Moi) REFERENCES CHI_NHANH(MaCN)
);

-- 2.3. Bảng Khách Hàng
CREATE TABLE KHACH_HANG (
    MaKH INT IDENTITY(1,1) PRIMARY KEY,
    TenKH NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) UNIQUE,
    Email VARCHAR(100),
    CCCD VARCHAR(20),
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    DiemLoyalty INT DEFAULT 0,
    MaHang INT DEFAULT 1, 
    FOREIGN KEY (MaHang) REFERENCES HANG_THANH_VIEN(MaHang)
);

-- 2.4. Bảng Thú Cưng
CREATE TABLE THU_CUNG (
    MaTC INT IDENTITY(1,1) PRIMARY KEY,
    TenTC NVARCHAR(50),
    Loai NVARCHAR(50), -- Chó, Mèo...
    Giong NVARCHAR(50),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    TinhTrangSucKhoe NVARCHAR(MAX),
    MaKH INT,
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH)
);

-----------------------------------------------------------
-- PHẦN 3: GIAO DỊCH (HÓA ĐƠN & CHI TIẾT)
-----------------------------------------------------------

-- 3.1. Bảng Hóa Đơn
CREATE TABLE HOA_DON (
    MaHD INT IDENTITY(1,1) PRIMARY KEY,
    NgayLap DATETIME DEFAULT GETDATE(),
    -- Tổng tiền có thể tính toán (Derived field), nhưng lưu lại để truy xuất nhanh
    TongTien DECIMAL(18,0) DEFAULT 0, 
    HinhThucThanhToan NVARCHAR(50),
    MaCN INT,
    MaKH INT,
    MaNV INT, -- Nhân viên lập hóa đơn
    FOREIGN KEY (MaCN) REFERENCES CHI_NHANH(MaCN),
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
    FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);

-- 3.2. Chi Tiết Hóa Đơn - Sản Phẩm (Bán hàng)
CREATE TABLE CT_HOA_DON_SP (
    MaHDSP INT IDENTITY(1,1) PRIMARY KEY,
    MaHD INT,
    MaSP INT,
    SoLuong INT CHECK (SoLuong > 0),
    DonGia DECIMAL(18,0), -- Giá chốt tại thời điểm bán
    ThanhTien AS (SoLuong * DonGia), -- Computed Column (Cột tính toán tự động)
    FOREIGN KEY (MaHD) REFERENCES HOA_DON(MaHD),
    FOREIGN KEY (MaSP) REFERENCES SAN_PHAM(MaSP)
);

-- 3.3. Chi Tiết Hóa Đơn - Dịch Vụ (Bảng Cha cho các dịch vụ)
-- CẬP NHẬT: Đã đưa MaDV và DonGia về đây để quản lý tập trung
CREATE TABLE CT_HOA_DON_DV (
    MaHDDV INT IDENTITY(1,1) PRIMARY KEY,
    MaHD INT,
    MaDV INT NOT NULL, -- Xác định đây là dịch vụ gì (Khám hay Tiêm...)
    DonGia DECIMAL(18,0) DEFAULT 0, -- Giá dịch vụ chốt tại thời điểm làm
    FOREIGN KEY (MaHD) REFERENCES HOA_DON(MaHD),
    FOREIGN KEY (MaDV) REFERENCES DICH_VU(MaDV)
);

-- 3.4. Thông Tin Khám Bệnh (Chi tiết chuyên môn - Extension của CT_HOA_DON_DV)
-- CẬP NHẬT: Đã bỏ cột DonGia ở đây để tránh dư thừa
CREATE TABLE TT_KHAM_BENH (
    MaLanKham INT IDENTITY(1,1) PRIMARY KEY,
    MaHDDV INT UNIQUE, -- 1 dòng hóa đơn chỉ ứng với 1 lần khám (1-1)
    NgayKham DATETIME DEFAULT GETDATE(),
    TrieuChung NVARCHAR(MAX),
    ChuanDoan NVARCHAR(MAX),
    ToaThuoc NVARCHAR(MAX),
    NgayHenTaiKham DATE,
    MaTC INT,
    BSPhuTrach INT, -- Bác sĩ thực hiện
    FOREIGN KEY (MaHDDV) REFERENCES CT_HOA_DON_DV(MaHDDV),
    FOREIGN KEY (MaTC) REFERENCES THU_CUNG(MaTC),
    FOREIGN KEY (BSPhuTrach) REFERENCES NHAN_VIEN(MaNV)
);

-- 3.5. Thông Tin Tiêm Phòng (Chi tiết chuyên môn - Extension của CT_HOA_DON_DV)
-- CẬP NHẬT: Đã bỏ cột DonGia ở đây
CREATE TABLE TT_TIEM_PHONG (
    MaLanTiem INT IDENTITY(1,1) PRIMARY KEY,
    MaHDDV INT UNIQUE, -- 1-1 relationship
    NgayTiem DATETIME DEFAULT GETDATE(),
    LoaiVacXin NVARCHAR(100),
    LieuLuong NVARCHAR(50),
    MaGoi INT NULL, -- Nếu dùng trong gói
    MaTC INT,
    NguoiTiem INT, -- Bác sĩ/Y tá
    FOREIGN KEY (MaHDDV) REFERENCES CT_HOA_DON_DV(MaHDDV),
    FOREIGN KEY (MaGoi) REFERENCES GOI_TIEM(MaGoi),
    FOREIGN KEY (MaTC) REFERENCES THU_CUNG(MaTC),
    FOREIGN KEY (NguoiTiem) REFERENCES NHAN_VIEN(MaNV)
);

-----------------------------------------------------------
-- PHẦN 4: ĐÁNH GIÁ & FEEDBACK
-----------------------------------------------------------

CREATE TABLE DANH_GIA (
    MaDG INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT,
    MaCN INT,
    NgayDanhGia DATETIME DEFAULT GETDATE(),
    DiemChatLuongDV INT CHECK (DiemChatLuongDV BETWEEN 1 AND 5),
    DiemThaiDoNV INT CHECK (DiemThaiDoNV BETWEEN 1 AND 5),
    MDHaiLongTT INT CHECK (MDHaiLongTT BETWEEN 1 AND 5),
    BinhLuan NVARCHAR(MAX),
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
    FOREIGN KEY (MaCN) REFERENCES CHI_NHANH(MaCN)
);
GO

