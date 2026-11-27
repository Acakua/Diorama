# UX3: thông báo, băng đêm, bình minh, chế độ ngắm, tấm trượt (2026-11-27)

Run result: OBSERVED, 3 vòng. Không lỗi console.

- `1280-night-toasts.jpg`: băng đêm giữa trên "Đêm 15 · Sóng 0/6" + thanh vòm; 2 toast (viền tím
  rgb(183,155,255) cho bình minh, vàng cho quà); dòng dưới vẫn là lời kể của Linh.
- `1280-viewing-mode.png`: thanh kéo giờ ẩn mặc định; bật "Chế độ ngắm" trong ⚙ thì hiện kèm nhãn,
  nhớ trong `localStorage['dao-view']`.
- `375-sheet-night.jpg`: điện thoại, sổ là tấm trượt (top 263) dưới băng đêm (193..263), băng đêm dưới
  hàng nút (đáy 185); đồng hồ ẩn khi tấm mở; tab cuộn ngang.
- `1280-night-defence.jpg`: đêm, 9 ma sương, sổ tab Phòng thủ.
- Vòng 2: từ khóa "xu" bắt nhầm "xuống"; băng đêm đè nút trên điện thoại. Vòng 3: `--toolbar-h` đo
  một lần lúc khởi động nên lệch 23 px; nay đo bằng ResizeObserver.

## Tự chấm theo thang của `Tự thiết kế game.pdf` (sau UX1–UX3)

| Tiêu chí | Điểm | Ghi chú |
|---|---|---|
| Hierarchy | 26/30 | Đảo giữa, đồng hồ + lời kể, nút Sổ nổi nhất; vàng chỉ cho hành động. Trừ: tab Phòng thủ có 4–5 nút vàng cùng lúc. |
| Composition | 21/25 | Bốn góc có vai trò rõ, giữa để trống cho đảo; sổ vẫn chiếm 1/3 phải khi mở. |
| Spacing & Alignment | 16/20 | Mọi dòng một khuôn; thẻ trạng thái hơi dày chữ ở 1280. |
| Functional clarity | 13/15 | 2 giây thấy giờ, xu, việc chờ, giờ tới đêm; lý do khóa hiện chữ. |
| Consistency | 9/10 | Một bộ biểu tượng nét, một kiểu nút bật, một kiểu dòng. |
| **Tổng** | **85/100** | Đạt (≥ 80). |

Việc nên làm sau: Gemini (art director, ≈03/12) duyệt màu và biểu tượng; gom nút "Nâng" của phòng thủ
thành một nút vàng cho món rẻ nhất.
