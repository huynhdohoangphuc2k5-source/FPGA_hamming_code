# Hamming (7,4) Code - Verilog

Bộ mã hóa/giải mã Hamming (7,4) viết bằng Verilog, kiểm chứng bằng testbench so sánh với golden model C++.
Mã có thể **phát hiện và sửa 1 lỗi bit** trong 7 bit nhận được.

## Cấu trúc thư mục

```
hamming-code/
├── rtl/
│   ├── hamming_encode.v    # Mã hóa: 4 bit data -> 7 bit codeword
│   └── hamming_decode.v    # Giải mã: 7 bit -> 4 bit data + syndrome + cờ lỗi
├── tb/
│   └── tb_hamming.v        # Testbench đọc vectors.txt và tự kiểm tra
├── model/
│   ├── hamming_golden.h    # Golden model C++ (encode/decode)
│   └── gen_vectors.cpp     # Sinh file vectors.txt
├── sim/
│   └── vectors.txt         # 128 vector kiểm tra (chạy mô phỏng tại đây)
├── .gitignore
└── README.md
```

## Bố trí bit

Codeword 7 bit, vị trí tính từ 1 (bit 0 của vector Verilog = vị trí 1):

| Vị trí | 1  | 2  | 3  | 4  | 5  | 6  | 7  |
|--------|----|----|----|----|----|----|----|
| Bit    | p1 | p2 | d1 | p3 | d2 | d3 | d4 |

Bit parity:
- `p1 = d1 ^ d2 ^ d4`
- `p2 = d1 ^ d3 ^ d4`
- `p3 = d2 ^ d3 ^ d4`

Giải mã: tính `s1, s2, s3` (parity các nhóm vị trí), `syndrome = {s3, s2, s1}`.
Syndrome bằng 0 là không lỗi; khác 0 thì giá trị đó chính là **vị trí bit bị lỗi** (1-7), bit này được lật lại rồi lấy `data = {c7, c6, c5, c3}`.

## Giao diện module

| Module | Cổng vào | Cổng ra |
|--------|----------|---------|
| `hamming_encode` | `data[3:0]` | `codeword[6:0]` |
| `hamming_decode` | `codeword[6:0]` | `data[3:0]`, `syndrome_out[2:0]`, `error_detected` |

## Cách chạy

Yêu cầu: `g++` và [Icarus Verilog](https://steveicarus.github.io/iverilog/).

```bash
cd sim

# 1. Sinh vectors.txt từ golden model
g++ ../model/gen_vectors.cpp -o gen
./gen

# 2. Biên dịch và chạy mô phỏng
iverilog -o sim_out ../tb/tb_hamming.v ../rtl/hamming_encode.v ../rtl/hamming_decode.v
vvp sim_out
```

> Chạy từ thư mục `sim/` vì testbench mở `vectors.txt` theo đường dẫn tương đối.

## Kiểm chứng

`vectors.txt` gồm 16 giá trị data x 8 trường hợp (không lỗi + lật từng bit 1-7) = **128 vector**.
Mỗi dòng (hex): `data code_clean err_mask code_rx syndrome data_out`.

Testbench kiểm tra:
- Encoder RTL trùng codeword của golden model.
- Decoder RTL trùng `data_out`, `syndrome` của golden model, và data sau sửa lỗi bằng data gốc.
- `error_detected` bằng 1 khi và chỉ khi syndrome khác 0.

Kết quả mong đợi:

```
 Tong so vector : 128
 Encoder  PASS/FAIL: 128 / 0
 Decoder  PASS/FAIL: 128 / 0
 KET QUA: PASS
```

## Giới hạn

- Chỉ sửa được **1 lỗi bit**. Khi có 2 lỗi trở lên, decoder có thể sửa sai mà không báo hiệu.
- Chưa có bit parity tổng, nên không phân biệt được lỗi đơn với lỗi kép (SECDED).
