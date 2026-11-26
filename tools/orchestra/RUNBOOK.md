# Điều hành worker — sổ tay cho phiên Claude Code (Đảo Cối Nước)

*Chép từ `D:\Game3\godot-open-rts\tools\orchestra\RUNBOOK.md` (Game3) ngày 2026-11-26, viết lại
cho diorama three.js và thêm art director Gemini. Phiên điều phối nào cũng đọc hết file này một
lần trước khi giao việc, rồi **chỉ làm theo nó**.*

Bạn (Claude Code) là **người điều hành** (trưởng phòng). Worker là các model chạy qua
`opencode`; **art director là Gemini 4 Hydrogen chạy qua `agy`**. Bạn viết brief, chạy worker ở
chế độ nền, soát kết quả bằng chính tay mình (chạy kiểm, đọc diff, chụp ảnh), rồi mới báo người
dùng và commit. Báo cáo của worker là lời khai, không phải bằng chứng.

## 0. Luật gốc (người dùng chốt, 2026-11-26)

1. **Trưởng phòng chỉ điều hành.** Không tự viết hay sửa code trang, shader, CSS, asset, kể cả
   một dòng. Mọi việc đó đi qua brief cho worker hoặc art director.
2. **Art director (Gemini) có quyền mỹ thuật:** viết `design/art-bible.md`, chấm ảnh chụp, và
   **được sửa phần mỹ thuật** trong `dao-coi-nuoc.html` (màu, ánh sáng, vật liệu, shader nhìn,
   texture vẽ canvas, hình khối cảnh, hạt/thời tiết, màu chữ UI). Ranh giới: `ART-DIRECTOR.md`.
   Mọi việc phải *nhìn* đều theo art bible; lời phán của art director thắng worker về mỹ thuật.
   Bất đồng giữa art director và yêu cầu kỹ thuật (hiệu năng, logic) thì hỏi người dùng.
3. Trưởng phòng được tự làm: `design/*` trừ art bible, `production/*` (brief, kế hoạch, báo cáo
   QA, ảnh bằng chứng), `HANDOFF.md`, `CLAUDE.md`, file trong `tools/orchestra/`, ảnh chụp trong
   `.orchestra/` (không commit), mọi lệnh git, chạy server/trình duyệt để kiểm.
4. Worker sửa hỏng **hai lần** thì đổi model khác (mạnh hơn hoặc khác họ) với brief rõ hơn.
   Không tự làm thay.
5. Mỗi vòng chỉ **một** worker được sửa `dao-coi-nuoc.html` (file duy nhất, mọi việc đều đụng nó).

## 1. Mỗi phiên, theo thứ tự

1. Đọc `HANDOFF.md`, rồi `design/game-brief.md` và `design/art-bible.md`.
2. Việc mới: viết brief trong `production/briefs/<mã>.md` (mục 4), kế hoạch vòng trong
   `production/plans/<mốc>.md` nếu nhiều việc.
3. Giao việc theo vòng (mục 5). Cuối phiên: cập nhật `HANDOFF.md` và mục 10 file này.

## 2. Đội

| Chức vụ | Model | Chạy bằng | Nhìn ảnh | Dùng cho |
|---|---|---|---|---|
| `art-director` | `gemini-4-hydrogen-high` | agy | có | Art bible, chấm ảnh, sửa mỹ thuật. |
| `art-director-max` | `gemini-4-hydrogen-xhigh` | agy | có | Art bible lần đầu, ca khó. Chậm hơn. |
| `art-gemini-fast` | `gemini-3.8-flash-high` | agy | có | Vòng chỉnh nhanh đã có lời chê cụ thể. |
| `coder` / `builder` | BytePlus deepseek-v4-pro / ark-code | opencode | không | Logic, hệ thống, ghép nối. |
| `art` / `ui` / `qa` | BytePlus seed-2-0 / deepseek-flash | opencode | có | Đồ họa theo lời art director, UI, soát. |
| `free-*`, `reserve` | opencode Zen miễn phí | opencode | tùy | Khi BytePlus hết hạn mức. |

Bảng model đầy đủ: `tools/orchestra/roles.conf`. Số đo các model opencode: RUNBOOK của Game3 §2.

- **BytePlus hết hạn mức tuần tới 2026-11-30 00:00 (+08).** Tới lúc đó dùng `free-*`.
- Model free hay treo khi chạy 2–3 việc cùng lúc: chạy lần lượt. Không chạy hai worker BytePlus cùng lúc.
- Người soát phải khác họ với người viết: Gemini sửa mỹ thuật thì worker `qa` (opencode) hoặc
  trưởng phòng soát; worker opencode làm đồ họa thì art director phán.
- `agy` dùng tài khoản Google của người dùng (hạn mức Antigravity), không cần khóa API.

## 3. Lệnh chạy

Luôn từ gốc repo, **ở chế độ nền** (`run_in_background: true`), mỗi worker một lệnh Bash:

```bash
bash tools/orchestra/run-worker.sh <chức vụ | provider/model | agy/model> <brief.md> [thư mục] [-- cờ thêm]
```

- Với `agy/*`: script chạy `agy -p <lời nhắc> --model <m> --dangerously-skip-permissions` từ gốc
  repo; lời nhắc mặc định bảo Gemini đọc `tools/orchestra/ART-DIRECTOR.md` rồi brief. `agy` không
  in gì tới khi xong lượt, nên log trống lúc đang chạy là bình thường; log nội bộ ở `<log>.agy`.
