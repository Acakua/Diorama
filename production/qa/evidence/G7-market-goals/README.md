# Bằng chứng G7: thuyền chợ, túi tinh thể, mục tiêu đảo (2026-11-27)

Run result: OBSERVED (trang thật `?g7`, gọi `__dao.market` / `__dao.goals`, DOM + ảnh). Không lỗi console.

- `goals-home.jpg`: tab "Nhà" mở đầu bằng "Mục tiêu đảo": 3 mục chưa nhận, tiến độ, quà, nút
  "Nhận quà" khi đạt; dòng "Đã xong 1/10 mục tiêu."
- `market-trade.jpg`: cuối tab "Buôn bán" là "Thuyền chợ": mỗi món đang có một dòng, giá, "Bán 1",
  "Bán 5" (mờ khi có dưới 5), "Túi tinh thể · 10 tinh thể · Mua · 40 xu", "Hôm nay thuyền còn nhận 14 món."
- Bán 1 trứng: +2 xu, −1 trứng, `W.mkt.n`=1. Mua túi tinh thể: +10 tinh thể, −40 xu.
- Room 1 món: "Bán 5" tắt với lý do "Thuyền chợ chỉ nhận thêm 1 món hôm nay."; gọi `sell('eggs',5)` không làm gì.
- Nhận "Mua món nâng cấp đầu tiên": +10 tinh thể, `W.goals=['first-upg']`.
- Chấm báo: đang ở "Buôn bán", một mục tiêu mới đạt → chấm trên `#bLedger` và tab "Nhà"; mở "Nhà" thì tắt.
- Đẩy đủ điều kiện rồi nhận cả 10: sổ hiện "Chương một đã xong. Người giữ đảo: Mun.", nhật ký có đúng
  một dòng "Chương một khép lại…". (Trạng thái thử đã được trả lại sau đó.)
- Lúc vắng nhà: củi đốt mỗi tối 2 → 1 (soát diff).

Worker báo PARTIAL chỉ vì `production/plans/game-v1.md` do người điều phối sửa từ trước; phần việc đạt.
