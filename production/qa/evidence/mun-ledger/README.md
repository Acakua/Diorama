# Bằng chứng: Sổ của Mun và giao việc (bước 1, 2026-11-05)

Bước 1 trong `design/game-brief.md`, thay đổi trong `dao-coi-nuoc.html` (chưa commit):

- **Sổ của Mun**: một nút mới trên thanh công cụ. Bảng sổ có khung giống Nhật ký và gồm:
  - kho chung: củi, bí, cá, trứng, thuốc và xu (`W.coins`, tạm thời bằng 0);
  - tối đa 3 việc mỗi ngày;
  - năm nút giao việc.
- **Bấm vào chỗ làm việc** (đống củi, bến câu, chuồng gà, vườn bí, tháp nấu thuốc) thì hiện một thẻ nhỏ để nhờ Linh làm việc ở chỗ đó. Rê chuột lên chỗ làm việc thì con trỏ thành bàn tay.
- **Linh xếp việc vào bốn khung rảnh**: 09:45–11:45, 12:45–14:30, 14:30–15:51 và 15:51–16:45.
  - Bữa ăn, việc thường ngày và kế hoạch riêng của cô được giữ: thư, làm bánh, dã ngoại, việc theo mùa.
  - Việc ngoài trời tránh giờ dự báo có mưa.
  - Nếu cô đang trong khung rảnh và còn đủ giờ, cô đi làm ngay.
  - Việc đang dở lúc hết khung thì được làm tiếp sang khung rảnh liền sau. Lỡ khung thì việc chuyển sang khung khác hoặc sang hôm sau; không có hạn chót.
  - Khi không có việc nào, lịch giữ nguyên như trước.
- **Lưu dữ liệu**: `saveW` lưu `W.tasks` và `W.coins`, `loadW` kiểm tra các giá trị đó.

Run result: OBSERVED — qua một ngày đảo mô phỏng ở tốc độ 6× (từ 08:00 ngày 2 đến 02:45 ngày 3, rồi thêm ban ngày của ngày 3), Linh làm đúng các việc được giao. Trong suốt quá trình, việc cô làm luôn khớp với lịch cũ cộng các việc đã xếp (0 khung lệch quá 25 khung hình liền). Console không có lỗi. Ảnh: `production/qa/evidence/mun-ledger/01-ledger-task-in-progress.jpg`.

## Ảnh chụp

Chụp khung Browser ở cửa sổ 1280×800, ảnh thu về 800×500.

| Ảnh | Nội dung |
|---|---|
| [01-ledger-task-in-progress.jpg](01-ledger-task-in-progress.jpg) | 15:32 ngày 5 (Thứ Sáu). Chặt củi đang làm (+1), Câu cá xong (+2 con cá), Pha thuốc để mai: Thứ Sáu Linh làm bánh nên không còn khung đủ dài. Dòng chữ dưới đồng hồ ghi "Việc Mun nhờ: Linh đang phù phép cho chiếc rìu tự bổ củi." |
| [02-ledger-tasks-done.jpg](02-ledger-tasks-done.jpg) | 16:33 cùng ngày. Chặt củi đã xong (+3 khúc củi) và bị gạch ngang trong sổ. |
| [03-workplace-card.jpg](03-workplace-card.jpg) | Thẻ "Vườn bí" hiện khi bấm vào vườn: số bí trong kho, số quả đã chín, nút "Nhờ Linh hái bí" bị khoá vì sổ đã đủ 3 việc. Ảnh chụp trước khi đổi cách dò mặt đất (xem dưới); giao diện thẻ không đổi. |

## Kết quả kiểm thử

