# Bằng chứng G1: đơn hàng hạc giấy (2026-11-27)

`ledger-orders.jpg`: Sổ của Mun với hai đơn; đơn thiếu hàng có nút "Gửi hàng" mờ.
Run result: OBSERVED, không lỗi console.

Thử bằng `__dao` và bấm thật:
- `newDay()` ×3: đơn quá 2 ngày bị bỏ, luôn có 1–2 đơn, không trùng mẫu.
- Gửi đơn cá (4 cá, 29 xu): cá 10 → 6, xu 0 → 29; gọi `send` với chỉ số sai không làm gì.
- Bấm "Gửi hàng" đơn Tiệm trà: thuốc 1 → 0, trứng 10 → 8, xu 29 → 57, nhật ký ghi đúng câu.
- Lý do thiếu: "Còn thiếu 2 chai thuốc". Lưu: `orders`, `orderN`, `coins` có trong `dao-world`.

Còn nhỏ: nút × của đơn dài xuống dòng riêng (để vòng UI sau).
