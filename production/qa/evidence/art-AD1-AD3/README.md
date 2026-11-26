# Bằng chứng: vòng mỹ thuật AD1–AD3 và PERF1 (2026-11-26)

Canvas 1280×720, Chrome trong khung Browser của Claude. Ảnh "trước" là commit `43db1d7`, ảnh
"sau" là bản có AD2 + AD3 (và PERF1 cho ảnh 08). Cùng góc camera mặc định.

| Ảnh | Nội dung |
|---|---|
| 01 / 02 | 18:00 mùa thu: trước sập tối, sau giữ nắng chiều và đèn cửa sổ bật sớm |
| 03 / 04 | 22:00: trước là vòm lưới lục giác lam neon, sau là dải cổ ngữ và sương; đêm còn thấy khối |
| 05 / 06 | Giông mùa hạ: sau có tông chì lạnh, khác mưa xuân |
| 07 / 08 | Trưa mùa thu: đáy đảo hết bóng như gốm; 08 chụp sau PERF1, hình không đổi vì PERF1 |

Run result: OBSERVED. Trang tải không có lỗi console ở cả ba bản.

## Ai làm
- AD1, AD2: Gemini 4 Hydrogen (art director, qua `agy`).
- AD3: Claude Opus 4.6 qua `agy` thay Gemini (mọi model Gemini hết hạn mức, mở lại khoảng 03/12),
  theo art bible của Gemini. Gemini sẽ duyệt lại AD2 và AD3 khi có hạn mức.
- PERF1: worker opencode `hy4-flash-free`, vòng 2 sau lời chê `.orchestra/fb_PERF1.txt`.

## Số đo PERF1 (2560×1270, mức "Cao")
| | Trước | Sau |
|---|---|---|
| `scene.updateMatrixWorld()` mỗi khung | 1,00 ms | 0,41 ms |
| Vật bị tính lại ma trận mỗi khung | 1121 / 1179 | 482 / 907 sau fold (425 đóng băng) |
| CPU mỗi khung (`perf.stats.cpuFrame`) | 7,4–9,2 ms | 5,4–5,9 ms |

Chưa đo được thời gian khung tổng hay GPU một cách công bằng: lúc đo sau, người dùng đang chơi
League of Legends trên cùng GPU. Đo lại khi máy rảnh.

Vật bị code di chuyển qua biến cục bộ sẽ được tự gỡ băng trong khoảng 0,5 s
(`__dao.perf.staticCheck().healed`); lần kiểm này gỡ 1–2 group.
