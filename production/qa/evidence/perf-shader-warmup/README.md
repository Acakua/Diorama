# Bằng chứng: làm ấm shader lúc khởi động, vây koi vẽ một lượt (2026-11-05)

Hai thay đổi trong `dao-coi-nuoc.html` (chưa commit):

1. **Làm ấm shader.** Cuối phần khởi động, ngay trước khung đầu:
   ```js
   renderer.setRenderTarget(rtScene);
   const warm = renderer.compileAsync(scene, camera);
   renderer.setRenderTarget(null);
   await warm;
   for (const p of renderer.info.programs) p.getUniforms();
   ```
   - `compileAsync` biên dịch cả các vật thể đang ẩn.
   - Vòng `getUniforms()` ép driver hoàn tất liên kết ngay khi màn hình tải còn che.
2. **Vây koi.** Vật liệu vây và đuôi cá koi (`fm`) được đặt `forceSinglePass:true`.

Run result: OBSERVED — trang tải không có lỗi console và Linh (VRM) hiện bình thường; nhấc mái, trời tối, tuyết và giông không còn biên dịch shader mới (0 ms bị chặn); vây koi vẽ một lượt trông giống hệt hai lượt — `production/qa/evidence/perf-shader-warmup/01-koi-fins-single-pass.jpg`.

## Ảnh chụp

Chụp từ canvas 1280×720 của bản cuối.

| Ảnh | Nội dung |
|---|---|
| [01-koi-fins-single-pass.jpg](01-koi-fins-single-pass.jpg) | Vây koi khi bật `forceSinglePass:true` (bản đã sửa) |
| [02-koi-fins-two-pass.jpg](02-koi-fins-two-pass.jpg) | Cùng cảnh, tắt `forceSinglePass` lúc chạy (hình cũ); giống 01 |
| [03-day-overview.jpg](03-day-overview.jpg) | Đảo ban ngày mùa thu, sau khi làm ấm |
| [04-roof-lifted-interior.jpg](04-roof-lifted-interior.jpg) | Nhấc mái, thấy đồ trong nhà. Trước đây lần đầu giật 354 ms khi nguội |
| [05-night.jpg](05-night.jpg) | Ban đêm, đèn và bướm đêm. Trước đây lần đầu giật 290 ms khi nguội |
| [06-winter-snow.jpg](06-winter-snow.jpg) | Mùa đông, tuyết rơi |

Ảnh tĩnh chỉ chứng minh phần hình: mọi thứ vẽ đúng và hình không đổi. Phần cảm giác (hết giật) được chứng minh bằng số đo bên dưới.

## Số đo

Môi trường: Chrome 152 trong khung Browser của Claude, ANGLE D3D11, GTX 1660 SUPER.

Cách đo:
- Bọc `getProgramInfoLog`, `getShaderInfoLog`, `getProgramParameter`, `getUniformLocation` và `getActiveUniform` để đo thời gian luồng chính chờ driver.
- Đếm số lần gọi `linkProgram`.
- "Nguội" nghĩa là thêm một chú thích ngẫu nhiên vào cuối mã shader, để không trúng bộ nhớ đệm chương trình của ANGLE. Đây là trường hợp lần đầu mở trang.

| Sự kiện | Trước (nguội) | Sau |
|---|---|---|
| Trời tối lần đầu | Khung 290 ms, 2 chương trình mới | 0 chương trình mới, 0 ms |
| Nhấc mái lần đầu | Khung 354 ms, 2 chương trình mới | 0 chương trình mới, 0 ms |
| Tuyết | 14 ms | 0 ms |
| Giông | 12 ms | 0 ms |
| Mưa | 35 ms | Khoảng 12 ms: còn 1 shader bóng mà `compile` không với tới |
| Tải trang khi nguội, tính đến hết khung đầu | 10,9 s (khung đầu chặn liền 7,6 s) | Khoảng 8,3 s (biên dịch song song khi màn hình tải còn che) |
| Khung đầu khi ấm | 707 ms | 573 ms |
| Vây koi, CPU mỗi khung | Khoảng 0,6 ms (chọn lại shader 40 lần mỗi khung) | Khoảng 0 (`version` không đổi) |

## Chưa sửa

Lúc Linh (VRM) xuất hiện ngay sau khi trang tải, trang vẫn giật: khoảng 0,24 s khi ấm và khoảng 2,6 s khi nguội.
- Đã thử biên dịch trước các shader của cô trong lúc ẩn cô. Cách này không đỡ: GPU vẫn bận, nên các khung khác bị chặn thay. Vì vậy thay đổi đó đã được gỡ.
- Hướng còn lại là nạp Linh trước khi màn hình tải biến mất. Đây là lựa chọn thiết kế, cần người dùng quyết.

`stamp.txt` lưu mã băm nội dung của `dao-coi-nuoc.html` lúc chụp. Nếu sau này trang bị sửa, mã băm sẽ cho thấy bằng chứng này cũ hơn code.
