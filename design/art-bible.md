# Art Bible — Đảo Cối Nước (Vân Miên Đảo)

> Tài liệu chuẩn hóa định hướng mỹ thuật cho `dao-coi-nuoc.html`. Các mã hex, tên hàm và hằng số giữ nguyên theo mã nguồn; giá trị nào đang có sẵn được ghi `(hiện tại: ...)`, giá trị cần chỉnh cho các vòng sau được ghi `(đề xuất: ...)`.

---

## 1. Ý tưởng hình ảnh

**Không khí chung:** Đảo Cối Nước là một góc cổ tích lơ lửng giữa tầng mây — nơi cô phù thủy trẻ Linh sống cùng chú mèo đen Mun trong căn nhà gỗ ghép tường vữa có bánh xe nước quay bên dòng suối. Diorama phải tạo cảm giác như một mô hình tiểu cảnh làm bằng tay đặt trên bàn gỗ dưới ánh sáng tự nhiên: ấm áp, êm dịu, hơi hậu đậu nhưng chan chứa sinh khí. Dù trang mở nền cả ngày như một "tranh sống", từng giờ và từng mùa đều chuyển biến tinh tế từ sương mai dịu mắt đến bếp lửa ấm buổi đêm, để người xem luôn muốn ghé nhìn xem Linh và đàn gà lửa đang làm gì.

**Ba trụ cột thị giác:**
1. **Tiểu cảnh thủ công ấm áp (Tactile Handmade Miniature):** Gỗ bào sờn, ngói rêu phong, đá cuội xếp tay và ánh đèn lồng vàng mật ong là trung tâm cảm xúc; ưu tiên chất liệu mờ ấm (`roughness` cao) thay vì bề mặt trơn láng.
2. **Nhịp thở ánh sáng theo giờ và mùa (Living Daylight & Seasonal Mood):** Bầu trời, độ ấm ánh nắng, tán lá và độ phủ tuyết đồng bộ như một hệ sinh thái khép kín từ rạng đông đến khuya và xuyên suốt 4 mùa.
3. **Phép thuật đời thường (Cozy Domestic Magic):** Phép thuật không khoa trương hay công nghệ hóa; nó chỉ lấp ló qua những đốm sáng đom đóm, lọ thuốc phát sáng trong tháp đá, tinh thể phát quang dưới gầm đảo và đàn gà lửa tí tách bên chuồng.

**Ba điểm quy chiếu tinh thần (mô tả bằng lời):**
1. *Mô hình sa bàn thủy tinh / nhà búp bê Bắc Âu-Nhật Bản:* tỷ lệ hơi mũm mĩm, ấm gỗ, cửa sổ mái nhô ra, lộ nội thất ấm cúng khi mở mái nhà.
2. *Thế giới đồng thoại phù thủy làm vườn:* mái ngói phủ rêu xen lá thu, cối xay gió đá cuội, ao cá koi có cầu gỗ bắc ngang, phép thuật gắn với bếp núc và thảo mộc.
3. *Tranh màu nước và ánh đèn đêm ấm:* bầu trời chuyển sắc mềm, ban đêm tối vừa đủ để giữ sắc xanh lam sâu mà vẫn sáng rõ các ô cửa hổ phách và đèn đường pha lê.

**Hòn đảo không bao giờ được phép trông như:**
- Một trạm không gian hay thế giới sci-fi (cấm lưới lục giác kỹ thuật số, ánh neon chói lòa, viền năng lượng kiểu game bắn súng).
- Nhựa bóng hay đất nặn sơn dầu trơn trượt (`roughness` thấp tạo mảng phản chiếu lóa trên đất đá).
- Bối cảnh kinh dị u tối bệt đen mất chi tiết vào ban đêm hoặc lúc giông bão.

---

## 2. Bảng màu

### Bảng màu nền tảng (Base Palette)

