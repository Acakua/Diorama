# AD3 — Đánh giá ảnh AD2-r2 và danh sách chỉnh sửa

> Đánh giá 11 ảnh trong `.orchestra/shots/AD2-r2/` so sánh trực tiếp với `.orchestra/shots/AD1/`, dựa trên tiêu chí (a)–(g) của `design/art-bible.md` §8. Sau đó liệt kê mọi thay đổi trong vòng AD3 (giá trị cũ → mới, lý do).

---

## 1. Nhận xét từng ảnh AD2-r2

### `01-autumn-0700-morning.jpg` (07:00 · thu · toàn cảnh)
So sánh AD1→AD2: Đáy đảo chuyển từ nâu cam bóng gốm sang tông đất-đá trầm mờ (`roughness 0.92`) — cải thiện lớn, mép viền không còn cắt cam gắt. Nửa dưới bầu trời vẫn hơi xỉn olive nhưng bớt nặng hơn AD1. Linh vẫn chìm vào nền ở tầm xa. Nimbus vẫn là điểm sáng nhất.

### `02-autumn-1200-noon.jpg` (12:00 · thu · toàn cảnh)
Đáy đảo rõ cải thiện. Bầu trời trưa vẫn hơi xỉn ở vùng dưới chân trời do `low = mix(hor,zen,.75)*.62` chưa thay đổi. Các đảo phụ xa vẫn giữ sắc thu cố định (`#c8542a`, `#6f8f3a`) — không thay đổi theo mùa. Dải thác vẫn thẳng cứng (P3 ngoài phạm vi AD3).

### `03b-autumn-1730-golden.jpg` (17:30 · thu · toàn cảnh)
**Ảnh mới.** Ánh nắng ấm vàng rất đẹp, cửa sổ bắt đầu phát sáng hổ phách nhẹ. Đây là cải thiện có giá trị lớn nhất của AD2 — "giờ vàng" trước hoàng hôn ấm áp và dễ chịu, tạo chuyển tiếp mượt sang `03`.

### `03-autumn-1800-sunset.jpg` (18:00 · thu · toàn cảnh)
**Cải thiện đáng kể so AD1.** AD1 ở 18:00 sập tối bệt hoàn toàn, AD2-r2 cho thấy cửa sổ hổ phách sáng rõ, đèn hiên bật, đèn đường pha lê nhấp nháy. Mặt sân và cây vẫn tối hơn mong muốn nhưng giữ được khối nhờ `si=1.5` và `env=0.76` ở stop `18.5h`. Chuyển tiếp tốt hơn nhiều.

### `03c-autumn-1900-dusk.jpg` (19:00 · thu · toàn cảnh)
**Ảnh mới.** Chạng vạng tím-chàm sâu, cửa sổ sáng hổ phách mạnh, đèn pha lê dọc đường phát sáng. Gradient bầu trời cam→tím→chàm sâu rất đẹp. `env=0.64` ở `19.2h` giữ được phom thông và cối xay gió mà không bệt đen.

### `04-autumn-2200-night.jpg` (22:00 · thu · toàn cảnh)
**Ward:** Lưới lục giác sci-fi đã bị xóa hoàn toàn — cải thiện quyết định. Thay vào đó là vòng cổ ngữ ôm sát mép đảo + sương Fresnel ánh trăng vàng-oải hương. **Nhưng** vòm sương Fresnel quá sáng và bao trùm toàn bộ bán cầu, nhìn như một quả cầu thủy tinh sữa phủ kín đảo, che mờ đường nét bầu trời đêm phía sau. Vòng cổ ngữ ở `vUv.y=0.255` nằm dưới bệ đảo, hơi thấp so với mép cỏ. Ánh sáng môi trường đêm cải thiện rõ: cối xay gió, hàng thông và mặt cỏ giữ được sắc lam-lục tối.

### `06-spring-1500-rain.jpg` (15:00 · xuân · mưa · toàn cảnh)
Ward không hiện — sửa đúng. Mùa xuân xanh non + hoa đào tươi tắn. Vệt mưa vẫn đều và thô (P3). Đáy đảo tối hơn nhưng mờ nhám — đúng hướng.

