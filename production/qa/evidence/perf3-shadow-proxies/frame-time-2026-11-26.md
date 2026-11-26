# Đo thời gian khung PERF1–PERF3 khi máy rảnh (2026-11-26, 23:35)

So hai bản: **trước** = `2f4c879` (trước PERF1), **sau** = `5de6df0` (sau PERF1+2+3).
Đo lần lượt trong khung Browser của Claude, canvas giả lập 1920×1080, cùng góc
`setView([14,13,16],[0,0.8,0])`, 12:00, trời quang, mức chất lượng ghim bằng `perf.setQ`.
League đã tắt; Wallpaper Engine vẫn chạy (card nghỉ ~37 W, 28 %).

## CPU mỗi khung (`perf.stats.cpuFrame`, 60 khung/giây, trung bình 8–10 mẫu mỗi giây)

| Mức | Trước | Sau | Đổi |
|---|---|---|---|
| Cao | ~5,45 ms | ~5,05 ms | −7 % |
| Thấp | ~5,13 ms | ~4,67 ms | −9 % |

## Lượt vẽ và tam giác một khung đủ (`bench(40)`, bóng vẽ mỗi khung)

| | Trước | Sau | Đổi |
|---|---|---|---|
| Lượt vẽ (7h/12h/20h) | 645 / 650 / 642 | 558 / 553 / 557 | −14 % |
| Tam giác | 3,03 triệu | 2,68 triệu | −12 % |
| Thời gian tường `bench` (Cao) | 12,7–12,9 ms | 12,8–12,9 ms | không đổi |

## GPU (nvidia-smi, 15 mẫu, 60 khung/giây)

| Mức | Trước | Sau |
|---|---|---|
| Cao | 75 %, ~115 W | 77 %, ~118 W |
| Thấp | 56 %, ~45 W | 56 %, ~46 W |

Khác biệt GPU nằm trong sai số.

## Kết luận

- PERF1–3 giảm việc CPU (ít lượt vẽ, ít dựng ma trận) khoảng 7–9 % và bớt 14 % lượt vẽ.
- Ở mức **Cao** trang bị giới hạn bởi GPU (tô điểm ảnh: MSAA 4, AO, DOF, tia nắng, độ phân giải
  1.0), nên thời gian tường và công suất card không đổi: card kéo ~115 W ở 60 khung/giây.
- Số "CPU 7,4–9,2 → 5,4–5,9 ms" ghi ở PERF1 đo lúc máy đang chạy game nên phóng đại; dùng số ở đây.
- Mục tiêu hiệu năng kế tiếp nên là **GPU ở mức Cao** (hậu kỳ và độ phân giải), không phải lượt vẽ.
