# Bàn giao: Đảo Cối Nước

*Phiên Claude Code mới: đọc file này trước, rồi `tools/orchestra/RUNBOOK.md` (cách điều hành;
**trưởng phòng chỉ điều hành, không tự viết code**), `design/game-brief.md` và
`design/art-bible.md`.*

## 1. Dựng lại

1. `git clone https://github.com/Acakua/Diorama.git` (riêng tư, nhánh `main`).
2. `python -m http.server 8765`, mở `http://localhost:8765/dao-coi-nuoc.html`
   (`.claude/launch.json`, cấu hình `dao`).
3. Kiểm cú pháp: `node tools/orchestra/check-page.mjs` → `0 failed`.
4. Bản xuất bản: artifact riêng tư trên claude.ai; xuất bản lại vào cùng URL (bộ nhớ dự án).

## 2. Cách điều hành (từ Game3, 2026-11-26)

- Claude Code = trưởng phòng: viết brief trong `production/briefs/`, chạy worker bằng
  `bash tools/orchestra/run-worker.sh <chức vụ> <brief>` ở chế độ nền, tự soát (kiểm cú pháp,
  đọc diff, chụp ảnh) rồi mới commit.
- Worker opencode đọc `AGENTS.md`. **Art director = Gemini 4 Hydrogen qua `agy`**, đọc
  `tools/orchestra/ART-DIRECTOR.md`; giữ `design/art-bible.md`, chấm ảnh, được sửa phần mỹ thuật.
- Model của từng chức vụ: `tools/orchestra/roles.conf`. Log: `.orchestra/logs/`, nhật ký
  `.orchestra/runs.tsv` (không lên git).

## 3. Đang ở đâu (26/11/2026)

- Commit cuối trước khi lập đội: `43db1d7` (sổ của Mun, việc Linh xếp vào giờ rảnh).
- Vòng AD1: Gemini viết art bible và chấm bộ ảnh `.orchestra/shots/AD1/`. Bước sau: chọn các
  điểm P1 trong bản chấm thành brief sửa mỹ thuật (AD2).
- Còn mở: Linh (VRM) giật khi hiện lần đầu (bộ nhớ `reference-shader-compile-measurement`).
