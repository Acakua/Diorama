# Thiết kế lại UI/UX — Đảo Cối Nước v2 (2026-11-27)

Người dùng giao: học cách thiết kế theo `Tự thiết kế game.pdf`, tìm tài liệu, tự quyết, cho worker
làm, tự duyệt. Tài liệu này đi đúng quy trình của PDF: **tham khảo → phân tích → phân cấp →
wireframe → màu, chữ, thành phần → đưa vào game → tự phê bình bằng ảnh**.

## 1. Tham khảo và rút ra gì

| Nguồn | Rút ra cho đảo |
|---|---|
| Stardew Valley (HUD) | Một cụm nhỏ ở góc gom ngày, mùa, thời tiết, giờ, tiền; phần còn lại để thế giới. Bảng lớn mở đè lên giữa và có tab. HUD được khen "không chen" nhưng đủ thông tin cần canh. |
| Dorfromantik | Ít chữ, ít khung; nhiệm vụ đặt ngay trên bàn chơi, đếm được ("cần 30 cây"). Tối giản là trụ cột, mọi tính năng mới phải qua trụ cột đó. |
| Bài "coziness" (Kitfox, 80.lv, SDLC) | Màu dịu, tương phản mềm cho cảnh; hiện ít thông tin cùng lúc; thống nhất phong cách; nhắc bằng gợi ý nhỏ thay vì hộp thoại. |
| Game idle (welcome back) | Màn "trong lúc bạn vắng" nên ngắn, đọc lướt được: đi bao lâu, được gì; không bắt chờ. |
| Unity / Toptal / Gamedeveloper (HUD) | HUD trả lời 3 câu: đang ở đâu, đang làm gì, sắp gặp gì. Rối không chỉ xấu mà làm hỏng chức năng. Trạng thái quan trọng đặt nơi mắt dừng tự nhiên. |
| Game Accessibility Guidelines, Xbox XAG 101/102 | Chữ mặc định dễ đọc; tương phản chữ ≥ 4.5:1 (chữ lớn ≥ 3:1), đo ở chỗ nền kém tương phản nhất; trên nền 3D dùng bóng chữ hoặc nền đặc. |

Nguồn: gamedeveloper.com (Dorfromantik, HUD), 80.lv, medium.com/kitfox-games, unity.com/blog
(UI/UX basics, accessibility basics), toptal.com (game UI), learn.microsoft.com (XAG 101, 102),
gameaccessibilityguidelines.com.

## 2. Phân tích bản hiện tại (ảnh 1600×900, 1280×720, 375 px)

Theo 6 công cụ phân cấp của PDF (kích thước, tương phản, màu, vị trí, khoảng trống, hình dạng):

1. **Kích thước:** 11 nút trên cùng to như nhau → không nút nào là hành động chính. Nút "Sổ của
   Mun" (cửa vào toàn bộ game) bằng nút "Nạp mô hình VRoid khác" (nút thử nghiệm).
2. **Màu:** vàng hổ phách dùng cho mọi nút đang bật (Mũ, Góc neo, tab, 1×) và cũng cho hành động
   "Gửi hàng", "Nhận quà". Như PDF nói: *nếu nút nào cũng đỏ thì đỏ hết nghĩa*. Vàng phải có lý do.
3. **Vị trí:** tài nguyên, đơn, giờ tới đêm nằm sâu trong sổ → màn chính không trả lời "tôi có gì,
   sắp có gì". Góc trên trái bị dòng gợi ý dài và "30 khung hình/giây" chiếm.
4. **Khoảng trống:** sổ 352 px che đảo và che 3 nút ở 1280 px; tab Buôn bán dài 1000 px; mỗi mục có
   đoạn giải thích dài.
5. **Phản hồi:** thông báo game (đơn mới, nấu xong) thay chỗ lời kể của Linh ở dưới → mất giọng kể;
   đêm và bình minh chỉ là chữ nhỏ ở góc.
