# UX1: HUD (2026-11-27)

Run result: OBSERVED, 3 vòng. Không lỗi console.

- `1600-main.jpg`: thẻ trạng thái góc trái (ngày, xu, tinh thể, 5 món kho, "Sắp tới"), dòng gợi ý dài
  và "khung hình/giây" đã rời màn chính; hàng nút chính "Sổ của Mun" + "Nhật ký", hàng phụ chỉ biểu
  tượng (góc neo, góc phim, theo Linh, ?, ⚙). So với `../before/1600-main.jpg` (11 nút ngang hàng).
- `375-main.jpg`: có `meta viewport`, trang rộng đúng 375 px (trước: 980 px); thẻ trạng thái chỉ còn
  xu, tinh thể, "Sắp tới".
- `375-menu.jpg`: menu ⚙ (Mùa và thời tiết, Âm thanh, Hiệu năng, Mở mái nhà, Mũ phù thủy, Nạp VRoid),
  chữ căn trái, nằm trong màn (17..251 px). Popover ? 17..227 px. Ở 1600: ? 1316..1544, ⚙ 1350..1584.
- Menu: Esc đóng và trả focus về ⚙; mở "Mùa và thời tiết" thì menu tự đóng; mục bật/tắt có
  `menuitemcheckbox` + `aria-checked`.
- Vòng 2: popover ? tràn mép phải ở 1600 (1510..1738). Vòng 3: tràn ở 375.
