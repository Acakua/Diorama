# Bằng chứng G5a: luật giữ đảo ban đêm (2026-11-27)

Run result: OBSERVED (logic và giao diện sổ; hình 3D là G5b). Không lỗi console.

- `ledger-defence-round1.jpg`: mục "Phòng thủ" ở vòng 1 (giá vòng 1; vòng 2 đổi giá sang bậc hai,
  tối đa tháp 10, vòm 12, thêm "Mức ma sương").
- Trận thật ở 6×: `startNight()` → sau 20 giây thật: sóng 3/6, 9 ma sương tan, HUD
  "Đêm 2 · Sóng 3/6 / Tan: 9 · +9 tinh thể", 33 sự kiện FX.

## Cân bằng (vòng 2, code thật trong trang, `simNight` 56 đêm, 45 xu/ngày, mua tham lam)

| Mua sắm | 28 đêm đầu | 28 đêm sau | Giữ được | Cuối kỳ |
|---|---|---|---|---|
| mỗi sáng | HHHHHHHHHHHHHHHHLHHLHHHLHHHL | HLLLHLLHLHLHHHHLLHHLHHHHHLHL | 40/56 | mức 24, vòm 7, tháp 7/7/7 |
| 3 ngày một lần | HHHHHLHHHHHHHHLHHHLLHHHLLHHH | HHHLHHHLHHHHHLHLLLHHLLLLHLHH | 39/56 | mức 22 |
| 7 ngày một lần | HHHLHLHHHHHHHHHHHHLHHHHHLHLH | HHLHLHHLHHLLHLHLHLHLHHHLLHHH | 40/56 | mức 24 |

Mức ma sương tăng khi giữ, giảm khi thua, nên lâu dài tự cân ở khoảng 70 % đêm giữ được; chưa
ai chạm trần nâng cấp sau 56 đêm. Vòng 1 (hệ số cũ) thua từ đêm 4 nếu không nâng cấp và chạm trần
ở đêm ~15, nên đã trả về với 6 điểm (`.orchestra/fb_G5a.txt`).
