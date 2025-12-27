USE PetCareX;
GO
-----------------------------------------------------------
-- 1. INSERT DANH MỤC CƠ BẢN (CHI NHÁNH, SẢN PHẨM, GÓI TIÊM)
-----------------------------------------------------------
INSERT INTO CHI_NHANH (TenCN, DiaChi, SDT, TGMoCua, TGDongCua) VALUES
(N'PetCareX Quận 5', N'227 Nguyễn Văn Cừ, P4, Q5, TP.HCM', '02838354266', '08:00', '20:00'),
(N'PetCareX Thủ Đức', N'Làng Đại Học, TP. Thủ Đức', '02837244270', '07:30', '21:00');

-- Dịch vụ
INSERT INTO DICH_VU (LoaiDV, MoTa) VALUES 
(N'Khám bệnh', N'Khám sức khỏe tổng quát'),
(N'Tiêm phòng', N'Tiêm vaccine'),
(N'Spa & Grooming', N'Cắt tỉa lông');

-- Dịch vụ cung cấp (Ghép tất cả chi nhánh với tất cả dịch vụ)
INSERT INTO DICH_VU_CUNG_CAP (MaCN, MaDV)
SELECT CN.MaCN, DV.MaDV FROM CHI_NHANH CN CROSS JOIN DICH_VU DV;

-- Hạng thành viên
INSERT INTO HANG_THANH_VIEN (TenHang, ChiTieuGiuHang, ChiTieuDatHang) VALUES 
(N'Cơ bản', 0, 0),
(N'Thân thiết', 3000000, 5000000),
(N'VIP', 8000000, 12000000);

-- Sản phẩm
INSERT INTO SAN_PHAM (TenSP, LoaiSP, GiaBan, SoLuongTonKho) VALUES
(N'Hạt Royal Canin Mini Adult (2kg)', N'Thức ăn', 350000, 100),
(N'Pate Me-O Cá Ngừ (80g)', N'Thức ăn', 15000, 500),
(N'Vòng cổ trị ve rận', N'Thuốc', 95000, 200);

-- Gói tiêm
INSERT INTO GOI_TIEM (TenGoi, ThoiGian, UuDai) VALUES
(N'Gói Tiêm Chó Con', 12, 10),
(N'Gói Tiêm Mèo Cơ Bản', 12, 5);
GO

-----------------------------------------------------------
-- 4. INSERT DỮ LIỆU ĐỘNG (NHÂN VIÊN, KHÁCH, THÚ CƯNG)
-----------------------------------------------------------
-- Block này chạy riêng, khai báo biến riêng
DECLARE @CN1 INT, @CN2 INT;
SELECT TOP 1 @CN1 = MaCN FROM CHI_NHANH WHERE TenCN LIKE N'%Quận 5%';
SELECT TOP 1 @CN2 = MaCN FROM CHI_NHANH WHERE TenCN LIKE N'%Thủ Đức%';

-- Nhân viên
INSERT INTO NHAN_VIEN (HoTen, NgaySinh, GioiTinh, SDT, LuongCoBan, ChucVu, MaCN) VALUES
(N'Nguyễn Văn A', '1990-01-01', N'Nam', '0901111111', 15000000, N'Quản lý', @CN1),
(N'Trần Thị B', '1995-05-15', N'Nữ', '0902222222', 20000000, N'Bác sĩ', @CN1),
(N'Lê Văn C', '1998-08-20', N'Nam', '0903333333', 8000000, N'Bán hàng', @CN1),
(N'Hoàng Văn E', '1992-03-03', N'Nam', '0905555555', 22000000, N'Bác sĩ', @CN2);

-- Khách hàng
INSERT INTO KHACH_HANG (TenKH, SDT, Email, CCCD, GioiTinh, NgaySinh, DiemLoyalty, MaHang) VALUES
(N'Huỳnh Văn Sinh', '0912345678', 'sinh@email.com', '079123456789', N'Nam', '2003-01-01', 100, 1),
(N'Tô Trần Hoàng Triệu', '0987654321', 'trieu@email.com', '079987654321', N'Nam', '2003-02-02', 500, 2);

-- Thú cưng (Phải lấy ID khách hàng vừa tạo)
DECLARE @KH1 INT = (SELECT MaKH FROM KHACH_HANG WHERE SDT = '0912345678');
DECLARE @KH2 INT = (SELECT MaKH FROM KHACH_HANG WHERE SDT = '0987654321');

INSERT INTO THU_CUNG (TenTC, Loai, Giong, NgaySinh, GioiTinh, TinhTrangSucKhoe, MaKH) VALUES
(N'Mimi', N'Mèo', N'Anh Lông Ngắn', '2023-01-01', N'Cái', N'Bình thường', @KH1),
(N'Lu', N'Chó', N'Poodle', '2022-06-01', N'Đực', N'Viêm da nhẹ', @KH1),
(N'Kiki', N'Chó', N'Corgi', '2021-12-12', N'Đực', N'Khỏe mạnh', @KH2);
GO 

