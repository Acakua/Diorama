# Đo hiệu năng trận đêm (2026-11-27)

Khung Browser của Claude, canvas giả lập 1920×1080, mức "Cao" ghim bằng `perf.setQ('high')`,
`perf.drive(60)`, góc `setView([14,13,16],[0,0.8,0])`. League tắt; Wallpaper Engine vẫn chạy.
Số trung bình 10–12 mẫu mỗi giây từ `perf.stats`.

| Cảnh | CPU / khung | Logic | Lượt vẽ | Ma sương sống |
|---|---|---|---|---|
| Ban ngày 12:00 | 5,32 ms | 1,24 ms | 381 | 0 |
| Đêm, sóng 1 (thật) | 4,95 ms | 1,06 ms | 551 | 0–7 |
| Đêm, ép 38 ma sương bất tử | 4,92 ms | 1,05 ms | 525 | 38 |

GPU lúc ép 38 ma sương (nvidia-smi, 12 mẫu): 77,6 %, 118 W. Ban ngày cùng mức Cao đo hôm
2026-11-26: 77 %, ~118 W (`perf3-shadow-proxies/frame-time-2026-11-26.md`).

Kết luận: trận đêm (5 lượt vẽ instanced) không làm tăng thời gian khung hay tải GPU đo được.
Lượt vẽ đêm cao hơn ngày do đèn đêm và bóng, không do trận đánh (đêm 20h trước G5b: ~557).
Trạng thái lưu của trang thử đã được trả lại sau khi đo.
