#!/usr/bin/env bash
set -e

for port in 3000 8080; do
  url="http://localhost:$port"
  echo "Cổng $port"

  curl -sS --noproxy '*' --max-time 15 -o /dev/null \
    -w 'Tìm sản phẩm: %{http_code}\n' \
    "$url/rest/products/search?q=apple"

  curl -sS --noproxy '*' --max-time 15 -o /dev/null \
    -w 'SQL Injection: %{http_code}\n' \
    -H 'Content-Type: application/json' \
    --data "{\"email\":\"' OR 1=1-- \",\"password\":\"sai-mat-khau\"}" \
    "$url/rest/user/login"

  curl -sS --noproxy '*' --max-time 15 -o /dev/null \
    -w 'Payload XSS: %{http_code}\n' \
    -G --data-urlencode 'q=<script>alert(1)</script>' \
    "$url/rest/products/search"

  echo
done
