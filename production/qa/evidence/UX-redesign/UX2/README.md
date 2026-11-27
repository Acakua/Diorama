# UX2: Sổ của Mun (2026-11-27)

Run result: OBSERVED, 3 vòng. Không lỗi console.

- `1280-today-r1.jpg`: sổ rộng 414 px, bắt đầu ngay dưới hàng nút (top 102), không che nút nào
  (kiểm bằng getBoundingClientRect). Vòng 1 tab thứ 5 rớt dòng.
- `900-trade-r2.jpg`: mọi dòng dùng chung một kiểu (tên · giá/quà bên phải · chi tiết · lý do khóa ·
  nút bên phải). Vòng 1 tên người gửi bị bóp mỗi dòng một chữ.
- `900-defence-r2.png`: thẻ vòm và 3 tháp có chấm cấp, bùa thành hàng "Mưa sao"/"Sương giá" có nút mở.
- `900-today.jpg` (vòng 3): 5 tab một hàng (#lTabs 380/380), không còn thanh cuộn ngang; vàng chỉ ở
  tab đang chọn và "Nhận quà"; đoạn giải thích gom vào "Cách tính".
- Chiều cao nội dung ở 1280×720: Hôm nay 600, Buôn bán 931 (trước 1001), Bếp 600, Nâng cấp 600,
  Phòng thủ 621. `localStorage['dao-ledger-tab']='home'` cũ đổi thành `today`.
