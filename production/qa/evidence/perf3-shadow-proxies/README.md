# Bằng chứng: PERF3, proxy đổ bóng cho mặt đất và đáy đảo (2026-11-26)

Canvas 1280×720, cùng góc camera `setView([14,13,16],[0,0.8,0])`, trời quang ép tạm thời
(sau đó trả về tự động). Bóng của nhà, cây, đá và hàng rào giống nhau trước/sau; khác biệt về độ
nét là do điểm lấy nét DOF lúc chụp, không phải do bóng.

| Ảnh | Giờ |
|---|---|
| before-0700 / after-0700 | 07:00, nắng xiên |
| before-1200 / after-1200 | 12:00 |
| before-1736 / after-1736 | 17:36, bóng dài |

Run result: OBSERVED. Không có lỗi console.

| Số đo | Trước | Sau |
|---|---|---|
| Tam giác trong pass bóng | ~980 nghìn | ~632 nghìn (−35 %) |
| Mặt đất đổ bóng | 327.080 tam giác | proxy 14.800 |
| Đáy đảo đổ bóng | 45.840 tam giác | proxy 1.104 |

Hai proxy nằm ở layer 1, nên cũng được vẽ ở pass chính nhưng không ghi màu, không ghi độ sâu
(thêm 2 lượt vẽ rẻ). Thời gian khung tổng chưa đo khi máy rảnh.