| Vai trò | Hex | Ghi chú |
|---|---|---|
| Nền trời ban ngày (zenith) | `#478a90` | Hiện tại: `STOPS` (11h); `(đề xuất: #4f949e)` trong trẻo hơn |
| Chân trời ban ngày (horizon) | `#9cc2b6` | Hiện tại: `STOPS` (11h); `(đề xuất: #b8d8d2)` sáng nhẹ hơn |
| Nền trời đêm sâu | `#0f162c` / `#1e2c4c`..`#233356` | Hiện tại: `STOPS` (0h/4.8h/20.2h/24h) |
| Gỗ sẫm kết cấu nhà | `#4d3221` / `#432c1d` | Hiện tại: `cD()` trong `buildHouse` |
| Gỗ ván ấm & thân cây | `#a0704c` / `#54392a` | Hiện tại: `cW()` (`buildHouse`) và `buildTrees` |
| Tường vữa kem ấm | `#e4d8bf` | Hiện tại: `cP()` (`buildHouse`) |
| Đá xám ấm | `#8f8880` / `#7d766e` | Hiện tại: `cS()` (`buildHouse`), `C.rock` (`#77706a`) |
| Ngói nâu rêu | `#5a3a2a` + `#5f6c34` | Hiện tại: `buildHouse` (mái nhà) |
| Ngói đá phiến tháp | `#3d4250` / `#454a59` | Hiện tại: `buildHouse` (mái nón tháp) |
| Cỏ đồng nội mùa thu | `#566f2c` → `#8d8439` | Hiện tại: `C.g1`..`C.g3` trong `groundCol` |
| Nước ao sâu | `#041314` → `#0d332e` | Hiện tại: `buildWater` (`vec3(.015,.075,.08)`..`vec3(.05,.2,.18)`) |
| Ánh đèn ấm nội thất / cửa sổ | `#ffb066` / `#ffb35c` | Hiện tại: `inLight`, `porch`, `anim.glass` emissive |
| Tinh thể gầm đảo | `#c9a8ff`/`#7a3dff`, `#a8fff0`/`#1fc8b0` | Hiện tại: `Deep.cm` (`buildDepths`) |
| Nhấn giao diện (vàng hổ phách) | `#e9b872` trên `#14201f` | Hiện tại: `--glass-on` và `--glass` trong `<style>` |

### Theo thời gian trong ngày (`STOPS` trong `applyTime`)

| Giờ | Bầu trời (`zen` / `hor`) | Ánh nắng (`sun`) & `si` | Tán lá & Mặt đất | Ghi chú hiện tại vs đề xuất |
|---|---|---|---|---|
| **Bình minh (05:30)** | `#27345c` / `#c98067` (hiện tại) | `#ff8a4f`, `si=0.0`, `env=0.5` (hiện tại) | Nhuốm hồng-đồng nhạt từ `hor` | *Chưa thấy ảnh AD1*; cần kiểm tra `si=0` có làm cảnh quá tối trước 06:00 không `(đề xuất: si=0.45..0.6)` |
| **Buổi sáng (06:30–08:00)** | `#3a6a78`→`#3f8284` / `#e6b187`→`#8fb9a9` (hiện tại) | `#ffb06a`→`#ffd09a`, `si=2.1..3.3` (hiện tại) | Tán sáng ấm, bóng đổ dài rõ | Nửa dưới `skyMat` (`low`) đã sáng hơn: `mix(hor,zen,.6)*.78` (AD3) |
| **Trưa (11:00–15:30)** | `#478a90` / `#9cc2b6` (hiện tại) | `#fff1dc`, `si=3.7`, `env=1.0` (hiện tại) | Màu chuẩn mùa, tương phản rõ | Nửa dưới bầu trời đã sáng hơn nhờ `low=mix(hor,zen,.6)*.78` (AD3) |
| **Hoàng hôn (17:30–19:12)** | `#5a7c96`→`#4b5582`→`#222c54` / `#f2c28e`→`#f5a066`→`#866078` | `#ffb46a`→`#ff8045`→`#8aa0de`, `si=2.8→1.5→0`, `env=0.86→0.76→0.64` (hiện tại) | Ấm và đọc rõ khối ở 18:00 nhờ `si`, `env` và đèn bật từ `17.0–18.4h` | Đã cập nhật ở AD2; `fireOn` vẫn giữ `hour>18.7` (chờ AD2b nếu cần đồng bộ khói/lò sưởi) |
| **Đêm (20:20–24:00)** | `#111933`→`#0f162c` / `#233356`→`#1e2c4c` (hiện tại) | Trăng `#9cb4f0`, `si=1.25`, `env=0.78` (hiện tại) | Cỏ, cối xay gió và hàng thông giữ được sắc lam-lục tối có khối | Đã nâng ở AD2 (`c1=#384468`/`#344062`, `c2=#202744`/`#1d243e`) |