-----------------------------------------------------------
-- 5. INSERT GIAO DỊCH 1: KHÁM BỆNH & MUA HÀNG
-----------------------------------------------------------
-- Block mới, reset lại biến, không sợ lỗi trùng tên
DECLARE @CN1 INT = (SELECT TOP 1 MaCN FROM CHI_NHANH WHERE TenCN LIKE N'%Quận 5%');
DECLARE @KH1 INT = (SELECT TOP 1 MaKH FROM KHACH_HANG WHERE SDT = '0912345678');
DECLARE @NV_BanHang INT = (SELECT TOP 1 MaNV FROM NHAN_VIEN WHERE ChucVu = N'Bán hàng' AND MaCN = @CN1);
DECLARE @BS INT = (SELECT TOP 1 MaNV FROM NHAN_VIEN WHERE ChucVu = N'Bác sĩ' AND MaCN = @CN1);
DECLARE @TC_Mimi INT = (SELECT TOP 1 MaTC FROM THU_CUNG WHERE TenTC = N'Mimi');

-- A. Tạo Hóa đơn
INSERT INTO HOA_DON (NgayLap, TongTien, HinhThucThanhToan, MaCN, MaKH, MaNV) 
VALUES (GETDATE(), 0, N'Tiền mặt', @CN1, @KH1, @NV_BanHang);

DECLARE @MaHD1 INT = SCOPE_IDENTITY(); -- Lưu ID hóa đơn ngay

-- B. Thêm Sản phẩm
DECLARE @SP1 INT = (SELECT TOP 1 MaSP FROM SAN_PHAM WHERE TenSP LIKE N'%Royal Canin%');
DECLARE @GiaSP1 DECIMAL(18,0) = (SELECT GiaBan FROM SAN_PHAM WHERE MaSP = @SP1);
INSERT INTO CT_HOA_DON_SP (MaHD, MaSP, SoLuong, DonGia) VALUES (@MaHD1, @SP1, 2, @GiaSP1);

-- C. Thêm Dịch vụ Khám
DECLARE @DV_Kham INT = (SELECT MaDV FROM DICH_VU WHERE LoaiDV LIKE N'%Khám bệnh%');
INSERT INTO CT_HOA_DON_DV (MaHD, MaDV, DonGia) VALUES (@MaHD1, @DV_Kham, 200000);

DECLARE @MaHDDV_Kham INT = SCOPE_IDENTITY(); -- Lưu ID dòng dịch vụ ngay

-- D. Thêm Chi tiết Khám
INSERT INTO TT_KHAM_BENH (MaHDDV, TrieuChung, ChuanDoan, ToaThuoc, NgayHenTaiKham, MaTC, BSPhuTrach)
VALUES (@MaHDDV_Kham, N'Bỏ ăn', N'Rối loạn tiêu hóa', N'Men tiêu hóa', DATEADD(DAY, 7, GETDATE()), @TC_Mimi, @BS);

-- E. Cập nhật tổng tiền
UPDATE HOA_DON SET TongTien = (2 * @GiaSP1) + 200000 WHERE MaHD = @MaHD1;
GO

-----------------------------------------------------------
-- 6. INSERT GIAO DỊCH 2: TIÊM PHÒNG
-----------------------------------------------------------
-- Block mới tiếp
DECLARE @CN1 INT = (SELECT TOP 1 MaCN FROM CHI_NHANH WHERE TenCN LIKE N'%Quận 5%');
DECLARE @KH2 INT = (SELECT TOP 1 MaKH FROM KHACH_HANG WHERE SDT = '0987654321');
DECLARE @NV_BanHang INT = (SELECT TOP 1 MaNV FROM NHAN_VIEN WHERE ChucVu = N'Bán hàng' AND MaCN = @CN1);
DECLARE @BS INT = (SELECT TOP 1 MaNV FROM NHAN_VIEN WHERE ChucVu = N'Bác sĩ' AND MaCN = @CN1);
DECLARE @TC_Kiki INT = (SELECT TOP 1 MaTC FROM THU_CUNG WHERE TenTC = N'Kiki');

-- A. Tạo Hóa đơn
INSERT INTO HOA_DON (NgayLap, TongTien, HinhThucThanhToan, MaCN, MaKH, MaNV) 
VALUES (GETDATE(), 0, N'Chuyển khoản', @CN1, @KH2, @NV_BanHang);

DECLARE @MaHD2 INT = SCOPE_IDENTITY();

-- B. Thêm Dịch vụ Tiêm
DECLARE @DV_Tiem INT = (SELECT MaDV FROM DICH_VU WHERE LoaiDV LIKE N'%Tiêm phòng%');
INSERT INTO CT_HOA_DON_DV (MaHD, MaDV, DonGia) VALUES (@MaHD2, @DV_Tiem, 150000);

DECLARE @MaHDDV_Tiem INT = SCOPE_IDENTITY();

-- C. Thêm Chi tiết Tiêm
INSERT INTO TT_TIEM_PHONG (MaHDDV, LoaiVacXin, LieuLuong, MaTC, NguoiTiem)
VALUES (@MaHDDV_Tiem, N'Rabisin', N'1 liều', @TC_Kiki, @BS);

-- D. Cập nhật tổng tiền
UPDATE HOA_DON SET TongTien = 150000 WHERE MaHD = @MaHD2;
GO

PRINT N'=== HOÀN TẤT: ĐÃ TẠO DB VÀ THÊM DỮ LIỆU THÀNH CÔNG ===';