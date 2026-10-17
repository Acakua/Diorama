# Thiết kế — bản công khai

Tài liệu này chỉ có **luật chơi**: những gì người chơi được biết trước. Toàn bộ nội dung
(toà nhà có gì, ai ở đâu, chuyện gì xảy ra lúc nào, đồ nằm ở đâu) nằm trong `content/` và
được giữ kín. **Đừng mở `content/`** nếu muốn chơi mà không biết trước.

## Ý tưởng

Một người bình thường, những ngày đầu của dịch bệnh, kẹt trong một toà chung cư. Ban ngày ra
khỏi phòng tìm đồ trong toà nhà. Ban đêm cố thủ trong phòng mình. Sống tới khi có cứu hộ.

## Vòng chơi

| Pha | Giờ trong game | Thời gian thật | Việc chính |
|---|---|---|---|
| Ngày | 16:00 → 20:00 | ~3 phút | Ra hành lang, vào các căn hộ, lục đồ, mang về. |
| Chạng vạng | 20:00 | | Phải ở trong phòng mình. Ở ngoài là gặp nguy. |
| Đêm | 20:00 → 05:30 | ~3,5 phút | Giữ phòng bằng những gì đã tìm được. |

- **Một chuyến chơi** gồm nhiều ngày. Thua là bắt đầu chuyến mới; đồ đạc và sự kiện được xáo
  lại nên mỗi chuyến một khác.
- **Thế giới nhớ trạng thái**: chỗ đã lục thì đã lục, cửa đã mở thì vẫn mở, cửa hỏng thì vẫn hỏng.

## Luật chung

- **Ánh sáng và tiếng động** thu hút sự chú ý của thứ ở bên ngoài: đèn, radio, đèn pin (ít
  hơn), bước chân sát cửa, tiếng búa. Tối và yên lặng thì sự chú ý giảm dần.
- **Cửa** có độ bền. Bị đập là mất độ bền; hỏng hẳn là nó vào được.
- **Chặn cửa**: kê ghế dưới tay nắm, và đóng ván. Đóng ván cần **búa**, cần **ánh sáng**, mất
  vài giây và **gây ồn**. Ván có thể bị giật bung khi cửa bị đập mạnh.
- **Ánh sáng là đánh đổi**: đèn trần sáng nhưng lộ; đèn pin kín đáo hơn nhưng tốn **pin**;
  bóng tối an toàn nhưng không làm được việc gì cần nhìn.
- **Túi** có 3 ô cho đồ tiêu hao (ván, pin...). Về tới phòng thì đồ trong túi được cất vào
  phòng. Dụng cụ (đèn pin, búa) tìm được một lần là giữ luôn, không tốn ô.
- Không có chiến đấu. Cách sống sót là chuẩn bị, giữ im lặng và chọn đúng lúc.

## Điều khiển

Chơi được hoàn toàn bằng chuột (một tay):

| Chuột | Việc |
|---|---|
| Rê lên đồ vật | Hiện vòng đánh dấu và việc cú bấm sẽ làm |
| Bấm trái lên sàn | Đi tới đó (tự tìm đường) |
| Bấm trái lên đồ vật | Đi tới rồi làm việc chính (việc cần giữ thì tự làm tới xong) |
| Bấm phải lên đồ vật | Menu các việc khác (mắt mèo, đóng ván...) |
| Bấm khi đang làm / đang nhìn | Dừng lại |
| Nút "Flashlight" | Bật / tắt đèn pin |
| Lăn chuột | Zoom |

Bàn phím vẫn dùng được: W A S D đi, E dùng (giữ E để lục tìm), F hành động thứ hai, R dùng đồ
trong túi, Q đèn pin, F3 thông tin gỡ lỗi, Esc thoát.

## Lộ trình

1. **Phần 1 — một ngày và một đêm** (đang làm): hành lang, một căn hộ để lục, túi đồ, ván và
   búa, đèn pin, đêm có việc phải làm.
2. **Phần 2 — nguy hiểm ban ngày**: phải đi lén trong toà nhà.
3. **Phần 3 — người sống sót** có thể đưa về phòng.
4. **Phần 4 — mở rộng**: thêm nơi chốn, người, sự kiện; một chuyến nhiều ngày tới khi cứu hộ.

## Câu hỏi khi chơi thử phần 1

1. Ban ngày có muốn "liều thêm một chỗ nữa" không, hay thấy đủ sớm?
2. Ban đêm còn khoảng nào thấy không có gì làm không?
3. Có lúc nào phải đắn đo giữa làm việc (đóng ván, soi đèn) và giữ im lặng không?
4. Cái gì làm bạn bất ngờ? Cái gì thấy vô lý?