### Theo mùa (`SEAP` & `buildTrees` `PAL`)

| Mùa | Tán lá (`SEAP.leaf` / `PAL`) | Cỏ (`SEAP.grass`) & Mặt đất | Trời & Nước |
|---|---|---|---|
| **Xuân (`0`)** | Xanh cốm non `#9fd46b`, `#b5df79`, `#8ccb5b`, `#c8e98a` + 16% hoa hồng `#f4a6c2`..`#ffffff` (hiện tại) | Cỏ tươi sáng `[0.8, 1.16, 0.74]` + cánh hoa rơi `SEAP.petal` (hiện tại) | Trong mát; `(đề xuất: đảo phụ xa thêm sắc hoa xuân)` |
| **Hạ (`1`)** | Xanh lục đậm `#4d8c39`, `#5c9b41`, `#437e33`, `#68a548` (hiện tại) | Cỏ xanh rậm `[0.84, 1.1, 0.78]` (hiện tại) | Khi giông (`storm`) trời ngả chì-chàm thẫm: `grey` lerp sang `#465363`, `sky0.z`/`sky0.h` hạ thêm `stormK*.18` (AD3) |
| **Thu (`2`)** | Cam-hổ phách-vàng `PAL`: `#e0812c`, `#d56a22`, `#d9642a`, `#ecb535`, `#f4b63f` + thông `#2c4f33` (hiện tại) | Cỏ vàng olive `[1, 1, 1]` + lá rụng dưới gốc `C.litter` `#c0632a` (hiện tại) | Trời ấm trong; nước xanh rêu phản chiếu bầu trời |
| **Đông (`3`)** | 90% lá rụng hết, còn ít lá khô `#8a6a4a`, `#7a5c40` và tán tuyết `#eef2f7`; thông phủ tuyết ở mặt trên (hiện tại) | `addSnow` phủ `vec3(.9,.93,.97)`, cỏ `[0.93, 0.95, 1.02]` (hiện tại) | `applyTime` pha trời `#a9bcc8`/`#d5dde2`; nước đóng băng `uIce` `0.62..0.96`; `(đề xuất: thêm tuyết lên viền đá bờ đảo & đảo phụ xa)` |

---

## 3. Ánh sáng

- **Mặt trời / Mặt trăng (`sun`):** `DirectionalLight` đổ bóng chính (`PCFSoftShadowMap`, `shadow.mapSize` `2048` ở `high` và `4096` ở `max`, vùng chiếu `[-18, 18]`). Ban ngày hướng nắng xiên tạo khối cho mái nhà và rặng thông; ban đêm `sun` đổi sang hướng `moonD` mang sắc lam nhạt `#8fa6e6`.
- **Ánh sáng môi trường (`bounce`, `fill`, `scene.environmentIntensity`):**
  - `bounce`: `HemisphereLight('#ffffff', '#6b5a3e', .34 * envLvl)`.
  - `fill`: `DirectionalLight` từ hướng ngược sáng `(-20, 14, 26)`, cường độ `.75 * envLvl`, màu pha giữa `sky0.s` và `sky0.h` để giữ chi tiết trong vùng râm.
  - Cần giữ tỷ lệ **nắng chính / phụ khoảng 3:1 vào ban ngày** (hiện tại `3.7 : 0.75` — tốt), và **không hạ `envLvl` xuống quá `0.64` ở chạng vạng và `>= 0.76` ở hoàng hôn/đêm** (đã cập nhật ở AD2: `18.5h env=0.76`, `19.2h env=0.64`, đêm `0.78`) để tránh hiện tượng sập tối.
