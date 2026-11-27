# Bằng chứng G4: bếp và chạn (2026-11-27)

Run result: OBSERVED (logic qua `__dao.kitchen` trên trang thật; ảnh giao diện). Không lỗi console.

- `ledger-kitchen.jpg`: mục "Bếp và chạn": chạn 4 món, hàng nấu "Súp bí · còn 53 phút",
  "chờ · Trứng chiên thảo mộc", nút "Súp bí · 1 bí, 1 củi"…, "Bữa tối trước đêm".
- Dặn nấu súp + trứng chiên: bí 5 → 4, củi 10 → 8, trứng 6 → 3 ngay lúc dặn.
- 70 bước `Kitchen.step(1)` (1,75 giờ đảo): chạn súp 1, trứng chiên 1; nhật ký "Linh nấu xong…".
- Chọn bữa tối súp, `startNight()`: buff `soup`, súp còn 0, `ate` = ngày 13; `begin(22)` (tải lại
  giữa đêm): buff vẫn `soup`, không ăn thêm.

Vòng 1 bị trả về: vòng rAF riêng cho bếp, nút thiếu tên món, `note` khi `simNight`, ăn lại khi tải lại.
Ghi chú: khung Browser bị hãm (2 rAF/2 giây) trong lúc thử nên thời gian được đẩy bằng `Kitchen.step`.
