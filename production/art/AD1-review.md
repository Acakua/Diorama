# AD1 — Đánh giá mỹ thuật vòng đầu (commit `43db1d7`)

> Đánh giá 10 ảnh trong `.orchestra/shots/AD1/` (đối chiếu thêm ảnh tham chiếu cũ ở `production/qa/evidence/*/` cho giao diện và nội thất) dựa trên [design/art-bible.md](file:///C:/Users/Admin/Desktop/diorama/design/art-bible.md). Vòng này chỉ đánh giá, **không sửa `dao-coi-nuoc.html`**.

---

## 1. Nhận xét từng ảnh chụp

### `01-autumn-0700-morning.jpg` (07:00 · thu · trời quang · toàn cảnh)
Ánh sáng buổi sáng vàng dịu, tia nắng xiên góc phải và tán lá thu cam-vàng tương phản với hàng thông xanh đậm tạo tổng thể rất ấm áp, đúng tinh thần cổ tích; đèn lồng hiên nhà sáng nhẹ giúp căn nhà đọc rất nhanh. Tuy nhiên nửa dưới bầu trời phía sau đáy đảo ngả màu ô-liu/nâu xỉn hơi đục, đáy đảo nâu bóng có vệt phản chiếu sáng kiểu vỏ gáo dừa đánh vecni, mép cắt cỏ–đáy đảo sắc như một lát cắt tròn, và ở khoảng cách này Linh gần như chìm vào bóng cây bên trái trong khi Nimbus trắng sáng lại thu hút mắt trước.

### `02-autumn-1200-noon.jpg` (12:00 · thu · trời quang · toàn cảnh)
Ánh nắng ban trưa lên rõ toàn bộ chi tiết tiểu cảnh: đường đá cuội, luống bí, cối xay gió, mái ngói rêu và mặt ao xanh ngọc. Điểm trừ là bầu trời trưa (đặc biệt vùng dưới đường chân trời) bị xỉn thành màu xanh xám trầm khá nặng thay vì trong trẻo, đáy đảo vẫn lộ độ bóng cao (`roughness: .52`), dải thác bên phải trông như một vạch trắng thẳng cứng đâm xuống không trung, các đảo phụ xa còn khối nón khá đơn giản, và Linh chưa đọc ra ngay ở góc nhìn mặc định.

### `03-autumn-1800-sunset.jpg` (18:00 · thu · trời quang · toàn cảnh)
Sắc chân trời cam hồng chuyển tím và viền mây ấm khá dễ chịu, cùng vài đốm sáng nhỏ bên bờ suối tạo chất chiều muộn. Tuy nhiên, đây là ảnh có lỗi ánh sáng nặng nhất trong bộ ngày bình thường: ở 18:00 mặt trời đã hạ thấp và tắt cường độ nhanh nhưng cửa sổ nhà (`anim.glass`) và đèn đường vẫn chưa bật hết (`night` mới chớm), khiến toàn bộ ngôi nhà, cây cối và mặt sân chìm vào tông nâu đen u ám, mất hẳn sự ấm áp của "giờ vàng".

### `04-autumn-2200-night.jpg` (22:00 · thu · trời quang · toàn cảnh)
Các ô cửa sổ hổ phách, đèn đường pha lê và tinh thể tím/ngọc phát quang dưới đáy đảo tạo cảm giác ấm áp và huyền bí rất tốt cho cảnh đêm. Ngược lại, **mái vòm lục giác màu xanh dương sáng (`Place.ward`)** phủ kín toàn bộ hòn đảo trông giống hệt một khiên năng lượng khoa học viễn tưởng, cắt nát đường nét ngôi nhà và phá vỡ hoàn toàn không khí cổ tích; ngoài ra vùng rìa đảo (cối xay gió, rừng thông, thảm cỏ) bị tối bệt gần như đen hoàn toàn, khó đọc hình khối.

### `05-winter-1000-snow.jpg` (10:00 · đông cưỡng bức 9 giây trước · tuyết · toàn cảnh)
Tuyết rơi mịn và lớp tuyết bám trên ngọn thông, mái ngói cùng ánh đèn ấm từ cửa sổ mang lại cảm giác mùa đông dễ chịu. Điểm hỏng nặng nhất là **vòm lục giác sci-fi (`Place.ward`) vẫn hiện diện giữa ban ngày lúc trời tuyết**; đồng thời đáy đảo không phản ứng với mùa đông (vẫn giữ màu đất nâu cam ấm nguyên vẹn dưới viền mép đảo, nhìn tách rời khỏi phần tuyết phía trên). *(Phần mặt cỏ còn loang lổ xanh-trắng là do quá trình chuyển mùa chưa ổn định — xem mục "Không phải lỗi".)*

### `06-spring-1500-rain.jpg` (15:00 · xuân cưỡng bức 9 giây trước · mưa · toàn cảnh)
Tán lá xanh non điểm hoa hồng đào mùa xuân trông tươi tắn, trẻ trung và tách rõ khỏi thông già; đèn hiên nhà sáng ấm giữa trời mưa là điểm nhấn rất có tình. Nhưng **vòm lục giác xanh dương (`Place.ward`) lại xuất hiện sáng rõ ngay trên nóc tháp**, xung đột trực diện với phong cách truyện cổ tích; đồng thời các vệt mưa (`anim.rain`) hơi thô, dài và đều nhau như gạch chéo phủ khắp khung hình.

### `07-summer-1600-storm.jpg` (16:00 · hạ cưỡng bức 9 giây trước · giông · toàn cảnh)
Lá hè xanh đậm và tia sáng phép thuật tím ở hiên nhà tạo điểm tập trung tốt. Tuy nhiên, **bầu trời giông mùa hạ trông gần như giống hệt trời mưa mùa xuân (`06`)** — cùng một tông xám-lục đều đều thay vì bầu không khí giông bão sâu thẫm và kịch tính hơn; thêm vào đó vòm lục giác `Place.ward` lại bật dải sóng sáng xanh chói ngay phía trên mái nhà, gây rối mắt nghiêm trọng.

### `08-winter-1100-snow-after30s.jpg` (11:00 · đông sau 30 giây · tuyết · toàn cảnh)
Khi tuyết đã phủ đều, toàn bộ mặt đảo, mái nhà, cầu gỗ, mặt ao đóng băng và tán thông nhìn rất gắn kết, ấm mắt nhờ các chấm màu cam từ bí đỏ, gà lửa và đèn hiên. Điểm trừ rõ nhất là **đường cắt ngang cực gắt ở vành đảo `R=13`**: lớp tuyết trắng muốt dừng đột ngột ngay trên viền nâu sẫm và phần đáy gốm nâu cam sáng bóng; ngoài ra hai đảo nhỏ bay xa phía trên vẫn mang lá xanh/vàng mùa thu và thảm cỏ xanh nguyên xi, phá vỡ sự thống nhất của khung cảnh mùa đông.

### `09-autumn-1300-roof-lifted.jpg` (13:00 · thu · trời quang · trên cao mở mái nhà)
Nội thất khi mở mái giàu chi tiết và rất duyên dáng: sàn gỗ ấm, tháp sách tròn với vạc thuốc xanh lục phát sáng, ghế đỏ và bếp lò đọc rõ ràng. Điểm chưa ổn là **hai bức tường đầu hồi lộ cấu trúc bậc thang vuông vức** (nhìn thô kiểu khối voxel khi nhìn từ trên xuống), đỉnh tường cắt ngang sáng trắng quá gắt so với dầm gỗ tối, và `dofQ` làm mờ nhẹ phần ngọn thông/đỉnh ống khói ở rìa trên cũng như tán cây dưới cùng. *(Nền đất và mái hiên còn trắng tuyết cạnh cây lá thu là tàn dư chuyển mùa — xem mục "Không phải lỗi".)*

### `10-autumn-0900-linh-closeup.jpg` (09:00 · thu · trời quang · sau lưng Linh tại cổng vườn)
Đàn gà lửa bên trái lên hình cực kỳ sinh động (đuôi và mào lửa rực rỡ, mắt sáng, dáng mũm mĩm dễ thương); lối đi đá cuội, bướm xanh và luống bí cũng đọc rõ. Tuy nhiên ảnh lộ ba lỗi rõ rệt: (1) ở góc này mái chuồng gà che khuất thân dưới của Linh trong khi áo cardigan `#b6a585` và mũ `#2b2530` lại hòa sắc với hàng rào gỗ và bóng râm; (2) **đốm tinh linh xanh (`Magic.wisp`) bên trái cổng vườn bị `dofQ` làm nhòe thành một khối cầu mờ đục rỗ hạt**; (3) tán cỏ khi còn dính tuyết chuyển sắc xám bạc đều từ gốc đến ngọn trông như cỏ khô bạc, và lá dây bí dựng trên cọc thẳng hơi cứng. *(Mặt đất trắng tuyết là tàn dư chuyển mùa.)*

*(Ghi chú tham chiếu HUD từ `production/qa/evidence/mun-ledger/01..03`: Giao diện nền kính `#14201f` + chữ kem `#f4efe2` + nhấn vàng `#e9b872` đẹp và hài hòa với đảo, nhưng khi `#spot` mở đè lên `#ledger` ở `03-workplace-card.jpg`, hai thẻ cùng nền và viền mảnh dễ lẫn vào nhau.)*

---

## 2. Danh sách lỗi ưu tiên (P1 → P3)

1. **[P1] Vòm kết giới lục giác kiểu sci-fi và kẹt bật sai lúc ban ngày**
   - *Ảnh:* `04-autumn-2200-night.jpg`, `05-winter-1000-snow.jpg`, `06-spring-1500-rain.jpg`, `07-summer-1600-storm.jpg`
   - *Vấn đề:* `Place.ward` dùng lưới lục giác `hexd` màu lam neon `vec3(.3,.6,1.2)` trông giống khiên năng lượng khoa học viễn tưởng; hơn nữa trong `stepPlaces`, điều kiện tắt `if(!bed&&h>5&&h<12)Wd.t=-1` không tắt `Wd.t` sau 12:00 và thành phần `wave` trong shader không nhân với `night`, nên vòm vẫn hiện cả khi chuyển sang chiều mưa/giông (`06`, `07`).
   - *Cách sửa cụ thể:* Trong `stepPlaces`, reset `Wd.t=-1` ngay khi `!bed && AG.cur!=='wards'`, đồng thời tắt hẳn `Wd.d.visible` khi `night<=0.05 && AG.cur!=='wards'`. Trong shader của `Place.ward` (`buildPlaces`), thay lưới `hexd(g)` bằng các vòng cổ ngữ/hoa văn mềm hoặc dải sương ánh sao dịu sắc vàng-oải hương nhạt `vec3(.92,.78,1.0)` chỉ quét nhẹ quanh vành đảo (giảm độ sáng tổng từ `uA*.9` xuống `uA*.28`) và tan biến hẳn sau ~4 giây thay vì giữ lưới vĩnh viễn suốt đêm.
   - *Chi phí:* none (chỉ sửa logic và shader sẵn có).

2. **[P1] Hoàng hôn 18:00 sập tối bệt màu vì nắng tắt trước khi đèn bật**
   - *Ảnh:* `03-autumn-1800-sunset.jpg`
   - *Vấn đề:* Tại `18.0h`, nội suy `STOPS` từ `[17.5]` sang `[18.5]` làm cường độ nắng `si` giảm nhanh xuống ~`1.8` rồi `0.9` ở góc chiếu thấp; trong khi đó biến `night` trong `stepPlaces` và khối `// night-life lights` (`sstep(17.8,19,h)`) mới đạt ~0.07, `U.night` (`sstep(18.6,20,h)`) bằng `0`, còn `fireOn` phải sau `hour>18.7` mới bật (lúc `18.0h` Linh lại ở ngoài trời nên `inhab` bằng `false`) — dẫn tới nhà và cây tối sầm mà cửa sổ, đèn hiên (`pOn = awake&&night>.55`) và đèn đường gần như tắt hoàn toàn.
   - *Cách sửa cụ thể:* Trong `STOPS` (`applyTime`), nâng độ ấm và cường độ nắng lúc `[18.5]` lên `['#3f4f78', '#ef8d58', '#ff7b42', 1.45, .74, '#f0a67c', '#6a5275']` (hiện tại `si=.9`, `env=.62`) và `[19.2]` lên `env=.58`. Trong `stepPlaces` và khối `// night-life lights`, dời ngưỡng bật đèn ấm xuống sớm hơn: dùng `sstep(17.0, 18.4, h)` cho `night` và mở `fireOn` từ `hour>17.4` (hoặc giữ ánh đèn hiên/cửa sổ ấm dịu `inside` tối thiểu `0.35` lúc hoàng hôn).
   - *Chi phí:* none.

3. **[P1] Đáy đảo quá bóng kiểu gốm, mép đảo cắt gắt và thiếu tuyết mùa đông**
   - *Ảnh:* `01-autumn-0700-morning.jpg`, `02-autumn-1200-noon.jpg`, `05-winter-1000-snow.jpg`, `08-winter-1100-snow-after30s.jpg`
   - *Vấn đề:* `buildBowl` tạo vật liệu riêng có `roughness: .52` và bảng màu cam-đỏ no (`#c07a48`, `#a8683c`) làm đáy đảo bóng như gốm tráng men; hàm `buildWeather` không gọi `addSnow` lên vật liệu của `buildBowl`, còn mép `buildTerrain` ép vòng ngoài cùng `lip` thành `#6b4228`, tạo đường cắt nâu-trắng sắc lẹm vào mùa đông.
   - *Cách sửa cụ thể:* Trong `buildBowl`, tăng `roughness` lên `0.9` (`0.88–0.94`), hạ độ bão hòa màu đáy xuống tông đất-đá tự nhiên (`a='#543c2c'`, `b='#7d5b42'`, `d='#694c37'`, `e='#3e2d22'`), lưu tham chiếu `Deep.bowlMat = m` và gọi `addSnow(Deep.bowlMat)` trong `buildWeather`. Đồng thời trong `buildTerrain`, ở `lip` giảm mức pha `#6b4228` hoặc dùng chính màu đất/rêu trộn `C.soil` (`#47301f`) và thêm viền đá/rễ nhỏ quanh mép `dep = 0.02..0.06` để phá đường tròn cứng.
   - *Chi phí:* none (vật liệu đã tồn tại, `addSnow` gắn trước khi `compileAsync` lúc boot).

4. **[P1] Ban đêm vùng rìa đảo tối bệt mất khối, cối xay gió và rừng thông chìm hẳn**
   - *Ảnh:* `04-autumn-2200-night.jpg` (xem thêm `perf-shader-warmup/05-night.jpg`)
   - *Vấn đề:* `STOPS` ban đêm (`0h`, `4.8h`, `20.2h`, `24h`) đặt `zen='#070c1e'..#0a1024`, `hor='#141f3a'..#1b2642`, `si=0.95`, `env=0.62`; qua bộ lọc `aces` và `vignette .62` ở `finalQ`, vùng ngoài tầm đèn đường mất gần hết chi tiết hình khối.
   - *Cách sửa cụ thể:* Nâng các stop đêm trong `STOPS`: `zen='#101830'`, `hor='#223254'`, `sun='#9cb4f0'`, `si=1.25`, `env=0.78`, `c1='#364266'`, `c2='#1f2642'`. Giữ `bounce.intensity` có sàn tối thiểu để thảm cỏ đêm còn thấy sắc lam-lục tối thay vì đen.
   - *Chi phí:* none.

5. **[P2] Các đảo phụ bay xa không đổi sang mùa đông và khối nón hơi đơn điệu**
   - *Ảnh:* `08-winter-1100-snow-after30s.jpg`, `01-autumn-0700-morning.jpg`, `02-autumn-1200-noon.jpg`
   - *Vấn đề:* Trong `buildDepths`, các đảo nhỏ xa dùng màu cứng `#6f8f3a` (cỏ) và bảng tán thu cố định `['#c8542a','#d9822b','#e8b13a','#8a3a22','#6f8a3a']` mà không đổi theo `Sea.apply`, nên ở `08` (giữa mùa đông tuyết trắng) chúng vẫn xanh mướt và cam rực ở phía trên đảo chính.
   - *Cách sửa cụ thể:* Gọi `addSnow` cho vật liệu `hazeMat` của đảo xa (bỏ đoạn kiểm tra dưới mái nhà hoặc nâng cao `uSnow` trực tiếp theo mùa đông), hoặc tách màu đỉnh cỏ/tán đảo xa để `Sea.apply` cập nhật sang trắng tuyết `#dce5ec` / nâu khô mùa đông và xanh cốm mùa xuân. Thêm nhẹ biến dạng nhiễu ở nửa trên nón đá đảo xa để đỡ giống hình nón thẳng.
   - *Chi phí:* small (chỉ sửa shader/màu vertex đã có lúc boot).

6. **[P2] Đọc hình Linh yếu ở tầm trung–xa và thiếu tách nền ở tầm gần**
   - *Ảnh:* `01-autumn-0700-morning.jpg`, `02-autumn-1200-noon.jpg`, `10-autumn-0900-linh-closeup.jpg`
   - *Vấn đề:* `styleLinh` tắt hẳn ánh sáng viền (`parametricRimColorFactor.set('#000000')`), áo cardigan `#b6a585` và mũ `#2b2530` tiệp màu với gỗ hàng rào, thân cây và bóng râm; trong khi đó Nimbus (`#f6f8fb` + emissive `#c8d8ff`) lại quá sáng trắng ở tầm nhìn mặc định.
   - *Cách sửa cụ thể:* Trong `styleLinh`, bật rim light dịu cho VRM `MToon` (`parametricRimColorFactor.set('#e2d2c0')` trên áo/tóc/váy, `parametricRimFresnelPowerFactor = 4.5`, `parametricRimLiftFactor = 0.08`), nâng nhẹ độ sáng áo cardigan từ `#b6a585` lên `#cbb998` (shade `#7d6c58`) và dải ruy-băng mũ sang `#964a35` hoặc `#8b62a8`. Giảm nhẹ độ sáng cừu Nimbus trong `buildCreatures2` từ `#f6f8fb` (`emissiveIntensity: .05`) xuống `#e8ecf2` (`emissiveIntensity: 0`).
   - *Chi phí:* none (uniform/màu MToon và StandardMaterial sẵn có).

7. **[P2] Nửa dưới bầu trời ban ngày xỉn màu và giông mùa hạ không khác mưa mùa xuân**
   - *Ảnh:* `01-autumn-0700-morning.jpg`, `02-autumn-1200-noon.jpg`, `06-spring-1500-rain.jpg`, `07-summer-1600-storm.jpg`
   - *Vấn đề:* Trong `skyMat`, công thức `low = mix(hor, zen, .75) * .62` làm nửa dưới khung hình (bao quanh phần lớn đáy đảo) bị tối đục thành màu ô-liu/xám sẫm; còn trong `applyTime`, khi `ovK` tiến tới `0.9` (mưa) hay `1.0` (giông), cả hai đều lerp mạnh về cùng một màu `#6a7780` khiến trời giông mùa hạ `07` nhìn y hệt trời mưa xuân `06`.
   - *Cách sửa cụ thể:* Trong `skyMat`, nâng `low = mix(hor, zen, .6) * .78` để nền không gian dưới đảo thoáng nhẹ hơn. Trong `applyTime`, tách màu mây u ám cho `stormK`: khi `stormK > 0`, lerp `grey` sang sắc lam-chì thẫm `#465363` và giảm `sky0.h`/`sky0.z` thêm ~15% để trời giông sẫm uy nghi hơn mưa xuân `#6f7f88`.
   - *Chi phí:* none.

8. **[P2] Quả cầu tinh linh `Magic.wisp` bị vỡ đốm bokeh và DOF hơi mạnh ở tầm trung**
   - *Ảnh:* `10-autumn-0900-linh-closeup.jpg`, `09-autumn-1300-roof-lifted.jpg`
   - *Vấn đề:* `dofQ` có bán kính mờ `amt = Hh/1080 * 9` (6 px tại 720p) với 26 mẫu đĩa thưa; khi điểm sáng HDR mạnh như `Magic.wisp` (`Color(3,4,7)`) nằm hơi lệch mặt phẳng nét như trong `10`, nó biến thành một đĩa chấm lấm tấm thô (`#9bb8ff`). Đồng thời trong `09`, ống khói và rìa nội thất hơi mất độ sắc.
   - *Cách sửa cụ thể:* Giảm `prepQ.material.uniforms.amt.value` từ `Hh/1080 * 9` xuống `Hh/1080 * 5.0` (hoặc tăng vùng rõ nét bằng cách hạ hệ số nhân `1.25` trong `prepQ` xuống `0.95`), và hạ cường độ HDR của `Magic.wisp` trong `buildMagic` từ `(3,4,7)` xuống `(1.5, 2.1, 3.6)` kết hợp tăng kích thước chuyển sắc mượt hơn trên `glowT`.
   - *Chi phí:* none.

9. **[P2] Đầu hồi tường khi mở mái nhà bị bậc thang vuông vức và viền cắt quá sáng**
   - *Ảnh:* `09-autumn-1300-roof-lifted.jpg`
   - *Vấn đề:* Trong `buildHouse`, vách đầu hồi (`gable: 1`) ghép từ các cột hộp chữ nhật thẳng đứng cắt theo `roofY`, nên khi mở mái nhà nhìn từ trên xuống sẽ lộ các bậc thang vuông rất thô, khác hẳn đường dốc mượt của mái và dầm.
   - *Cách sửa cụ thể:* Bổ sung thanh xiên dầm mái đỉnh đầu hồi (`LD.add` dọc theo `slope`) hoặc dùng `slopedBox` cho phần tam giác trên cùng mỗi nhịp cột vách đầu hồi (`gable: 1`) để cạnh trên tường thẳng mượt theo độ dốc mái, và tối nhẹ màu lát cắt đỉnh tường nếu lộ phần vữa `#e4d8bf`.
   - *Chi phí:* none (dùng lại hàm `slopedBox` có sẵn và batch `PS`/`DK` hiện tại).

10. **[P3] Dải thác đổ bên mép đảo cứng thẳng và hạt mưa/cỏ tuyết hơi đồng đều**
    - *Ảnh:* `02-autumn-1200-noon.jpg`, `06-spring-1500-rain.jpg`, `10-autumn-0900-linh-closeup.jpg`
    - *Vấn đề:* Phần suối tràn mép phải trong `buildWater` rớt xuống thành một vệt trắng thẳng đơ khá dài; vệt mưa `anim.rain` có độ dài và góc nghiêng đồng nhất tuyệt đối; và `addSnow` phủ đều từ gốc lên ngọn trên `buildGrass` (do normal lá cỏ cố định `(0,1,0)`) làm bụi cỏ nhìn bạc trắng như khô héo khi tuyết tan dở.
    - *Cách sửa cụ thể:* Trong `buildWater`, cho dải nước đổ mép uốn nhẹ ra ngoài theo parabol ngắn hơn và tăng nhiễu bọt tan ở chân (`alpha` fade nhanh hơn ở `foamK > .8`); trong `buildAtmos`, cho `anim.rain` biến thiên nhẹ độ dài từng giọt theo hàm ngẫu nhiên; và trong `buildGrass`, truyền `vH` vào shader mảnh để mức phủ tuyết tập trung ở nửa ngọn cỏ (`smoothstep(.25, .9, vH)`).
    - *Chi phí:* none.

11. **[P3] Hai thẻ giao diện `#spot` và `#ledger` trùng nền khi mở chồng (đối chiếu ảnh tham chiếu cũ)**
    - *Ảnh:* `production/qa/evidence/mun-ledger/03-workplace-card.jpg` (không mở HUD trong bộ AD1)
    - *Vấn đề:* `#spot` và `#ledger` cùng dùng nền `#14201fd9` và viền `--ink-faint`, nên khi `#spot` nổi đè lên góc `#ledger`, ranh giới giữa hai thẻ khó phân biệt nhanh.
    - *Cách sửa cụ thể:* Thêm `box-shadow: 0 8px 24px #0008` và tăng viền của `#spot` lên `border-color: #e9b87255` trong thẻ `<style>`.
    - *Chi phí:* none.

---

## 3. Không phải lỗi

Các hiện tượng dưới đây trong bộ ảnh AD1 xuất phát trực tiếp từ việc chụp liên tiếp nhiều mùa trong một phiên bằng cách ép `__dao.W.seaWant` (như `shots.md` đã ghi chú) và **không cần sửa**:

- **Mặt đất loang xanh–nâu trong `05-winter-1000-snow.jpg`:** Mùa đông vừa được ép 9 giây trước khi chụp; `Sea.step` làm mịn `U.snow.value` tăng dần với tốc độ `0.18` mỗi giây nên tuyết trên mặt đất chưa kịp phủ kín (đến `08-winter-1100-snow-after30s.jpg` sau 30 giây đã phủ trắng đồng nhất).
- **Mặt đất và mái hiên còn trắng tuyết giữa mùa thu ở `09-autumn-1300-roof-lifted.jpg` và `10-autumn-0900-linh-closeup.jpg`:** Do chụp ngay sau phiên mùa đông (`08`), giá trị `U.snow.value` tan chậm hơn với tốc độ `0.05` mỗi giây (`tgt < U.snow.value ? .18 : .05`), trong khi màu tán lá cây (`Sea.apply`) đổi tức thì về mùa thu — tạo cảnh lá thu cam đỏ mọc trên nền đất chưa tan hết tuyết. Đây là hành vi chuyển mùa có chủ đích cho tiến trình tự nhiên 7 ngày/mùa, không phải lỗi khi chơi bình thường.

---

## 4. Ba thay đổi ưu tiên làm trước ở vòng tiếp theo (AD2)

1. **Sửa logic và giao diện thẩm mỹ của vòm kết giới (`Place.ward`)** để tắt hoàn toàn vào ban ngày/mưa/giông và thay lưới lục giác sci-fi bằng vòng cổ ngữ ánh trăng-vàng dịu tan nhẹ chỉ khi đi ngủ hoặc làm phép kết giới.
2. **Cân chỉnh lại chuyển sắc giờ vàng và đêm (`STOPS`, `stepPlaces`, `applyTime`)** bằng cách đẩy ngưỡng bật đèn ấm cửa sổ/đường lên `17.0–18.4h`, giữ nắng `18:30` ấm hơn và nâng sàn sáng đêm (`env`, `zen`, `hor`) để `03` (18h) và `04` (22h) đọc rõ hình khối ngôi nhà và toàn đảo.
3. **Khắc phục chất liệu đáy đảo (`buildBowl`) và ranh giới mùa (`addSnow`, `skyMat`, `stormK`)** bằng cách nâng `roughness` đáy lên `0.9`, giảm độ bóng gốm, gắn `addSnow` cho đáy đảo cùng các đảo phụ xa, làm sáng nửa dưới bầu trời `skyMat` và tách tông trời giông lạnh sâu hơn trời mưa xuân.