- **Đèn đêm và cửa sổ (`inLight`, `porch`, `anim.glass`, `Place.lamps`, `anim.hearthL`):**
  - Cửa sổ nhà (`anim.glass` emissive `#ffb35c` tối đa `2.4`), đèn hiên (`porch`, `#ffb066`), đèn lò sưởi (`anim.hearthL`, `#ff9a4a`) và đèn cột pha lê dọc đường (`Place.lampGlow`) bắt đầu **bật ấm dần ngay từ 17:00–18:24** (đã cập nhật ở AD2: `night` dùng `sstep(17.0, 18.4, h)` trong `stepPlaces` và `// night-life lights`; đèn hiên `pOn = awake ? sstep(.3, .6, night) : 0`; cửa sổ có mức nền hoàng hôn `win = Math.max(inside, awake ? .65 * sstep(.15, .55, night) : 0)`). Riêng `fireOn` hiện vẫn giữ `hour>18.7` (thuộc phần logic chờ AD2b).
  - Đêm khuya sau khi Linh đi ngủ (`awake == false`), đèn đường giảm còn `0.18` (hiện tại) để giữ sự yên tĩnh, chỉ còn cửa sổ tháp hoặc lò sưởi âm ỉ.
- **Sương mù (`scene.fog`):** Chỉ bật rõ khi thời tiết `fog` (`fogK=1`), tuyết (`0.35`) hoặc mưa (`0.2`), cự ly tính theo khoảng cách camera `dd` (`near = dd * lerp(3, .45, fogK)`, `far = dd * lerp(8, 1.7, fogK)`). Màu sương pha `sky0.h` với `#9aa4aa`.

---

## 4. Hình khối và vật liệu

- **Tỷ lệ hòn đảo:** Mặt đảo bán kính `R = 13` (đường kính ~26 m), tỷ lệ thu gọn kiểu diorama: căn nhà (`HS = 1.3`, rộng ~6.8 m) nằm hơi lệch sau-trái làm điểm neo thị giác; phía trước là sân, suối, ao cá và cối xay gió; bên phải là vườn bí và chuồng gà. Camera mặc định (`HERO_DIR = (-.62, .56, .69)`, `startDist = 67`, `fov = 26°`) đặt đảo trọn vẹn ở giữa khung hình cùng vài đảo nhỏ xa.
- **Ngôn ngữ hình khối:**
  - Đường nét **hơi bầu bĩnh, bo góc nhẹ (`rbox`), bất đối xứng tự nhiên**: thân cây uốn cong theo `taperTube`, mái tháp hơi nghiêng, vành mũ phù thủy lượn sóng, ngói xếp lệch góc nhẹ.
  - Tránh mép cắt vuông thành sắc cạnh hoặc bậc thang vuông vức (như đầu hồi tường tam giác ghép khối bậc thang khi mở mái nhà cần được vát chéo bằng `slopedBox` thay vì xếp bậc).
  - Đáy đảo (`buildBowl`) nên trông như khối đất đá nứt gồ ghề gắn kết rễ cây, **không** trơn tròn như vỏ gáo dừa hay bát gốm.
- **Nhóm vật liệu chính:**
  - **Gỗ (`woodMat`):** `roughness: 0.85`, có map vân gỗ + `bumpScale: 1.6`. Mộc mạc, không bóng.
  - **Đá (`stoneMat`):** `roughness: 0.92`, `bumpScale: 2.4`. Dùng cho móng nhà, ống khói, tháp, cối xay gió, đường lát cuội.
  - **Mái nhà & Tháp:** Ngói gỗ phủ rêu (`#5a3a2a`..`#5f6c34`) và đá phiến xám xanh (`#3d4250`), độ nhám cao, xếp từng phiến nổi khối.
  - **Tán lá & Cỏ:** Lá mảng phẳng `InstancedMesh` tụ thành từng cụm tròn mềm trên đầu cành; cỏ 3 lá mỏng vuốt nhọn (`buildGrass`), `roughness: 0.85`, chuyển động gió theo `uWind`.
  - **Nước (`buildWater`):** Shader bán trong suốt có sóng FBM, phản chiếu bầu trời theo Fresnel, bọt trắng ở ghềnh/thác, đóng băng có vết nứt khi mùa đông (`uIce`). Lưu ý: dòng thác đổ khỏi mép đảo phải uốn cong và tan thành sương bọt ở chân thác thay vì dải thẳng đơ.
  - **Đáy đảo & Tinh thể (`buildBowl`, `buildDepths`):** Đá đáy đảo **bắt buộc dùng `roughness >= 0.88`** (đã chỉnh lên `0.92` với tông đất đá trầm `#4a3a2e` / `#725845` / `#5e4d41` / `#382b22` tại AD2), lưu `Deep.bowlMat` để nhận `addSnow` vào mùa đông, và mép `lip` trong `buildTerrain` pha `0.65` vào `#4a3a2e` thay vì cắt gắt; tinh thể lục giác đáy đảo (`#c9a8ff`, `#a8fff0`) phát sáng dịu vừa phải (`emissiveIntensity ~0.6–0.9`) để giữ vai trò phép thuật ẩn sâu, không lấn át mặt đảo.
