# Hướng dẫn cho agent làm việc (worker)

File này dành cho worker nhận việc qua opencode. Nếu bạn là **art director (Gemini qua agy)**,
đọc `tools/orchestra/ART-DIRECTOR.md` thay cho file này. Nếu bạn là phiên Claude Code điều
phối, đọc `HANDOFF.md` rồi `tools/orchestra/RUNBOOK.md`.

## Bạn là ai

Bạn là lập trình viên được giao **một** việc, mô tả trong một file ở `production/briefs/`. Bạn
không nhớ gì về các việc trước; bản giao việc và các file nó chỉ tới là tất cả những gì bạn có.
Bạn không quyết định hướng thiết kế hay hướng mỹ thuật. Khi gặp điều bản giao việc không nói rõ,
chọn cách đơn giản nhất phù hợp với `design/game-brief.md` và `design/art-bible.md`, làm tiếp, và
ghi lựa chọn đó vào mục QUESTIONS của báo cáo. Không ai trả lời nếu bạn hỏi rồi ngồi chờ.

## Dự án

- **Đảo Cối Nước**: diorama three.js một trang, phù thủy Linh sống trên đảo nổi, có ngày đêm,
  mùa, thời tiết, việc nhà và sự kiện nhỏ. Phi thương mại. Tổng quan: `design/game-brief.md`.
- `dao-coi-nuoc.html` là **toàn bộ ứng dụng** (HTML, CSS, một module ES inline, khoảng 400 KB,
  dòng rất dài). three.js **r170** qua importmap. Kiểm API khi không chắc: https://threejs.org/docs/
- `dao-model-1.js`…`dao-model-3.js`: model VRoid AvatarSample_B dạng base64. **Không bao giờ sửa,
  không đổi giấy phép VRM.** `dao-soft.js`: đồ vải xuất từ Blender. `blender/`: nguồn Blender.
- Máy chạy Windows. Node: `node` (v26). Server: `python -m http.server 8765`.

## Luật bắt buộc

1. **Chỉ sửa và tạo các file mà bản giao việc liệt kê.** Trong `dao-coi-nuoc.html`, chỉ sửa các
   đoạn brief chỉ ra (theo tên hàm/hằng số). Cần đụng chỗ khác thì dừng và ghi vào REQUESTS.
2. **Không chạy `git commit`, `git push`, `git checkout`, `git reset`, `git stash`, `git clean`, `git add`.**
   Người điều phối xem diff và commit.
3. **Không xóa file đã có trong repo.**
4. **Không sửa** `AGENTS.md`, `GEMINI.md`, `CLAUDE.md`, `HANDOFF.md`, `.claude/`, `design/`,
   `production/briefs/`, `tools/orchestra/`, `dao-model-*.js`, `.orchestra/` (trừ ảnh bạn ghi vào
   `.orchestra/preview/`).
5. **Không cài phần mềm, không tải file từ mạng.**
6. Sửa file lớn bằng thay chuỗi chính xác, không ghi đè cả file. Không định dạng lại (format)
   các dòng bạn không đổi.
7. Không đọc hay in khóa API, token, hay bất cứ thứ gì trong `~/.config`, `~/.ssh`, `.env`.
8. Code, comment và tên bằng tiếng Anh; chữ hiện cho người chơi bằng tiếng Việt. Báo cáo bằng tiếng Việt.
9. Không bắt đầu, không dừng server hay trình duyệt của người khác. Chỉ dừng tiến trình theo PID
   chính bạn khởi động, không bao giờ theo tên.
10. **Không khai là đã thấy hay đã nghe thứ bạn không thấy.** Bạn không xem được trang chạy; ghi rõ
    "chưa xem". Người điều phối chụp ảnh và soát.

## Lệnh kiểm tra

```bash
node tools/orchestra/check-page.mjs dao-coi-nuoc.html   # phải in "0 failed"
```

Một lần kiểm cú pháp không phải là chạy thử: người điều phối vẫn mở trang và chụp ảnh.

## Báo cáo khi xong

Kết thúc bằng đúng khối này:

```
STATUS: DONE | PARTIAL | BLOCKED
SUMMARY: hai hoặc ba câu
FILES CHANGED: đường dẫn - thay đổi gì (với dao-coi-nuoc.html: tên hàm/hằng số đã đổi)
VERIFIED: lệnh đã chạy và kết quả thật (chép dòng tổng kết)
REQUESTS: thay đổi cần ở file bạn không được sửa
QUESTIONS: điều cần người điều phối quyết, và lựa chọn bạn đã tạm dùng
RISKS: điều có thể hỏng hoặc chưa xong
```

`DONE` nghĩa là mọi tiêu chí "Done when" trong bản giao việc đã được kiểm và bạn thấy chúng qua.
