# Bằng chứng: PERF2, lửa đuôi và mào gà vẽ bằng instancing (2026-11-26)

Canvas 1280×720, cùng góc camera, gà được đặt cố định bằng tay trước khi chụp (vị trí, hướng).
Khác biệt nhỏ giữa trước và sau là pha nhấp nháy của lửa (scale.y đổi theo thời gian).

| Ảnh | Nội dung |
|---|---|
| 01 / 02 | 21:30, lửa phát sáng: trước / sau |
| 03 / 04 | 12:00: trước / sau |

Run result: OBSERVED. Không có lỗi console; `staticCheck().healed` rỗng.

| Số đo (lượt vẽ mỗi khung, cả pass bóng) | Trước (PERF1) | Sau |
|---|---|---|
| 12:00 | 743 | 656 |
| 22:00 | 715 | 619 |
| Mesh trong 5 con gà | 70 | 20 (+2 InstancedMesh) |

Thời gian khung chưa đo lại: máy đang chạy game cùng GPU. Đo khi máy rảnh.
