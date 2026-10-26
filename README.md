# WAF với Juice Shop

Đỗ Đức Đạt - 26/10/2026

Em dùng Docker Compose để chạy Juice Shop và đặt WAF phía trước.
Image `owasp/modsecurity-crs:nginx` có sẵn Nginx, ModSecurity và bộ luật CRS.
WAF chuyển request được phép đến `http://web:3000` theo cấu hình `BACKEND`.
`BLOCKING_PARANOIA` giữ ở mức 1 như đề. Có thể đặt từ 1 đến 4;
mức càng cao thì càng dễ chặn nhầm request hợp lệ.

## Cách chạy

Mở Docker rồi chạy:

```bash
docker compose up -d
```

Mở [localhost:3000](http://localhost:3000) để vào thẳng Juice Shop,
còn [localhost:8080](http://localhost:8080) là đi qua WAF.
Em để cả hai cổng để thử cùng một request và so sánh kết quả.

Khi web đã mở được, chạy script thử bằng curl và xem log:

```bash
bash test.sh
docker compose logs waf
```

Trong `test.sh` có request tìm sản phẩm, SQL Injection vào phần đăng nhập
và chuỗi `<script>alert(1)</script>` trong tham số tìm kiếm. SQL Injection dùng
email `' OR 1=1-- ` để thử đăng nhập với mật khẩu sai.

## Kết quả

| Request | Vào thẳng cổng 3000 | Qua WAF, On | Qua WAF, DetectionOnly |
| --- | --- | --- | --- |
| Tìm sản phẩm | 200 | 200 | 200 |
| SQL Injection | 200 | 403 | 200 |
| Chuỗi XSS | 200 | 403 | 200 |

Khi thử SQL Injection qua cổng 3000, em nhận được token đăng nhập.
Gửi cùng request qua cổng 8080 thì bị trả 403. Log có rule `942100` cho SQL
Injection và `941100`, `941110` cho XSS ở cả hai chế độ.

Để thử DetectionOnly, đổi chế độ bằng lệnh:

```bash
MODSEC_RULE_ENGINE=DetectionOnly docker compose up -d --force-recreate waf
```

Đợi WAF khởi động lại rồi chạy lại `bash test.sh` và `docker compose logs waf`.
Ở chế độ này, hai request tấn công đều trả 200 nhưng log vẫn có cảnh báo.
Khi bật On thì hai request đó bị chặn, còn tìm sản phẩm bình thường vẫn trả 200.

Thử xong bật lại On:

```bash
MODSEC_RULE_ENGINE=On docker compose up -d --force-recreate waf
```

Ở phép thử XSS em mới kiểm tra WAF có chặn chuỗi gửi lên hay không,
chưa kiểm tra JavaScript có thực thi trong trình duyệt.

Dừng các container bằng `docker compose down`.

Tham khảo: [CRS Docker](https://github.com/coreruleset/modsecurity-crs-docker),
[Juice Shop](https://github.com/juice-shop/juice-shop).
