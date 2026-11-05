# Game Brief: Đảo Cối Nước — Mun quản gia

*2026-11-05 · bản nháp đã được người dùng duyệt · chưa có code*

**One-sentence pitch:** Linh là phù thủy giỏi phép nhưng chẳng biết lo toan cuộc sống; bạn là Mun, con mèo bạn thân của cô, người giữ kho, lên kế hoạch và nhắc việc. Linh làm, Mun lo, và hòn đảo lớn dần qua từng mùa.

## Core loop
- **Xem:** mở Sổ của Mun để xem kho chung (củi, bí, cá, trứng, thuốc, xu), mùa sắp tới cần gì, và những gì Linh đã làm. Nếu bạn vừa vắng mặt, sổ có bản tóm tắt.
- **Giao việc:** chọn vài việc cho Linh trong ngày: chặt củi, câu cá, nhặt trứng, thu hoạch, pha thuốc, gửi hàng.
  - Chọn trong sổ, hoặc bấm vào chỗ làm việc trên đảo: vạc, bến câu, chuồng gà, đống củi.
  - Linh tự xếp việc vào lịch và làm theo kiểu của cô, đôi khi lơ đễnh.
- **Đổi chác:** đơn hàng từ đảo khác tới bằng hạc giấy. Nhận đơn thì Linh giao hàng từ kho; đảo nhận xu và đồ hiếm.
- **Nâng cấp:** dùng xu và vật liệu để nâng cấp nhà và đảo (những thay đổi nhìn thấy được), và để những mong ước nhỏ của Linh thành thật.

## Player goal & fail state — what "working" looks like
- **Mục tiêu:** giữ cuộc sống của Linh đủ đầy, chuẩn bị cho từng mùa (nhất là mùa đông), và làm đảo lớn dần.
- **Không có thua:** việc không có hạn chót, không có chỉ số tụt. Kho cạn thì Linh tự xoay xở như hiện nay. Sự hậu đậu của cô (bỏ dở việc, khét nồi) chỉ để vui.
- **Một phiên chơi trọn vẹn khi** trong vài phút, bạn xem sổ, giao vài việc hoặc chốt một đơn hàng, rồi thấy Linh làm hoặc đảo thay đổi.

## MVP — what must exist to be the game
1. **Sổ của Mun:** kho chung lấy từ dữ liệu đã có (`W.wood`, `W.stock`, `W.fish`, `W.eggs`, `W.potions`) cộng thêm xu; dự báo mùa; bản tóm tắt khi quay lại.
2. **Giao việc:** tối đa 3 việc mỗi ngày, chọn trong sổ hoặc bấm vào chỗ làm việc. Linh làm khi rảnh và theo cách của cô; hết việc thì cô sống như cũ.
3. **Đơn hàng hạc giấy:** 1–2 đơn mỗi ngày, khoảng 8 mẫu. Nhận hay bỏ qua đều không bị phạt.
4. **Nâng cấp:** 3 nâng cấp có hình trên đảo, ví dụ kho củi lớn, luống bí mới, kệ thuốc.
5. **Linh hậu đậu:** thỉnh thoảng cô mải mê, bỏ dở việc rồi làm tiếp; Nhật ký kể lại theo giọng của Linh.
6. **Tóm tắt khi quay lại:** có giới hạn trên, ví dụ tối đa 1 ngày đảo, để không cộng dồn vô hạn.
7. **Lưu và kiểm tra dữ liệu** như `loadW` đang làm; giữ nguyên ngân sách hiệu năng (60 khung/giây khi đang dùng, 20–30 khi để yên).

## Out of scope — not building this
- Không điều khiển Mun hay Linh đi lại trực tiếp.
- Không có mini-game, không có giá dao động hay chợ, không có trang trí tự do.
- Không có phạt, không có hạn chót, không có cốt truyện dài (giữ quyết định chỉ có sự kiện lẻ).

## Build order
1. Sổ của Mun và giao việc, nối vào lịch tự động của Linh. Đây là rủi ro chính: việc được giao phải hòa vào lịch mà Linh vẫn còn "tự sống".
2. Đơn hàng hạc giấy và xu.
3. Một nâng cấp có hình trên đảo.
4. Bản tóm tắt khi quay lại.
5. Mô phỏng một năm đảo (28 ngày) để cân bằng, đo hiệu năng, chơi thử với người dùng, rồi quyết có làm tiếp không.

---
**Who it's for / what they feel:** người chủ đảo mở trang vài phút để ngắm và chơi; cảm giác là người bạn mèo chu đáo của một cô phù thủy hậu đậu, tinh nghịch và ấm áp.

**Art & audio direction:** giữ phong cách diorama hiện tại; Sổ của Mun như cuốn sổ tay có dấu chân mèo; tiếng mèo kêu khẽ, tiếng giở giấy.

**Reference game:** The Sims khi nhân vật bật "ý chí tự do". Giữ lại khoảng 10% của nó: xếp việc cho một nhân vật vẫn tự sống, quỹ chung, mua nâng cấp. Không xây nhà tự do, không có nhu cầu tụt dần.