- **Mức độ chi tiết bề mặt:** Texture procedural 512×512 hạt mịn (`tileNoise`) kết hợp màu đỉnh (`vertexColors`) + hiệu ứng rêu/lá rụng; tránh họa tiết sắc nét kiểu ảnh chụp hay bề mặt trơn lì không hạt.
- **Độ sâu trường ảnh (`dofQ`):** Giữ `dofQ` nhẹ để tạo cảm giác mô hình thu nhỏ ở tầm gần, nhưng **không làm mờ chủ thể chính hay biến đốm sáng thành chấm rỗ**. AD3: giảm `amt` từ `Hh/1080*9` xuống `Hh/1080*5` và hệ số focus từ `1.25` xuống `0.95`, vùng rõ nét rộng hơn, bán kính bokeh giảm gần nửa.

---

## 5. Nhân vật

- **Linh (mô hình VRoid toon `MToon` trong `dao-model-*.js`):**
  - Bảng màu hiện tại (`styleLinh`): tóc đen ánh tím `#34323f`, mắt tím `#b08cff`, áo cardigan màu yến mạch `#b6a585`, váy/quần `#2d2737`, giày `#5b3f2c`, mũ phớt `#2b2530` kèm dải ruy-băng nâu đỏ `#7a3d2c`.
  - **Vấn đề đọc hình:** Đã bổ sung `parametricRimColorFactor '#e2d2c0'` với `parametricRimFresnelPowerFactor=4.5`, `parametricRimLiftFactor=0.08` (AD3), tạo viền kem ấm mảnh giúp Linh tách khỏi nền.
  - **Quy tắc kết hợp:** Giữ chất liệu MToon dịu (không chói màu anime gắt), viền sáng ấm mảnh (`parametricRimColorFactor '#e2d2c0'`, power `4.5`), áo cardigan `'#c4b494'` (shade `'#7a6b56'`) sáng hơn gỗ hàng rào.
- **Đàn gà lửa (`buildHens`):** Thân nâu sẫm `#3a2620` với mào và đuôi lửa cam-vàng phát sáng (`#fff0a0`→`#ff7a1a`). Tỷ lệ tách biệt rất tốt, là điểm dẫn mắt tự nhiên quanh chuồng gà — giữ nguyên phong cách này.
- **Cá koi (`Crit.koi`):** Thân trắng ngà `#f6f2ea` đốm cam đỏ `#ff7a2a`/`#d8261c` với vây bán trong suốt (`forceSinglePass: true`). Độ tương phản với nền nước xanh thẫm `#041314` rất tốt.
- **Mun (`Life.cat`):** Mèo đen `#17141f` với đôi mắt vàng hổ phách phát sáng (`#ffd76a`, `emissiveIntensity: 1.6`). Vì lông rất tối, ở tầm xa và ban đêm cần giữ ánh mắt vàng và bóng khói tím `#2a2040` rõ ràng; khi Mun bước ra thảm cỏ tối có thể nâng lông lên xám than rất đậm `#231f2e` để vẫn thấy phom dáng mèo thay vì chấm đen bệt.
- **Nimbus (`Crit2.sheep`):** Cừu mây `#e8ecf2` (AD3: hạ từ `#f6f8fb`), `emissiveIntensity:0` (AD3: tắt emissive); sắc trắng ngà dịu hơn để không cướp tiêu điểm khỏi Linh và ngôi nhà.

---

## 6. Hiệu ứng và thời tiết