6. **Thao tác:** lý do nút khóa chỉ nằm trong `title` (không thấy khi chạm, khi dùng phím);
   thanh kéo giờ cho nhảy qua cả đêm; thiếu `meta viewport` nên điện thoại vẽ như màn 980 px.

## 3. Phân cấp (3 tầng)

| Tầng | Thành phần | Cách làm nổi |
|---|---|---|
| 1 — thấy ngay | Hòn đảo (trung tâm); đồng hồ + lời kể của Linh (dưới trái); nút **Sổ của Mun** có chấm báo | Đảo chiếm khoảng trống; đồng hồ serif lớn; Sổ là nút lớn nhất, có nhãn và biểu tượng |
| 2 — dễ tìm | Dải tài nguyên (xu, tinh thể, 5 món kho); "sắp tới" (đơn chờ, giờ tới đêm); tốc độ thời gian; băng đêm khi đánh | Góc trên trái, chữ số serif, cỡ vừa; băng đêm giữa trên |
| 3 — nhỏ | Nhật ký, 4 nút camera, ⚙ cài đặt (mùa/thời tiết, âm thanh, hiệu năng, VRoid, mũ, chế độ ngắm), ? hướng dẫn | Nút vuông nhỏ chỉ biểu tượng + `aria-label` + `title`; gom một cụm |

## 4. Wireframe (1920×1080, chỉ khối)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ [Thứ Hai · ngày 15 · hạ · nắng]               [ĐÊM 12 · Sóng 3/6 ▬▬▬▬▬ ]     [📖 Sổ của Mun •][Nhật ký] │
│ [◉ 462 xu][✦ 227][củi 6/30 bí 3 cá 4 trứng 7 thuốc 0]   (toast)    [⚓][🎬][👣][⌂] [?][⚙] │
│ [Sắp tới: 2 đơn chờ · đêm sau 10 giờ]                      (toast)                ┌──────────┐│
│                                                                                   │ SỔ (5 tab)││
│                               HÒN ĐẢO                                             │ ~420 px   ││
│                                                                                   │           ││
│ 10:32  Linh đang quét nhà, bụi bay lấp lánh.                                       │           ││
│ [Dừng][1×][6×][30×]                                                               └──────────┘│
└──────────────────────────────────────────────────────────────────────────────┘
```
- Trên trái: **thẻ trạng thái** (ngày/mùa/thời tiết, dải tài nguyên, dòng "Sắp tới").
- Giữa trên: **băng đêm** (chỉ khi đánh) và **chồng toast** (tối đa 3, 4 giây) cho sự kiện game.
- Trên phải: hàng chính (Sổ, Nhật ký) rồi hàng phụ (camera, ?, ⚙).
- Phải: sổ rộng `clamp(380px, 28vw, 440px)`, bắt đầu dưới cụm nút, không che nút.
- Dưới trái: đồng hồ, lời kể (chỉ giọng Linh), tốc độ. Thanh kéo giờ chuyển vào ⚙ → "Chế độ ngắm".
- Dưới 700 px: sổ thành tấm trượt từ dưới (cao 70vh), cụm nút chỉ còn biểu tượng.

## 5. Màu, chữ, hình dạng (giữ art bible §7, chỉ siết quy tắc)

- **Vàng `--glass-on` chỉ cho 3 việc:** hành động nên làm ngay (Gửi hàng, Nhận quà, Mua/Nâng khi đủ
  tiền, Đã hiểu), chấm báo, tab đang chọn. Nút bật/tắt (camera, tốc độ, mũ…) khi bật dùng kiểu
  **"ấn chìm"**: nền `#f4efe21f`, viền `--ink-dim`, chữ `--ink`, gạch chân 2 px vàng ở đáy.
