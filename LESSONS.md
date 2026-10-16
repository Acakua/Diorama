# Bài học từ ESP32S3World (2026-09 → 2026-10-16)

Dự án dừng ngày 2026-10-16. File này để mang sang dự án mới: điều gì sai, điều gì đúng, cái gì dùng lại được.
Repo cũ vẫn còn nguyên (thẻ `archive-2026-10`); cần gì thì chép có chọn lọc, đừng kéo cả khối.

## 1. Vì sao dừng

Dự án bắt đầu từ một mục tiêu không phải người chơi: AI tiến hoá trên ESP32 → vua AI chọn lá bài → một thế giới để **xem**.
Mọi quyết định sau đó phục vụ mục tiêu ấy, nên khi muốn có người chơi thì phần chơi chỉ là thứ gắn thêm:

- **Luật được cân cho ổn định thống kê** (bảng điểm 8 seed × 80 năm, dân cuối kỳ, sai số), không cho lựa chọn thú vị của người chơi.
- **Mọi thứ tự động** (dân tự chia việc, quan lại tự xây, vua tự chọn bài); quyền người chơi phải chèn vào như ngoại lệ ("ghim vai",
  "tắt quan lại tự xây").
- **Hành động khó thấy kết quả**: giao thêm một nông dân thì vài ngày sau kho lúa nhích lên; người chơi không cảm thấy mình vừa làm gì.
- **Sai thang**: thế giới 192×144 ô, 30 nước, 4.000 người, một năm chỉ 6 ngày; người chơi cần một làng 20–50 người, từng đêm, từng trận.
- **Không có mục tiêu, thắng / thua, tiến trình** rõ ràng.
- Rất nhiều công sức (93 phiên bản luật, hàng trăm vòng đo) vào chiều sâu mô phỏng mà người chơi không bao giờ thấy.

## 2. Nguyên tắc cho dự án mới

1. **Thiết kế từ người chơi trước.** Viết ra (≤ 2 trang) trước khi viết mã: người chơi là ai, cảm giác cốt lõi, vòng 30 giây /
   5 phút / 1 giờ, thắng / thua / tiến trình. Mô phỏng chỉ tồn tại để phục vụ các vòng đó.
2. **Demo chơi được sớm nhất có thể**: một làng nhỏ, vài người, một mối đe doạ, chơi trong 10 phút. Chơi thấy vui rồi mới thêm.
3. **Mỗi hành động thấy kết quả ngay** (hình, tiếng, con số) và hậu quả muộn phải được báo lại cho người chơi.
4. **Thang thời gian, kích thước hợp người chơi** ngay từ đầu (nhịp ngày / đêm, số dân, bản đồ cận). Thế giới lớn nếu có thì chạy thô ở
   nền, phục vụ chuyện cho người chơi, không phải ngược lại.
5. **Đo bằng chơi thử** (người chơi làm gì mỗi phút, chỗ nào chán, chỗ nào rối), không đo bằng thống kê thế giới trước khi có thứ để chơi.
6. **Người chơi điều khiển trực tiếp; AI chỉ lo phần người chơi không muốn lo.** Đừng làm AI tự động hết rồi gỡ dần ra.
7. Mỗi tính năng mới phải trả lời được: *người chơi sẽ làm gì khác đi vì nó?* Không trả lời được thì chưa làm.

## 3. Điều đã làm đúng (giữ cách làm)

- **Tất định + hash**: cùng seed, cùng lệnh ở cùng lượt → cùng thế giới; ghi lệnh người chơi kèm lượt để phát lại. Bắt lỗi rất nhanh.
- **Công cụ chơi thử không cần trình duyệt** (`tools/playtest.c`): chạy cả ván vài giây, in chuyện và số liệu.
- **Một lệnh kiểm tra bắt buộc** trước khi commit (build không cảnh báo, tất định, hash, UBSan).
- **Mô phỏng chạy trong Web Worker**, trang chỉ vẽ snapshot; lệnh người chơi đi qua Worker giữa hai lượt.
- **Chữ kể chuyện sinh từ sự kiện** (biên niên sử) rất được: người chơi hiểu thế giới qua câu chuyện, không qua bảng số.
- **Tin tức tới chậm theo khoảng cách**, **tự dừng khi có chuyện**, **tua tới sáng**: các ý nhịp này nên giữ.
- **Mô hình có xương và animation miễn phí** thay vì tự dựng: nhanh và đẹp hơn nhiều.
- **Chọn việc theo trạng thái thật** (người chặt cây thì đứng cạnh cây, cầm rìu) thay vì đoán ngẫu nhiên ở phía hình.

## 4. Điều đã làm sai (tránh)

- Cân luật hàng tuần trên số liệu tổng (dân, làng, chiến tranh) khi chưa có người chơi; nhiều lần sửa "đúng logic" lại làm dân giảm 30–50%.
- Để thế giới quá rộng, quá nhanh; người xem không theo dõi được gì.
- Thêm nội dung (trùm, phép, hàng hoá, triều đại…) trước khi có vòng chơi cơ bản.
- Lịch nén (6 ngày / năm): ngày dài nhưng mùa, đời người trôi vèo; khó sửa về sau vì mọi tỉ lệ tính theo năm.
- Một file vẽ khổng lồ (`diorama.js` ~180 KB, nhiều dòng rất dài) khó sửa, khó đọc; chia module từ đầu.
- Tên làng sinh theo vị trí bị trùng nhau (hai "Greenmoor").

