# Bằng chứng G6: tab sổ, chấm báo, HUD đêm, hướng dẫn lần đầu (2026-11-27)

Run result: OBSERVED (trang thật `?g6`, DOM + ảnh). Không lỗi console.

- `guide-home-tab.jpg`: lần đầu (`W.guide` chưa có) sổ tự mở, thẻ "Cách chơi" 5 dòng trên các tab,
  tab "Nhà" (kho chung, việc hôm nay). Tab "Buôn bán" có chấm báo vì có đơn gửi được.
- `trade-tab-night-hud.jpg`: tab "Buôn bán": mỗi đơn 3 dòng (người gửi, hàng cần, xu bên trái và
  "Gửi hàng" "×" bên phải, không xuống dòng lẻ). HUD đêm "Đêm 11 · Sóng 0/6" nằm dưới dòng gợi ý,
  `position: static`, trong `.hintWrap`, không chồng chữ.
- Tab: bấm "Buôn bán" thì chỉ `lPanel-trade` hiện, `aria-selected` đúng, `localStorage['dao-ledger-tab']`
  = `trade`; 4 nút là `<button>` (Tab/Enter/Space dùng được).
- Chấm báo: thêm một đơn gửi được → chấm trên `#bLedger` và tab "Buôn bán" sau ≤ 1 giây; mở tab
  "Buôn bán" → cả hai tắt. Thêm 1 món vào chạn → chấm bật lại.
- "Đã hiểu" ẩn thẻ và lưu `guide: 1` vào `dao-world`.