### `07-summer-1600-storm.jpg` (16:00 · hạ · giông · toàn cảnh)
Ward không hiện — sửa đúng. **Nhưng** bầu trời giông mùa hạ vẫn gần như giống hệt mưa xuân (`06`) — cùng tông xám-xanh đều `#6a7780`, không có sắc chì/chàm sâu kịch tính phân biệt giông bão. Đây vẫn là lỗi P2 chưa sửa.

### `08-winter-1100-snow.jpg` (11:00 · đông 35 giây · tuyết · toàn cảnh)
Đáy đảo nhận `addSnow` — tuyết bám mỏng lên bề mặt đáy (cải thiện). Mép viền không còn cắt cam gắt. **Nhưng** hai đảo phụ xa phía trên vẫn giữ nguyên sắc thu cam-xanh rực, không đổi theo mùa đông — phá vỡ sự thống nhất. Tuyết mặt đất mỏng (do mới 35 giây — bình thường).

### `08b-winter-1748-dusk-snow.jpg` (17:48 · đông · tuyết · toàn cảnh)
**Ảnh mới.** Khung cảnh mùa đông chiều muộn rất đẹp: tuyết phủ dày, cửa sổ sáng ấm, bầu trời xám-tím. Đảo phụ xa vẫn giữ sắc xanh lục — cần đồng bộ.