| Phép thử | Kết quả |
|---|---|
| Ngày 2, giao lúc 08:08 | Ba việc được xếp như sau. **Chặt củi** lúc 09:45: xong lúc 11:10 với +3, cô làm tiếp tới hết khung nên tổng là +4. **Câu cá** lúc 12:45: xong lúc 13:46 với +1. **Pha thuốc** lúc 14:30: ở 6× không kịp xong trong khung nên chuyển sang 09:45 ngày 3. Mình đã sửa để việc đang dở được làm tiếp sang khung liền sau. |
| Nửa đêm | Việc đã xong bị xoá khỏi sổ. Việc chưa xong chuyển sang ngày mới và được xếp lại. |
| Ngày 3 | **Pha thuốc** xong lúc 11:16 (+1 chai), sau đó cô quay về việc riêng. **Nhặt trứng** lúc 12:45: gà đẻ lứa mới và cô nhặt được +3. **Hái bí** được làm nối ngay sau đó (+1). Việc gom lá theo mùa của cô giữ nguyên. |
| Mưa | Có dự báo mưa 11:24–14:22 thì chặt củi tránh sang 14:30. Khi ghim thời tiết mưa, việc ngoài trời ghi "chờ trời tạnh"; pha thuốc vẫn được xếp. |
| Giao giữa khung rảnh | Pha thuốc được giao lúc 13:00, khi Linh đang trú mưa, thì cô đi làm ngay. |
| Làm tiếp | Câu cá còn dở lúc 15:51 thì việc tự chuyển sang khung 15:51–16:45. Linh vẫn đang câu, không phải đi lại. |
| Huỷ việc | Bấm × thì dòng việc biến mất và Linh quay về kế hoạch riêng. |
| Dữ liệu lưu hỏng | Xu `'lots'` thành 0. Việc lạ, việc rỗng và việc đã xong từ hôm trước bị bỏ. Số lượng bị kẹp ở 999. Sổ giữ tối đa 3 việc. Trang vẫn khởi động bình thường. |
| Chế độ để yên | Khi không mở bảng nào, chữ còn hiện ở giây 43,4 và đã ẩn ở giây 45,9. |
| Hiệu năng (mức Cao) | `Mun.step` mất 0,08 µs mỗi khung. Kiểm tra sổ có cần vẽ lại không mất 3,8 µs, chạy 5 lần mỗi giây khi sổ mở. Một khung `bench` mất 13,86 ms khi có việc và 13,83 ms khi không có việc. |
| Bấm chỗ làm việc | Lúc đầu mỗi lần bấm dò tia vào lưới địa hình, tốn khoảng 53 ms. Bản cuối dò theo bản đồ độ cao, gần như 0 ms. Nhìn từ dưới đáy đảo lên thì không bấm xuyên qua đất được. |

## Lưu ý

- Khung Browser bị che nên `requestAnimationFrame` chỉ chạy khoảng 1,5 khung/giây. Vì vậy mình kiểm thử bằng các khung `__dao.bench`, đồng thời dùng `__dao.perf.drive` để vòng vẽ thường đứng yên.
- **Lỗi có sẵn, đã sửa ngày 2026-11-06** (người dùng đồng ý sửa ở phiên này):
  - Cách lỗi xảy ra: `__dao.bench` coi mỗi khung là 16,7 ms. Nếu máy vẽ nhanh hơn thế, `last` chạy trước giờ thật. Khi vòng vẽ thường chạy lại, khung kế tiếp nhận một bước thời gian âm, vì `raw` trong `frame()` không bị chặn dưới 0.
  - Hậu quả khi kiểm thử: giờ đảo lùi và sinh nhầm một ngày mới. Sau đó các giá trị chuyển động bùng lên và vòng `while` trong `angleTo` không dừng, làm tab treo.
  - Nút "Bắt đầu đo" trong bảng Hiệu năng cũng gây được phần đầu của lỗi: lượt đo để `last` chạy trước khoảng 0,35 giây, đủ sinh nhầm một ngày mới.
  - Cách sửa: `raw` được chặn bằng `Math.max(0, …)`, nên khung đầu sau khoảng lệch có bước 0 rồi chạy tiếp theo giờ thật.
  - Thử lại với `bench(1500)` để đồng hồ trang chạy trước 14,8 giây (gấp khoảng 8 lần lần làm treo tab):
    - trong 2,5 giây sau đó, 452 mẫu giờ đảo không lùi lần nào, đi từ 10,01 lên 10,07 đúng nhịp 1×;
    - không có ngày mới; vị trí và hướng của Linh vẫn hữu hạn.
  - Thử lại nút "Bắt đầu đo": chạy xong trong 3,66 giây, đủ 4 mức; sau đó giờ đảo đi tiếp từ 10,50 lên 10,57, không lùi, không có ngày mới.
  - Hai lần thử lại này chạy trên `localhost:8765` khi `localStorage` của trang đó còn trống. Sau khi thử, mình xoá các khoá trang đã ghi.
- `localStorage['dao-world']` của `localhost:8765` đã được chụp lại trước khi thử và khôi phục sau khi thử. Chuỗi khôi phục dài 3.206 ký tự, khớp bản gốc.
