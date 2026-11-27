# Kế hoạch: từ diorama thành game chơi được (bắt đầu 2026-11-27)

Người dùng: "làm liên tục cho tới khi thành một game hoàn chỉnh có thể chơi", worker làm logic,
chiến đấu = **giữ đảo ban đêm** (AFK, trên đảo 3D). Phạm vi: `design/game-brief.md`, mục "Phạm vi v2".

| Mốc | Brief | Worker | Trạng thái |
|---|---|---|---|
| G1 đơn hạc giấy, xu | `production/briefs/G1-crane-orders.md` | free-builder | xong (7a7cef1) |
| G2 nâng cấp | G2-upgrades.md | free-builder | xong (f6d16c1) |
| G3 tóm tắt khi quay lại | G3-away-summary.md | free-builder | xong (f6f5c60) |
| G5a giữ đảo đêm: luật, mô phỏng, sổ, HUD | G5a-night-defence-logic.md | free-builder, 2 vòng | xong (a372a72) |
| G5b giữ đảo đêm: hình 3D (ma sương, tháp, tia) | G5b-night-defence-3d.md | free-art, 2 vòng | xong (acad15b); chờ Gemini duyệt mỹ thuật (≈03/12) |
| G4 bếp: món ăn bán được, ăn trước đêm | G4-kitchen-recipes.md | free-builder, 2 vòng | xong (f3a01ae) |
| G6 sổ chia tab, chấm báo, HUD đêm, hướng dẫn | G6-ledger-ui.md | free-ui | xong (1af60ed) |
| G7 thuyền chợ, tinh thể bằng xu, mục tiêu đảo, chương một | G7-market-goals.md | free-builder | đang làm |
| G8 chơi thử, cân bằng, đo hiệu năng đêm, xuất bản | | trưởng phòng | chờ |

Luống trồng theo mùa (G4 cũ) hoãn: bếp đã nối nông trại với phòng thủ.

Mỗi mốc: brief → mốc git → worker → soát (STATUS, diff, check-page, console, ảnh, thử bằng
`__dao`) → bằng chứng `production/qa/evidence/<mã>/` → commit, push.
