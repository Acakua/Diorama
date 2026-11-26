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
- Xong: AD1 (art bible, Gemini), AD2 (hoàng hôn, đêm, đáy đảo, vòm cổ ngữ; Gemini), AD3 (bầu trời
  dưới, giông, viền Linh, DOF, đảo xa; **Claude Opus 4.6 qua agy làm thay**), PERF1 (đóng băng ma
  trận vật tĩnh, CPU 7,4–9,2 → 5,4–5,9 ms/khung). Bằng chứng: `production/qa/evidence/art-AD1-AD3/`.
- **Hạn mức:** mọi model Gemini trong agy hết tới khoảng **2026-12-03**; Claude/GPT trong agy
  ("third-party") cũng hết tới khoảng 2026-12-03; BytePlus mở lại 2026-11-30. Hiện chỉ còn đội
  opencode `free-*`.
- Việc kế tiếp:
  1. Khi Gemini có hạn mức: chạy lại bộ chụp chuẩn, cho `art-director` phán AD2+AD3 (bản AD3 do
     người thay làm), rồi sửa tiếp: vòm còn viền sáng như bong bóng thủy tinh và dấu "+" trông
     như bia mộ; trời hoàng hôn hơi đục nâu-tím; tuyết mặt đất mùa đông mỏng (`U.snow` thấp).
  2. PERF2: gộp các con vật làm từ nhiều khối tiện nhỏ (35 + 20 lượt vẽ MeshBasic có đổ bóng)
     bằng InstancedMesh; đo lại PERF1 + PERF2 khi máy rảnh (không chạy game).
  3. Một lần chụp 17:30 ra khung gần như đen (vật tối bay sát camera?); chưa tái hiện được.
- Mẹo chụp: mùa/thời tiết ép bằng `__dao.W.seaWant/wxWant` được **lưu** vào `localStorage['dao-world']`;
  trả về `-1`/`null` sau khi chụp. Khung Browser phải đang hiện, không thì rAF dừng.
- Còn mở: Linh (VRM) giật khi hiện lần đầu (bộ nhớ `reference-shader-compile-measurement`).
