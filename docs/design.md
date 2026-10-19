# Thiết kế — bản công khai

Tài liệu này chỉ có **luật chơi**: những gì người chơi được biết trước. Toàn bộ nội dung
(toà nhà có gì, ai ở đâu, chuyện gì xảy ra lúc nào, đồ nằm ở đâu) nằm trong `content/` và
được giữ kín. **Đừng mở `content/`** nếu muốn chơi mà không biết trước.

## Ý tưởng

Một người bình thường, những ngày đầu của dịch bệnh, kẹt trong một toà chung cư. Ban ngày ra
khỏi phòng tìm đồ trong toà nhà. Ban đêm cố thủ trong phòng mình. Sống tới khi có cứu hộ.

Bốn trụ cột:

1. **Khám phá và giải đố là chính.** Mỗi nơi chốn trong toà nhà là một diorama mới: có đồ, có
   chuyện, có câu đố. Ban ngày không có gì rượt đuổi: thử thách là động não, không phải phản xạ.
2. **Tài nguyên nhẹ, đủ tạo áp lực.** Vài thứ thôi (ván, pin...), không chế tạo, không thanh
   chỉ số dày đặc. Chúng buộc bạn phải ra ngoài và phải chọn.
3. **Khoá và chìa.** Toà nhà mở dần: cửa khoá, mã số, máy móc cũ, lối bị chặn, mở được nhờ đồ,
   nhờ ghép đồ, nhờ tìm ra lối đi khác, hoặc nhờ hiểu biết.
4. **Hiểu biết là thứ mang theo.** Mỗi chuyến bắt đầu lại với túi trống, nhưng **nhật ký** giữ
   lại mọi thứ bạn đã biết. Thua không mất trắng: lần sau bạn biết đi đâu, mở gì, tránh gì.

Sau này còn một trụ nữa: **con người và lòng tin** (những người khác trong toà nhà).

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
- Không có chiến đấu, không có rượt đuổi ban ngày. Cách sống sót là chuẩn bị, giữ im lặng và
  chọn đúng lúc; cách tiến lên là quan sát và suy luận.
- **Câu đố** có bốn kiểu, trộn lẫn nhau: suy luận từ manh mối, khoá và cơ chế (mã số, két, máy
  móc), dùng và ghép đồ vật, và tìm lối đi. Đáp án luôn nằm trong toà nhà; không cần đoán mò.
- **Nhật ký** tự ghi lại ghi chú đã đọc, người đã gặp, nơi đã tới và manh mối đã hiểu ra. Nó
  được lưu lại qua mọi chuyến chơi (và cả khi tắt game). Có những thứ trong toà nhà chỉ "hiện
  ra" khi nhật ký đã có manh mối về nó. Mở nhật ký là game tạm dừng.

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
| Nút "Journal" | Mở / đóng nhật ký (game tạm dừng) |
| Lăn chuột | Zoom |

Bàn phím vẫn dùng được: W A S D đi, E dùng (giữ E để lục tìm), F hành động thứ hai, R dùng đồ
trong túi, Q đèn pin, J nhật ký, F3 thông tin gỡ lỗi, Esc thoát.

## Lộ trình

1. **Phần 1 — một ngày và một đêm** (xong): hành lang, căn hộ để lục, túi đồ, ván và búa,
   đèn pin, đêm có việc phải làm. Điều khiển bằng chuột.
2. **Nhật ký** (xong): hiểu biết giữ lại qua các chuyến, thứ chỉ mở khi đã biết. Kèm theo: cửa sổ
   chỉ ở tường ngoài, âm thanh nghe từ chỗ nhân vật (xa gần, trái phải, vang theo phòng, nghẹt
   qua tường và cửa đóng, bước chân, âm nền ngoài cửa sổ).
3. **Phần 2 — chuỗi câu đố đầu tiên**: ghép manh mối ngay trong nhật ký (chọn hai manh mối, nếu
   đúng thì rút ra kết luận mới), khoá mã số và cơ chế, ghép đồ vật, một lối đi phải tự tìm ra.
   Mở được một phần mới của toà nhà. Đêm giữ nguyên.
4. **Phần 3 — người đầu tiên**: con người và lòng tin.
5. **Phần 4 — mở rộng**: thêm nơi chốn, người, sự kiện; một chuyến nhiều ngày tới khi cứu hộ.

## Câu hỏi khi chơi thử phần 1

1. Ban ngày có muốn "liều thêm một chỗ nữa" không, hay thấy đủ sớm?
2. Ban đêm còn khoảng nào thấy không có gì làm không?
3. Có lúc nào phải đắn đo giữa làm việc (đóng ván, soi đèn) và giữ im lặng không?
4. Cái gì làm bạn bất ngờ? Cái gì thấy vô lý?
