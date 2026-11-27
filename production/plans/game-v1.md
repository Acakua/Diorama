# Kế hoạch: từ diorama thành game chơi được (bắt đầu 2026-11-27)

Người dùng: "làm liên tục cho tới khi thành một game hoàn chỉnh có thể chơi", worker làm logic,
chiến đấu = **giữ đảo ban đêm** (AFK, trên đảo 3D). Phạm vi: `design/game-brief.md`, mục "Phạm vi v2".

| Mốc | Brief | Worker | Trạng thái |
|---|---|---|---|
| G1 đơn hạc giấy, xu | `production/briefs/G1-crane-orders.md` | free-builder | đang làm |
| G2 nâng cấp có hình | G2-upgrades.md | free-builder | chờ |
| G3 tóm tắt khi quay lại | G3-away-summary.md | free-builder | chờ |
| G4 luống trồng theo mùa, pha chế | G4-… | | chờ |
| G5a giữ đảo đêm: logic, dữ liệu, mô phỏng | G5a-… | coder (BytePlus từ 30/11) hoặc free | chờ |
| G5b giữ đảo đêm: hình 3D (ma sương instanced, tháp, tia) | G5b-… | art / Gemini (≈03/12) | chờ |
| G6 mô phỏng một năm, cân bằng, xuất bản | | trưởng phòng + qa | chờ |

Mỗi mốc: brief → mốc git → worker → soát (STATUS, diff, check-page, console, ảnh, thử bằng
`__dao`) → bằng chứng `production/qa/evidence/<mã>/` → commit, push.
