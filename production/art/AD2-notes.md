# AD2 — Ghi chú chỉnh sửa mỹ thuật (4 lỗi P1 từ AD1)

> Thực hiện theo `production/briefs/AD2-light-bowl-ward.md` trên `dao-coi-nuoc.html` và cập nhật `design/art-bible.md`. Chỉ sửa 5 vùng được phép (màu sắc, ánh sáng, vật liệu, shader); không đụng logic lịch trình hay `fireOn`.

---

## 1. Hoàng hôn và ban đêm trong `STOPS` (`dao-coi-nuoc.html`)

| Stop (giờ) | Trường | Giá trị cũ | Giá trị mới | Lý do |
|---|---|---|---|---|
| `0` & `24` | `zen`, `hor`, `sun`, `si`, `env`, `c1`, `c2` | `'#070c1e'`, `'#141f3a'`, `'#8fa6e6'`, `0.95`, `0.62`, `'#2a3350'`, `'#171d33'` | `'#0f162c'`, `'#1e2c4c'`, `'#9cb4f0'`, `1.25`, `0.78`, `'#344062'`, `'#1d243e'` | Đêm bớt bệt đen qua bộ lọc `aces` + vignette, giữ được khối hàng thông, cối xay gió và mặt cỏ dưới ánh trăng dịu. |
| `4.8` & `20.2` | `zen`, `hor`, `sun`, `si`, `env`, `c1`, `c2` | `'#0a1024'`, `'#1b2642'`, `'#8fa6e6'`, `0.95`, `0.62`, `'#2a3350'`, `'#171d33'` | `'#111933'`, `'#233356'`, `'#9cb4f0'`, `1.25`, `0.78`, `'#384468'`, `'#202744'` | Đồng bộ nâng sáng đầu/cuối đêm trong khi vẫn giữ chuyển độ nhẹ vào lúc nửa đêm (`0`/`24`). |
| `17.5` | `zen`, `hor`, `sun`, `si`, `env`, `c1`, `c2` | `'#57788f'`, `'#efc08c'`, `'#ffb066'`, `2.7`, `0.82`, `'#ffdcb4'`, `'#a48a90'` | `'#5a7c96'`, `'#f2c28e'`, `'#ffb46a'`, `2.8`, `0.86`, `'#ffe0ba'`, `'#a68c92'` | Mở đầu giờ vàng ấm và sáng hơn nhẹ trước khi nội suy sang `18.5h`. |
| `18.5` | `zen`, `hor`, `sun`, `si`, `env`, `c1`, `c2` | `'#3f4f78'`, `'#ef8d58'`, `'#ff6f38'`, `0.9`, `0.62`, `'#e89c7c'`, `'#6a5275'` | `'#4b5582'`, `'#f5a066'`, `'#ff8045'`, `1.5`, `0.76`, `'#f0a67c'`, `'#6e567a'` | Sửa lỗi sập tối tại 18:00: giữ nắng xiên chiều muộn và ánh sáng môi trường đủ ấm để không bệt đen mặt khuất. |
| `19.2` | `zen`, `hor`, `sun`, `si`, `env`, `c1`, `c2` | `'#1c2448'`, `'#7a5468'`, `'#7f96d6'`, `0.0`, `0.42`, `'#6b5270'`, `'#2f2c4c'` | `'#222c54'`, `'#866078'`, `'#8aa0de'`, `0.0`, `0.64`, `'#765e7e'`, `'#363254'` | Tránh hố tối `env=0.42` lúc chạng vạng sau khi mặt trời lặn (`19:12`). |

---

## 2. Ngưỡng bật đèn ấm trong `stepPlaces` & `// night-life lights`