## 5. Bài học kỹ thuật

- **three.js r128** (một file, không build tool) gói thành **một HTML offline** (`tools/wasm/pack.py`): chạy bằng bấm đúp, tiện chia sẻ.
- **C → WASM bằng clang `--target=wasm32 -nostdlib`** + một `minilib.c` nhỏ (memcpy, strlen, `snprintf` tối giản %s %d %u %c %x) là đủ;
  không cần Emscripten. Xuất hàm bằng `--export=` từng cái; JS đọc mảng byte cố định (đừng để JS đoán bố cục struct C).
- **Người đông (hàng trăm) có animation**: VAT (ảnh xương trong DataTexture, shader trộn 4 xương × 2 khung, InstancedMesh, mỗi kiểu
  người một lệnh vẽ) — `tools/concept/crowd3d.js`, `make_crowd.js`. Dụng cụ cầm tay: tính ma trận tay trên CPU cùng phép chọn khung.
- **Ghép animation sang khung xương khác** (retarget, sửa lệch tư thế chữ T / chữ A theo hướng xương trong không gian thế giới):
  `tools/concept/retarget.js`.
- **FBX → GLB trong node** (three r128 + FBXLoader + GLTFExporter) rồi `gltfpack -noq` (**không lượng tử hoá**: r128 tính hộp bao sai).
  Ảnh nén còn 512 jpg bằng ffmpeg. Mô hình đơn vị cm: lấy hộp bao theo xương nếu hộp lưới lớn bất thường.
- **Hiệu năng**: đo bằng một cảnh cố định (seed + lượt + góc máy cố định, hash phải khớp); số lệnh vẽ và tam giác quan trọng hơn FPS
  trên máy mạnh. Gộp mọi thứ cùng loại vào InstancedMesh.
- **Mô phỏng**: lưới ô + trường khoảng cách (BFS) cho đường đi rẻ hơn A* từng người khi đông; mỗi chu kỳ (100 lượt) mới tính lại
  những thứ chậm.

## 6. Tài sản dùng lại được (chép từ repo cũ)

Đường dẫn tính từ gốc repo cũ `ESP32S3World/`. Thư mục `kit_src/` **không commit** (tải lại theo hướng dẫn trong
`tools/concept/kit_src/README.md`).

| Thứ | Ở đâu | Giấy phép |
|---|---|---|
| Nhà, công trình low-poly | KayKit Medieval Hexagon Pack 1.0 (Kay Lousberg) — `tools/concept/kit_src/kaykit_hex/`, dựng bằng `make_kit.py` → `kit_data.js`, `kit3d.js` | CC0 |
| Người trung cổ (14 kiểu) + 86 animation | Free Medieval 3D People Low Poly Pack + Quaternius Universal Animation Library 1+2 — `make_crowd.js` → `crowd_data.js`, `crowd3d.js` | CC0 (xem License trong gói People) |
| Lính (mũ, giáp vai, kiếm, khiên) | Quaternius Animated Knight Pack — `kit_src/knight/` | CC0 |
| Sói, hươu, yêu tinh, bộ xương | Quaternius Animated Animal Pack; KayKit Skeletons — `kit_src/rigged/` | CC0 |
| Warg, gấu | Daniel Gruginski "Creatures" — `kit_src/rigged/creatures/` | CC0 |
| Rồng (Ashwing Drake) | `docs/concept/Ashwing_Drake_Lite_v1.0.0/` (xem license trong thư mục) | xem file license |
| Rắn, cây ăn thịt, rồng tưởng tượng, Lurker | Sketchfab — `kit_src/rigged/*.glb` | **CC-BY-4.0: phải ghi công** (ghi công có sẵn trong `kit_src/README.md`) |
| Trình nạp có xương + animation theo trạng thái | `tools/concept/rig3d.js` (SPEC từng con, cắt clip con, đánh trúng theo ngưỡng máu) | mã của mình |
| Chuyển FBX → GLB, gắn ảnh | `tools/concept/fbx2glb.js`, `fbx2glb_tex.js`, `make_rig.py` | mã của mình |
| Gói HTML offline + Worker | `tools/wasm/pack.py`, `diorama_worker.js`, `template.html` | mã của mình |
| WASM không Emscripten | `tools/wasm/build.ps1`, `minilib.c`, `include/` | mã của mình |
| Bộ chữ biên niên sử tiếng Việt, tên người / làng / nước | `pc/common/realm_text.c` | mã của mình |
| Mặt đất, cây, nước, ngày / đêm (low-poly tối) | `tools/wasm/diorama.js` (mặt đất, gió cỏ, sương, đêm), `tree_data.js`, `ground_data.js` | mã của mình |
| Bài đo khung hình | `tools/wasm/diorama_bench.js` | mã của mình |

Hướng mỹ thuật đã chốt với người dùng: **low-poly, tối nhưng có màu, độ tối theo trạng thái thế giới**.

## 7. Câu hỏi phải trả lời ở buổi đầu dự án mới

1. Người chơi là ai (trưởng làng, lãnh chúa, thần hộ mệnh, một người dân)?
2. Một ván có kết thúc không (sống đủ X năm, hạ con trùm) hay chơi mãi?
3. Phần nào hứng thú nhất: giữ làng (đánh nhau), xây làng lớn, chuyện đời từng người, khám phá / săn trùm?
4. Một buổi chơi dài bao lâu?

Trả lời xong → viết bản thiết kế 1–2 trang → dựng demo 10 phút → chơi thử → mới thêm.