- **Mưa (`rain` & `anim.rain`):** 2400 vạch mưa sắc xanh nhạt `vec4(.8,.88,.95,uA)`. Cần tăng độ mềm/ngẫu nhiên về độ dài và độ mờ theo khoảng cách để vệt mưa không trông như lưới gạch thẳng đều tăm tắp.
- **Giông (`storm`):** Phải phân biệt rõ với mưa thường! Bầu trời và mây khi `storm` cần tối sâu và lạnh hơn (`#3d4a5a` thay vì cùng màu xám nhạt `#6a7780` như mưa xuân), tăng ánh chớp phản chiếu trên mái/nước, giữ đèn cửa sổ nhà bật ấm tạo tương phản "trú ẩn ấm áp".
- **Tuyết (`snow` & `addSnow`):** Hạt tuyết tròn mềm bay chậm (`anim.snow`), đồng bộ với lớp phủ tuyết `vec3(.9,.93,.97)` trên mặt hướng lên trời. Riêng `buildGrass` cần phủ tuyết giảm dần theo chiều cao lá (`vH`) thay vì làm xám trắng đều cả bụi cỏ.
- **Đom đóm (`anim.fireflies`) & Bướm đêm (`Crit2.moths`):** Đom đóm mùa hạ dùng sắc vàng-lục ấm (`Color(4, 5.4, 1.2)`), số lượng vừa phải (40 đốm), bay thấp quanh thảm cỏ và ghế đá; không tăng mật độ gây rối khung hình.
- **Phép thuật (`Magic`):** Màu sắc gắn với từng phép (tím `#a880ff`, vàng ấm, xanh ngọc, lửa than), điểm nhấn phải nhỏ gọn và mềm. Đốm tinh linh đi theo Linh (`Magic.wisp`) dùng độ phân giải/dạng hào quang mịn để khi `dofQ` hoạt động không bị vỡ thành hình tròn lấm tấm hạt.
- **Vòm bảo vệ (`Place.ward`):** **Không được phép trông giống khiên lục giác khoa học viễn tưởng (`hexd`, `vec3(.3,.6,1.2)`)** và **tuyệt đối không bật/đọng lại vào ban ngày hoặc khi trời mưa/tuyết**. Đã đổi shader sang **vòng cổ ngữ mờ và sương ánh trăng vàng-oải hương nhạt** (`vec3(.88,.76,1.)` pha `vec3(1.,.86,.58)`, độ sáng giữ ở `uA*.34` / `uA*.15` (AD3: giảm mist từ `.22`) và `vis=smoothstep(.02,.2,uA)`) ôm sát vành đảo (`vUv.y ~ 0.27`, Fresnel power `3.2`, mist Gaussian `σ=.08`; AD3: thu hẹp + nâng vị trí) và tan nhanh; phần logic tắt `Wd.t` / `Wd.d.visible` chờ AD2b xử lý.
- **Mây (`anim.clouds`):** Các cụm mây phẳng xoay theo góc nhìn (`puffTex`) nhẹ nhàng, ánh theo màu `sky0.c1` / `sky0.c2`, đứng lùi xa sau đảo để không che tán cây chính.

---

## 7. Giao diện

- **Bảng màu & Chất liệu:** Kính mờ tối sâu màu rừng thông (`--glass: #14201f8c` cho nút, `#14201fd9` cho bảng nổi, `backdrop-filter: blur(8px..10px)`), viền mảnh `--ink-faint` (`#f4efe240`), chữ màu giấy kem ấm `--ink` (`#f4efe2`), chữ phụ `--ink-dim` (`#f4efe2b3`). Trạng thái bật/nhấn dùng vàng hổ phách ấm `--glass-on` (`#e9b872`) với chữ nâu sẫm `--on-ink` (`#1d1710`).
- **Kiểu chữ & Bo góc:**
  - Tiêu đề, đồng hồ, lời kể và nội dung Sổ dùng serif văn học (`--display: "Literata", Georgia, serif`) tạo giọng kể chuyện ấm áp; nút và nhãn chỉ số dùng sans gọn (`--ui: "Be Vietnam Pro", system-ui, sans-serif`).
  - Bo góc thống nhất `border-radius: 3px` — vuông vắn gọn gàng như thẻ ghi chú và gáy sổ tay, không bo tròn quá mức kiểu ứng dụng di động.