- Với opencode: như Game3 (`opencode run --auto`, nạp `ARK_API_KEY` từ biến môi trường User).
- Biến: `WORKER_TIMEOUT` (giây, mặc định 1500; art bible nên 2400), `WORKER_PROMPT`, `WORKER_FALLBACK`.
- Trả việc về: chạy lại từ đầu với lời nhắc ngắn chỉ tới file `.orchestra/fb_<mã>.txt` (lời chê
  đánh số) và đường dẫn ảnh; không nối phiên cũ.
- Worker opencode treo (log < 200 byte sau 10 phút): `run-retry.sh` hoặc dừng đúng PID theo dòng
  lệnh chứa tên brief. Không bao giờ dừng theo tên tiến trình.

## 4. Viết brief

Brief bằng **tiếng Anh**, 50–100 dòng, trong `production/briefs/`:

```markdown
# <mã> — <tên việc>
## Objective        khi xong thì điều gì phải đúng, và vì sao
## Read first       file và mục cần đọc (với dao-coi-nuoc.html: tên hàm/hằng số, số dòng neo)
## Files you may change   đường dẫn chính xác; với dao-coi-nuoc.html: những hàm/hằng số nào
## Spec             giá trị, hex, chữ ký hàm, ví dụ
## Steps            từng bước
## Constraints      không được đổi gì; bẫy đã biết (mục 9)
## Done when        lệnh chạy được + đầu ra mong đợi
## Return           khối báo cáo (AGENTS.md hoặc ART-DIRECTOR.md)
```

Brief mỹ thuật luôn dẫn tới `design/art-bible.md` và nêu ảnh nào trong `.orchestra/shots/<vòng>/`.

## 5. Quy trình một vòng

1. Chia việc theo file/đoạn code; một người sửa `dao-coi-nuoc.html` mỗi vòng.
2. Viết brief, commit nó.
3. **Đặt mốc:** worktree sạch (commit trước) để `git diff` chỉ hiện phần worker vừa làm.
   (`agy` chạy với mọi quyền tự duyệt: mốc git là hàng rào.)
4. Chạy worker ở chế độ nền. Trong lúc chờ: viết brief sau. Đừng dò log.
5. **Soát:** đọc `STATUS` → `git status --short` (file ngoài danh sách thì khôi phục) →
   `node tools/orchestra/check-page.mjs` → đọc diff (đổi logic ngoài ranh giới thì trả về) →
   mở trang, xem console, **chụp ảnh** (mục 7) cùng các góc của vòng trước để so.
6. **Vòng mỹ thuật có mắt:** sau khi worker/Gemini sửa, chụp ảnh mới vào `.orchestra/shots/<vòng>-r2/`
   rồi chạy art director lần nữa để phán (pass/fail từng tiêu chí). Duyệt tối thiểu 2 vòng cho
   thay đổi lớn. Chưa qua tiêu chí thì không commit.
7. Hiệu năng: thay đổi ánh sáng/shader/hạt thì đo lại (bộ nhớ `reference-gpu-measurement`).
8. **Commit** (Conventional Commits, kèm mã brief), push `main` khi người dùng cho phép.
   Ảnh bằng chứng cuối vào `production/qa/evidence/<mã>/` (CLAUDE.md: bằng chứng phải giữ lại).

## 7. Chụp ảnh

- Server: `preview_start` cấu hình `dao` (cổng 8765), mở `/dao-coi-nuoc.html`, chờ Linh tải.
- Điều khiển cảnh qua `window.__dao`: `setHour(h)`, `setView([x,y,z],[tx,ty,tz])`,
  `toggleRoof(true)`, `W.seaWant` (mùa 0–3, `-1` = tự), `W.wxWant` (thời tiết), `settle(n)`.
- Bộ chụp chuẩn mỗi vòng (cùng góc để so trước/sau): sáng 7h, trưa 12h, hoàng hôn 18h, đêm 22h,
  mùa đông, mưa/giông, nhấc mái, cận Linh. Ghi `shots.md` liệt kê giờ/mùa/thời tiết/góc từng ảnh.
- Ảnh toàn một màu nghĩa là camera hay cảnh sai, không phải "hiệu ứng".

## 9. Bẫy đã biết

- `dao-coi-nuoc.html` có dòng rất dài: sửa bằng thay chuỗi chính xác; worker định dạng lại cả
  file sẽ làm diff vô dụng → trả về.
- Shader biên dịch lúc khởi động (`compileAsync`): vật liệu mới phải có mặt lúc boot, không thì
  giật lần đầu xuất hiện (bằng chứng `production/qa/evidence/perf-shader-warmup/`).
- Chạy bench/drive tay có thể làm đồng hồ đảo nhảy (bộ nhớ `reference-bench-negative-dt`); khung
  Browser bị ẩn thì rAF dừng.
- `agy` ở chế độ print không hỏi quyền được: thiếu `--dangerously-skip-permissions` thì nó tự từ
  chối mọi lệnh và không in gì.
- Bash của Claude Code đổi `>nul` thành `>/dev/null` trong `.bat`: viết `.bat` bằng Write.

## 10. Dự án đang ở đâu

*2026-11-26.* Lập bộ điều hành theo Game3; thêm Gemini 4 Hydrogen (agy) làm art director. Vòng
đầu AD1: Gemini viết `design/art-bible.md` và chấm bộ ảnh hiện tại.