### `09-autumn-1300-roof-lifted.jpg` (13:00 · thu · mở mái nhà)
Nội thất đẹp, chi tiết phong phú. Linh ở trong nhà với vạc thuốc phát sáng tím. DOF mờ mạnh ở rìa hình — đỉnh ống khói, tán cây rìa, và vườn rau bên phải bị nhòe rõ. Bậc thang đầu hồi tường vẫn còn (P2 issue #9 từ AD1 — ngoài phạm vi trực tiếp nhưng sẽ cải thiện gián tiếp qua DOF).

---

## 2. Bảng tiêu chí (a)–(g): so sánh AD1 → AD2-r2

| Tiêu chí | AD1 | AD2-r2 | Ghi chú |
|---|---|---|---|
| **(a) Đọc rõ tiêu điểm dưới 1 giây** | fail (03, 04 tối bệt) | pass (03/03b/03c đọc rõ nhà + đèn) | Cải thiện đáng kể nhờ STOPS và bật đèn sớm |
| **(b) Đồng bộ màu giờ và mùa** | fail (giông=mưa, đêm bệt) | partial (đêm sáng hơn, nhưng giông≈mưa, đảo xa≠mùa) | Giông chưa phân biệt; đảo xa không đổi mùa |
| **(c) Nhất quán phong cách thủ công cổ tích** | fail (ward hex sci-fi) | pass (ward → cổ ngữ+sương; đáy nhám; nhà ấm) | Cải thiện quyết định |
| **(d) Độ nổi nhân vật và sinh vật** | fail (Linh chìm, Nimbus quá sáng) | fail (Linh vẫn chìm, Nimbus vẫn sáng gắt) | Chưa sửa styleLinh/Nimbus |
| **(e) Chuyển tiếp mép đảo và đáy đảo** | fail (bóng gốm, cắt cam) | pass (roughness 0.92, lip lerp #4a3a2e) | Cải thiện lớn |
| **(f) Hiệu ứng và DOF sạch mắt** | fail (DOF=9, wisp vỡ bokeh) | fail (DOF=9 chưa đổi, wisp chưa đổi) | Chưa sửa |
| **(g) Giao diện gọn, đọc rõ trên nền cảnh** | pass | pass (không đổi HUD) | Giữ nguyên |

---

## 3. Danh sách thay đổi vòng AD3

### 3.1. Nửa dưới bầu trời (`skyMat`) — AD1 issue #7

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| `low` trong `skyMat` fragment | `mix(hor,zen,.75)*.62` | `mix(hor,zen,.6)*.78` | Nửa dưới bầu trời bớt tối đục olive/xám, thoáng sáng hơn, bao quanh đáy đảo tự nhiên hơn |

### 3.2. Phân biệt giông và mưa (`applyTime`, `stormK`) — AD1 issue #7

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| `grey` dùng cho `ovK` | `col('#6a7780')` cả mưa lẫn giông | Khi `stormK>0`: grey lerp thêm sang `'#465363'` và hạ `sky0.z`/`sky0.h` thêm `stormK*.18` | Trời giông chì xám sâu, lạnh hơn hẳn mưa xuân |

### 3.3. Đọc hình Linh (`styleLinh`) — AD1 issue #6

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| `parametricRimColorFactor` | `'#000000'` (tắt rim) | `'#e2d2c0'` (rim kem ấm) | Viền sáng mảnh giúp Linh tách khỏi nền gỗ/cỏ |
| Áo cardigan `Tops` color | `'#b6a585'` / shade `'#6c5d4a'` | `'#c4b494'` / shade `'#7a6b56'` | Sáng nhẹ hơn để không lẫn hàng rào gỗ |

### 3.4. Giảm sáng Nimbus (`buildCreatures2`) — AD1 issue #6

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| Nimbus wool `std(...)` | `'#f6f8fb'`, emissive `'#c8d8ff'`, `emissiveIntensity:.05` | `'#e8ecf2'`, emissive `'#c8d8ff'`, `emissiveIntensity:0` | Giảm chói để không lấn át Linh ở tầm xa |

### 3.5. Giảm DOF (`prepQ` / `dofQ`) — AD1 issue #8

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| `prepQ.material.uniforms.amt.value` | `Hh/1080*9` | `Hh/1080*5` | Giảm bán kính mờ gần một nửa; cảnh vẫn có độ sâu tilt-shift nhẹ nhưng không nhòe rìa và không vỡ bokeh trên đốm sáng |
| `abs(z-focus)/z*1.25` trong `prepQ` shader | `1.25` | `0.95` | Nới vùng rõ nét rộng hơn ở tầm trung |

### 3.6. Giảm wisp HDR (`Magic.wisp`) — AD1 issue #8

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| `Magic.wisp` color | `Color(3,4,7)` | `Color(1.5,2.1,3.6)` | Giảm cường độ HDR quá gắt gây vỡ đốm bokeh thành đĩa chấm khi DOF hoạt động |

### 3.7. Giảm vòm Fresnel ward quá sáng (`Place.ward` shader) — Lỗi mới AD2-r2

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| `mist` Gaussian center | `(vUv.y-.27)/.11` | `(vUv.y-.27)/.08` | Thu hẹp dải sương về sát mép đảo thay vì phủ toàn bán cầu |
| `mist` Fresnel power | `pow(...,2.6)` | `pow(...,3.2)` | Fresnel chỉ bắt sáng mạnh ở mép nhìn ngang, không phủ trắng toàn bề mặt |
| Rune band y center | `vUv.y-.255` → `gp.y = (vUv.y-.255)*22.` | `vUv.y-.27` → `gp.y = (vUv.y-.27)*22.` | Nâng vòng cổ ngữ lên sát mép đảo thay vì dưới bệ |
| Mist coefficient | `uA*.22` | `uA*.15` | Giảm sương để không che bầu trời đêm |

### 3.8. Đảo phụ xa đồng bộ mùa đông (`buildDepths`) — AD1 issue #5

| Giá trị | Cũ (AD2-r2) | Mới (AD3) | Lý do |
|---|---|---|---|
| Cỏ đảo xa (`jitter('#6f8f3a',...)`) | Màu xanh cố định | Thêm `addSnow` cho `hazeMat` nếu có thể; nếu không, đổi sang tông trung tính hơn `'#8a8870'` để bớt xanh rực khi tuyết phủ chính đảo | Giảm xung đột thị giác khi mùa đông |
| Foliage palette `fol` | `['#c8542a','#d9822b','#e8b13a','#8a3a22','#6f8a3a']` (thu cố định) | `['#8a7a6a','#9a8a72','#a89878','#7a6a5a','#6a7a5a']` (trung tính bốn mùa) | Tông nâu-xám trung tính hòa với mọi mùa; `hazeMat` pha haze 28–72% vào `uHor` nên sắc sẽ theo bầu trời |

---

## 4. Chi phí hiệu năng

Không có chi phí bổ sung: tất cả thay đổi đều sửa uniform, constant, hoặc shader đã có lúc boot. Không thêm material, render pass, hay shadow caster.