- **Quan hệ với cảnh 3D:** Toàn màn hình là thế giới 3D; HUD bám sát mép trên/dưới với `text-shadow` dịu và thanh trượt ngày-đêm mang phổ màu bầu trời (`#121a33` → `#d98a58` → `#b9d2cf` → `#e39a55` → `#3a2c52`). Khi thẻ `#spot` (chỗ làm việc) mở cùng lúc với `#ledger` (Sổ của Mun), cần tăng nhẹ độ tương phản viền hoặc bóng đổ quanh `#spot` để hai thẻ không hòa làm một.

---

## 8. Tiêu chí duyệt (Review Criteria)

Mỗi vòng kiểm tra ảnh chụp ở độ phân giải `1280×720` (hoặc `1440p`) phải chấm **pass / fail / not judged** theo đúng 7 tiêu chí sau:

- **(a) Đọc rõ tiêu điểm dưới 1 giây:** Tiêu điểm của góc máy (căn nhà cối nước ở góc nhìn tổng thể, hoặc Linh/vật dụng ở góc cận) tách bạch ngay lập tức, không bị tán lá tiền cảnh, tối sập hay hiệu ứng làm mờ che mất đường nét chính.
- **(b) Đồng bộ màu giờ và mùa:** Bầu trời, ánh nắng, tán lá, mặt cỏ và các đảo phụ xa thể hiện đúng không khí giờ trong ngày và mùa được chụp; vùng tối giữ được khối, bầu trời không bị xỉn bùn ở nửa dưới, và các trạng thái thời tiết (mưa vs giông) phân biệt rõ.
- **(c) Nhất quán phong cách thủ công cổ tích:** Toàn bộ kiến trúc, địa hình và phép thuật giữ cảm giác chất liệu mộc mạc (gỗ, đá, sương, cổ ngữ); không có chi tiết khoa học viễn tưởng (lưới lục giác), bề mặt nhựa bóng hay bậc thang khối thô trên đường chéo.
- **(d) Độ nổi của nhân vật và sinh vật:** Linh, Mun và các sinh vật (gà lửa, cá koi, Nimbus) đọc được phom dáng và tách khỏi nền xung quanh ở tầm cận lẫn tầm trung, không có sinh vật phụ nào sáng chói lấn át nhân vật chính.
- **(e) Chuyển tiếp liền mạch của mép đảo và đáy đảo:** Ranh giới `R=13` nối tự nhiên từ mặt cỏ/tuyết sang đá, rễ và đáy đất nhám (`roughness >= 0.88`), không lộ vệt cắt trơn bóng hay dòng thác cứng thẳng.
- **(f) Hiệu ứng và DOF sạch mắt:** Hạt mưa, tuyết, phép thuật, tia nắng và `dofQ` hỗ trợ chiều sâu mà không gây đốm bokeh lấm tấm trên đốm sáng, không che rối màn hình hoặc làm nhòe chủ thể chính.
- **(g) Giao diện gọn, đọc rõ trên nền cảnh:** Khi HUD hoặc bảng nổi mở, chữ kem trên nền kính tối `#14201f` đủ tương phản trên mọi nền trời và các thẻ nổi tách bạch rõ khi mở chồng.

---

## 9. Ngân sách hiệu năng

- **Mục tiêu khung hình:** **60 fps** trên GPU **GTX 1660 SUPER** ở `1280×720` đến `1440p` khi tương tác, **20–30 fps** khi để yên (`idle`).
- **Biên dịch shader lúc khởi động (`renderer.compileAsync`):** Mọi vật liệu và biến thể shader (kể cả tuyết, mưa, sấm sét, đom đóm, nội thất và hiệu ứng ẩn) phải nằm sẵn trong scene lúc boot; tuyệt đối không tạo `ShaderMaterial` hay đổi khóa `onBeforeCompile` mới giữa phiên chạy vì sẽ gây khựng (~0.35 s/shader). Ưu tiên chỉnh uniform hoặc bảng màu trên vật liệu sẵn có.
- **Không tự ý thêm render pass hay shadow caster:** Giữ nguyên chuỗi `rtScene` → `aoQ` → `prepQ` + `dofQ` → `bloom` → `shQ` → `finalQ` và các mức chất lượng `QUAL` (`low`/`mid`/`high`/`max`). Mọi đề xuất thêm pass, tăng tap lấy mẫu hoặc thêm đèn đổ bóng đều phải ghi rõ chi phí ước lượng.
