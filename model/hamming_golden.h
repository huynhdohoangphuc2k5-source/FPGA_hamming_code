#pragma once
// Golden model Hamming(7,4)
// Bo tri bit (vi tri 1..7 <-> bit 0..6): p1 p2 d1 p3 d2 d3 d4

inline int hamming_encode(int d1, int d2, int d3, int d4) {
    int p1 = d1 ^ d2 ^ d4;
    int p2 = d1 ^ d3 ^ d4;
    int p3 = d2 ^ d3 ^ d4;

    int codeword = (p1 << 0) | (p2 << 1) | (d1 << 2) | (p3 << 3)
                 | (d2 << 4) | (d3 << 5) | (d4 << 6);
    return codeword;
}

// r: 7 bit nhan duoc; syndrome_out: vi tri bit loi (0 = khong loi)
// Tra ve 4 bit data sau khi sua loi
inline int hamming_decode(int r, int &syndrome_out) {
    int c[8];
    for (int i = 1; i <= 7; i++) {
        c[i] = (r >> (i - 1)) & 1;
    }

    int s1 = c[1] ^ c[3] ^ c[5] ^ c[7];
    int s2 = c[2] ^ c[3] ^ c[6] ^ c[7];
    int s3 = c[4] ^ c[5] ^ c[6] ^ c[7];

    int s = (s3 * 4) + (s2 * 2) + (s1 * 1);
    syndrome_out = s;

    if (s != 0) {
        c[s] ^= 1;
    }

    int d1 = c[3];
    int d2 = c[5];
    int d3 = c[6];
    int d4 = c[7];

    int data_out = (d1 << 0) | (d2 << 1) | (d3 << 2) | (d4 << 3);
    return data_out;
}