- Nút phụ: kính mờ như cũ. Nút khóa: mờ 45 % **và** hiện lý do bằng chữ nhỏ ngay dưới.
- Chữ: số liệu HUD và tiêu đề dùng Literata (giọng sổ tay); nhãn, nút dùng Be Vietnam Pro.
  Cỡ tối thiểu 12 px (bỏ 10.5–11.5 px), nội dung sổ 13–14 px. Số luôn `tabular-nums`.
- Hình: bo 3 px như cũ; chấm báo tròn; biểu tượng là SVG nét 1.6 px, 18 px, cùng một bộ.
- Tương phản: chữ HUD trên cảnh 3D có `text-shadow` hoặc nền kính `#14201fd9`; đạt ≥ 4.5:1.

## 6. Thành phần

- **Thẻ trạng thái:** nền kính, 1 dòng ngày (12 px), 1 hàng "chip" tài nguyên (biểu tượng + số
  serif 16 px), 1 dòng "Sắp tới" (12 px, dim). Số đổi thì nháy "+n" bay lên 0.8 s.
- **Toast:** kính đặc, viền trái 3 px màu theo loại (vàng: tiền/quà; tím `#b79bff`: đêm/tinh thể;
  kem: thường), 13 px, tự tắt 4 s, `aria-live="polite"`. `note()` vẫn ghi nhật ký như cũ.
- **Băng đêm:** 260 px, "Đêm 12 · Sóng 3/6", thanh vòm 6 px, "Tan 14 · +14 tinh thể".
  Bình minh: một toast lớn 8 s "Bình minh: vòm giữ vững · 23 ma sương tan · +51 tinh thể".
- **Sổ, 5 tab:** Hôm nay (mục tiêu, việc hôm nay, nhờ Linh) · Buôn bán (đơn, thuyền chợ) · Bếp
  (chạn, hàng nấu, công thức, bữa tối) · Nâng cấp · Phòng thủ (thẻ vòm và 3 tháp với chấm cấp
  ●●●○○, chọn bùa). Đoạn giải thích dài gom vào `<details>` "Cách tính" đóng sẵn. Kho chung rời khỏi
  sổ (đã ở HUD).
- **Cụm ⚙:** một menu thả (role="menu") gồm: Mùa và thời tiết, Âm thanh, Hiệu năng, Mở mái nhà,
  Chế độ ngắm (hiện thanh kéo giờ), Mũ phù thủy, Nạp mô hình VRoid khác.
- **?:** popover chứa các dòng gợi ý điều khiển (kéo xoay, cuộn zoom, nhấp đúp, H ẩn chữ) và nút
  "Xem lại cách chơi" (mở thẻ hướng dẫn của sổ).

## 7. Chia việc cho worker

| Mã | Phạm vi | Brief |
|---|---|---|
| UX1 | Quy tắc màu nút bật, thẻ trạng thái + Sắp tới, thanh nút mới, menu ⚙, popover ?, ẩn fps, meta viewport | `production/briefs/UX1-hud.md` |
| UX2 | Sổ: vị trí/kích thước, 5 tab, `<details>`, lý do khóa hiện chữ, thẻ phòng thủ, vàng chỉ cho hành động | `production/briefs/UX2-ledger.md` |
| UX3 | Toast, băng đêm giữa trên, thẻ bình minh, chế độ ngắm, tấm trượt dưới 700 px | `production/briefs/UX3-feedback.md` |

## 8. Tiêu chí tự duyệt (thang điểm của PDF)

Chụp 1600×900, 1280×720 và 375×812, ngày và đêm, rồi chấm: phân cấp 30, bố cục 25, khoảng cách
và căn lề 20, rõ chức năng 15, nhất quán 10. Đạt khi ≥ 80 và:
- Nhìn 2 giây biết: mấy giờ, có bao nhiêu xu, có việc gì chờ (chấm báo), đêm còn bao lâu.
- Sổ mở không che nút nào; ở 1280×720 đảo vẫn thấy trọn bên trái.
- Vàng chỉ xuất hiện ở hành động/chấm báo/tab chọn.
- Không lỗi console; `check-page` 0 failed.