| Vị trí | Biến / biểu thức | Giá trị cũ | Giá trị mới | Lý do |
|---|---|---|---|---|
| `stepPlaces` | `night` | `clamp(1-sstep(5.2,6.6,h)+sstep(17.8,19,h))` | `clamp(1-sstep(5.2,6.6,h)+sstep(17.0,18.4,h))` | Đèn cột pha lê (`Place.lampM`, `Place.lampGlow`) bật sớm, đạt ~80% lúc 18:00 thay vì chỉ ~7%. |
| `// night-life lights` | `night` | `clamp(1-sstep(5.2,6.6,hour)+sstep(17.8,19,hour))` | `clamp(1-sstep(5.2,6.6,hour)+sstep(17.0,18.4,hour))` | Đồng bộ ngưỡng hoàng hôn với `stepPlaces`. |
| `// night-life lights` | `anim.glass.emissiveIntensity` & `inLight.intensity` target | Dùng trực tiếp `inside` (bằng `0` lúc 18:00 khi `fireOn` và `inhab` đều `false`) | Thêm `duskWin = awake ? .65*sstep(.15,.55,night) : 0`, dùng `win = Math.max(inside, duskWin)` | Giữ cửa sổ nhà và ánh sáng hắt từ trong nhà bật ấm ngay lúc hoàng hôn (~1.25 emissive lúc 18:00) mà không đụng tới `fireOn` hay `inhab`; vẫn tắt khi Linh đi ngủ (`!awake`). |
| `// night-life lights` | `pOn` (đèn hiên `anim.lamp` & `porch`) | `awake&&night>.55?1:0` | `awake?sstep(.3,.6,night):0` | Đèn hiên bật êm hơn từ cuối chiều, đạt 100% trước 18:00. |

---

## 3. Chất liệu đáy đảo (`buildBowl`, `buildWeather`) và mép viền (`buildTerrain`)

| Hàm | Thuộc tính | Giá trị cũ | Giá trị mới | Lý do |
|---|---|---|---|---|
| `buildBowl` | Bảng màu `a, b, d, e` | `'#6b4228'`, `'#c07a48'`, `'#a8683c'`, `'#5a3a26'` | `'#4a3a2e'`, `'#725845'`, `'#5e4d41'`, `'#382b22'` | Bỏ sắc cam đất nung quá no; chuyển sang tông đất-đá tự nhiên, hòa với rễ cây và tinh thể. |
| `buildBowl` | `roughness` | `0.52` | `0.92` | Đạt chuẩn `>= 0.88` trong art bible, xóa hoàn toàn độ bóng kiểu gốm tráng men. |
| `buildBowl` | Tham chiếu vật liệu | Không lưu | `Deep.bowlMat = m.material` | Lưu tham chiếu để `buildWeather` gắn `addSnow` trước lúc `compileAsync`. |
| `buildWeather` | Danh sách `addSnow` | `[woodMat,stoneMat,plainMat,plasterMat,anim.barkMat]` | `[woodMat,stoneMat,plainMat,plasterMat,anim.barkMat,Deep.bowlMat]` | Biên dịch biến thể tuyết cho đáy đảo ngay lúc khởi động. |
| `buildTerrain` | Màu vòng ngoài `lip` | `if(dark)c.set('#6b4228')` | `const lipC=col('#4a3a2e'); ... if(dark)c.lerp(lipC,.65)` | Xóa vệt cắt nâu cam gắt quanh `R=13`, chuyển tiếp mượt từ lớp đất mặt đảo sang màu đỉnh đáy đảo `#4a3a2e`. |

---

## 4. Shader `Place.ward` trong `buildPlaces`

| Thành phần | Giá trị cũ | Giá trị mới | Lý do |
|---|---|---|---|
| Họa tiết | Lưới lục giác `hexd(g)` trên toàn vòm cầu | Dải cổ ngữ thủ công mảnh (`rune` + hai đường viền `ring` quanh `vUv.y ~ 0.255`) kèm lớp sương Fresnel (`mist * f`) ôm mép đảo (`vUv.y ~ 0.16..0.38`) | Bỏ cảm giác khiên năng lượng sci-fi; giữ lại vòng phép thuật cổ tích ôm sát mép đảo, không che cắt mái nhà. |
| Bảng màu | `vec3(.3, .6, 1.2)` (lam neon) | `lav = vec3(.88, .76, 1.)`, `gold = vec3(1., .86, .58)` | Chuyển sang vàng mật ong pha tím oải hương ánh trăng đúng art bible. |
| Độ sáng & lọc ban ngày | `uA * .9`, `wave` không nhân `uA` | Cổ ngữ/viền `* uA * .34`, sương `* uA * .22`, toàn bộ nhân `vis = smoothstep(.02, .2, uA)` (kể cả `wave`) | Giảm chói gắt, và ngăn dải `wave` hiện lờ mờ lúc ban ngày (`uA == 0`) trong khi chờ AD2b sửa logic `Wd.t` / `Wd.d.visible`. |
